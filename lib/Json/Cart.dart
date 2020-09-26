import 'package:intl/intl.dart';

import 'Product.dart';

class Cart {
  String id;
  int checkFlag;
  String itemId;
  String sourceItemId;
  String stationId;
  String itemTitle;
  int itemNum;
  String itemImg;
  double itemPrice;
  String itemCategory;
  String itemSku;
  String shopId;
  String shopName;
  String shopUrl;
  String createTime;
  int stationType;
  bool commented = false;

  bool get selected => checkFlag == 1;
  bool updating = false;

  Cart.fromJson(Map<String, dynamic> json)
      : id = json['cartRecordId'],
        checkFlag = json['checkFlag'],
        sourceItemId = json['sourceItemId'],
        stationId = json['stationId'],
        itemTitle = json['itemTitle'],
        itemImg = json['itemImg'],
        commented = json['isCommented'] ?? false,
        itemNum = json['itemNum'],
        itemPrice = json['itemPrice'],
        itemCategory = json['itemCategory'],
        itemSku = json['itemSku'],
        shopId = json['shopId'],
        shopName = json['shopName'],
        shopUrl = json['shopUrl'],
        createTime = json['createTime'],
        itemId = json['itemId'];

  var format = DateFormat("dd MMM yyyy, EEE");

  double get total => itemPrice * itemNum;


  Product get product =>Product(this.itemPrice, this.itemTitle, this.itemImg, this.itemNum,this.itemSku,this.shopId,this.itemPrice,this.itemNum);

  double get percent => 10;
  double get bonus => total * percent / 100;

  String get bonusStr => bonus.toStringAsFixed(3);
}
