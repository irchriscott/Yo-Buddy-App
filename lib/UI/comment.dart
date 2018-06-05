import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/comment.dart';

class CommentListItem extends StatefulWidget{

    CommentListItem({Key key, @required this.comment, @required this.userID}):super(key:key);

    final Comment comment;
    final int userID;

    @override
    _CommentListItemState createState() => _CommentListItemState();
}

class _CommentListItemState extends State<CommentListItem>{

    Comment comment;
    @override
    void initState() {
        super.initState();
        this.comment = this.widget.comment;
    }

    @override
    Widget build(BuildContext context){
        return Container(
            child: Text(this.comment.comment),
        );
    }
}