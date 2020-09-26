
import 'package:afri_shop/Json/position.dart';

class Picture {
  String id;
  String image;
  bool isImage = true;
  int size;
  var _tagList;
  List<Position> _products;

  Picture.fromJson(Map<String, dynamic> json)
      : image = json['content'],
        id = json['id'],
  isImage = json['image'] ?? true,
        _products = _productList(json['contentTags']),
        _tagList = json['tagList'],
        size = json['size'];


  static List<Position> _productList(json) {
    Iterable map = json;
    return map != null ? map.map((f) => Position.fromJson(f)).toList() : [];
  }

  Map<String, dynamic> toJson() => {
    'content': image,
    'image': isImage,
    'size': size,
    "tagList":_tagList,
    'id': id,
  };
  List<Position> get products => _products ?? [];

}
