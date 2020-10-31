import 'package:afri_shop/Json/Sku.dart';
import 'package:afri_shop/Json/option.dart';
import 'package:sqflite/sqflite.dart';

import 'Review.dart';

class Product {
  final String title;
  final String url;
  double discountPrice;
  int totalScore = 0;
  double _price;
  String size;
  String itemSku;
   int count;
  int items = 1;
  String itemId;
  List<String> images;
  bool selected = false;
  List<ProductInfo> infos = [];
  List<String> images2;


  String fromCode;

  Product(this._price, this.title, this.url, this.count, this.itemSku,
      this.itemId, this.discountPrice,this.items,this.totalScore);

  Product.fromJson(Map<String, dynamic> json, {Iterable det,Iterable options,Iterable params,Map<String, dynamic> desc})
      : title = json['itemName'],
        count = json['itemCount'],
        itemId = json['itemId'],
        itemSku = json['itemSku'],
        discountPrice = json['discountPrice'],
        _price = json['itemPrice'],
        fromCode = json['fromCode'],
        totalScore = json['totalScore'] ?? 0,
        sku = getSku(det),
        options = getOptions(options),
        url = getImg(json['itemImg']),
        infos = getInfo(params),
        images2 = desc == null ? [] : parse(desc['itemDesc']),
        images = getImages(json['itemImg']);

  static List<ProductInfo> getInfo(Iterable iterable) {
    if (iterable == null) return [];
    return iterable.map((f) => ProductInfo.fromJson(f)).toList();
  }

  static List<String> parse(String data) {
    RegExp exp = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(data);
    var list = <String>[];

    matches.forEach((match) {
      var https = data.substring(match.start, match.end);
      if( https.contains("https:") || https.contains("http:") ){
        list.add(https);
      }
    });
    return list;
  }

  double get total => items * price;

  double get price => discountPrice ?? _price ?? 0.0;

  set price(double price){
    this.discountPrice = price;
    this._price = price;
  }

  double get oldPrice => _price;

  bool get hasOldPrice => _price != null;

  static String getImg(String chunk) {
    var list = (chunk ?? "").split(";");
    return list.isNotEmpty ? list.first : "";
  }

  static List<String> getImages(String chunk) => (chunk ?? "").split(";");

  Map<String, dynamic> toJson() => {
        "itemId": itemId,
        "itemImg": (images ?? []).join(";"),
        "itemSku": itemSku,
        "discountPrice": price,
        "itemCount": count,
        "fromCode": fromCode,
        "itemName": title
      };

  Map<String, dynamic> toJson2() => {
        "itemId": itemId,
        "itemImg": (images ?? []).join(";"),
        "itemSku": itemSku,
        "discountPrice": price,
        "itemCount": count,
        "itemName": title
      };

  static List<Sku> getSku(Iterable iterable) {
    if (iterable == null) return [];
    return iterable.map((f) => Sku.fromJson(f)).toList();
  }

  static List<Option> getOptions(Iterable iterable) {
    if (iterable == null) return [];
    return iterable.map((f) => Option.fromJson(f)).toList();
  }

  Product.fromDb(Map<String, dynamic> json)
      : title = json['title'],
        count = json['count'],
        itemId = json['itemId'],
        items = json['items'],
        discountPrice = json['discountPrice'],
        size = json['size'],
        _price = json['price'],
        url = json['url'];

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<Product>> itemList(Database db,
      {int limit: 50, int offset: 1, String append: "", String search}) async {
    // Get a reference to the database.\
    if (db == null || !db.isOpen) return [];

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = (await db.query('cart',
            limit: limit,
            offset: limit == null ? null : (offset - 1) * limit,
            orderBy: "itemId desc"))
        .toList();

    return maps.map((map) => Product.fromDb(map)).toList();
  }

  void inc() {
    if (items < count) {
      items++;
    }
  }

  void dec() {
    if (items > 1) {
      items--;
    }
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<Product> byId(Database db, String id,
      {int limit: 1, int offset: 0}) async {
    // Get a reference to the database.
    if (db == null || !db.isOpen) return null;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('cart',
        where: "itemId = ? ",
        limit: limit,
        whereArgs: [id],
        orderBy: "itemId desc",
        offset: offset);
    return maps.isNotEmpty ? Product.fromDb(maps[0]) : null;
  }

  Future<void> updateItem(Database db) async {
    // Get a reference to the database.

    if (db == null || !db.isOpen) return;

    // Remove the Dog from the Database
    await db.update(
      "cart", this.toMap(),
      // Use a `where` clause to delete a specific dog.
      where: "itemId = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [itemId],
    );
  }

  Future<void> insertItem(Database db) async {
    // Get a reference to the database.
    if (db == null || !db.isOpen) return;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    await db.insert(
      "cart",
      this.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(Database db) async {
    // Get a reference to the database.

    if (db == null || !db.isOpen) return;

    // Remove the Dog from the Database.
    await db.delete(
      'cart',
      // Use a `where` clause to delete a specific dog.
      where: "itemId = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [itemId],
    );
  }

  List<Review> reviews = [];
  List<Review> subReviews = [];

  List<Sku> sku = [];
  List<Option> options = [];

  Map<String, dynamic> toMap() => {
        "items": items,
        "title": title,
        "itemId": itemId,
        "count": count,
        "size": size,
        "price": price,
        "url": url
      };
}

class ProductInfo{
  String paramName;
  String paramValue;

  ProductInfo.fromJson(Map<String,dynamic> json):paramName = json['paramName'],paramValue = json['paramValue'];
}