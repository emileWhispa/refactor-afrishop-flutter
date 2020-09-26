import 'package:afri_shop/Json/Product.dart';
import 'package:afri_shop/Json/hashtag.dart';
import 'package:afri_shop/Json/position.dart';

import 'Picture.dart';

import 'User.dart';

class Post {
  String id;
  int likes;
  int comments;
  String description;
  String title;
  String sharer;
  String date;
  User user;
  List<Picture> pictures;
  DateTime dateTime;

  bool liked =false;

  var _contentList;
  List<Position> products;
  List<Hashtag> hashtags;

  var _hashtags;

  Post.fromJson(Map<String, dynamic> json)
      : likes = json['likes'],
        comments = json['comments'],
        title = json['title'],
        sharer = json['sharer'],
        date = json['date'],
        dateTime = DateTime.tryParse(json['date']),
        liked = json['liked'] ?? false,
        user = json['user'] == null ? null : User.fromJson2(json['user']),
        description = json['description'],
        _contentList = json['contentList'],
        _hashtags = json['hashtags'],
        pictures = _list(json['contentList']),
        products = _list(json['contentList']).expand((f)=>f.products).toList(),
        hashtags = _listHash(json['hashtags']),
        id = json['id'];

  Map<String,dynamic> toJson()=>{
    "likes":likes,
    "comments":comments,
    "title":title,
    "date":date,
    "sharer":sharer,
    "liked":liked,
    "user":user?.toJson(),
    "description":description,
    "hashtags":_hashtags,
    "contentList":_contentList,
    "id":id,
  };

  static List<Picture> _list(json) {
    Iterable map = json;
    return map != null ? map.map((f) => Picture.fromJson(f)).toList() : [];
  }

  static List<Hashtag> _listHash(json) {
    Iterable map = json;
    return map != null ? map.map((f) => Hashtag.fromJson(f)).toList() : [];
  }


  String get username => user?.username ?? "-- name --";

  String get bigImage => pictures.isNotEmpty ? pictures.first.isImage ? pictures.first.image : "" : "";



  int get userId => user?.discoverId ?? 0;
}
