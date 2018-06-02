import '../providers/app.dart';

class User{
    int id;
    String name;
    String username;
    String email;
    String country;
    String town;
    String image;
    String gender;
    int followers;
    int following;
    String url;
    int items;
    int request;
    int borrow;
    int favourites;
    List<dynamic> followersList;
    List<dynamic> followingList;

    User({this.id, this.name, this.username, this.email, this.country, this.town, this.image, this.gender, this.followers, this.following, this.url, this.items, this.request, this.borrow, this.followersList, this.followingList, this.favourites});

    factory User.fromJson(Map<String, dynamic> json){
        return new User(
            id: json['id'],
            name: json['name'],
            username: json['username'],
            email: json['email'],
            country: json['country'],
            town: json['town'],
            image: json['image'],
            gender: json['gender'],
            followers: json['followers'],
            following: json['following'],
            url: json['url'],
            items: json['items'],
            request: json['requests'],
            borrow: json['borrow'],
            followersList: json['followers_list'],
            followingList: json['following_list'],
            favourites: json['favourites']
        );
    }

    User.map(dynamic json){
        this.id = json['id'];
        this.name = json['name'];
        this.username = json['username'];
        this.email = json['email'];
        this.country = json['country'];
        this.town = json['town'];
        this.image = json['image'];
        this.gender = json['gender'];
        this.followers = json['followers'];
        this.following = json['following'];
        this.url = json['url'];
        this.items = json['items'];
        this.request = json['requests'];
        this.borrow = json['borrow'];
        this.favourites = json['favourites'];
    }

    Map<String, dynamic> toMap() {
        Map<String, dynamic> map = Map<String, dynamic>();
        map['id'] = id;
        map['name'] = name;
        map['username'] = username;
        map['email'] = email;
        map['country'] = country;
        map['town'] = town;
        map['image'] = image;
        map['gender'] = gender;
        map['followers'] = followers;
        map['following'] = following;
        map['url'] = url;
        map['items'] = items;
        map['requests'] = request;
        map['borrow'] = borrow;
        map['favourites'] = favourites;
        return map;
    }

    User.fromMap(Map map){
        id = map['id'];
        name = map['name'];
        username = map['username'];
        email = map['email'];
        country = map['country'];
        town = map['town'];
        image = map['image'];
        gender = map['gender'];
        followers = map['followers'];
        following = map['following'];
        url = map['url'];
        items = map['items'];
        request = map['requests'];
        borrow = map['borrow'];
        favourites = map['favourites'];
    }

    String get getImageURL => AppProvider().baseURL + this.image;
    
    List<User> getUsersList(dynamic json){
        if(json != null){
            List data = json.toList();
            List<User> users = List<User>();
            data.forEach((user){
                users.add(User.fromJson(user));
            });
            return users;
        } 
        return [];
    }
}