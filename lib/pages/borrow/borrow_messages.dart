import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:buddyapp/UI/borrow/message_image_viewer.dart';
import 'package:buddyapp/pages/borrow/description.dart';
import 'package:buddyapp/pages/borrow/image_message.dart';
import 'package:buddyapp/pages/borrow/qrcode.dart';
import 'package:buddyapp/pages/borrow/update.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/UI/borrow/message.dart';
import 'package:buddyapp/UI/popup.dart';
import 'package:buddyapp/UI/loading_popup.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

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
    bool canShowLoading = false;
    bool canShowQrCode = false;
    bool canViewImages = false;
    String _message;
    String _type;

    Borrow borrow;
    List<PopupMenuItem<String>> menuItemList = [];

    List<BorrowMessage> borrowMessages = [];
    List<BorrowMessageImage> messageImages = [];
    String messageSender = "";

    bool canShowMessages = false;
    TextEditingController message = TextEditingController();

    List<String> menuList = ["update", "accept", "reject", "renew", "extend", "followup", "description", "review", "report", "code"];

    SocketIO socketIO;
    Widget appBarStatus;
    PushNotification pushNotification;

    List<CameraDescription> cameras;

    @override
    void initState() {
        setState((){ this.getUserData(); this.getCameras(); });
        this.borrow = this.widget.borrow;
        this._loadBorrowingMessages();
        this.loadBorrowData();

        Timer(Duration(seconds: 1), (){ setState((){ this.canShowProfileImage = true; }); });
        Timer(Duration(seconds: 2), (){
            setState(() { this.loadBorrowingMessages(); });
        });

        this.socketIO = SocketIOManager().createSocketIO(AppProvider().socketURL, "");
        this.socketIO.init();
        this.socketIO.subscribe("getMessage", _onReceiveMessageSocket);
        this.socketIO.subscribe("isTyping", _onUserIsTyping);
        this.socketIO.connect();

        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken, context: context);
            this.pushNotification.initNotification();
            this.setMenuItemList();
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
                ),
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
        super.dispose();
    }

    Future<void> getCameras() async{
        try {
            cameras = await availableCameras();
        } on CameraException catch (e) {
            logError(e.code, e.description);
        }
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
        YoBuddyService().getBorrowMessages(this.borrow.id, this.borrow.messagesURL, this.sessionToken).then((data) {
            this._setBorrowingMessages(data);
            setState((){
                this.loadBorrowData();
                this.setMenuItemList();
            });
        });
        return null;
    }

    void loadBorrowData() async{
        this.borrow.getBorrow(this.sessionToken).then((response){
            setState(() { this.borrow = response; this.setMenuItemList(); });
        });
    }

    void menuItemSelected(String value){
        if(this.menuList.contains(value)){
            switch(value){
                case "accept":
                    this.updateBorrowStatus(borrow, "accepted", 1);
                    break;
                case "reject":
                    this.updateBorrowStatus(borrow, "rejected", 2);
                    break;
                case "description":
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => BorrowDescription(borrow: this.borrow, sessionToken: this.sessionToken, session: this.sessionUser))
                    );
                    break;
                case "update":
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => UpdateBorrowItemForm(borrow: this.borrow, onUpdateSuccess: (){
                            Navigator.of(context).pop();
                            this.loadBorrowingMessages();
                        }))
                    );
                    break;
                case "code":
                    setState((){ this.canShowQrCode = true; });
            }
        }
    }

    void setMenuItemList(){
        setState(() {
            this.menuItemList.clear();
            if(this.borrow.expiration == "orange"){
                if(this.sessionUser.id == this.borrow.user.id){
                    this.menuItemList.add(
                        PopupMenuItem<String>(
                            value: "update",
                            enabled: true,
                            child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text("Update")
                            )
                        )
                    );

                } else if(this.sessionUser.id == this.borrow.item.user.id){
                    this.menuItemList.add(
                        PopupMenuItem<String>(
                            value: "reject",
                            enabled: true,
                            child: ListTile(
                                leading: Icon(Icons.close),
                                title: Text("Reject")
                            )
                        )
                    );
                }
            } else if(this.borrow.expiration == "lightgreen"){
                if(this.sessionUser.id == this.borrow.lastUpdateBy.id){
                    this.menuItemList.add(
                        PopupMenuItem<String>(
                            value: "update",
                            enabled: true,
                            child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text("Update")
                            )
                        )
                    );
                } else {
                    this.menuItemList.add(
                        PopupMenuItem<String>(
                            value: "accept",
                            enabled: true,
                            child: ListTile(
                                leading: Icon(Icons.check),
                                title: Text("Accept")
                            )
                        )
                    );
                    this.menuItemList.add(
                        PopupMenuItem<String>(
                            value: "reject",
                            enabled: true,
                            child: ListTile(
                                leading: Icon(Icons.close),
                                title: Text("Reject")
                            )
                        )
                    );
                    this.menuItemList.add(
                        PopupMenuItem<String>(
                            value: "update",
                            enabled: true,
                            child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text("Update")
                            )
                        )
                    );
                }
            } else if(this.borrow.expiration == "green"){
                this.menuItemList.add(
                    PopupMenuItem<String>(
                        value: "code",
                        enabled: true,
                        child: ListTile(
                            leading: Icon(Icons.fullscreen),
                            title: Text("Get Code")
                        )
                    )
                );
                if(this.sessionUser.id == this.borrow.user.id){
                    if(this.borrow.wasRendered == true){
                        this.menuItemList.add(
                            PopupMenuItem<String>(
                                value: "extend",
                                enabled: true,
                                child: ListTile(
                                    leading: Icon(Icons.open_with),
                                    title: Text("Extend")
                                )
                            )
                        );
                    }
                    if(["returned", "succeeded"].contains(this.borrow.status)){
                        this.menuItemList.add(
                            PopupMenuItem<String>(
                                value: "renew",
                                enabled: true,
                                child: ListTile(
                                    leading: Icon(Icons.refresh),
                                    title: Text("Renew")
                                )
                            )
                        );
                    }
                } else if(this.sessionUser.id == this.borrow.item.user.id){
                    if(this.borrow.wasReceived == true && this.borrow.item.user.isPrivate == false){
                        this.menuItemList.add(
                            PopupMenuItem<String>(
                                value: "followup",
                                enabled: true,
                                child: ListTile(
                                    leading: Icon(Icons.subdirectory_arrow_right),
                                    title: Text("Follow Up")
                                )
                            )
                        );
                    }
                } else if(this.borrow.expiration == "red"){
                    this.menuItemList.add(
                        PopupMenuItem<String>(
                            value: "delete",
                            enabled: true,
                            child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text("Delete")
                            )
                        )
                    );
                    if(this.sessionUser.id == this.borrow.user.id){
                        this.menuItemList.add(
                            PopupMenuItem<String>(
                                value: "renew",
                                enabled: true,
                                child: ListTile(
                                    leading: Icon(Icons.refresh),
                                    title: Text("Renew")
                                )
                            )
                        );
                    }
                }
            }
            this.menuItemList.add(
                PopupMenuItem<String>(
                    value: "description",
                    enabled: true,
                    child: ListTile(
                        leading: Icon(Icons.insert_drive_file),
                        title: Text("Description")
                    )
                )
            );
            this.menuItemList.add(
                PopupMenuItem<String>(
                    value: "review",
                    enabled: true,
                    child: ListTile(
                        leading: Icon(Icons.assignment),
                        title: Text("Review")
                    )
                )
            );
            this.menuItemList.add(
                PopupMenuItem<String>(
                    value: "report",
                    enabled: true,
                    child: ListTile(
                        leading: Icon(Icons.info),
                        title: Text("Report")
                    )
                )
            );
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
            String data = '{"item": "${this.borrow.item.id}","borrow": "${this.borrow.id}","receiver": "${(this.sessionUser.id == this.borrow.user.id) ? this.borrow.item.user.id : this.borrow.user.id}","sender": "${this.sessionUser.username}","message": "$message","url": "${this.borrow.messagesURL}","path": "${this.borrow.url}","type": "message", "about": "borrow_message"}';
            this.socketIO.sendMessage("messageSent", data, _onReceiveMessageSocket);
        }
    }

    void sendNotificationSocket() async{
        if(this.socketIO != null){
            String data = (this.sessionUser.id == this.borrow.user.id) ? "${this.borrow.item.user.id.toString()}" : "${this.borrow.user.id.toString()}";
            this.socketIO.sendMessage("setNotification", data);
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
                if(resp['message'].toString() != "" && resp['message'].toString() != null){
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

    Future<void> updateBorrowStatus(Borrow borrow, String status, int index) async{
        showDialog<Null>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Update Borrow Status", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: SingleChildScrollView(
                        child: ListBody(
                            children: <Widget>[
                                Text("Do you really want to update this borrow status to ${status.replaceRange(0, 1, status[0].toUpperCase())} ?"),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text("YES", style: TextStyle(color: Color(0xFFCC8400))),
                            onPressed: () {
                                Navigator.of(context).pop();
                                setState((){ this.canShowLoading = true; });
                                borrow.updateBorrowStatus(index, status, this.sessionToken).then((response){
                                    setState((){
                                        this._message = response.text;
                                        this._type = response.type;
                                        this.canShowLoading = false;
                                        this.canShowPopup = true;
                                    });
                                    this.sendMessageSocket("Borrow Item Status To " + status.toUpperCase() + " !!!");
                                    this.sendNotificationSocket();
                                    this.loadBorrowingMessages();
                                });
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
    }

    Future<void> downloadBorrowCodePdf() async{
        Dio dio = Dio();
        try{
            setState(() { this.canShowLoading = true; });
            var dir = await getApplicationDocumentsDirectory();
            final String dirPath = "${dir.path}/pdf";
            await Directory(dirPath).create(recursive: true);
            final String filePath = "$dirPath/borrow_no_${this.borrow.code.toString()}.pdf";
            await dio.download(
                Uri.encodeFull(AppProvider().baseURL + "/item/enc-dt-${this.borrow.uuid}-${this.borrow.item.id.toString()}-${this.borrow.id.toString()}/borrow/description/download.pdf?token=${this.sessionToken}"),
                filePath,
                onProgress: (rec, total){
                    var progressValue = ((rec / total) * 100).toStringAsFixed(0) + "%";
                });
        } catch(e){
            setState(() {
                this._type = "error";
                this._message = e.toString(); //An Error Has Occurred !!!
                this.canShowLoading = false;
                this.canShowPopup = true;
            });
        }
        setState((){
            this._type = "success";
            this._message = "Download Completed !!!";
            this.canShowLoading = false;
            this.canShowPopup = true;
        });
    }

    void onOpenImages(int i){
        setState((){
            if(this.borrowMessages[i].hasImages){
                this.messageImages = this.borrowMessages[i].images;
                this.messageSender = this.borrowMessages[i].sender.name;
                this.canViewImages = true;
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return Hero(
            tag: "borrow messages",
            child : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                    Scaffold(
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
                                                    padding: EdgeInsets.only(left: 15.0, right: 10.0, bottom: 1.7),
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
                                                padding: EdgeInsets.only(bottom: 60.0),
                                                child: (this.borrowMessages.length > 0) ? ListView.builder(
                                                    reverse: true,
                                                    itemCount: this.borrowMessages.length,
                                                    itemBuilder: (BuildContext context, int i){
                                                        return BorrowMessageLayout(
                                                            borrow: this.borrow,
                                                            message: this.borrowMessages[i],
                                                            session: this.sessionUser,
                                                            onViewImages: (){
                                                                //this.onOpenImages(i);
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(builder: (BuildContext context) =>
                                                                        MessageImageViewPage(
                                                                            images: this.borrowMessages[i].images,
                                                                            sender: this.borrowMessages[i].sender.name,
                                                                            onImageViewClose: (){
                                                                                Navigator.of(context).pop();
                                                                            },
                                                                        )
                                                                    )
                                                                );
                                                            },
                                                        );
                                                    }
                                                ) : Center(
                                                    child: Container(
                                                        child: Text("No Messages", style: TextStyle(fontSize: 27.0))
                                                    )
                                                )
                                            ) : Center(
                                                child: Container(
                                                    child: Text("No Messages", style: TextStyle(fontSize: 27.0))
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
                                            padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
                                            child: Row(
                                                children: <Widget>[
                                                    Expanded(
                                                        child: Container(
                                                            padding: EdgeInsets.only(left: 52.0),
                                                            child: TextFormField(
                                                                autofocus: false,
                                                                controller: this.message,
                                                                style: TextStyle(
                                                                    fontSize: 16.0,
                                                                    color: Colors.black
                                                                ),
                                                                decoration: InputDecoration(
                                                                    hintText: 'Enter Message',
                                                                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
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
                                        bottom: 9.0,
                                        left: 10.0,
                                        child: InkWell(
                                            onTap: (){
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (BuildContext context) => ImageMessage(
                                                        borrow: this.borrow,
                                                        sessionToken: this.sessionToken,
                                                        session: this.sessionUser,
                                                        cameras: this.cameras,
                                                        onSendImages: (){
                                                            Navigator.of(context).pop();
                                                            this.loadBorrowingMessages();
                                                        }
                                                    ))
                                                );
                                            },
                                            child: Container(
                                                width: 40.0,
                                                height: 40.0,
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
                                    )
                                ],
                            ),
                        )
                    ),
                    (this.canShowPopup == true) ? PopupOverlay(
                        type: this._type,
                        message: this._message,
                        onTap: (){ setState((){ this.canShowPopup = false; }); },
                    ) : Container(),
                    (this.canShowLoading == true) ? LoadingOverlay() : Container(),
                    (this.canShowQrCode == true) ? BorrowQrCode(borrow: this.borrow, session: this.sessionUser, onCancel: (){
                        setState((){ this.canShowQrCode = false; });
                    }, onDownload: (){
                        setState((){ this.canShowQrCode = false; });
                        this.downloadBorrowCodePdf();
                    }) : Container(),
                    (this.canViewImages == true) ? MessageImageViewPage(
                        images: this.messageImages,
                        sender: this.messageSender,
                        onImageViewClose: (){
                            setState((){
                                this.canViewImages = false;
                            });
                        },
                    ) : Container()
                ]
            )
        );
    }
}