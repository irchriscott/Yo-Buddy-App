import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:buddyapp/pages/borrow/borrow_messages.dart';

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
            onLongPress: (){},
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
                                        image: (this.widget.borrow.item.user.id == this.widget.session.id) ? NetworkImage(this.widget.borrow.user.getImageURL) : NetworkImage(this.widget.borrow.item.images[0].imageUrl),
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
                                            (this.widget.borrow.item.user.id == this.widget.session.id) ? this.widget.borrow.user.name : this.widget.borrow.item.name,
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
                                            (this.widget.borrow.item.user.id == this.widget.session.id) ? "Status - ${this.widget.borrow.status.replaceRange(0, 1, this.widget.borrow.status[0].toUpperCase())}" : "by ${this.widget.borrow.item.user.name}",
                                            style: TextStyle(
                                                color: Color(0xFF666666),
                                                fontSize: 15.0,
                                                height: 0.8
                                            )
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, top: 2.0, right: 10.0),
                                        child: Text(
                                            "From ${HelperProvider().formatDateTimeString(this.widget.borrow.fromDate)}",
                                            style: TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 13.0
                                            ),
                                            overflow: TextOverflow.clip
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(left: 15.0, top: 2.0, right: 10.0),
                                        child: Text(
                                            "To ${HelperProvider().formatDateTimeString(this.widget.borrow.toDate)}",
                                            style: TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 13.0
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