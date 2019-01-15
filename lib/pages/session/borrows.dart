import 'dart:async';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/UI/borrow/borrow_item.dart';
import 'package:buddyapp/UI/item/item_row.dart';
import 'package:buddyapp/providers/notification.dart';


class SessionBorrows extends StatefulWidget{

    @override
    _SessionBorrowsState createState() => _SessionBorrowsState();
}

class _SessionBorrowsState extends State<SessionBorrows>{

    User sessionUser;
    int userID;
    String sessionToken;

    List<Borrow> borrowings = [];
    List<Item> items = [];
    bool canShowBorrowings = false;
    bool canShowItems = false;
    bool showProgress = true;
    PushNotification pushNotification;

    @override
    void initState() {
        this.getUserData();
        this._loadSessionBorrowings();
        this._loadSessionLendingItems();
        Timer(Duration(seconds: 2), (){
            setState(() {
                this.loadSessionBorrowings();
                this.loadSessionLendingItems();
            });
        });
        Timer(Duration(seconds: 3), (){
            setState((){
                this.canShowBorrowings = true;
                this.canShowItems = true;
            });
        });
        Timer(Duration(seconds: 9), (){
            setState(() {
                this.showProgress = false;
            });
        });
        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken, context: context);
            this.pushNotification.initNotification();
        }); });
        super.initState();
    }

    @override
    void dispose(){
        this.pushNotification.dispose();
        super.dispose();
    }

    void _setUserID(int id){
        this.userID = id;
    }

    void _setUser(User user){
        this.sessionUser = user;
    }

    void _setUserToken(String token){
        this.sessionToken = token;
    }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
        Authentication().getSessionUser().then((value) => _setUser(value));
        Authentication().getUserToken().then((value) => _setUserToken(value));
    }

    void _setSessionBorrowings(List<Borrow> _borrowings){
        setState((){
            if(_borrowings != null && _borrowings.length > 0){
                this.borrowings = _borrowings.toList();
                this.canShowBorrowings = true;
            } else {
                this.loadSessionBorrowings();
            }
        });
    }

    void _loadSessionBorrowings(){
        YoBuddyService().getBorrowingsInPreferences().then((data) => this._setSessionBorrowings(data));
    }

    Future<Null> loadSessionBorrowings() async{
        YoBuddyService().getBorrowing(this.sessionToken).then((data) => _setSessionBorrowings(data));
        return null;
    }

    void _setSessionLendingItems(List<Item> _items){
        setState((){
            if(_items != null && _items.length > 0){
                this.items = _items.toList();
                this.canShowItems = true;
            } else {
                this.loadSessionLendingItems();
            }
        });
    }

    void _loadSessionLendingItems(){
        YoBuddyService().getLendingItemsInPreferences().then((data) => this._setSessionLendingItems(data));
    }

    Future<Null> loadSessionLendingItems() async{
        YoBuddyService().getLendingItems(this.sessionToken).then((data) => _setSessionLendingItems(data));
        return null;
    }

    @override
    Widget build(BuildContext context){
        return Material(
            child: DefaultTabController(
                length: 2,
                child: Scaffold(
                    appBar: AppBar(
                        title: Text("Borrows"),
                        actions: <Widget>[
                            IconButton(icon: Icon(IconData(0xf4a4, fontFamily: 'ionicon')), onPressed: (){})
                        ],
                        bottom: TabBar(
                            indicatorColor: Colors.white70,
                            tabs: [
                                Tab(text: "Lending".toUpperCase()),
                                Tab(text: "Borrowing".toUpperCase())
                            ]
                        ),
                    ),
                    body: TabBarView(
                        children: [
                            Container(
                                child: (this.items != null) ? Container(
                                    child: (this.canShowItems == true) ? Container(
                                        child: (this.items.length > 0) ? ListView.builder(
                                            itemCount: this.items.length,
                                            itemBuilder: (BuildContext context, int i){
                                                return this.items[i].borrow > 0 ? ItemRow(item: this.items[i]) : Container();
                                            }
                                        ) : Container(
                                            child: Center(
                                                child: (this.showProgress == true) ? Container(
                                                    width: 25.0,
                                                    height: 25.0,
                                                    child: CircularProgressIndicator(
                                                        backgroundColor: Color(0xFFCC8400),
                                                        strokeWidth: 2.0,
                                                    ),
                                                ) : Container(
                                                    child: Text("No Lending Items", style: TextStyle(fontSize: 27.0))
                                                )
                                            )
                                        )
                                    ) : Container(
                                        child: Center(
                                            child: Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: CircularProgressIndicator(
                                                    backgroundColor: Color(0xFFCC8400),
                                                    strokeWidth: 2.0,
                                                ),
                                            )
                                        ),
                                    )
                                ) : Container(
                                    child: Center(
                                        child: Container(
                                            width: 25.0,
                                            height: 25.0,
                                            child: CircularProgressIndicator(
                                                backgroundColor: Color(0xFFCC8400),
                                                strokeWidth: 2.0,
                                            ),
                                        )
                                    ),
                                )
                            ),
                            Container(
                                child: ( this.borrowings != null) ? Container(
                                    child: (this.canShowBorrowings == true) ? Container(
                                        child: (this.borrowings.length > 0) ? ListView.builder(
                                            itemCount: this.borrowings.length,
                                            itemBuilder: (BuildContext context, int i){
                                                return BorrowItem(borrow: this.borrowings[i], session: this.sessionUser);
                                            }
                                        ) : Container(
                                            child: Center(
                                                child: (this.showProgress == true) ? Container(
                                                    width: 25.0,
                                                    height: 25.0,
                                                    child: CircularProgressIndicator(
                                                        backgroundColor: Color(0xFFCC8400),
                                                        strokeWidth: 2.0,
                                                    ),
                                                ) : Container(
                                                    child: Text("No Borrowings", style: TextStyle(fontSize: 27.0))
                                                )
                                            )
                                        )
                                    ) : Container(
                                        child: Center(
                                            child: Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: CircularProgressIndicator(
                                                    backgroundColor: Color(0xFFCC8400),
                                                    strokeWidth: 2.0,
                                                ),
                                            )
                                        ),
                                    )
                                ) : Container(
                                    child: Center(
                                        child: Container(
                                            width: 25.0,
                                            height: 25.0,
                                            child: CircularProgressIndicator(
                                                backgroundColor: Color(0xFFCC8400),
                                                strokeWidth: 2.0,
                                            ),
                                        )
                                    ),
                                )
                            )
                        ]
                    )
                )
            )
        );
    }
}