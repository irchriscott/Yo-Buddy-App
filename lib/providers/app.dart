import 'package:flutter/material.dart';
import 'dart:async';

class AppProvider{

    final String baseURL = "http://192.168.43.214:3000";
    final String defaultImage = "http://192.168.43.214:3000/assets/default.jpg";
    final String socketURL = "http://192.168.43.214:5000";

    Future<Null> alert(BuildContext context, String type, String message) async {
        return showDialog<Null>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
                return new AlertDialog(
                    title: new Text(type, style: TextStyle(fontWeight: FontWeight.bold)),
                    content: new SingleChildScrollView(
                        child: new ListBody(
                            children: <Widget>[
                                new Text(message),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        new FlatButton(
                            child: new Text(
                                "OK", 
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
            content: new Text(message, style: TextStyle(fontSize: 16.0, fontFamily: 'popins')),
            action: new SnackBarAction(
                label: 'Cancel'.toUpperCase(),
                onPressed: () {},
            ),
            duration: Duration(seconds: 3),
        );
    }
}