import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
    SearchPage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
    
  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        body: Center(
            child: Text(
                "Search",
                style: TextStyle(
                    fontSize: 30.0
                ),
            ),
        ),
    );
  }
}
