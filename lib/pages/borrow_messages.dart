import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/UI/message.dart';
import 'package:buddyapp/UI/popup.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class BorrowMessages extends StatefulWidget{
    BorrowMessages({Key key, @required this.borrow}) : super(key : key);
    final Borrow borrow;
    @override
    _BorrowMessagesState createState() => _BorrowMessagesState();
}

class _BorrowMessagesState extends State<BorrowMessages>{

    User sessionUser;
    int userID;
    String sessionToken;
    bool canShowProfileImage = false;

    bool canShowPopup = false;
    String _message;
    String _type;

    Borrow borrow;
    List<PopupMenuItem<String>> menuItemList = [];

    List<BorrowMessage> borrowMessages = [];
    bool canShowMessages = false;
    TextEditingController message = TextEditingController();

    SocketIO socketIO;
    Widget appBarStatus;
    PushNotification pushNotification;

    @override
    void initState() {
        setState((){ this.getUserData();});
        this.borrow = this.widget.borrow;
        this._loadBorrowingMessages();

        Timer(Duration(seconds: 1), (){ setState((){ this.canShowProfileImage = true; }); });
        Timer(Duration(seconds: 3), (){ setState(() { this.loadBorrowingMessages(); }); });

        this.socketIO = SocketIOManager().createSocketIO(AppProvider().socketURL, "");
        this.socketIO.init();
        this.socketIO.subscribe("getMessage", _onReceiveMessageSocket);
        this.socketIO.subscribe("isTyping", _onUserIsTyping);
        this.socketIO.connect();

        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken);
            this.pushNotification.initNotification();
        }); });

        this.message.addListener(userIsTyping);
        this.appBarStatus = Container(
            padding: EdgeInsets.only(left: 15.0, right: 10.0),
            child: Text(
                "From ${HelperProvider().formatDateTimeString(this.borrow.fromDate)} - To ${HelperProvider().formatDateTimeString(this.borrow.toDate)}",
                style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 11.0,
                    height: 0.8
                )
            ),
        );

        super.initState();
    }

    @override
    void dispose(){
        this.message.removeListener(userIsTyping);
        this.message.dispose();
        userIsTyping();
        this.pushNotification.dispose();
        this.socketIO.disconnect();
        this.socketIO.destroy();
        super.dispose();
    }

    void _setUser(User user){ this.sessionUser = user; }

    void _setUserID(int id){ this.userID = id; }

    void _setSessionToken(String token){ this.sessionToken = token; }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
        Authentication().getSessionUser().then((value) => _setUser(value));
        Authentication().getUserToken().then((value) => _setSessionToken(value));
    }

    void _setBorrowingMessages(List<BorrowMessage> messages){
        setState((){
            if(messages != null && messages.length > 0){
                this.borrowMessages = messages.reversed.toList();
                this.canShowMessages = true;
            } else { this.loadBorrowingMessages(); }
        });
    }

    void _loadBorrowingMessages(){
        YoBuddyService().getBorrowMessagesInSharedPreferences(this.borrow.id).then((data) => this._setBorrowingMessages(data));
    }

    Future<Null> loadBorrowingMessages() async{
        YoBuddyService().getBorrowMessages(this.borrow.id, this.borrow.messagesURL, this.sessionToken).then((data) => this._setBorrowingMessages(data));
        return null;
    }

    void menuItemSelected(String value){

    }

    void setMenuItemList(){
        setState(() {

        });
    }

    void sendBorrowMessage() async{
        if(this.message.text != null && this.message.text != ""){
            BorrowMessage newMessage = BorrowMessage(
                message: this.message.text,
                receiver: (this.sessionUser.id == this.borrow.user.id) ? this.borrow.item.user : this.borrow.user,
                isDeleted: false,
                status: "unread"
            );
            newMessage.sendTextMessage(this.sessionToken, this.borrow.item.id, this.borrow.id).then((response){
                if(response.type == "success"){
                    if (this.socketIO != null) this.socketIO.subscribe("message", _onReceiveMessageSocket);
                    this.sendMessageSocket(this.message.text);
                    setState((){ this.message.text = ""; });
                    this.loadBorrowingMessages();
                    userIsTyping();
                } else { setState((){ this._message = response.text; this._type = response.type; this.canShowPopup = true; });}
            });
        }
    }

    void sendMessageSocket(String message) async{
        if (this.socketIO != null) {
            String data = '{"item": "${this.borrow.item.id}","borrow": "${this.borrow.id}","receiver": "${(this.sessionUser.id == this.borrow.user.id) ? this.borrow.item.user.id : this.borrow.user.id}","sender": "${this.sessionUser.username}","message": "$message","url": "${this.borrow.messagesURL}","path": "${this.borrow.url}","type": "message"}';
            this.socketIO.sendMessage("messageSent", data, _onReceiveMessageSocket);
        }
    }

    void _onReceiveMessageSocket(dynamic message){
        var msg = json.decode(message.toString());
        if(this.sessionUser.id == int.parse(msg['receiver']) && this.borrow.id == int.parse(msg['borrow'])) {
            setState((){
                this.borrowMessages.insert(this.borrowMessages.length, BorrowMessage(
                    id: Random().nextInt(1000),
                    sender: (this.borrow.user.id == this.sessionUser.id) ? this.borrow.item.user : this.borrow.user,
                    type: "user",
                    isDeleted: false,
                    hasImages: false,
                    message: msg['message'],
                    status: "read",
                    createdAt: DateTime.now().toString(),
                    images: []
                ));
            });
            this.loadBorrowingMessages();
        }
    }

    void userIsTyping() async{
        if(this.socketIO != null){
            String data = '{"item": "${this.borrow.item.id}","borrow": "${this.borrow.id}","receiver": "${(this.sessionUser.id == this.borrow.user.id) ? this.borrow.item.user.id : this.borrow.user.id}","sender": "${this.sessionUser.username}","message": "${this.message.text}"}';
            this.socketIO.sendMessage("textType", data, _onUserIsTyping);
        }
    }

    void _onUserIsTyping(dynamic response){
        var resp = json.decode(response.toString());
        if(this.sessionUser.id == int.parse(resp['receiver']) && this.borrow.id == int.parse(resp['borrow'])){
            setState((){
                if(resp['message'] != "" && resp['message'] != null){
                    this.appBarStatus = Container(
                        padding: EdgeInsets.only(left: 15.0, right: 10.0),
                        child: Text(
                            "${resp['sender'].replaceRange(0, 1, resp['sender'][0].toUpperCase())} is typing...",
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 11.0,
                                height: 0.8
                            )
                        ),
                    );
                } else {
                    this.appBarStatus = Container(
                        padding: EdgeInsets.only(left: 15.0, right: 10.0),
                        child: Text(
                            "From ${HelperProvider().formatDateTimeString(this.borrow.fromDate)} - To ${HelperProvider().formatDateTimeString(this.borrow.toDate)}",
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 11.0,
                                height: 0.8
                            )
                        ),
                    );
                }
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Row(
                    children: <Widget>[
                        Container(
                            width: 45.0,
                            height: 45.0,
                            padding: EdgeInsets.only(right: 15.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 2.0,
                                    color: Color(0xFFFFFFFF)
                                ),
                                shape: BoxShape.circle,
                                color: Color(0xFFFFFFFF),
                                image: DecorationImage(
                                    image: (this.borrow.item.user.id == this.userID) ? NetworkImage(this.borrow.user.getImageURL) : NetworkImage(this.borrow.item.user.getImageURL),
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
                                        padding: EdgeInsets.only(top: 2.0, left: 15.0, right: 10.0),
                                        child: Text(
                                            (this.borrow.item.user.id == this.userID) ? this.borrow.user.name : this.borrow.item.user.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, right: 10.0),
                                        child: Text(
                                            this.borrow.item.name,
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 13.0,
                                                height: 0.8
                                            )
                                        ),
                                    ),
                                    Container( child: this.appBarStatus),
                                ],
                            ),
                        ),
                    ],
                ),
                actions: <Widget>[
                    PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: menuItemSelected,
                        itemBuilder: (BuildContext context) => this.menuItemList
                    ),
                ],
            ),
            body: Container(
                color: Colors.white,
                child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                        Container(
                            child: (this.canShowMessages == true) ? Container(
                                child: (this.borrowMessages != null) ? Container(
                                    padding: EdgeInsets.only(bottom: 70.0),
                                    child: (this.borrowMessages.length > 0) ? ListView.builder(
                                        reverse: true,
                                        itemCount: this.borrowMessages.length,
                                        itemBuilder: (BuildContext context, int i){
                                            return BorrowMessageLayout(
                                                borrow: this.borrow,
                                                message: this.borrowMessages[i],
                                                session: this.sessionUser
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
                                                    autofocus: false,
                                                    controller: this.message,
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.black
                                                    ),
                                                    decoration: InputDecoration(
                                                        hintText: 'Enter Message',
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
                                            onPressed: () => this.sendBorrowMessage(),
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
                        ),
                        (this.canShowPopup == true) ? PopupOverlay(
                            type: this._type,
                            message: this._message,
                            onTap: (){ setState((){ this.canShowPopup = false; }); },
                        ) : Container()
                    ],
                ),
            )
        );
    }
}