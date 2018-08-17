import 'package:flutter/material.dart';
import 'package:buddyapp/models/comment.dart';
import 'package:flutter/foundation.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/auth.dart';

class CommentActionSheet extends StatefulWidget{
    const CommentActionSheet({Key key, @required this.comment, @required this.scaffoldContext}):super(key: key);
    final Comment comment;
    final BuildContext scaffoldContext;
    @override
    _CommentActionSheetState createState() => _CommentActionSheetState();
}
class _CommentActionSheetState extends State<CommentActionSheet>{

    Comment comment;
    int userID;

    @override
    void initState(){
        super.initState();
        this.comment = widget.comment;
        this.getUserData();
    }

    void _setUserID(int id){
        this.userID = id;
    }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
    }

    void editComment(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Comment Edited"));
        Navigator.of(context).pop();
    }

    void deleteComment(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Comment Deleted"));
        Navigator.of(context).pop();
    }

    void reportComment(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Comment Reported"));
        Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context){
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)
                )
            ),
            height: 210.0,
            child: Column(
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Menu Comment", textAlign: TextAlign.left)
                    ),
                    ListTile(
                        leading: Icon(Icons.edit),
                        title: Text("Edit"),
                        enabled: (this.comment.user.id == this.userID),
                        onTap: () => this.editComment(),
                    ),
                    ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete"),
                        enabled: (this.comment.user.id == this.userID),
                        onTap: () => this.deleteComment(),
                    ),
                    ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("Report"),
                        onTap: (){}
                    )
                ],
            ),
        );
    }
}