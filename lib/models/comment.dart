import 'user.dart';

class Comment{
    final int id;
    final User user;
    final String comment;
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
}