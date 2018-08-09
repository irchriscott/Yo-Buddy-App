import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/category.dart';

class CategoriesSelectList extends StatefulWidget{

    CategoriesSelectList({Key key, @required this.categories, @required this.onChange}) : super(key : key);

    final List<Category> categories;
    final VoidCallback onChange;
    _CategoriesSelectList createState() => _CategoriesSelectList();
}

class _CategoriesSelectList extends State<CategoriesSelectList>{

    @override
    Widget build(BuildContext context) {
        return Material(
            color: Color.fromRGBO(0,0,0,0.7),
            child: Container(
                padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
                child: Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                    ),
                    child: (widget.categories.length > 0) ? ListView.builder(
                        itemBuilder: (BuildContext context, int i){
                            return Text(widget.categories[i].name);
                        },
                        itemCount: widget.categories.length,
                    ) : Container(),
                ),
            ),
        );
    }
}