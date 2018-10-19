import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:buddyapp/pages/borrow_messages.dart';

class BorrowItem extends StatefulWidget{
    BorrowItem({Key key, @required this.borrow, @required this.session}) : super(key : key);
    final Borrow borrow;
    final User session;
    @override
    _BorrowItemState createState() => _BorrowItemState();
}

class _BorrowItemState extends State<BorrowItem>{

    @override
    void initState() {
        super.initState();
    }

    void redirectSingleBorrow(){
        Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => BorrowMessages(borrow: this.widget.borrow))
        );
    }

    @override
    Widget build(BuildContext context) {
        return InkWell(
            onTap: () => this.redirectSingleBorrow(),
            child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(style: BorderStyle.solid, color: Color(0xFFDDDDDD), width: 0.5))
                ),
                padding: EdgeInsets.all(15.0),
                child: Row(
                    children: <Widget>[
                        Container(
                            width: 75.0,
                            height: 85.0,
                            padding: EdgeInsets.only(right: 15.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 1.0,
                                    color: Color(0xFF999999)
                                ),
                                color: Color(0xFF999999),
                                image: DecorationImage(
                                    image: NetworkImage(this.widget.borrow.item.images[0].imageUrl),
                                    fit: BoxFit.fitWidth
                                )
                            )
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
                                            this.widget.borrow.item.name,
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
                                            "by ${this.widget.borrow.item.user.name}",
                                            style: TextStyle(
                                                color: Color(0xFF666666),
                                                fontSize: 16.0,
                                                height: 0.8
                                            )
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, top: 2.0, right: 10.0),
                                        child: Text(
                                            "From ${HelperProvider().formatDateTimeString(this.widget.borrow.fromDate)}",
                                            style: TextStyle(
                                                color: Color(0xFF999999)
                                            ),
                                            overflow: TextOverflow.clip
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, top: 2.0, right: 10.0),
                                        child: Text(
                                            "To ${HelperProvider().formatDateTimeString(this.widget.borrow.toDate)}",
                                            style: TextStyle(
                                                color: Color(0xFF999999)
                                            ),
                                            overflow: TextOverflow.clip
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        Container(
                            child: InkWell(
                                onTap: () {},
                                child: Icon(IconData(0xf21b, fontFamily: 'ionicon'), color: this.widget.borrow.borrowColor(), size: 15.0),
                            ),
                        )
                    ],
                ),
            )
        );
    }
}