import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/UI/item/item_action_sheet.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/pages/item/single_item.dart';
import 'package:buddyapp/providers/helper.dart';

class ItemPage extends StatefulWidget{
    const ItemPage({Key key, @required this.item, @required this.scaffoldContext}): super(key:key);
    final Item item;
    final BuildContext scaffoldContext;
    @override
    _ItemPageState createState() => _ItemPageState();
}
class _ItemPageState extends State<ItemPage>{

    Item item;
    User sessionUser;
    int userID;
    bool isLiked = false;
    String sessionToken;

    SocketIO socketIO;

    @override
    void initState(){
        this.item = widget.item;

        this.getUserData();
        this.checkUserLike();

        Timer(Duration(seconds: 3), (){ this.getSingleItem(); });

        this.socketIO = SocketIOManager().createSocketIO(AppProvider().socketURL, "");
        this.socketIO.init();
        this.socketIO.connect();

        super.initState();
    }

    void _setUser(User user){ this.sessionUser = user; }

    void _setUserID(int id){ this.userID = id; }

    void _setSessionToken(String token){ this.sessionToken = token; }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
        Authentication().getSessionUser().then((value) => _setUser(value));
        Authentication().getUserToken().then((value) => _setSessionToken(value));
    }

    void _showBottomSheet(){
        showModalBottomSheet(
            context: context,
            builder: (builder){
                return ItemActionSheet(item: this.item, scaffoldContext: widget.scaffoldContext, context: context, session: this.sessionUser, sessionToken: this.sessionToken);
            }
        );
    }

    void checkUserLike(){ setState((){ this.isLiked = this.item.likes.likers.contains(this.userID) ? true : false; }); }

    void likeItem(){
        YoBuddyService().likeItem(this.item, this.sessionUser, this.sessionToken).then((response){
            setState((){
                _emitLikeEventSocket(response.type);
                if(response.type == "dislike"){ this.isLiked = false;
                Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Item Disiked !!!"));
                } else if(response.type == "like") {this.isLiked = true;
                    Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Item Liked !!!"));
                } else {
                    Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Oops... Something happend !!!"));
                }
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
        if(int.parse(dt['item']) == this.item.id && dt['liker'] == this.sessionUser.username){
            setState(() { this.isLiked = true; });
        }
    }

    Future<void> getSingleItem() async{
        YoBuddyService().getSingleItem(this.item.user.username, this.item.uuid, this.item.id).then((value){
            setState((){ if(value != null) { this.item = value; this.checkUserLike(); } });
        });
    }

    void navigateSingleItem(){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => SingleItemPage(item:  this.item, isOwner: (this.item.user.id == this.userID)))
        );
    }

    @override
    Widget build(BuildContext context){
        return Stack(
            children: <Widget>[
                Container(
                    child: Card(
                        child: Container(
                            child: Column(
                                children: <Widget>[
                                    InkWell(
                                        onDoubleTap: () => this.likeItem(),
                                        onLongPress: () => this._showBottomSheet(),
                                        onTap: () => this.navigateSingleItem(),
                                        child: Container(
                                            child: FadeInImage.memoryNetwork(
                                                image: AppProvider().baseURL + this.item.images[0].image.path,
                                                placeholder: kTransparentImage,
                                            )
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
                                                        onPressed: () => this.likeItem(),
                                                        icon: (this.isLiked == true) ? Icon(IconData(0xf443, fontFamily: 'ionicon'), color: Colors.red) : Icon(IconData(0xf442, fontFamily: 'ionicon')),
                                                        iconSize: 35.0,
                                                        color: Color(0xFF333333),
                                                    )
                                                )
                                            ],
                                        )
                                    )
                                ],
                            ),
                        )
                    ),
                ),
                Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Container(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        width: 200.0,
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
                                Text(HelperProvider().formatPrice(this.item.price.toInt()), style: TextStyle(color: Colors.white)),
                                Padding(padding: EdgeInsets.only(left: 8.0)),
                                Text(this.item.currency, style: TextStyle(color: Colors.white)),
                                Padding(padding: EdgeInsets.only(left: 8.0)),
                                Text("/", style: TextStyle(color: Colors.white)),
                                Padding(padding: EdgeInsets.only(left: 8.0)),
                                Text(this.item.per, style: TextStyle(color: Colors.white))
                            ],
                        )
                    ),
                ),
            ],
        );
    }
}