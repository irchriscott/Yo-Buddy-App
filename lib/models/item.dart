import 'category.dart';
import 'subcategory.dart';
import 'user.dart';
import 'comment.dart';
import '../providers/app.dart';

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
    final String status;
    final bool isAvailable;
    final DateTime createdAt;
    final String url;
    final Like likes;
    final int comments;
    final int borrow;
    final List<ItemImage> images;
    final List<User> likers;
    final List<Comment> commenters;

    Item({this.id, this.category, 
          this.subcategory, this.user, 
          this.name, this.price, this.currency, 
          this.per, this.description, this.status, 
          this.isAvailable, this.createdAt, this.url, 
          this.likes, this.comments, this.borrow, this.likers, 
          this.commenters, this.images
        });

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
            url: json['url'],
            likes: Like.fromJson(json['likes']),
            comments: json['comments'],
            borrow: json['borrow'],
            likers: User().getUsersList(json['likers']),
            commenters: Comment().getCommentsList(json['commenters']),
            images: ItemImage().getItemImages(json['images'])
        );
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