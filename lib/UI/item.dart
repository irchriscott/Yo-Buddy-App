import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../providers/app.dart';
import 'package:intl/intl.dart';

class ItemPage extends StatefulWidget{
    const ItemPage({Key key, @required this.item}): super(key:key);
    final Item item;
    @override
    _ItemPageState createState() => _ItemPageState();
}
class _ItemPageState extends State<ItemPage>{

    Item item;

    @override
    void initState(){
        super.initState();
        this.item = widget.item; 
    }

    @override
    Widget build(BuildContext context){
        return Stack(
            children: <Widget>[
                Container(
                    child: InkWell(
                        onDoubleTap: (){},
                        onLongPress: (){},
                        onTap: (){},
                        child: Card(
                            child: Container(
                                child: Column(
                                    children: <Widget>[
                                        Container(
                                            child: Image.network(AppProvider().baseURL + this.item.images[0].image.path),
                                        )
                                    ],
                                ),
                            )
                        ),
                    ),
                ),
                Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Container(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        width: 170.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: Colors.black45, 
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                Icon(
                                    Icons.local_offer,
                                    color: Colors.white
                                ),
                                Padding(padding: EdgeInsets.only(left: 8.0)),
                                Text(NumberFormat.compact().format(this.item.price), style: TextStyle(color: Colors.white)),
                                Padding(padding: EdgeInsets.only(left: 8.0)),
                                Text(this.item.currency),
                                Padding(padding: EdgeInsets.only(left: 8.0)),
                                Text("/", style: TextStyle(color: Colors.white)),
                                Padding(padding: EdgeInsets.only(left: 8.0)),
                                Text(this.item.per, style: TextStyle(color: Colors.white))
                            ],
                        )
                    ),
                ),
            ],
        );
    }
}