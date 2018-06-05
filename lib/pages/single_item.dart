import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import '../models/item.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../providers/app.dart';
import '../providers/auth.dart';
import '../providers/yobuddy.dart';
import '../UI/image_viewer.dart';
import '../UI/comment.dart';

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
    User sessionUser;
    int userID;
    String sessionToken;
    static const bool isOwner = false;
    bool isFollowed = false;
    int itemLikes;
    bool isLiked;
    bool isFavourite;
    bool canViewImages;
    bool canShowComments = false;

    List<Comment> comments;

    TextEditingController comment = TextEditingController();
    Random random = Random();

    @override
    void initState() {
        super.initState();
        this.item = widget.item;
        this.getUserData();
        this.itemLikes = this.item.likes.count;
        this.getSingleItem();
        this.checkIsFavourite();
        this.checkIsLiked();
        this.checkIsFollowed();
        this._loadItemComments(this.item.id);
        Timer(Duration(seconds: 5), (){
            setState((){
                this.loadItemComments(this.item.id);
                this.canShowComments = true;
            });
        });
    }

    void checkIsFollowed(){
        if(this.item.user.followersList.contains(this.userID)){
            this.isFollowed = true;
        } else {
            this.isFollowed = false;
        }
    }

    void checkIsLiked(){
        if(this.item.likes.likers.contains(this.userID)){
            this.isLiked = true;
        } else {
            this.isLiked = false;
        }
    }

    void checkIsFavourite(){
        if(this.item.favourites.contains(this.userID)){
            this.isFavourite = true;
        } else {
            this.isFavourite = false;
        }
    }

    void followUser(){
        YoBuddyService().followUser(this.item.user.id, this.sessionUser.id, this.sessionToken).then((response){
            setState((){
                if(response.type == "followed"){
                    this.isFollowed = true;
                } else if(response.type == "unfollowed") {
                    this.isFollowed = false;
                }
            });
            AppProvider().showSnackBar(response.text);
        });
    }

    void _setUserID(int id){
        this.userID = id;
    }

    void _setUser(User user){
        this.sessionUser = user;
    }

    void _setUserToken(String token){
        this.sessionToken = token;
    }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
        Authentication().getSessionUser().then((value) => _setUser(value));
        Authentication().getUserToken().then((value) => _setUserToken(value));
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

    void onImageViewOpen(){
        setState((){
          this.canViewImages = true;
        });
    }

    void onImageViewClose(){
        setState((){
            this.canViewImages = false;
        });
    }

    Future<Null> getSingleItem() async{
        YoBuddyService().getSingleItem(this.item.id).then((value){
            setState((){
                if(value != null) {
                    this.item = value;
                    this.checkIsFavourite();
                    this.checkIsLiked();
                    this.checkIsFollowed();
                    this.itemLikes = value.likes.count;
                } else {
                    AppProvider().alert(context, "Error", "This item might be deleted !!!").then((_){
                        Navigator.of(context).pop();
                    });
                }
            });
        });
        return null;
    }

    void likeItem(){
        YoBuddyService().likeItem(this.item, this.sessionUser, this.sessionToken).then((response){
            setState((){
                if(response.type == "dislike"){
                    this.isLiked = false;
                    this.itemLikes -= 1;
                } else if(response.type == "like") {
                    this.isLiked = true;
                    this.itemLikes += 1;
                }
                this.getSingleItem();
            });
        });
    }

    void _setItemComments(List<Comment> _comments){
        setState((){
            if(_comments != null){
                this.comments = _comments.toList();
                this.canShowComments = true;
            } else {
                this.loadItemComments(this.item.id);
            }
        });
    }


    void _loadItemComments(int itemID){
        YoBuddyService().getItemCommentsInPreferences(itemID).then((data) => this._setItemComments(data));
    }

    Future<Null> loadItemComments(int itemID) async{
        YoBuddyService().getItemComments(itemID).then((data) => _setItemComments(data));
        return null;
    }

    void submitItemComment(){
        AppProvider().alert(context, "Comment", this.comment.text);
        setState((){
            Comment _comment = Comment(
                id: random.nextInt(999999),
                comment: comment.text,
                createdAt: DateTime.now(),
                user: this.sessionUser
            );
            this.comments.add(_comment);
        });
        this.comment.text = "";
    }

    @override
    Widget build(BuildContext context){
        return Stack(
            fit: StackFit.expand,
            children: <Widget>[
                Scaffold(
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
                            Container(
                                color: Colors.white,
                                child: ListView(
                                    children: <Widget>[
                                        InkWell(
                                            onTap: () => this.onImageViewOpen(),
                                            onDoubleTap: (){},
                                            onLongPress: (){},
                                            child: Container(
                                                child: Column(
                                                    children: <Widget>[
                                                        Container(
                                                            width: MediaQuery.of(context).size.width,
                                                            child: Image.network(AppProvider().baseURL + this.item.images[0].image.path, fit: BoxFit.fill)
                                                        )
                                                    ],
                                                ),
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
                                                          icon: (this.isFollowed == true) ? Icon(IconData(0xf213, fontFamily: 'ionicon'), color: Color(0xFFCC8400)) : Icon(IconData(0xf211, fontFamily: 'ionicon'), color: Color(0xFF999999)),
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
                                                                      icon: (this.isLiked == true) ? Icon(IconData(0xf443, fontFamily: 'ionicon'), color: Colors.red) : Icon(IconData(0xf442, fontFamily: 'ionicon')),
                                                                      iconSize: 30.0,
                                                                      color: Color(0xFF333333),
                                                                      onPressed: () => this.likeItem(),
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
                                                                  child: Icon(IconData(0xf3fc, fontFamily: 'ionicon'), size: 30.0, color: Color(0xFF333333)),
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
                                                                  child: Icon(IconData(0xf3f8, fontFamily: 'ionicon'), size: 30.0, color: Color(0xFF333333)),
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
                                                                    child: (this.isFavourite == true) ? Icon(Icons.star, size: 35.0, color: Color(0xFFCC8400)) : Container(),
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
                            ),

                            //Comments Page

                            Container(
                                color: Colors.white,
                                child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                        Container(
                                            child: (this.canShowComments == true) ? Container(
                                                child: (this.comments != null) ? Container(
                                                    child: (this.comments.length > 0) ? ListView.builder(
                                                        itemCount: this.comments.length,
                                                        itemBuilder: (BuildContext context, int i){
                                                            return CommentListItem(comment: this.comments[i], userID: this.userID);
                                                        }
                                                    ) : Center(
                                                        child: Container(
                                                            child: Text("No Comment", style: TextStyle(fontSize: 27.0))
                                                        )
                                                    )
                                                ) : Center(
                                                    child: Container(
                                                        child: Text("No Comment", style: TextStyle(fontSize: 27.0))
                                                    ),
                                                )
                                            ) : Center(
                                                child: Container(
                                                    width: 25.0,
                                                    height: 25.0,
                                                    child: CircularProgressIndicator(
                                                        backgroundColor: Color(0xFFCC8400),
                                                        strokeWidth: 2.0,
                                                    ),
                                                )
                                            )
                                        ),
                                        Positioned(
                                            bottom: 0.0,
                                            left: 0.0,
                                            right: 0.0,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border(top: BorderSide(style: BorderStyle.solid, color: Color(0xFFDDDDDD)))
                                                ),
                                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
                                                child: Row(
                                                    children: <Widget>[
                                                        Expanded(
                                                            child: Container(
                                                                padding: EdgeInsets.only(left: 57.0),
                                                                child: TextFormField(
                                                                    autofocus: true,
                                                                    controller: this.comment,
                                                                    style: TextStyle(
                                                                        fontSize: 20.0,
                                                                        color: Colors.black
                                                                    ),
                                                                    decoration: InputDecoration(
                                                                        hintText: 'Enter Comment',
                                                                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                                                        hintStyle: TextStyle(color: Color(0x99999999)),
                                                                        border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(20.0)
                                                                        )
                                                                    ),
                                                                    maxLines: null,
                                                                    keyboardType: TextInputType.multiline,
                                                                )
                                                            ),
                                                        ),
                                                        IconButton(
                                                            onPressed: () => this.submitItemComment(),
                                                            icon: Icon(Icons.send),
                                                            iconSize: 30.0,
                                                            color: Color(0xFF666666),
                                                            disabledColor: Color(0xFFDDDDDD)
                                                        )
                                                    ],
                                                ),
                                            ),
                                        ),
                                        Positioned(
                                            bottom: 12.0,
                                            left: 10.0,
                                            child: Container(
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
                                                        image: NetworkImage(this.sessionUser.getImageURL),
                                                        fit: BoxFit.fill
                                                    )
                                                )
                                            ),
                                        )
                                    ],
                                ),
                            )
                        ],
                    )
                ),
              (this.canViewImages == true) ? ImageViewPage(images: this.item.images, onImageViewClose: this.onImageViewClose, name: this.item.name, isLiked: this.isLiked) : Container()
            ],
        );
    }
}

