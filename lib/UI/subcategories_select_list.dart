import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:buddyapp/models/category.dart';

class SubcategoriesSelectList extends StatefulWidget{

    SubcategoriesSelectList({Key key, @required this.subcategories, @required this.onClose}) : super(key : key);

    final List<Widget> subcategories;
    final VoidCallback onClose;
    _SubcategoriesSelectListState createState() => _SubcategoriesSelectListState();
}

class _SubcategoriesSelectListState extends State<SubcategoriesSelectList>{

    int categoryGroupValue;

    @override
    Widget build(BuildContext context) {
        return Material(
            color: Color.fromRGBO(0,0,0,0.7),
            child: Hero(
                tag: "showsubcat",
                child: Container(
                    padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
                    child: Container(
                        padding: EdgeInsets.only(top: 30.0, bottom: 30.0, right: 10.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                        ),
                        child: Stack(
                            children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(left: 30.0),
                                    child: Text(
                                        "Select Item Subcategory : ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0
                                        )
                                    ),
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
                                    child: ListView(
                                        children: <Widget>[
                                            Column(children: widget.subcategories)
                                        ],
                                    ),
                                ),
                                Positioned(
                                    bottom: 0.0,
                                    right: 30.0,
                                    child: InkWell(
                                        onTap: () => widget.onClose(),
                                        child: Text(
                                            "OK".toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                color: Theme.of(context).primaryColor
                                            ),
                                        )
                                    )
                                ),
                            ],
                        )
                    ),
                ),
            ),
        );
    }
}