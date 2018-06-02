import 'package:flutter/material.dart';
import '../UI/drawer_content.dart';
import 'home.dart';
import 'categories.dart';
import 'notifications.dart';
import 'search.dart';

class TabsPage extends StatefulWidget{

    @override
    _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> with SingleTickerProviderStateMixin{

    final String title = "yo  buddy !";
    final GlobalKey<ScaffoldState> _this = new GlobalKey<ScaffoldState>();

    TabController _tabController;

    @override
    void dispose(){
        super.dispose();
        _tabController.dispose();
    }

    @override
    void initState(){
        super.initState();
        _tabController = new TabController(length: 4, vsync: this); 
    }

    @override
    Widget build(BuildContext context){
        return new Scaffold(
            key: _this,
            appBar: AppBar(
                backgroundColor: Color(0xFFCC8400),
                centerTitle: true,
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
                child: DrawerContent(),
            ),
            body: TabBarView(
                children: <Widget>[
                    HomePage(title: this.title),
                    CategoriesPage(title: this.title),
                    NotificationPage(title: this.title),
                    SearchPage(title: this.title)
                ],
                controller: _tabController,
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
                                    IconData(0xf4a4, fontFamily: 'ionicon'),
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
        );
    } 
}