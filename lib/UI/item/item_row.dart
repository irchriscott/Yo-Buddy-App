import 'package:flutter/material.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:buddyapp/pages/session/lending.dart';

class ItemRow extends StatefulWidget{
    ItemRow({Key key, @required this.item}) : super(key : key);
    final Item item;
    @override
    _ItemRowState createState() => _ItemRowState();
}

class _ItemRowState extends State<ItemRow>{

    @override
    void initState() {
        super.initState();
    }

    void navigateToLending(){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) =>SessionLending(item: this.widget.item))
        );
    }

    @override
    Widget build(BuildContext context) {
        return InkWell(
            onTap: () => this.navigateToLending(),
            child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(style: BorderStyle.solid, color: Color(0xFFDDDDDD), width: 0.5))
                ),
                padding: EdgeInsets.all(15.0),
                child: Row(
                    children: <Widget>[
                        Container(
                            child: Container(
                                width: 85.0,
                                height: 85.0,
                                padding: EdgeInsets.only(right: 15.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(3.0),
                                    color: Color(0xFFDDDDDD),
                                    image: DecorationImage(
                                        image: NetworkImage(this.widget.item.images[0].imageUrl),
                                        fit: BoxFit.fitWidth
                                    )
                                )
                            ),
                        ),
                        Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                textDirection: TextDirection.ltr,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, bottom: 3.0, right: 10.0),
                                        child: Text(
                                            this.widget.item.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Color(0xFF333333),
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, right: 10.0),
                                        child: Text(
                                            "${this.widget.item.category.name} - ${this.widget.item.subcategory.name}",
                                            style: TextStyle(
                                                color: Color(0xFF666666),
                                                fontSize: 15.0,
                                                height: 0.8
                                            )
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, top: 4.0, right: 10.0),
                                        child: Container(
                                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                    Container(
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: <Widget>[
                                                                Container(
                                                                    child: Icon(IconData(0xf443, fontFamily: 'ionicon'), size: 20.0, color: Color(0xFF999999)),
                                                                    padding: EdgeInsets.only(right: 4.0),
                                                                ),
                                                                Text(
                                                                    this.widget.item.likes.count.toString(),
                                                                    style: TextStyle(
                                                                        fontSize: 14.0,
                                                                        color: Color(0xFF999999)
                                                                    )
                                                                )
                                                            ],
                                                        )
                                                    ),
                                                    Container(
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: <Widget>[
                                                                Container(
                                                                    child: Icon(IconData(0xf3fc, fontFamily: 'ionicon'), size: 20.0, color: Color(0xFF999999)),
                                                                    padding: EdgeInsets.only(left: 8.0, right: 4.0),
                                                                ),
                                                                Text(
                                                                    this.widget.item.comments.toString(),
                                                                    style: TextStyle(
                                                                        fontSize: 14.0,
                                                                        color: Color(0xFF999999)
                                                                    )
                                                                )
                                                            ],
                                                        )
                                                    ),
                                                    Container(
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: <Widget>[
                                                                Container(
                                                                    child: Icon(IconData(0xf3f8, fontFamily: 'ionicon'), size: 20.0, color: Color(0xFF999999)),
                                                                    padding: EdgeInsets.only(left: 8.0, right: 4.0),
                                                                ),
                                                                Text(
                                                                    this.widget.item.borrow.toString(),
                                                                    style: TextStyle(
                                                                        fontSize: 14.0,
                                                                        color: Color(0xFF999999)
                                                                    )
                                                                )
                                                            ],
                                                        )
                                                    ),
                                                ],
                                            ),
                                        ),
                                    )
                                ],
                            ),
                        ),
                    ],
                ),
            )
        );
    }
}