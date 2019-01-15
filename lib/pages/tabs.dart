import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:buddyapp/UI/drawer_content.dart';
import 'home.dart';
import 'categories.dart';
import 'notifications.dart';
import 'requests.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:buddyapp/providers/auth.dart';

class TabsPage extends StatefulWidget{

    @override
    _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> with SingleTickerProviderStateMixin{

    final String title = "yo  buddy !";
    final GlobalKey<ScaffoldState> _this = new GlobalKey<ScaffoldState>();

    TabController _tabController;
    BuildContext scaffoldContext;

    User sessionUser;
    int userID;
    String sessionToken;

    PushNotification pushNotification;

    @override
    void dispose(){
        _tabController.dispose();
        super.dispose();
    }

    @override
    void initState(){
        _tabController = new TabController(length: 4, vsync: this);
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

    @override
    Widget build(BuildContext context){
        Widget body = TabBarView(
            children: <Widget>[
                HomePage(title: this.title),
                CategoriesPage(title: this.title),
                NotificationPage(title: this.title),
                RequestsPage(title: this.title)
            ],
            controller: _tabController,
        );
        return DefaultTabController(
            length: 4,
            child: Scaffold(
                key: _this,
                appBar: AppBar(
                    backgroundColor: Color(0xFFCC8400),
                    centerTitle: true,
                    actions: <Widget>[
                        IconButton(icon: Icon(IconData(0xf4a4, fontFamily: 'ionicon')), onPressed: (){})
                    ],
                    title: Text(
                        this.title.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white
                        ),
                    ),
                    leading: IconButton(
                        icon: Icon(Icons.menu, color: Colors.white),
                        onPressed: () => _this.currentState.openDrawer(),
                    ),
                ),
                drawer: Drawer(
                    child: DrawerContent(scaffoldContext: scaffoldContext)
                ),
                body: Builder(
                    builder: (BuildContext context){
                        scaffoldContext = context;
                        return body;
                    }
                ),
                bottomNavigationBar: BottomAppBar(
                    hasNotch: true,
                    child: Material(
                        color: Color(0xFFCC8400),
                        child: TabBar(
                            indicatorColor: Color(0xFFFFFF),
                            controller: _tabController,
                            labelColor: Color(0xFFFFFFFF),
                            unselectedLabelColor: Colors.black54,
                            tabs: <Widget>[
                                Tab(
                                    icon: Icon(
                                        IconData(0xf448, fontFamily: 'ionicon'),
                                        size: 28.0
                                    )
                                ),
                                Tab(
                                    icon: Icon(
                                        IconData(0xf482, fontFamily: 'ionicon'),
                                        size: 28.0
                                    )
                                ),
                                Tab(
                                    icon: Icon(
                                        IconData(0xf3e2, fontFamily: 'ionicon'),
                                        size: 28.0
                                    )
                                ),
                                Tab(
                                    icon: Icon(
                                        IconData(0xf454, fontFamily: 'ionicon'),
                                        size: 28.0
                                    )
                                )
                            ],
                        ),
                    ),
                ),
                floatingActionButton: FloatingActionButton(
                    onPressed: (){},
                    child: Icon(Icons.add, color: Colors.white),
                    backgroundColor: Color(0xFFCC8400),
                    notchMargin: 3.0,
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked
            )
        );
    } 
}