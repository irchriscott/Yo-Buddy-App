import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
    NotificationPage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _NotificationPageState createState() => new _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
    
  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        body: Center(
            child: Text(
                "Notifications",
                style: TextStyle(
                    fontSize: 30.0
                ),
            ),
        ),
    );
  }
}
