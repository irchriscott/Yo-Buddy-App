import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:buddyapp/models/comment.dart';
import 'package:buddyapp/providers/helper.dart';
import 'package:buddyapp/UI/comment_action_sheet.dart';

class CommentListItem extends StatefulWidget{

    CommentListItem({
        Key key,
        @required this.comment,
        @required this.userID,
        @required this.scaffoldContext,
        @required this.onEdit,
        @required this.onDelete
    }):super(key:key);

    final Comment comment;
    final int userID;
    final BuildContext scaffoldContext;
    final VoidCallback onEdit;
    final VoidCallback onDelete;

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

    void showCommentBottomSheet(){
        showModalBottomSheet(
            context: context,
            builder: (builder){
                return CommentActionSheet(
                    comment: this.comment,
                    scaffoldContext: widget.scaffoldContext,
                    onEdit: () => this.widget.onEdit(),
                    onDelete: () => widget.onDelete(),
                );
            }
        );
    }

    @override
    Widget build(BuildContext context){
        return Container(
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(style: BorderStyle.solid, color: Color(0xFFDDDDDD), width: 0.5))
            ),
            padding: EdgeInsets.all(12.0),
            child: Row(
                children: <Widget>[
                    Container(
                        width: 45.0,
                        height: 45.0,
                        padding: EdgeInsets.only(right: 15.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                                style: BorderStyle.solid,
                                width: 2.0,
                                color: Color(0xFF999999)
                            ),
                            shape: BoxShape.circle,
                            color: Color(0xFF999999),
                            image: DecorationImage(
                                image: NetworkImage(this.comment.user.getImageURL),
                                fit: BoxFit.fill
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
                                        this.comment.user.name,
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
                                        this.comment.comment,
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
                                        HelperProvider().formatDateTime(this.comment.createdAt.toString()),
                                        style: TextStyle(
                                            color: Color(0xFF999999)
                                        ),
                                        overflow: TextOverflow.clip
                                    ),
                                )
                            ],
                        ),
                    ),
                    Container(
                        child: InkWell(
                            onTap: () => this.showCommentBottomSheet(),
                            child: Icon(Icons.more_vert, color: Color(0xFF666666)),
                        ),
                    )
                ],
            ),
        );
    }
}