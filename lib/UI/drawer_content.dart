import 'package:flutter/material.dart';

class DrawerContent extends StatefulWidget{
    @override
    _DrawerContentState createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent>{
    @override
    Widget build(BuildContext context){
        return new ListView(
            children: <Widget>[
                UserAccountsDrawerHeader(
                    accountName: Text(
                        "Christian Scott"
                    ),
                    accountEmail: Text(
                        "irchristianscott@gmail.com"
                    ),
                    currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: new Text("C"),
                    ),
                    onDetailsPressed: (){}, 
                )
            ],
        );
    }
}