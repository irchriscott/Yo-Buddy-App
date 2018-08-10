import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'category.dart';
import 'subcategory.dart';
import 'user.dart';
import 'comment.dart';
import 'response.dart';
import '../providers/app.dart';
import '../providers/net.dart' as net;

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
    final String url;
    final Like likes;
    final int comments;
    final int borrow;
    final List<ItemImage> images;
    final List<User> likers;
    final List<dynamic> favourites;

    final List<File> imageFiles;

    final JsonDecoder _decoder = new JsonDecoder();

    Item({this.id, this.category, 
          this.subcategory, this.user, 
          this.name, this.price, this.currency, 
          this.per, this.description, this.status, 
          this.isAvailable, this.createdAt, this.url, 
          this.likes, this.comments, this.borrow, this.likers,
          this.images, this.favourites, this.uuid, this.count, this.imageFiles
        });

    List<UploadFileInfo> getImagesInfo(){
        List<UploadFileInfo> images = List<UploadFileInfo>();
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
            status: json['status'],
            isAvailable: json['is_available'],
            createdAt: DateTime.parse(json['created_at']),
            uuid: json['uuid'],
            url: json['url'],
            likes: Like.fromJson(json['likes']),
            comments: json['comments'],
            borrow: json['borrow'],
            likers: User().getUsersList(json['likers']),
            images: ItemImage().getItemImages(json['images']),
            favourites: json['favourites']
        );
    }

    Future<ResponseService> saveItem(String sessionID, String sessionToken) async{
        //:name, :category_id, :subcategory_id, :price, :currency, :per, :description, :count
        if( this.name != "" &&
            this.category != null &&
            this.subcategory != null &&
            this.price > 0 &&
            this.price != null &&
            this.currency != "" &&
            this.per != "" &&
            this.description != "" &&
            this.count > 0 &&
            this.imageFiles.length > 0
        ){
            var uri = Uri.encodeFull(AppProvider().baseURL + "/item/create.json?token=$sessionToken");
            Dio request = Dio();

            FormData item = new FormData.from(
                {
                    "item[user_id]": sessionID.toString(),
                    "item[name]": this.name,
                    "item[category_id]": this.category.id.toString(),
                    "item[subcategory_id]": this.subcategory.id.toString(),
                    "item[price]": this.price.toString(),
                    "item[currency]": this.currency,
                    "item[per]": this.per,
                    "item[description]": this.description,
                    "item[count]": this.count.toString(),
                    "item[image][]" : this.getImagesInfo()
                }
            );
            try{
                var response = await request.post(uri, data: item);
                if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
                    return ResponseService.fromJson(_decoder.convert('{"type":"error", "text":"An error has occured, Sorry!"}'));
                }
                return ResponseService.fromJson(_decoder.convert(response.data.toString()));
            } on DioErrorType catch(e){
                return ResponseService.fromJson(_decoder.convert('{"type":"error", "text":"An error has occured, Sorry!"}'));
            }

        }
        return ResponseService(type: "error", text: "Fill all Fiels With Right Data !!!");
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