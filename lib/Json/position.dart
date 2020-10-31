import 'Product.dart';

class Position {
  final double x;
  final double y;
  final Product product;
  String tagName;

  Position(this.x, this.y, this.tagName, this.product);

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
        "tagName": tagName,
        "item": product.toJson2(),
      };

  Position.fromJson(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'],
        tagName = json['tag']['tagName'],
        product =  Product.fromJson(json['tag']['item']);

  Position.fromJson2(Map<String, dynamic> json)
      : x = json['x'],
        y = json['y'],
        tagName = json['tagName'],
        product = Product.fromJson(json['item']);

  String get getTagName => tagName ?? product?.title ?? "";
}
