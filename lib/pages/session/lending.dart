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
            body: CustomScrollView(
                slivers: <Widget>[
                    SliverAppBar(
                        expandedHeight: 200.0,
                        pinned: true,
                        floating: false,
                        snap: false,
                        flexibleSpace: FlexibleSpaceBar(
                            title: Text(this.widget.item.name),
                            background: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                    Image(
                                        image: NetworkImage(AppProvider().baseURL + this.widget.item.images[0].image.path),
                                        fit: BoxFit.fitWidth,
                                        height: 200.0,
                                    ),
                                    DecoratedBox(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment(0.0, -1.0),
                                                end: Alignment(0.0, -0.4),
                                                colors: <Color>[const Color(0x90000000), const Color(0x00000000)],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        actions: <Widget>[
                            IconButton(icon: Icon(IconData(0xf4a4, fontFamily: 'ionicon')), onPressed: (){})
                        ],
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate(
                            <Widget>[
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
                            ]
                        )
                    )
                ],
            )
        );
    }
}