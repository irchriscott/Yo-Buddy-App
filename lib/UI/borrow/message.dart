import 'package:buddyapp/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/helper.dart';

class BorrowMessageLayout extends StatefulWidget{

    BorrowMessageLayout({
        Key key,
        @required this.borrow,
        @required this.message,
        @required this.session,
        @required this.onViewImages
    }) : super(key : key);

    final Borrow borrow;
    final BorrowMessage message;
    final User session;
    final VoidCallback onViewImages;

    @override
    _BorrowMessageLayoutState createState() => _BorrowMessageLayoutState();
}

class _BorrowMessageLayoutState extends State<BorrowMessageLayout>{

    @override
    void initState() {
        super.initState();
    }

    String getAdminMessage(String message){
        if(message == "new"){
            return (this.widget.borrow.user.id == this.widget.session.id) ? "Borrow Request Sent" : "Borrow Request Received";
        } else if (message.contains("extension_request")){
            if(message.contains("rejected")){
                return "Borrow Extension Request Rejected";
            } else if(message.contains("canceled")){
                return "Borrow Extension Request Canceled";
            } else {
                return "Borrow Item Extended For ${message.split("_").last} ${this.widget.borrow.per}s";
            }
        } else {
            return this.widget.message.adminMessage;
        }
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            child: (this.widget.message.type == "admin") ? Container(
                padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 76.0, right: 76.0),
                child: SizedBox(
                    child: Container(
                        padding: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                            color: Color(0xFF90EE90),
                            borderRadius: BorderRadius.all(Radius.circular(35.0)),
                            boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0
                                ),
                            ]
                        ),
                        child: Center(
                            child: Column(
                                children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.only(bottom: 5.0),
                                        child: Center(
                                            child: Text(
                                                HelperProvider().formatDateTime(this.widget.message.createdAt),
                                                style: TextStyle(
                                                    color: Color(0xFF666666),
                                                    fontSize: 15.0
                                                ),
                                            ),
                                        ),
                                    ),
                                    Container(
                                        child: (this.widget.message.message.contains("extension_request_sent")) ? Container(
                                            child: (this.widget.borrow.item.user.id == this.widget.session.id) ? Container(
                                                child: Column(
                                                    children: <Widget>[
                                                        Center(
                                                            child: Container(
                                                                child: Text(
                                                                    "Borrow Extension Request Sent",
                                                                    style: TextStyle(
                                                                        color: Color(0xFF333333),
                                                                        fontSize: 17.0,
                                                                        height: 0.7
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                ),
                                                            )
                                                        ),
                                                        Row(
                                                            children: <Widget>[],
                                                        )
                                                    ],
                                                )
                                            ) : Center(
                                                child: Container(
                                                    child: Text(
                                                        "Borrow Extension Request Sent",
                                                        style: TextStyle(
                                                            color: Color(0xFF333333),
                                                            fontSize: 17.0,
                                                            height: 0.7
                                                        ),
                                                        textAlign: TextAlign.center,
                                                    ),
                                                )
                                            ),
                                        ): Center(
                                            child: Container(
                                                child: Text(
                                                    this.getAdminMessage(this.widget.message.message),
                                                    style: TextStyle(
                                                        color: Color(0xFF333333),
                                                        fontSize: 17.0,
                                                        height: 0.7
                                                    ),
                                                    textAlign: TextAlign.center,
                                                ),
                                            )
                                        ),
                                    )
                                ],
                            ),
                        ),
                    ),
                ),
            ) : Container(
                child: (this.widget.message.sender.id == this.widget.session.id) ? Container(
                    child: Stack(
                        children: <Widget>[
                            Row(
                                children: <Widget>[
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[
                                                SizedBox(
                                                    child: Container(
                                                        padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 50.0, right: 35.0),
                                                        child: Container(
                                                            padding: EdgeInsets.all(6.0),
                                                            decoration: BoxDecoration(
                                                                color: Color(0xFFCC8400),
                                                                borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                                                boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors.grey,
                                                                        blurRadius: 5.0
                                                                    ),
                                                                ]
                                                            ),
                                                            child: Column(
                                                                children: <Widget>[
                                                                    Container(
                                                                        padding: EdgeInsets.only(left: 13.0, right: 13.0, top: 2.0),
                                                                        child: (this.widget.message.hasImages == true) ? Container(
                                                                            child: Stack(
                                                                                children: <Widget>[
                                                                                    Container(
                                                                                        padding: EdgeInsets.only(top: 8.0),
                                                                                        width: MediaQuery.of(context).size.width,
                                                                                        child: Hero(
                                                                                            tag: this.widget.message.images[0].image.path,
                                                                                            child: InkWell(
                                                                                                onTap: () => widget.onViewImages(),
                                                                                                child: Image(
                                                                                                    image: NetworkImage(AppProvider().baseURL + this.widget.message.images[0].image.path),
                                                                                                    fit: BoxFit.fill
                                                                                                )
                                                                                            )
                                                                                        )
                                                                                    ),
                                                                                    Positioned(
                                                                                        bottom: 6.0,
                                                                                        right: 6.0,
                                                                                        child: Container(
                                                                                            decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                                                color: Color.fromRGBO(0,0,0,0.7)
                                                                                            ),
                                                                                            child: Container(
                                                                                                padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 14.0, right: 14.0),
                                                                                                child: Text(
                                                                                                    "+ ${this.widget.message.images.length - 1}",
                                                                                                    style: TextStyle(
                                                                                                        color: Colors.white,
                                                                                                        fontSize: 17.0,
                                                                                                        fontWeight: FontWeight.w700
                                                                                                    ),
                                                                                                )
                                                                                            )
                                                                                        )
                                                                                    )
                                                                                ],
                                                                            )
                                                                        ) : Text(
                                                                            this.widget.message.message,
                                                                            style: TextStyle(
                                                                                color: Color(0xFFFFFFFF),
                                                                                fontSize: 17.0,
                                                                            ),
                                                                        ),
                                                                    ),
                                                                    Container(
                                                                        padding: EdgeInsets.only(left: 13.0, right: 13.0, bottom: 2.0),
                                                                        child: Text(
                                                                            HelperProvider().formatDateTime(this.widget.message.createdAt),
                                                                            style: TextStyle(
                                                                                color: Colors.white70,
                                                                                fontSize: 15.0,
                                                                            ),
                                                                            textAlign: TextAlign.right,
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                        ),
                                                    ),
                                                )
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                            Positioned(
                                bottom: 6.0,
                                right: 5.0,
                                child: Container(
                                    width: 25.0,
                                    height: 25.0,
                                    padding: EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            style: BorderStyle.solid,
                                            width: 2.0,
                                            color: Color(0xFF999999)
                                        ),
                                        shape: BoxShape.circle,
                                        color: Color(0xFF999999),
                                        image: DecorationImage(
                                            image: NetworkImage(this.widget.message.sender.getImageURL),
                                            fit: BoxFit.fill
                                        )
                                    )
                                ),
                            )
                        ],
                    ),
                ) : Container(
                    child: Stack(
                        children: <Widget>[
                            Row(
                                children: <Widget>[
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                                Container(
                                                    padding: EdgeInsets.only(top: 6.0, bottom: 6.0, right: 50.0, left: 35.0),
                                                    child: Container(
                                                        padding: EdgeInsets.all(6.0),
                                                        decoration: BoxDecoration(
                                                            color: Color(0xFFDDDDDD),
                                                            borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                                            boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors.grey,
                                                                    blurRadius: 5.0
                                                                ),
                                                            ]
                                                        ),
                                                        child: Column(
                                                            children: <Widget>[
                                                                Container(
                                                                    padding: EdgeInsets.only(left: 13.0, right: 13.0, top: 2.0),
                                                                    child: (this.widget.message.hasImages == true) ? Container(
                                                                        child: Stack(
                                                                            children: <Widget>[
                                                                                Container(
                                                                                    padding: EdgeInsets.only(top: 8.0),
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    child: Hero(
                                                                                        tag: this.widget.message.images[0].image.path,
                                                                                        child: InkWell(
                                                                                            onTap: () => widget.onViewImages(),
                                                                                            child: Image(
                                                                                                image: NetworkImage(AppProvider().baseURL + this.widget.message.images[0].image.path),
                                                                                                fit: BoxFit.fill
                                                                                            )
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                Positioned(
                                                                                    bottom: 6.0,
                                                                                    left: 6.0,
                                                                                    child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(4.0),
                                                                                            color: Color.fromRGBO(0,0,0,0.7)
                                                                                        ),
                                                                                        child: Container(
                                                                                            padding: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 14.0, right: 14.0),
                                                                                            child: Text(
                                                                                                "+ ${this.widget.message.images.length - 1}",
                                                                                                style: TextStyle(
                                                                                                    color: Colors.white,
                                                                                                    fontSize: 17.0,
                                                                                                    fontWeight: FontWeight.w700
                                                                                                ),
                                                                                            )
                                                                                        )
                                                                                    )
                                                                                )
                                                                            ],
                                                                        )
                                                                    ) : Text(
                                                                        this.widget.message.message,
                                                                        style: TextStyle(
                                                                            color: Color(0xFF333333),
                                                                            fontSize: 17.0
                                                                        ),
                                                                        textAlign: TextAlign.start,
                                                                    ),
                                                                ),
                                                                Container(
                                                                    padding: EdgeInsets.only(left: 13.0, right: 13.0, bottom: 2.0),
                                                                    child: Text(
                                                                        HelperProvider().formatDateTime(this.widget.message.createdAt),
                                                                        style: TextStyle(
                                                                            color: Color(0xFF666666),
                                                                            fontSize: 15.0
                                                                        ),
                                                                        textAlign: TextAlign.left,
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                            Positioned(
                                bottom: 6.0,
                                left: 5.0,
                                child: Container(
                                    width: 25.0,
                                    height: 25.0,
                                    padding: EdgeInsets.only(right: 10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            style: BorderStyle.solid,
                                            width: 2.0,
                                            color: Color(0xFF999999)
                                        ),
                                        shape: BoxShape.circle,
                                        color: Color(0xFF999999),
                                        image: DecorationImage(
                                            image: NetworkImage(this.widget.message.sender.getImageURL),
                                            fit: BoxFit.fill
                                        )
                                    )
                                ),
                            )
                        ],
                    ),
                ),
            ),
        );
    }
}