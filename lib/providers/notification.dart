import 'dart:async';
import 'app.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/user.dart';
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
        this.socketIO.connect();

    }

    void initNot() async {
        var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
        var initializationSettingsIOS = IOSInitializationSettings();
        var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

        this.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        this.flutterLocalNotificationsPlugin.initialize(initializationSettings, selectNotification: onSelectNotification);
    }

    void dispose(){
        this.socketIO.disconnect();
        this.socketIO.destroy();
    }

    Future onSelectNotification(String payload) async {
        var data = json.decode(payload.toString());
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
}