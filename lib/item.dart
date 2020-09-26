import 'package:sqflite/sqflite.dart';

class Item {
  final String title;
  final String url;
  final double price;
  String itemSku;
  final int count;
  int items = 0;
  int id;
  String itemId;
  bool selected = false;

  Item(this.price, this.title, this.url, this.count);

  Item.fromJson(Map<String, dynamic> json)
      : title = json['itemName'],
        id = json['id'],
        count = json['itemCount'],
        itemId = json['itemId'],
        itemSku = json['itemSku'],
        price = json['discountPrice'],
        url = json['itemImg'];

  double get total => items * price;

  Item.fromDb(Map<String, dynamic> json)
      : title = json['title'],
        id = json['id'],
        count = json['count'],
        itemId = json['itemId'],
        items = json['items'],
        price = json['price'],
        url = json['url'];

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<Item>> itemList(Database db,
      {int limit: 50, int offset: 1, String append: "", String search}) async {
    // Get a reference to the database.\
    if (db == null || !db.isOpen) return [];

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = (await db.query('cart',
            limit: limit,
            offset: limit == null ? null : (offset - 1) * limit,
            orderBy: "id desc"))
        .toList();

    return maps.map((map) => Item.fromDb(map)).toList();
  }

  void inc(){
    if( items < count){
      items++;
    }
  }

  void dec(){
    if( items > 1){
      items--;
    }
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<Item> byId(Database db, String id,
      {int limit: 1, int offset: 0}) async {
    // Get a reference to the database.
    if (db == null || !db.isOpen) return null;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('cart',
        where: "itemId = ? ",
        limit: limit,
        whereArgs: [id],
        orderBy: "id desc",
        offset: offset);
    return maps.isNotEmpty ? Item.fromDb(maps[0]) : null;
  }

  Future<void> updateItem(Database db) async {
    // Get a reference to the database.

    if (db == null || !db.isOpen) return;

    // Remove the Dog from the Database
    await db.update(
      "cart", this.toMap(),
      // Use a `where` clause to delete a specific dog.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Future<void> insertItem(Database db) async {
    // Get a reference to the database.
    if (db == null || !db.isOpen) return;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    id = await db.insert(
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
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  Map<String, dynamic> toMap() => {
        "items": items,
        "title": title,
        "itemId": itemId,
        "count": count,
        "price": price,
        "url": url
      };
}
