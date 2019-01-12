import 'dart:async';
import 'user.dart';
import 'item.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/response.dart';
import 'package:buddyapp/providers/net.dart' as net;
import 'package:buddyapp/providers/app.dart';

class Borrow{

    final int id;
    final int code;
    final Item item;
    final User user;
    final String fromDate;
    final String toDate;
    final double price;
    final String currency;
    final String per;
    final int numbers;
    final String conditions;
    final String reasons;
    final int count;
    final String status;
    final bool isDeleted;
    final User lastUpdateBy;
    final double total;
    final double penalties;
    final String deadline;
    final String uuid;
    final int adminId;
    final int extension;
    final String expiration;
    final String url;
    final String messagesURL;
    final bool wasRendered;
    final bool wasReceived;
    final bool wasReturned;
    final String createdAt;
    final String updatedAt;

    Borrow({
        this.id, this.item, this.user, this.fromDate,
        this.toDate, this.price, this.currency, this.adminId, this.extension,
        this.per, this.numbers, this.conditions, this.messagesURL,
        this.count, this.status, this.isDeleted, this.url, this.reasons,
        this.lastUpdateBy, this.uuid, this.createdAt, this.updatedAt,
        this.code, this.deadline, this.penalties, this.total, this.expiration,
        this.wasReceived, this.wasRendered, this.wasReturned
    });

    factory Borrow.fromJson(Map<String, dynamic> json){
        return new Borrow(
            id: json['id'],
            item: Item.fromJson(json['item']),
            user: User.fromJson(json['user']),
            fromDate: json['from_date'],
            toDate: json['to_date'],
            price: json['price'],
            currency: json['currency'],
            per: json['per'],
            numbers: json['numbers'],
            conditions: json['conditions'],
            reasons: json['reasons'],
            count: json['count'],
            status: json['status'],
            isDeleted: json['is_deleted'],
            lastUpdateBy: User.fromJson(json['last_updated_by']),
            uuid: json['uuid'],
            adminId: json['admin_id'],
            extension: json['extension'],
            createdAt: json['created_at'],
            updatedAt: json['updated_at'],
            code: json['code'],
            total: json['total'],
            penalties: json['penalties'].toDouble(),
            deadline: json['deadline'],
            expiration: json['expiration'],
            url: json['url'],
            messagesURL: json['messages_url'],
            wasReceived: json['was_received'],
            wasRendered: json['was_rendered'],
            wasReturned: json['was_returned']
        );
    }

    List<String> get statuses => ["pending", "accepted", "rejected", "rendered", "returned", "succeeded", "failed"];

    Color borrowColor(){
        switch(this.expiration){
            case "orange":
                return Colors.orange;
            case "lightgreen":
                return Color(0xFF90EE90);
            case "red":
                return Colors.red;
            case "green":
                return Colors.green;
        }
        return Colors.grey;
    }

    Future<ResponseService> saveBorrow(String sessionToken) async{
        if(this.price > 0 && this.numbers > 0 && this.count > 0 && this.fromDate != "") {
            return net.NetworkUtil().post(
                Uri.encodeFull(AppProvider().baseURL + "/item/enc-dt-${this.item.uuid}-${this.item.id.toString()}/borrow/create.json?token=$sessionToken"),
                body: {
                    "item_borrow[item_id]": this.item.id.toString(),
                    "item_borrow[price]": this.price.toString(),
                    "item_borrow[currency]": this.currency,
                    "item_borrow[per]": this.per,
                    "item_borrow[numbers]": this.numbers.toString(),
                    "item_borrow[conditions]": this.conditions,
                    "item_borrow[count]": this.count.toString(),
                    "item_borrow[from_date]": this.fromDate,
                    "item_borrow[reasons]": this.reasons
                }
            ).then((response) {
                return ResponseService.fromJson(response);
            });
        }
        return ResponseService(text: "Fill all Fiels With Right Data !!!", type: "error");
    }
}

class BorrowMessage{

    final int id;
    final User sender;
    final User receiver;
    final String type;
    final String message;
    final String status;
    final bool isDeleted;
    final bool hasImages;
    final String createdAt;
    final List<BorrowMessageImage> images;

    BorrowMessage({
        this.id, this.sender, this.receiver, this.type, this.message,
        this.status, this.isDeleted, this.hasImages, this.createdAt, this.images
    });

    String get messageText => (this.type == "admin") ? this.message.replaceRange(0, 1, this.message[0].toUpperCase()) : this.message;
    String get adminMessage => (this.message == "data") ? "Borrow Item Updated" : "Borrow Status Updated To ${this.messageText}";

    factory BorrowMessage.fromJson(Map<String, dynamic> json){
        return BorrowMessage(
            id: json['id'],
            sender: User.fromJson(json['sender']),
            receiver: User.fromJson(json['receiver']),
            type: json['type'],
            message: json['message'],
            status: json['status'],
            isDeleted: json['is_deleted'],
            hasImages: json['has_images'],
            createdAt: json['created_at'],
            images: BorrowMessageImage().getMessageImages(json['images'])
        );
    }

    Future<ResponseService> sendTextMessage(String sessionToken, int item, int borrow) async{
        return net.NetworkUtil().post(Uri.encodeFull(AppProvider().baseURL + "/items/${item.toString()}/item_borrow_user/${borrow.toString()}/borrow_messages/send.json?token=$sessionToken"), body: {
            "message[message]": this.message,
            "message[receiver_id]": this.receiver.id.toString(),
            "message[status]": this.status,
            "message[is_deleted]": this.isDeleted.toString()
        }).then((response){
            return ResponseService.fromJson(response);
        });
    }
}

class BorrowMessageImage{

    final int id;
    final ImagePath image;

    BorrowMessageImage({ this.id, this.image });

    factory BorrowMessageImage.fromJson(Map<String, dynamic> json){
        return BorrowMessageImage(
            id: json['id'],
            image: ImagePath.fromJson(json['image'])
        );
    }

    List<BorrowMessageImage> getMessageImages(dynamic json){
        if(json != null){
            List data = json.toList();
            List<BorrowMessageImage> images = List<BorrowMessageImage>();
            data.forEach((image){
                images.add(BorrowMessageImage.fromJson(image));
            });
            return images;
        }
        return [];
    }
}