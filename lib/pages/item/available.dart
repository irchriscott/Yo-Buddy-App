import 'dart:async';
import 'package:buddyapp/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/models/utils.dart';

class ItemsAvailablePage extends StatefulWidget{

    ItemsAvailablePage({Key key, this.item}) : super(key : key);

    final Item item;

    @override
    State<StatefulWidget> createState() {
        return _ItemsAvailableStatePage();
    }
}

class _ItemsAvailableStatePage extends State<ItemsAvailablePage>{

    List<Available> itemAvailable = [];
    List<TableRow> availableWidgets = [];

    final EdgeInsets cellPadding = EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 10.0);
    final BoxDecoration rowDecoration = BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.3), width: 0.2)));

    @override
    void initState() {
        super.initState();
        this.getItemAvailable();
    }

    void onClose(){
        Navigator.of(context).pop();
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
        return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
                slivers: <Widget>[
                    SliverAppBar(
                        expandedHeight: 200.0,
                        pinned: true,
                        floating: false,
                        snap: false,
                        leading: IconButton(
                            onPressed: (){
                                Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close, color: Colors.white)
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                            title: Text("Available Dates"),
                            centerTitle: true,
                            background: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                    Image(
                                        image: NetworkImage(AppProvider().baseURL + this.widget.item.images[0].image.path),
                                        fit: BoxFit.fitWidth,
                                        height: 200.0,
                                    ),
                                    DecoratedBox(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment(0.0, -1.0),
                                                end: Alignment(0.0, -0.4),
                                                colors: <Color>[const Color(0x90000000), const Color(0x00000000)],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        actions: <Widget>[
                            Container(
                                padding: EdgeInsets.only(top: 18.0, right: 12.0),
                                child: InkWell(
                                    onTap: () => this.onClose(),
                                    child: Text("Ok".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 14.0)),
                                ),
                            )
                        ],
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate(
                            <Widget>[
                                Container(
                                    child: (this.itemAvailable.length > 0) ? Container(
                                        padding: EdgeInsets.only(top: 0.0, bottom: 30.0),
                                        child: Column(
                                            children: <Widget>[
                                                Table(children: this.availableWidgets)
                                            ],
                                        ),
                                    ) : Container(
                                        padding: EdgeInsets.only(top: 100.0),
                                        child: Center(
                                            child: Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: CircularProgressIndicator(
                                                    backgroundColor: Color(0xFFCC8400),
                                                    strokeWidth: 2.0,
                                                ),
                                            )
                                        ),
                                    )
                                )
                            ]
                        )
                    )
                ],
            )
        );
    }
}