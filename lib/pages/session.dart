import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget {
    SessionPage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _SessionPageState createState() => new _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
    
  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        body: Center(
            child: Text(
                "Session",
                style: TextStyle(
                    fontSize: 30.0
                ),
            ),
        ),
    );
  }
}
