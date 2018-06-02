import 'package:flutter/material.dart';
import '../models/item.dart';
import 'package:flutter/foundation.dart';
import '../providers/app.dart';
import '../providers/auth.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

class SingleItemPage extends StatefulWidget{
    
    SingleItemPage({Key key, @required this.item, @required isOwner}):super(key:key);

    final Item item;
    static const bool isOwner = false;

    @override
    _SingleItemPageState createState() => _SingleItemPageState(isOwner: isOwner);
}

class _SingleItemPageState extends State<SingleItemPage>{

    _SingleItemPageState({@required isOwner});

    Item item;
    int userID;
    static const bool isOwner = false;
    bool isFollowed = false;
    int itemLikes;
    bool isLiked;
    bool isFavourited;

    @override
    void initState() {
        super.initState();
        this.item = widget.item;
        this.getUserData();
        this.itemLikes = this.item.likes.count;
    }

    void checkIsFollowed(){
        if(this.item.user.followersList.contains(this.userID)){
            this.isFollowed = true;
        }
        this.isFollowed = false;
    }

    void checkIsLiked(){
        if(this.item.likes.likers.contains(this.userID)){
            this.isLiked = true;
        }
        this.isLiked = false;
    }

    void checkIsFavourited(){
        if(this.item.favourites.contains(this.userID)){
            this.isFavourited = true;
        }
        this.isFavourited = false;
    }

    void followUser(){
        setState((){
            if(this.isFollowed){
                this.isFollowed = false;
            } else {
                this.isFollowed = true;
            }
        });
    }

    void _setUserID(int id){
        this.userID = id;
    }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
    }

    static const String editVal = "Edit";
    static const String deleteVal = "Delete";
    static const String availVal = "Available";
    static const String borrowVal = "Borrow";
    static const String favVal = "Favourite";
    static const String reportVal = "Report";

    static const List<String> _menuValue = <String>[editVal, deleteVal, availVal, borrowVal, favVal, reportVal];

    void menuItemSelected(String value){
        if(_menuValue.contains(value)){

        }
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: Text(this.item.name),
                actions: <Widget>[
                    PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: menuItemSelected,
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                                value: editVal,
                                enabled: isOwner,
                                child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text(editVal)
                                )
                            ),
                            const PopupMenuItem<String>(
                                value: deleteVal,
                                enabled: isOwner,
                                child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text(deleteVal)
                                )
                            ),
                            const PopupMenuItem<String>(
                                value: availVal,
                                child: ListTile(
                                    leading: Icon(Icons.assignment),
                                    title: Text(availVal)
                                )
                            ),
                            const PopupMenuItem<String>(
                                value: borrowVal,
                                enabled: !isOwner,
                                child: ListTile(
                                    leading: Icon(Icons.add),
                                    title: Text(borrowVal)
                                )
                            ),
                            const PopupMenuItem<String>(
                                value: favVal,
                                child: ListTile(
                                    leading: Icon(Icons.star_border),
                                    title: Text(favVal)
                                )
                            ),
                            const PopupMenuItem<String>(
                                value: reportVal,
                                child: ListTile(
                                    leading: Icon(Icons.info_outline),
                                    title: Text(reportVal)
                                )
                            )
                        ],
                    )
                ],
            ),
            body: PageView(
                children: <Widget>[
                    ListView(
                        children: <Widget>[
                            Container(
                                child: Column(
                                    children: <Widget>[
                                        Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: Image.network(AppProvider().baseURL + this.item.images[0].image.path, fit: BoxFit.fill)
                                        )
                                    ],
                                ),
                            ),
                            Container(
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                    children: <Widget>[
                                        Container(
                                            width: 45.0,
                                            height: 45.0,
                                            padding: EdgeInsets.only(right: 10.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    style: BorderStyle.solid,
                                                    width: 2.0,
                                                    color: Color(0xFF999999)
                                                ),
                                                shape: BoxShape.circle,
                                                color: Color(0xFF999999),
                                                image: DecorationImage(
                                                    image: NetworkImage(this.item.user.getImageURL),
                                                    fit: BoxFit.fill
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                textDirection: TextDirection.ltr,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        padding: EdgeInsets.only(left: 10.0),
                                                        child: Text(
                                                            this.item.name,
                                                            overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    color: Color(0xFF333333),
                                                                    fontSize: 22.0,
                                                                    fontWeight: FontWeight.bold,
                                                                ),
                                                            ),
                                                    ),
                                                    Container(
                                                        padding: EdgeInsets.only(left: 10.0),
                                                        child: Text(
                                                            this.item.category.name + " - " + this.item.subcategory.name,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: Color(0xFF666666),
                                                                fontSize: 17.0
                                                            )
                                                        ),
                                                    ),
                                                    Container(
                                                        padding: EdgeInsets.only(left: 10.0),
                                                        child: Text(
                                                            "by " + this.item.user.name + "  -  " + this.item.createdAt.toString(),
                                                            style: TextStyle(
                                                                color: Color(0xFF999999)
                                                            ),
                                                            overflow: TextOverflow.clip
                                                        ),
                                                    )
                                                ],
                                            ),
                                        ),
                                        Container(
                                            child: IconButton(
                                                onPressed: () => this.followUser(),
                                                icon: (this.isFollowed == true) ? Icon(Icons.person, color: Color(0xFFCC8400)) : Icon(Icons.person_add, color: Color(0xFF999999)),
                                                iconSize: 35.0,
                                                color: Color(0xFF333333),
                                            )
                                        )
                                    ],
                                )
                            ),
                            Divider(),
                            Container(
                                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                child: Container(
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.0),
                                        color: Colors.black45, 
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                            Icon(
                                                Icons.local_offer,
                                                color: Colors.white
                                            ),
                                            Padding(padding: EdgeInsets.only(left: 8.0)),
                                            Text(this.item.price.toString(), style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                            Padding(padding: EdgeInsets.only(left: 8.0)),
                                            Text(this.item.currency, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                            Padding(padding: EdgeInsets.only(left: 8.0)),
                                            Text("/", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                            Padding(padding: EdgeInsets.only(left: 8.0)),
                                            Text(this.item.per, style: TextStyle(color: Colors.white, fontSize: 18.0))
                                        ],
                                    )
                                ),
                            ),
                            Divider(),
                            Container(
                                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                        Container(
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        child: IconButton(
                                                            icon: (this.isLiked == true) ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_border),
                                                            iconSize: 30.0,
                                                            color: Color(0xFF333333),
                                                            onPressed: (){},
                                                        )
                                                    ),
                                                    Text(
                                                        this.itemLikes.toString(), 
                                                        style: TextStyle(
                                                            fontSize: 20.0,
                                                            color: Color(0xFF333333)
                                                        )
                                                    )
                                                ],
                                            )
                                        ),
                                        Container(
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        child: Icon(Icons.comment, size: 30.0, color: Color(0xFF333333)),
                                                        padding: EdgeInsets.only(left: 12.0, right: 12.0),
                                                    ),
                                                    Text(
                                                        this.item.comments.toString(), 
                                                        style: TextStyle(
                                                            fontSize: 20.0,
                                                            color: Color(0xFF333333)
                                                        )
                                                    )
                                                ],
                                            )
                                        ),
                                        Container(
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        child: Icon(Icons.shopping_cart, size: 30.0, color: Color(0xFF333333)),
                                                        padding: EdgeInsets.only(left: 12.0, right: 12.0),
                                                    ),
                                                    Text(
                                                        this.item.borrow.toString(), 
                                                        style: TextStyle(
                                                            fontSize: 20.0,
                                                            color: Color(0xFF333333)
                                                        )
                                                    )
                                                ],
                                            )
                                        ),
                                        Container(
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        child: (this.isFavourited == true) ? Icon(Icons.star, size: 35.0, color: Color(0xFFCC8400)) : Container(),
                                                        padding: EdgeInsets.only(left: 10.0, right: 8.0),
                                                    ),
                                                ],
                                            )
                                        ),
                                    ],
                                ), 
                            ),
                            Divider(),
                            Container(
                                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                                child: HtmlView(data: this.item.description)
                            )
                        ],
                    )
                ],
            )
            
        );
    }
}

