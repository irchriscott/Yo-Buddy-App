import 'package:flutter/material.dart';
import '../models/user.dart';
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
                _listTimeItem(Icons.shopping_cart, "Items", this.user.items.toString(), (){

                }),
                _listTimeItem(Icons.play_for_work, "Borrows", this.user.borrow.toString(), (){

                }),
                _listTimeItem(Icons.people, "Followers", this.user.followers.toString(), (){

                }),
                _listTimeItem(Icons.people_outline, "Following", this.user.following.toString(), (){

                }),
                _listTimeItem(Icons.arrow_forward, "Requests", this.user.followers.toString(), (){

                }),
                Divider(),
                ListTile(
                    leading: Icon(Icons.add_shopping_cart),
                    title: Text("Add Item"),
                    onTap: (){},            
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