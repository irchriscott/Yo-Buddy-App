import 'package:flutter/material.dart';
import 'package:buddyapp/models/comment.dart';
import 'package:flutter/foundation.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/auth.dart';

class CommentActionSheet extends StatefulWidget{

    const CommentActionSheet({
        Key key,
        @required this.comment,
        @required this.scaffoldContext,
        @required this.onEdit,
        @required this.onDelete
    }):super(key: key);

    final Comment comment;
    final BuildContext scaffoldContext;
    final VoidCallback onEdit;
    final VoidCallback onDelete;

    @override
    _CommentActionSheetState createState() => _CommentActionSheetState();
}
class _CommentActionSheetState extends State<CommentActionSheet>{

    Comment comment;
    int userID;

    @override
    void initState(){
        this.comment = widget.comment;
        this.getUserData();
        super.initState();
    }

    void _setUserID(int id){ this.userID = id; }

    void getUserData(){ Authentication().getSessionUser().then((value) => _setUserID(value.id)); }

    void popNavigator(){ Navigator.of(context).pop(); }

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
                        onTap: () {
                            this.widget.onEdit();
                            this.popNavigator();
                        }
                    ),
                    ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete"),
                        enabled: (this.comment.user.id == this.userID),
                        onTap: () {
                            this.widget.onDelete();
                            this.popNavigator();
                        }
                    ),
                    ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("Report"),
                        onTap: () => this.popNavigator(),
                    )
                ],
            ),
        );
    }
}