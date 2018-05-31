import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
    CategoriesPage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _CategoriesPageState createState() => new _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
    
  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
        body: Center(
            child: Text(
                "Categories",
                style: TextStyle(
                    fontSize: 30.0
                ),
            ),
        ),
    );
  }
}
