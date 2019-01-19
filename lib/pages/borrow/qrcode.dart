import 'package:buddyapp/providers/helper.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:buddyapp/models/user.dart';

class BorrowQrCode extends StatefulWidget{

    BorrowQrCode({Key key, @required this.session, @required this.borrow, @required this.onCancel, @required this.onDownload}) : super(key : key);

    final User session;
    final Borrow borrow;
    final VoidCallback onCancel;
    final VoidCallback onDownload;

    @override
    State<StatefulWidget> createState() {
        return _BorrowQrCode();
    }
}

class _BorrowQrCode extends State<BorrowQrCode>{

    String qrData;

    @override
    void initState() {
        this.qrData = (this.widget.session.id == this.widget.borrow.user.id) ? "${this.widget.borrow.code}-borrower-${this.widget.borrow.user.username}-${HelperProvider().randomString(8)}" : "${this.widget.borrow.code}-owner-${this.widget.borrow.item.user.username}-${HelperProvider().randomString(8)}";
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Material(
            color: Color.fromRGBO(0, 0, 0, 0.7),
            child: Hero(
                tag: "qrcode",
                child: Container(
                    padding: EdgeInsets.fromLTRB(40.0, 140.0, 40.0, 140.0),
                    child: Container(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, right: 20.0, left: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                        ),
                        child: Stack(
                            children: <Widget>[
                                Column(
                                    children: <Widget>[
                                        Container(
                                            child: Container(
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 0.0),
                                                    child: Text(
                                                        "Borrow QR Code",
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
                                            padding: EdgeInsets.only(
                                                top: 10.0, bottom: 10.0),
                                            child: Container(
                                                child:  Center(
                                                    child: QrImage(
                                                        data: this.qrData
                                                    )
                                                )
                                            ),
                                        ),
                                        Center(
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                    Container(
                                                        padding: EdgeInsets.only(right: 25.0),
                                                        child: InkWell(
                                                            onTap: () => widget.onDownload(),
                                                            child: Text(
                                                                "DOWNLOAD".toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 15.0,
                                                                    color: Theme
                                                                        .of(context)
                                                                        .primaryColor
                                                                ),
                                                            )
                                                        )
                                                    ),
                                                    Container(
                                                        padding: EdgeInsets.only(right: 7.0),
                                                        child: InkWell(
                                                            onTap: () => widget.onCancel(),
                                                            child: Text(
                                                                "cancel".toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 15.0,
                                                                    color: Colors.redAccent
                                                                ),
                                                            )
                                                        )
                                                    ),
                                                ],
                                            )
                                        )
                                    ],
                                )
                            ],
                        )
                    ),
                ),
            )
        );
    }
}