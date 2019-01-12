import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'edit_item.dart';
import 'borrow_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/comment.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:buddyapp/UI/image_viewer.dart';
import 'package:buddyapp/UI/comment.dart';
import 'package:buddyapp/UI/items_available.dart';
import 'package:buddyapp/UI/popup.dart';
import 'package:buddyapp/UI/loading_popup.dart';
import 'package:buddyapp/UI/edit_comment.dart';
import 'package:buddyapp/UI/confirmation_popup.dart';

// ignore: must_be_immutable
class SingleItemPage extends StatefulWidget{
    
    SingleItemPage({Key key, @required this.item, @required this.isOwner}):super(key:key);

    final Item item;
    bool isOwner;

    @override
    _SingleItemPageState createState() => _SingleItemPageState();
}

class _SingleItemPageState extends State<SingleItemPage>{

    Item item;

    User sessionUser;
    int userID;
    String sessionToken;
    bool canShowProfileImage = false;

    bool isOwner;
    bool isFollowed = false;
    int itemLikes;
    bool isLiked;
    bool isFavourite;

    bool canViewImages = false;
    bool canShowComments = false;
    bool canViewAvailable = false;

    List<Comment> comments;
    bool canShowPopup = false;
    bool canShowConfirmation = false;
    bool isLoadingVisible;
    String message = "";
    String type = "";
    bool canEditComment = false;
    Comment selectedComment;
    int selectedCommentIndex;

    TextEditingController comment = TextEditingController();
    TextEditingController editableCommentCtrl = TextEditingController();
    Random random = Random();

    BuildContext scaffoldContext;
    Color disabledColor = Color.fromRGBO(0, 0, 0, 0.2);
    Color enabledColor = Colors.black;
    PushNotification pushNotification;

    SocketIO socketIO;

    @override
    void initState() {
        setState((){ this.getUserData(); });
        this.item = widget.item;
        this.itemLikes = this.item.likes.count;
        this.isOwner = widget.isOwner;

        this.checkIsFavourite();
        this.checkIsLiked();
        this.checkIsFollowed();

        this._loadItemComments(this.item.id);

        Timer(Duration(seconds: 1), (){ setState((){ this.canShowProfileImage = true; }); });
        Timer(Duration(seconds: 3), (){
            setState((){
                this.getSingleItem();
                this.loadItemComments(this.item.id);
                this.canShowComments = true;
            });
        });
        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken, context: context);
            this.pushNotification.initNotification();
        }); });

        this.socketIO = SocketIOManager().createSocketIO(AppProvider().socketURL, "");
        this.socketIO.init();
        this.socketIO.subscribe("getLike", _onItemLikeSocket);
        this.socketIO.subscribe("getComment", _onItemCommentSocket);
        this.socketIO.connect();

        super.initState();
    }

    @override
    void dispose(){
        this.canShowPopup = false;
        this.selectedComment = null;
        this.selectedCommentIndex = null;
        this.canShowConfirmation = false;
        this.isLoadingVisible = false;
        this.canEditComment = false;
        this.comment.dispose();
        this.editableCommentCtrl.dispose();
        this.pushNotification.dispose();
        this.socketIO.disconnect();
        this.socketIO.destroy();
        super.dispose();
    }

    void _setUserID(int id){ this.userID = id; }

    void _setUser(User user){ this.sessionUser = user; }

    void _setUserToken(String token){ this.sessionToken = token; }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
        Authentication().getSessionUser().then((value) => _setUser(value));
        Authentication().getUserToken().then((value) => _setUserToken(value));
    }

    void checkIsFollowed(){ this.isFollowed = this.item.user.followersList.contains(this.userID) ? true : false; }

    void checkIsLiked(){ this.isLiked = this.item.likes.likers.contains(this.userID) ? true : false; }

    void checkIsFavourite(){ this.isFavourite = this.item.favourites.contains(this.userID) ? true : false; }

    void followUser(){
        YoBuddyService().followUser(this.item.user.id, this.sessionUser.id, this.sessionToken).then((response){
            setState((){
                if(response.type == "followed"){ this.isFollowed = true; }
                else if(response.type == "unfollowed") { this.isFollowed = false; }
            });
            AppProvider().showSnackBar(response.text);
        });
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
            switch(value){
                case editVal:
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => EditItemForm(item:  this.item))
                    );
                    return;
                case deleteVal:
                    return;
                case availVal:
                    setState(() { this.canViewAvailable = true; });
                    return;
                case borrowVal:
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => BorrowItemForm(item:  this.item))
                    );
                    return;
                case favVal:
                    this.favouriteItem();
                    return;
                case reportVal:
                    return;

            }
        }
    }

    void onImageViewOpen(){ setState((){ this.canViewImages = true; }); }

    void onImageViewClosed(){ setState((){ this.canViewImages = false; }); }

    void onAvailableClosed(){ setState(() { this.canViewAvailable = false; }); }

    Future<Null> getSingleItem() async{
        YoBuddyService().getSingleItem(this.item.user.username, this.item.uuid, this.item.id).then((value){
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
                _emitLikeEventSocket(response.type);
                if(response.type == "dislike"){ this.isLiked = false; }
                else if(response.type == "like") { this.isLiked = true; }
                this.getSingleItem();
            });
        });
    }

    void _emitLikeEventSocket(String type){
        if (this.socketIO != null) {
            String data = '{"item": "${this.item.id}", "type": "$type", "liker": "${this.sessionUser.username}", "user": "${this.item.user.id}", "about": "like_item", "url": "${this.item.url}"}';
            String notification = '{"user": "${this.item.user.id}", "title": "From ${this.sessionUser.name}", "body": "${this.sessionUser.name} has liked your item.", "icon": "http://127.0.0.1:3000/${this.item.user.image}", "url": "http://127.0.0.1:3000/${this.item.url}"}';
            this.socketIO.sendMessage("like", data, _onItemLikeSocket);
            this.socketIO.sendMessage("setNotification", '{"user":"${this.item.user.id}"}');
            this.socketIO.sendMessage("notify", notification);
        }
    }

    void _onItemLikeSocket(dynamic data){
        var dt = json.decode(data.toString());
        if(int.parse(dt['item']) == this.item.id){
            setState((){
                if(dt['type'] == "dislike"){ this.itemLikes -= 1; }
                else if(dt['type'] == "like") { this.itemLikes += 1; }
                if(this.sessionUser.username == dt['liker']){ this.isLiked = true; }
            });
        }
    }

    void favouriteItem() async{
        this.item.favouriteItem(this.sessionToken, this.sessionUser.id.toString()).then((response){
            setState((){
                if(response.type == "success"){ this.isFavourite = true; }
                else if(response.type == "unmark"){ this.isFavourite = false; }
                else {
                    this.message = response.text;
                    this.type = response.type;
                    this.canShowPopup = true;
                }
            });
        });
    }

    void _setItemComments(List<Comment> _comments){
        setState((){
            if(_comments != null){
                this.comments = _comments.toList();
                this.canShowComments = true;
            } else { this.loadItemComments(this.item.id); }
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
        if(this.comment.text.isNotEmpty || this.comment.text != ""){
            setState((){
                Comment _comment = Comment(
                    id: random.nextInt(999999),
                    comment: comment.text,
                    createdAt: DateTime.now(),
                    user: this.sessionUser
                );
                this.comments.add(_comment);
                Comment().postComment(_comment, this.item.id.toString(), this.sessionToken).then((response){
                    setState(() {
                        _emitCommentItemSocket();
                        this.message = response.text;
                        this.type = response.type;
                        this.canShowPopup = true;
                    });
                });
            });
            this.comment.text = "";
        } else { AppProvider().alert(context, "Error", "Please, Enter Your Comment !!!"); }
    }

    void _emitCommentItemSocket(){
        if (this.socketIO != null) {
            String data = '{"url": "/items/${this.item.id}/comments", "item": "${this.item.id}", "from": "add", "user": "${this.item.user.id}", "commenter": "${this.sessionUser.username}", "itemurl": "${this.item.url}", "about": "comment_item"}';
            String notification = '{"user": "${this.item.user.id}", "title": "From ${this.sessionUser.name}", "body": "${this.sessionUser.name} has posted a comment to your item.", "icon": "http://127.0.0.1:3000/${this.item.user.image}", "url": "http://127.0.0.1:3000/${this.item.url}"}';
            this.socketIO.sendMessage("comment", data, _onItemCommentSocket);
            this.socketIO.sendMessage("setNotification", '{"user":"${this.item.user.id}"}');
            this.socketIO.sendMessage("notify", notification);
        }
    }

    void _onItemCommentSocket(String data){
        var dt = json.decode(data.toString());
        if(int.parse(dt['item']) == this.item.id){
            loadItemComments(int.parse(dt['item']));
        }
    }

    Future<void> updateComment(Comment comment, int index){
        comment.comment = editableCommentCtrl.text;
        comment.updateComment(this.userID.toString(), this.sessionToken).then((response){
            setState((){
                this.isLoadingVisible = false;
                this.message = response.text;
                this.type = response.type;
                this.canShowPopup = true;
                this.comments[index].comment = editableCommentCtrl.text;
                this.selectedComment = null;
                this.selectedCommentIndex = null;
                this.loadItemComments(this.item.id);
            });
        });
        return null;
    }

    Future<void> deleteComment(Comment comment, int index){
        showDialog<Null>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Delete Comment", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: SingleChildScrollView(
                        child: ListBody(
                            children: <Widget>[
                                Text("Do you really want to delete this comment ?"),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text("YES", style: TextStyle(color: Color(0xFFCC8400))),
                            onPressed: () {
                                setState((){ this.isLoadingVisible = true; });
                                comment.deleteComment(this.item.id.toString(), this.sessionToken).then((response){
                                    setState(() {
                                        this.message = response.text;
                                        this.type = response.type;
                                        this.isLoadingVisible = false;
                                        this.canShowPopup = true;
                                        this.comments.removeAt(index);
                                    });
                                });
                                Navigator.of(context).pop();
                            },
                        ),
                        FlatButton(
                            child: Text("NO", style: TextStyle(color: Colors.redAccent)),
                            onPressed: () { Navigator.of(context).pop(); },
                        ),
                    ],
                );
            },
        );
        return null;
    }

    @override
    Widget build(BuildContext context){
        Widget body = PageView(
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
                                                                fontSize: 18.0,
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
                                                                fontSize: 15.0
                                                            )
                                                        ),
                                                    ),
                                                    Container(
                                                        padding: EdgeInsets.only(left: 10.0),
                                                        child: Text(
                                                            "by " + this.item.user.name + "  -  " + HelperProvider().formatDateTime(this.item.createdAt.toString()),
                                                            style: TextStyle(
                                                                color: Color(0xFF999999),
                                                                fontSize: 13.0
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
                                            Text(HelperProvider().formatPrice(this.item.price.toInt()), style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                            Padding(padding: EdgeInsets.only(left: 8.0)),
                                            Text(this.item.currency, style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                            Padding(padding: EdgeInsets.only(left: 8.0)),
                                            Text("/", style: TextStyle(color: Colors.white, fontSize: 18.0)),
                                            Padding(padding: EdgeInsets.only(left: 8.0)),
                                            Text(this.item.per, style: TextStyle(color: Colors.white, fontSize: 18.0))
                                        ],
                                    )
                                ),
                                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
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
                                                        child: (this.isFavourite == true) ? IconButton(icon: Icon(Icons.star, size: 35.0, color: Color(0xFFCC8400)), onPressed: () => this.favouriteItem()) : Container(),
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
                                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 15.0),
                                child: MarkdownBody(data: html2md.convert(this.item.description))
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
                                        padding: EdgeInsets.only(bottom: 70.0),
                                        child: (this.comments.length > 0) ? ListView.builder(
                                            itemCount: this.comments.length,
                                            itemBuilder: (BuildContext context, int i){
                                                return CommentListItem(
                                                    comment: this.comments[i],
                                                    userID: this.userID,
                                                    scaffoldContext: this.scaffoldContext,
                                                    onDelete: () {
                                                        setState(() {
                                                            this.selectedComment = this.comments[i];
                                                            this.selectedCommentIndex = i;
                                                            this.canShowConfirmation = true;
                                                        });
                                                    },
                                                    onEdit: (){
                                                        setState(() {
                                                            this.selectedComment = this.comments[i];
                                                            this.selectedCommentIndex = i;
                                                            this.canEditComment = true;
                                                        });
                                                    },
                                                );
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
                                        border: Border(top: BorderSide(style: BorderStyle.solid, color: Color(0xFFDDDDDD))),
                                        color: Colors.white,
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
                                                        autovalidate: true,
                                                        autocorrect: true
                                                    )
                                                ),
                                            ),
                                            IconButton(
                                                onPressed: () => this.submitItemComment(),
                                                icon: Icon(Icons.send),
                                                iconSize: 30.0,
                                                color: Color(0xFF666666),
                                                disabledColor: Color(0xFFDDDDDD),
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
                                            image: (this.canShowProfileImage == false) ? NetworkImage(AppProvider().defaultImage) : NetworkImage(this.sessionUser.getImageURL),
                                            fit: BoxFit.fill
                                        )
                                    )
                                ),
                            )
                        ],
                    ),
                )
            ],
        );

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
                                    PopupMenuItem<String>(
                                        value: editVal,
                                        enabled: isOwner,
                                        child: ListTile(
                                            leading: Icon(Icons.edit),
                                            title: Text(editVal, style: TextStyle(color: isOwner ? enabledColor : disabledColor))
                                        )
                                    ),
                                    PopupMenuItem<String>(
                                        value: deleteVal,
                                        enabled: isOwner,
                                        child: ListTile(
                                            leading: Icon(Icons.delete),
                                            title: Text(deleteVal, style: TextStyle(color: isOwner ? enabledColor : disabledColor))
                                        )
                                    ),
                                    PopupMenuItem<String>(
                                        value: availVal,
                                        child: ListTile(
                                            leading: Icon(Icons.assignment),
                                            title: Text(availVal)
                                        )
                                    ),
                                    PopupMenuItem<String>(
                                        value: borrowVal,
                                        enabled: !isOwner,
                                        child: ListTile(
                                            leading: Icon(Icons.add),
                                            title: Text(borrowVal, style: TextStyle(color: !isOwner ? enabledColor : disabledColor))
                                        )
                                    ),
                                    PopupMenuItem<String>(
                                        value: favVal,
                                        child: ListTile(
                                            leading: Icon(Icons.star_border),
                                            title: Text(favVal)
                                        )
                                    ),
                                    PopupMenuItem<String>(
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
                    body: Builder(
                        builder: (BuildContext context){
                            scaffoldContext = context;
                            return body;
                        }
                    ),
                ),
                (this.canViewImages == true) ? ImageViewPage(images: this.item.images, onImageViewClose: this.onImageViewClosed, name: this.item.name, isLiked: this.isLiked) : Container(),
                (this.canViewAvailable == true) ? ItemsAvailable(item: this.item, onClose: this.onAvailableClosed) : Container(),
                (this.canShowPopup == true) ? PopupOverlay(type: this.type, message: this.message, onTap: (){
                    setState(() { this.canShowPopup = false; });
                }) : Container(),
                (this.isLoadingVisible == true) ? LoadingOverlay() : Container(),
                (this.canEditComment == true) ? EditComment(
                    comment: this.selectedComment,
                    onClose: (){ setState(() { this.canEditComment = false; this.selectedComment = null; this.selectedCommentIndex = null; });},
                    onUpdate: (){
                        setState(() {
                            this.canEditComment = false;
                            this.isLoadingVisible = true;
                        });
                        this.updateComment(selectedComment, selectedCommentIndex);
                    },
                    commentCtrl: this.editableCommentCtrl
                ) : Container(),
                (this.canShowConfirmation == true) ? ConfirmationPopup(
                    title: "Delete Comment",
                    message: "Do you really want to delete this comment ?",
                    onAccept: (){
                        setState((){ this.canShowConfirmation = false; this.isLoadingVisible = false; });
                        this.selectedComment.deleteComment(this.item.id.toString(), this.sessionToken).then((response){
                            setState(() {
                                this.message = response.text;
                                this.type = response.type;
                                this.isLoadingVisible = false;
                                this.canShowPopup = true;
                                this.comments.removeAt(this.selectedCommentIndex);
                                this.selectedComment = null;
                                this.selectedCommentIndex = null;
                            });
                        });
                    },
                    onDecline: (){ setState(() { this.canShowConfirmation = false; this.selectedComment = null; this.selectedCommentIndex = null; }); },
                ) : Container()
            ],
        );
    }
}

