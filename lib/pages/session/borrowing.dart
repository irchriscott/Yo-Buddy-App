import 'dart:async';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/UI/borrow_item.dart';
import 'package:buddyapp/providers/notification.dart';

class SessionBorrowing extends StatefulWidget{

    @override
    _SessionBorrowingState createState() => _SessionBorrowingState();
}

class _SessionBorrowingState extends State<SessionBorrowing>{

    User sessionUser;
    int userID;
    String sessionToken;

    List<Borrow> borrowings = [];
    bool canShowBorrowings = false;
    PushNotification pushNotification;

    @override
    void initState() {
        this.getUserData();
        this._loadSessionBorrowings();
        Timer(Duration(seconds: 5), (){
            setState(() {
                this.loadSessionBorrowings();
                this.canShowBorrowings = true;
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

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: AppBar(
                title: Text("Borrowings"),
                actions: <Widget>[
                    IconButton(icon: Icon(IconData(0xf4a4, fontFamily: 'ionicon')), onPressed: (){})
                ],
            ),
            body: (this.canShowBorrowings == true) ? Container(
                child: (this.borrowings != null) ? Container(
                    child: (this.borrowings.length > 0) ? ListView.builder(
                        itemCount: this.borrowings.length,
                        itemBuilder: (BuildContext context, int i){
                            return BorrowItem(borrow: this.borrowings[i], session: this.sessionUser);
                        }
                    ) : Container(
                        child: Center(
                            child: Container(
                                child: Text("No Borrowings", style: TextStyle(fontSize: 27.0))
                            )
                        )
                    )
                ) : Container(
                    child: Center(
                        child: Container(
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
        );
    }
}