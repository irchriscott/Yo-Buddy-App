import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/utils.dart';

class CurrenciesSelectList extends StatefulWidget{

    CurrenciesSelectList({Key key, @required this.currencies, @required this.onClose}) : super(key : key);

    final List<Widget> currencies;
    final VoidCallback onClose;
    _CurrenciesSelectList createState() => _CurrenciesSelectList();
}

class _CurrenciesSelectList extends State<CurrenciesSelectList>{

    int categoryGroupValue;

    @override
    Widget build(BuildContext context) {
        return Material(
            color: Color.fromRGBO(0,0,0,0.7),
            child: Hero(
                tag: "showcurrencies",
                child: Container(
                    padding: EdgeInsets.fromLTRB(20.0, 170.0, 20.0, 170.0),
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
                                        "Select Item Price Currency : ",
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
                                            Column(children: widget.currencies)
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