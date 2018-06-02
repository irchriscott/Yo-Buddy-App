import 'package:flutter/material.dart';
import '../models/user.dart';
import '../providers/session.dart';
import 'dart:async';
import '../providers/auth.dart';

class DrawerContent extends StatefulWidget{
    @override
    _DrawerContentState createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent>{

    User user;
    bool canShowData = false;

    @override
    void initState(){
        super.initState();  
        this.getUserData();
        this._getUserData();
        Timer(Duration(seconds: 3), (){
            setState(() {
                this.canShowData = true;         
            });
        });
    }

    void getUserData(){
        DatabaseHelper().userData().then((data){
            this.user = data;
        });
    }

    void _setValue(User user){
        setState((){
            this.user = user;
            this.canShowData = true;
        });
    }

    void _getUserData(){
        Authentication().getSessionUser().then((value) => _setValue(value));
    }

    ListTile _listTimeItem(IconData icon, String title, String value, VoidCallback _onTap){
        return ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: Container(
                padding: EdgeInsets.fromLTRB(5.0, 2.5, 5.0, 2.5),
                decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF)
                ),
                child: Text(value),
            ),
            onTap: () => _onTap,            
        );
    }

    @override
    Widget build(BuildContext context){
        return (this.canShowData == true) ? ListView(
            children: <Widget>[
                UserAccountsDrawerHeader(
                    accountName: Text(
                        this.user.name,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold
                        ),
                    ),
                    accountEmail: Text(
                        this.user.email
                    ),
                    currentAccountPicture: Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white,
                              style: BorderStyle.solid,
                              width: 2.0
                          ),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(this.user.getImageURL),
                              fit: BoxFit.fill
                          ) 
                        )
                    ),
                    onDetailsPressed: (){}, 
                ),
                _listTimeItem(Icons.grid_on, "Items", this.user.items.toString(), (){

                }),
                _listTimeItem(Icons.shopping_cart, "Borrows", this.user.borrow.toString(), (){

                }),
                _listTimeItem(Icons.people, "Followers", this.user.followers.toString(), (){

                }),
                _listTimeItem(Icons.people, "Following", this.user.following.toString(), (){

                }),
                _listTimeItem(Icons.list, "Requests", this.user.followers.toString(), (){

                }),
                Divider(),
                ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    onTap: (){},            
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text("Help"),
                    onTap: (){},            
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text("Logout"),
                    onTap: (){},            
                )
            ],
        ) : Container();
    }
}