import 'package:flutter/material.dart';
import 'dart:async';

class AppProvider{

    final String baseURL = "http://10.0.2.2:3000";

    Future<Null> alert(BuildContext context, String type, String message) async {
        return showDialog<Null>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
                return new AlertDialog(
                    title: new Text(type),
                    content: new SingleChildScrollView(
                        child: new ListBody(
                            children: <Widget>[
                                new Text(message),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        new FlatButton(
                            child: new Text("OK", 
                                style: TextStyle(
                                    color: Color(0xFFCC8400)
                                )
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                        ),
                    ],
                );
            },
        );
    }

    SnackBar showSnackBar(String message) {
        return SnackBar(
            content: new Text(message, style: TextStyle(fontSize: 16.0)),
            action: new SnackBarAction(
                label: 'Cancel'.toUpperCase(),
                onPressed: () {},
            ),
            duration: Duration(seconds: 3),
        );
    }
}