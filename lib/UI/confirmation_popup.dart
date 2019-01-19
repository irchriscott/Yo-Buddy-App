import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ConfirmationPopup extends StatefulWidget{

    ConfirmationPopup({
        Key key,
        @required this.title,
        @required this.message,
        @required this.onAccept,
        @required this.onDecline
    }) : super(key : key);

    final String title;
    final String message;
    final VoidCallback onAccept;
    final VoidCallback onDecline;

    @override
    _ConfirmationPopupState createState() => _ConfirmationPopupState();
}

class _ConfirmationPopupState extends State<ConfirmationPopup>{

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Material(
            color: Color.fromRGBO(0, 0, 0, 0.7),
            child: (this.widget.message != null) ? Hero(
                tag: "confirmpopup",
                child: Container(
                    padding: EdgeInsets.fromLTRB(40.0, 240.0, 40.0, 240.0),
                    child: Container(
                        padding: EdgeInsets.only(
                            top: 30.0, bottom: 30.0, right: 30.0, left: 30.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                        ),
                        child: Stack(
                            children: <Widget>[
                                Container(
                                    child: Container(
                                        child: Container(
                                            padding: EdgeInsets.only(
                                                bottom: 20.0),
                                            child: Text(
                                                this.widget.title,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22.0
                                                )
                                            ),
                                        ),
                                    )
                                ),
                                Container(
                                    padding: EdgeInsets.only(
                                        top: 50.0, bottom: 30.0),
                                    child: Container(
                                        child: Text(
                                            widget.message,
                                            style: TextStyle(
                                                fontSize: 17.0
                                            ),
                                        )
                                    ),
                                ),
                                Positioned(
                                    bottom: 0.0,
                                    right: 80.0,
                                    child: InkWell(
                                        onTap: () => widget.onDecline(),
                                        child: Text(
                                            "NO".toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                color: Colors.redAccent
                                            ),
                                        )
                                    )
                                ),
                                Positioned(
                                    bottom: 0.0,
                                    right: 0.0,
                                    child: InkWell(
                                        onTap: () => widget.onAccept(),
                                        child: Text(
                                            "YES".toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                color: Theme
                                                    .of(context)
                                                    .primaryColor
                                            ),
                                        )
                                    )
                                ),
                            ],
                        )
                    ),
                ),
            ) : Container(
                child: Center(
                    child: CupertinoActivityIndicator(radius: 15.0)
                ),
            ),
        );
    }
}