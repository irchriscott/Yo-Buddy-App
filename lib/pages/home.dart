import 'package:flutter/material.dart';
import '../providers/yobuddy.dart';
import '../models/item.dart';
import 'dart:async';
import '../providers/app.dart';
import '../UI/item.dart';

class HomePage extends StatefulWidget {
    HomePage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Item> items = [];
  bool canShowItems = false;
  
  @override
  void initState(){
      super.initState();
      this.loadHomeItems();
      Timer(Duration(seconds: 5), (){
          setState(() {
              this.canShowItems = true;            
          });
      });
  }

  Future<String> loadHomeItems() async{
      return YoBuddyService().getHomeItems().then((data){
          setState((){
              this.items = data.toList();
          });
      });
  }

  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        body: Container(
            child: this.canShowItems == true ? ListView.builder(
                itemCount: this.items.length,
                itemBuilder: (BuildContext context, int i){
                    return ItemPage(item: this.items[i]);
                },
            ) : Center(
                child: CircularProgressIndicator(
                    backgroundColor: Color(0xFFCC8400),
                    strokeWidth: 2.0,
                ),
            )
        )
    );
  }
}
