import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:buddyapp/models/comment.dart';

class EditComment extends StatefulWidget {

    EditComment({
        Key key,
        @required this.comment,
        @required this.onUpdate,
        @required this.onClose,
        @required this.commentCtrl
    }): super(key : key);

    final VoidCallback onClose;
    final VoidCallback onUpdate;
    final Comment comment;
    final TextEditingController commentCtrl;

    _EditCommentState createState() => _EditCommentState();
}

class _EditCommentState extends State<EditComment>{

    @override
    void initState() {
        this.widget.commentCtrl.text = widget.comment.comment;
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return new Material(
            color: Color.fromRGBO(0,0,0,0.7),
            child: (this.widget.comment != null) ? Hero(
                tag: "editcomment",
                child: Container(
                    padding: EdgeInsets.fromLTRB(20.0, 237.0, 20.0, 237.0),
                    child: Container(
                        padding: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 20.0, left: 20.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                        ),
                        child: Stack(
                            children: <Widget>[
                                Container(
                                    child: Container(
                                        child: Container(
                                            padding: EdgeInsets.only(bottom: 20.0),
                                            child: Text(
                                                "Edit Comment",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0
                                                )
                                            ),
                                        ),
                                    )
                                ),
                                Container(
                                    padding: EdgeInsets.only(top: 45.0, bottom: 30.0),
                                    child: Container(
                                        child: TextFormField(
                                            autofocus: false,
                                            controller: widget.commentCtrl,
                                            maxLines: 3,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                                hintText: 'Enter Comment',
                                                contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                                hintStyle: TextStyle(color: Color(0x99999999)),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4.0)
                                                )
                                            ),
                                            keyboardType: TextInputType.multiline,
                                            autovalidate: true,
                                            autocorrect: true
                                        )
                                    ),
                                ),
                                Positioned(
                                    bottom: 0.0,
                                    right: 80.0,
                                    child: InkWell(
                                        onTap: () => widget.onClose(),
                                        child: Text(
                                            "Cancel".toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                color: Colors.redAccent
                                            ),
                                        )
                                    )
                                ),
                                Positioned(
                                    bottom: 0.0,
                                    right: 0.0,
                                    child: InkWell(
                                        onTap: () => widget.onUpdate(),
                                        child: Text(
                                            "Update".toUpperCase(),
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