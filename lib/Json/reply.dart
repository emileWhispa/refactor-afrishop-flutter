import 'package:afri_shop/Json/User.dart';

class Reply {
  String id;
  String content;
  User user;

  Reply.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        content = json['content'],
        user = User.fromJson2(json['userInfo'] ?? {});
}
