import 'dart:async';
import 'package:flutter/material.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/UI/item.dart';
import 'package:buddyapp/models/user.dart';

class HomePage extends StatefulWidget {
    HomePage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Item> items = [];
  bool canShowItems = false;
  GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  BuildContext scaffoldContext;

  PushNotification pushNotification;

  User sessionUser;
  int userID;
  String sessionToken;
  
  @override
  void initState(){
      this._loadHomeItems();
      this.getUserData();
      Timer(Duration(seconds: 5), (){
          setState(() {
              this.loadHomeItems();
              this.canShowItems = true;
          });
      });

      Timer(Duration(seconds: 1), (){ setState((){
          this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken, context: context);
          this.pushNotification.initNotification();
      }); });

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

  void _setItems(List<Item> _items){
      setState((){
          if(_items != null) {
              this.items = _items.toList();
              this.canShowItems = true;
          }
      });
  }

  void _loadHomeItems(){
      YoBuddyService().getSharedHomeItems().then((value) => this._setItems(value));
  }

  Future<Null> loadHomeItems() async{
      await Future.delayed(Duration(seconds: 3));
      _refreshKey.currentState?.show(atTop: false);
      YoBuddyService().getHomeItems().then((data) => _setItems(data.toList()));
      return null;
  }

  @override
  Widget build(BuildContext context) {
      Widget body = RefreshIndicator(
          key: this._refreshKey,
          onRefresh: () => this.loadHomeItems(),
          child: Container(
              child: this.canShowItems == true ? ListView.builder(
                  itemCount: this.items.length,
                  itemBuilder: (BuildContext context, int i){
                      return ItemPage(item: this.items[i], scaffoldContext: scaffoldContext);
                  },
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
      );
      return new Scaffold(
          body: Builder(
              builder: (BuildContext context){
                  scaffoldContext = context;
                  return body;
              }
          ),
      );
  }
}
