import 'dart:async';
import 'package:buddyapp/UI/borrow/borrow_item.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/providers/notification.dart';

class SessionLending extends StatefulWidget{

    SessionLending({Key key, @required this.item}) : super(key: key);

    final Item item;

    @override
    State<StatefulWidget> createState() => _SessionLendingState();
}

class _SessionLendingState extends State<SessionLending>{

    User sessionUser;
    int userID;
    String sessionToken;

    List<Borrow> lending = [];
    bool canShowLending = false;
    bool showProgress = true;

    PushNotification pushNotification;

    @override
    void initState() {
        this.getUserData();
        this._loadSessionLendingBorrows();
        Timer(Duration(seconds: 2), (){
            setState(() {
                this.loadSessionLendingBorrows();
                this.canShowLending = true;
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
    void dispose() {
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

    void _setSessionLendingBorrows(List<Borrow> _borrowings){
        setState((){
            if(_borrowings != null && _borrowings.length > 0){
                this.lending = _borrowings.toList();
                this.canShowLending = true;
            } else {
                this.loadSessionLendingBorrows();
            }
        });
    }

    void _loadSessionLendingBorrows(){
        YoBuddyService().getLendingBorrowsInPreferences(this.widget.item.id).then((data) => this._setSessionLendingBorrows(data));
    }

    Future<Null> loadSessionLendingBorrows() async{
        YoBuddyService().getLendingBorrows(this.sessionToken, this.widget.item.user.username, this.widget.item.uuid, this.widget.item.id).then((data) => _setSessionLendingBorrows(data));
        return null;
    }

    List<Widget> getLendingList(){
        List<Widget> lendingList = [];
        this.lending.forEach((borrow){
            lendingList.add(BorrowItem(borrow: borrow, session: this.sessionUser));
        });
        return lendingList;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text("Lending For ${this.widget.item.name}", overflow: TextOverflow.ellipsis),
                actions: <Widget>[
                    IconButton(icon: Icon(IconData(0xf4a4, fontFamily: 'ionicon')), onPressed: (){})
                ],
            ),
            body: ListView(
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(bottom: 15.0, top: 15.0),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(style: BorderStyle.solid, color: Color(0xFFDDDDDD), width: 0.5))
                        ),
                        child: Container(
                            child: Column(
                                children: <Widget>[
                                    Center(
                                        child: Container(
                                            width: 150.0,
                                            height: 150.0,
                                            padding: EdgeInsets.only(right: 10.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    style: BorderStyle.solid,
                                                    width: 2.0,
                                                    color: Color(0xFFDDDDDD)
                                                ),
                                                shape: BoxShape.circle,
                                                color: Color(0xFFDDDDDD),
                                                image: DecorationImage(
                                                    image: NetworkImage(AppProvider().baseURL + widget.item.images[0].image.path),
                                                    fit: BoxFit.fitWidth
                                                )
                                            )
                                        ),
                                    ),
                                    Center(
                                        child: Container(
                                            padding: EdgeInsets.only(top: 12.0),
                                            child: Text(
                                                widget.item.name,
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.bold
                                                ),
                                            ),
                                        ),
                                    )
                                ],
                            ),
                        )
                    ),
                    Container(
                        child: ( this.lending != null) ? Container(
                            child: (this.canShowLending == true) ? Container(
                                child: (this.lending.length > 0) ? Column(children: this.getLendingList()) : Container(
                                    child: Center(
                                        child: (this.showProgress == true) ? Container(
                                            padding: EdgeInsets.only(top: 100.0),
                                            width: 25.0,
                                            height: 25.0,
                                            child: CircularProgressIndicator(
                                                backgroundColor: Color(0xFFCC8400),
                                                strokeWidth: 2.0,
                                            ),
                                        ) : Container(
                                            padding: EdgeInsets.only(top: 100.0),
                                            child: Text("No Lendings", style: TextStyle(fontSize: 27.0))
                                        )
                                    )
                                )
                            ) : Container(
                                padding: EdgeInsets.only(top: 100.0),
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
                            padding: EdgeInsets.only(top: 100.0),
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
                ],
            )
        );
    }
}