import 'dart:async';
import 'app.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/pages/borrow_messages.dart';
import 'package:buddyapp/pages/single_item.dart';
import 'package:buddyapp/providers/net.dart' as net;
import 'package:buddyapp/providers/helper.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification{

    final User user;
    final String token;
    final BuildContext context;

    PushNotification({this.user, this.token, @required this.context});

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    SocketIO socketIO;

    void initNotification () async{

        var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
        var initializationSettingsIOS = IOSInitializationSettings();
        var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

        this.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        this.flutterLocalNotificationsPlugin.initialize(initializationSettings, selectNotification: onSelectNotification);

        this.socketIO = SocketIOManager().createSocketIO(AppProvider().socketURL, "");
        this.socketIO.init();
        this.socketIO.subscribe("getMessage", _onReceiveMessageSocket);
        this.socketIO.subscribe("getLike", _onItemLikeSocket);
        this.socketIO.subscribe("getComment", _onItemCommentSocket);
        this.socketIO.connect();

    }

    void initNot() async {
        var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
        var initializationSettingsIOS = IOSInitializationSettings();
        var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

        this.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        this.flutterLocalNotificationsPlugin.initialize(initializationSettings, selectNotification: onSelectNotification);
    }

    void dispose(){}

    Future onSelectNotification(String payload) async {
        var data = json.decode(payload.toString());
        print(data['about']);
        switch(data['about']){
            case "borrow_message":
                net.NetworkUtil().get(Uri.encodeFull(AppProvider().baseURL + HelperProvider().checkJsonURL(data['path']) + "?token=${this.token}")).then((response){
                    Borrow borrow = Borrow.fromJson(response);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => BorrowMessages(borrow: borrow))
                    );
                });
                break;
            case "like_item":
                net.NetworkUtil().get(Uri.encodeFull(AppProvider().baseURL + HelperProvider().checkJsonURL(data['url']) + "?token=${this.token}")).then((response){
                    Item item = Item.fromJson(response);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => SingleItemPage(item: item, isOwner: true))
                    );
                });
                break;
            case "comment_item":
                net.NetworkUtil().get(Uri.encodeFull(AppProvider().baseURL + HelperProvider().checkJsonURL(data['itemurl']) + "?token=${this.token}")).then((response){
                    Item item = Item.fromJson(response);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => SingleItemPage(item: item, isOwner: true))
                    );
                });
                break;
        }
    }

    Future showNotification(String title, String message, String about, String data) async {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'yobuddy', 'yobuddy notification', 'notification for yobuddy',
            importance: Importance.Max, priority: Priority.High);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(0, title, message, platformChannelSpecifics, payload: data,);
    }

    void _onReceiveMessageSocket(dynamic message){
        this.initNot();
        var msg = json.decode(message.toString());
        if(this.user.id == int.parse(msg['receiver'])) {
            this.showNotification("${msg['sender'].replaceRange(0, 1, msg['sender'][0].toUpperCase())} has sent a message", msg['message'], "borrow_message", message);
        }
    }

    void _onItemLikeSocket(dynamic data){
        this.initNot();
        var dt = json.decode(data.toString());
        if(int.parse(dt['user']) == this.user.id){
            var msg = (dt['type'] == "like") ? " has liked your item" : " has disliked your item";
            this.showNotification("Item Liked", dt['liker'].replaceRange(0, 1, dt['liker'][0].toUpperCase()) + msg, "like_item", data);
        }
    }

    void _onItemCommentSocket(String data){
        this.initNot();
        var dt = json.decode(data.toString());
        if(int.parse(dt['user']) == this.user.id){
            this.showNotification("New Comment Posted", dt['commenter'].replaceRange(0, 1, dt['commenter'][0].toUpperCase()) + " has posted a comment to your item", "comment_item", data);
        }
    }
}