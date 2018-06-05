import 'package:flutter/material.dart';

class RequestsPage extends StatefulWidget {
    RequestsPage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _RequestsPageState createState() => new _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
    
  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        body: Center(
            child: Text(
                "Requests",
                style: TextStyle(
                    fontSize: 30.0
                ),
            ),
        ),
    );
  }
}
