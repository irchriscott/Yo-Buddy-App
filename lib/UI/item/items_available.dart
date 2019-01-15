import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/models/utils.dart';

class ItemsAvailable extends StatefulWidget{

    ItemsAvailable({Key key, this.item, this.onClose}) : super(key : key);

    final Item item;
    final VoidCallback onClose;

    @override
    State<StatefulWidget> createState() {
        return _ItemsAvailableState();
    }
}

class _ItemsAvailableState extends State<ItemsAvailable>{

    List<Available> itemAvailable = [];
    List<TableRow> availableWidgets = [];

    final EdgeInsets cellPadding = EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 10.0);
    final BoxDecoration rowDecoration = BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.3), width: 0.2)));

    @override
    void initState() {
        super.initState();
        this.getItemAvailable();
    }

    Future<List<Available>> getItemAvailable(){
        return Available().getItemAvailable(widget.item).then((response) {
            setState((){
                this.itemAvailable = response.toList();
                this.availableWidgets.add(
                    TableRow(
                        children: <Widget>[
                            Container(padding: cellPadding, child: Text("From Date", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            Container(padding: cellPadding, child: Text("To Date", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                            Container(padding: cellPadding, child: Text("Items", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))
                        ],
                        decoration: rowDecoration
                    )
                );
                this.itemAvailable.forEach((available) =>
                    this.availableWidgets.add(
                        TableRow(
                            children: <Widget>[
                                Container(padding: cellPadding, child: Text(available.from, textAlign: TextAlign.center)),
                                Container(padding: cellPadding, child: Text(available.to, textAlign: TextAlign.center)),
                                Container(padding: cellPadding, child: Text(available.count.toString(), textAlign: TextAlign.center))
                            ],
                            decoration: rowDecoration
                        )
                    )
                );
            });
        });
        return null;
    }

    @override
    Widget build(BuildContext context) {
        return new Material(
            color: Color.fromRGBO(0,0,0,0.7),
            child: (this.itemAvailable.length > 0) ? Hero(
                tag: "showavails",
                child: Container(
                    padding: EdgeInsets.fromLTRB(20.0, 130.0, 20.0, 130.0),
                    child: Container(
                        padding: EdgeInsets.only(top: 30.0, bottom: 30.0, right: 20.0, left: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                        ),
                        child: Stack(
                            children: <Widget>[
                                Container(
                                    height: 30.0,
                                    child: Center(
                                        child: Container(
                                            child: Text(
                                                "Available Dates",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18.0
                                                )
                                            ),
                                        ),
                                    )
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 30.0, bottom: 30.0),
                                    child: ListView(
                                        children: <Widget>[
                                            Table(children: this.availableWidgets)
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
            ) :  Container(
                child: Center(
                    child: CupertinoActivityIndicator(radius: 15.0)
                ),
            ),
        );
    }
}