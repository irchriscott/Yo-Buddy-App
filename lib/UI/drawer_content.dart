import 'package:flutter/material.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/pages/new_item.dart';
import 'package:buddyapp/pages/session/borrowing.dart';

class DrawerContent extends StatefulWidget{
    DrawerContent({Key key, @required this.scaffoldContext}) : super(key : key);
    final BuildContext scaffoldContext;
    @override
    _DrawerContentState createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent>{

    User user;
    bool canShowData = false;

    @override
    void initState(){
        super.initState();  
        this._getUserData();
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
            onTap: () => _onTap(),
        );
    }

    void showNewItemModal() {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => NewItemForm())
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
                _listTimeItem(IconData(0xf454, fontFamily: 'ionicon'), "Items", this.user.items.toString(), (){

                }),
                _listTimeItem(IconData(0xf3f8, fontFamily: 'ionicon'), "Borrows", this.user.borrow.toString(), (){
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (BuildContext context) => SessionBorrowing())
                    );
                }),
                _listTimeItem(Icons.star_border, "Favourites", this.user.favourites.toString(), (){

                }),
                _listTimeItem(Icons.people, "Followers", this.user.followers.toString(), (){

                }),
                _listTimeItem(IconData(0xf212, fontFamily: 'ionicon'), "Following", this.user.following.toString(), (){

                }),
                _listTimeItem(IconData(0xf13a, fontFamily: 'ionicon'), "Requests", this.user.followers.toString(), (){

                }),
                Divider(),
                ListTile(
                    leading: Icon(Icons.add_shopping_cart),
                    title: Text("Add Item"),
                    onTap: () => this.showNewItemModal(),
                ),
                ListTile(
                    leading: Icon(Icons.add),
                    title: Text("Add Request"),
                    onTap: (){},            
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    onTap: (){},            
                ),
                ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text("Help"),
                    onTap: (){},            
                ),
                Divider(),
                ListTile(
                    leading: Icon(Icons.exit_to_app, color: Color(0xFFFF9494)),
                    title: Text("Logout", style: TextStyle(color: Color(0xFFFF9494))),
                    onTap: (){},            
                )
            ],
        ) : Container();
    }
}