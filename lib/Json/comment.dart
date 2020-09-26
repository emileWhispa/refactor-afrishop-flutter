import 'User.dart';

class Comment {
  String id;
  String content;
  String date;
  DateTime dateTime;
  User user;
  int likes;
  int replies;

  Comment.fromJson(Map<String, dynamic> json)
      : content = json['content'],
        user = User.fromJson2(json['userInfo'] ?? {}),
        replies = json['replies'],
        likes = json['likes'],
        id = json['id'],
        dateTime = DateTime.tryParse(json['date']),
        date = json['date'];
}
