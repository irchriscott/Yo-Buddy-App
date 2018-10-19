import 'dart:async';
import 'user.dart';
import 'response.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/net.dart' as net;

class Comment{
    final int id;
    final User user;
    String comment;
    final DateTime createdAt;

    Comment({this.id, this.user, this.comment, this.createdAt});

    factory Comment.fromJson(Map<String, dynamic>json){
        return new Comment( 
            id: json['id'],
            user: User.fromJson(json['user']),
            comment: json['comment'],
            createdAt: DateTime.parse(json['created_at'])
        );
    }

    List<Comment> getCommentsList(dynamic json){
        if(json != null){
            List data = json.toList();
            List<Comment> comments = List<Comment>();
            data.forEach((comment){
                comments.add(Comment.fromJson(comment));
            });
            return comments;
        }
        return [];
    }


    Future<ResponseService> postComment(Comment comment, String itemID, String sessionToken) async{
        return net.NetworkUtil().post(
            Uri.encodeFull(AppProvider().baseURL + "/item/" + itemID + "/comment/create.json?token=" + sessionToken),
            body: {
                "comment[user_id]": comment.user.id.toString(),
                "comment[comment]": comment.comment,
                "comment[is_deleted]": 0.toString()
            }
        ).then((response){
            return ResponseService.fromJson(response);
        });
    }

    Future<ResponseService> updateComment(String itemID, String sessionToken) async{
        return net.NetworkUtil().post(
            Uri.encodeFull(AppProvider().baseURL + "/item/$itemID/comment/${this.id.toString()}/update.json?token=" + sessionToken),
            body: {
                "comment[user_id]": this.user.id.toString(),
                "comment[comment]": this.comment,
                "comment[is_deleted]": 0.toString(),
                "_method": "patch"
            }
        ).then((response){
            return ResponseService.fromJson(response);
        });
    }

    Future<ResponseService> deleteComment(String itemID, String sessionToken) async{
        return net.NetworkUtil().post(
            Uri.encodeFull(AppProvider().baseURL + "/item/$itemID/comment/${this.id.toString()}/delete.json?token=$sessionToken"),
            body: { "comment[comment_id]": this.id.toString(), "_method": "delete" }
        ).then((response){
            return ResponseService.fromJson(response);
        });
    }
}