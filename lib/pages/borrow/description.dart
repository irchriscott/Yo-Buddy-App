import 'dart:async';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/user.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:html2md/html2md.dart' as html2md;

class BorrowDescription extends StatefulWidget{

    BorrowDescription({Key key, @required this.borrow, @required this.sessionToken, @required this.session}) : super(key : key);

    final Borrow borrow;
    final String sessionToken;
    final User session;

    @override
    State<StatefulWidget> createState() {
        return _BorrowDescriptionState();
    }

}

class _BorrowDescriptionState extends State<BorrowDescription>{
    
    Borrow borrow;
    String sessionToken;

    PushNotification pushNotification;

    @override
    void initState() {
        this.borrow = this.widget.borrow;
        this.sessionToken = this.widget.sessionToken;
        Timer(Duration(seconds: 2), (){
            this.borrow.getBorrow(this.sessionToken).then((response){
                setState((){ this.borrow = response; });
            });
        });
        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.widget.session, token: this.sessionToken, context: context);
            this.pushNotification.initNotification();
        }); });
        super.initState();
    }

    @override
    void dispose(){
        this.pushNotification.dispose();
        super.dispose();
    }

    Widget descriptionDataWidget(String key, String value){
        return Container(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Container(
                child: Row(
                    children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Text(
                                "$key : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0
                                ),
                            ),
                        ),
                        Container(
                            child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15.0
                                ),
                            ),
                        )
                    ],
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
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
                            title: Text("Borrow Item Description"),
                            centerTitle: true,
                            background: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                    Image(
                                        image: NetworkImage(AppProvider().baseURL + this.widget.borrow.item.images[0].image.path),
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
                                child: Container(
                                    padding: EdgeInsets.only(top: 18.0, right: 12.0),
                                    child: InkWell(
                                        onTap: () {
                                            Navigator.of(context).pop();
                                        },
                                        child: Text("Close".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 14.0)),
                                    ),
                                )
                            )
                        ],
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate(
                            <Widget>[
                                Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            this.descriptionDataWidget("ID", this.borrow.code.toString()),
                                            this.descriptionDataWidget("Owner", this.borrow.item.user.name),
                                            this.descriptionDataWidget("Borrower", this.borrow.user.name),
                                            this.descriptionDataWidget("Item", this.borrow.item.name),
                                            this.descriptionDataWidget("Category", "${this.borrow.item.category.name} - ${this.borrow.item.subcategory.name}"),
                                            this.descriptionDataWidget("Single Price", "${HelperProvider().formatPrice(this.borrow.price.toInt())} ${this.borrow.currency} / ${this.borrow.per}"),
                                            this.descriptionDataWidget("Number", "${this.borrow.numbers.toString()} ${this.borrow.per}s"),
                                            this.descriptionDataWidget("Quantity", "${this.borrow.count.toString()} Items"),
                                            this.descriptionDataWidget("Total", "${HelperProvider().formatPrice(this.borrow.total.toInt())} ${this.borrow.currency}"),
                                            this.descriptionDataWidget("From", HelperProvider().formatDateTimeString(this.borrow.fromDate)),
                                            this.descriptionDataWidget("To", HelperProvider().formatDateTimeString(this.borrow.toDate)),
                                            this.descriptionDataWidget("Status", this.borrow.status.replaceRange(0, 1, this.borrow.status[0].toUpperCase())),
                                            this.descriptionDataWidget("Request Date", HelperProvider().formatDateTimeString(this.borrow.createdAt)),
                                            Container(
                                                padding: EdgeInsets.only(bottom: 5.0),
                                                child: Container(
                                                    padding: EdgeInsets.only(right: 6.0),
                                                    child: Text(
                                                        "Reasons : ",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15.0
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(bottom: 5.0),
                                                child: Container(
                                                    child: Text(
                                                        (this.borrow.reasons != null && this.borrow.reasons != "") ? this.borrow.reasons : " - ",
                                                        style: TextStyle(
                                                            fontSize: 15.0
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(bottom: 5.0),
                                                child: Container(
                                                    padding: EdgeInsets.only(right: 6.0),
                                                    child: Text(
                                                        "Conditions : ",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15.0
                                                        ),
                                                    ),
                                                ),
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(bottom: 3.0),
                                                child: MarkdownBody(data: html2md.convert(this.borrow.conditions))
                                            )
                                        ],
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