import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'category.dart';
import 'subcategory.dart';
import 'user.dart';
import 'response.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/net.dart' as net;

final JsonDecoder _decoder = new JsonDecoder();

class Item{

    final int id;
    final Category category;
    final Subcategory subcategory;
    final User user;
    final String name;
    final double price;
    final String currency;
    final String per;
    final String description;
    final int count;
    final String status;
    final bool isAvailable;
    final DateTime createdAt;
    final String uuid;
    final double saleValue;
    final String url;
    final Like likes;
    final int comments;
    final int borrow;
    final List<ItemImage> images;
    final List<User> likers;
    final List<dynamic> favourites;

    final List<File> imageFiles;

    Item({this.id, this.category, 
          this.subcategory, this.user, 
          this.name, this.price, this.currency, 
          this.per, this.description, this.status, 
          this.isAvailable, this.createdAt, this.url, 
          this.likes, this.comments, this.borrow, this.likers, this.saleValue,
          this.images, this.favourites, this.uuid, this.count, this.imageFiles
        });

    List<UploadFileInfo> getImagesInfo(){
        List<UploadFileInfo> images = [];
        this.imageFiles.forEach((image){
            UploadFileInfo imageInfo = UploadFileInfo(image, "my_item_image.png");
            imageInfo.contentType = ContentType("image", "png");
            images.add(imageInfo);
        });
        return images;
    }

    factory Item.fromJson(Map<String, dynamic> json){
        return new Item(
            id: json['id'],
            category: Category.fromJson(json['category']),
            subcategory: Subcategory.fromJson(json['subcategory']),
            user: User.fromJson(json['user']),
            name: json['name'],
            price: json['price'],
            currency: json['currency'],
            per: json['per'],
            description: json['description'],
            count: json['count'],
            status: json['status'],
            isAvailable: json['is_available'],
            createdAt: DateTime.parse(json['created_at']),
            uuid: json['uuid'],
            saleValue: json['sale_value'],
            url: json['url'],
            likes: Like.fromJson(json['likes']),
            comments: json['comments'],
            borrow: json['borrow'],
            likers: User().getUsersList(json['likers']),
            images: ItemImage().getItemImages(json['images']),
            favourites: json['favourites']
        );
    }

    Future<ResponseService> saveOrUpdateItem(String sessionID, String sessionToken) async{
        //:name, :category_id, :subcategory_id, :price, :currency, :per, :description, :count
        if( this.name != "" &&
            this.category != null &&
            this.subcategory != null &&
            this.price > 0 &&
            this.price != null &&
            this.currency != "" &&
            this.per != "" &&
            this.description != "" &&
            this.count > 0
        ){
            var uri = this.id != null && this.id > 0 ? Uri.encodeFull(AppProvider().baseURL + "/item/${this.id}/update.json?token=$sessionToken") : Uri.encodeFull(AppProvider().baseURL + "/item/create.json?token=$sessionToken");
            Dio request = Dio();

            if(this.imageFiles.length > 0 || this.id != null) {

                FormData item = new FormData.from(
                    {
                        "item[user_id]": sessionID.toString(),
                        "item[name]": this.name,
                        "item[category_id]": this.category.id.toString(),
                        "item[subcategory_id]": this.subcategory.id.toString(),
                        "item[price]": this.price,
                        "item[currency]": this.currency,
                        "item[per]": this.per,
                        "item[description]": this.description,
                        "item[count]": this.count,
                        "item[image][]": this.getImagesInfo(),
                        "item[is_available]": this.isAvailable,
                        "item[sale_value]": this.saleValue
                    }
                );

                if (this.id != null && this.id > 0) item.add("_method", "patch");

                try {
                    var response = await request.post(uri, data: item);
                    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
                        return ResponseService.fromJson(_decoder.convert('{"type":"error", "text":"An error has occured, Sorry!"}'));
                    }
                    return ResponseService.fromJson(response.data);
                } on DioError catch (_) {
                    return ResponseService.fromJson(_decoder.convert(
                        '{"type":"error", "text":"An error has occured, Sorry!"}'));
                }
            }
            return ResponseService(type: "error", text: "Fill all Fiels With Right Data !!!");
        }
        return ResponseService(type: "error", text: "Fill all Fiels With Right Data !!!");
    }
    
    Future<ResponseService> favouriteItem(String sessionToken, String userID){
        return net.NetworkUtil().post(
                Uri.encodeFull(AppProvider().baseURL + "/item/${this.id}/favourite.json?token=$sessionToken"),
                body: {"favourite[item_id]": this.id.toString()}
            ).then((response){
                return ResponseService.fromJson(response);
        });
    }
}

class Like{

    final int count;
    final List<dynamic> likers;

    Like({this.count, this.likers});

    factory Like.fromJson(Map<String, dynamic> json){
        return new Like(
            count: json['count'],
            likers: json['likers']
        );
    }

    int get likersCount => this.likers.length;
}

class ItemImage{

    final int id;
    final ImagePath image;

    ItemImage({this.id, this.image});

    factory ItemImage.fromJson(Map<String, dynamic> json){
        return new ItemImage(
            id: json['id'],
            image: ImagePath.fromJson(json['image'])
        );
    }

    String get imageUrl => AppProvider().baseURL + this.image.path;

    List<ItemImage> getItemImages(dynamic json){
        if(json != null){
            List data = json.toList();
            List<ItemImage> images = List<ItemImage>();
            data.forEach((image){
                images.add(ItemImage.fromJson(image));
            });
            return images;
        }
        return [];
    }

    Future<ResponseService> deleteImage(String itemID, String sessionToken){
        return net.NetworkUtil().get(
            Uri.encodeFull(AppProvider().baseURL + "/item/$itemID/image/${this.id}/delete.json?token=$sessionToken")
        ).then((response){
            return ResponseService.fromJson(response);
        });
    } 
}

class ImagePath{

    final String path;

    ImagePath({this.path});

    factory ImagePath.fromJson(Map<String, dynamic> json){
        return new ImagePath(
            path: json['url']
        );
    }
}