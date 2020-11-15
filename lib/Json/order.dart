import 'package:afri_shop/Json/Product.dart';
import 'package:intl/intl.dart';

import 'Cart.dart';

class Order {
  String ordersId;
  String orderId;
  String orderNo;
  String orderName;
  String orderTime;
  String updateTime;
  String dealTime;
  String userName;
  String userId;
  String deliveryAddressId;
  String deliveryAddress;
  String deliveryName;
  String deliveryPhone;
  int orderStatus;
  double itemsPrice;
  double totalPrice;
  double realityPay;
  int deliveryFlag;
  String deliveryTime;
  String couponId;
  String couponTitle;
  String payId;
  int payStatus;
  double couponPrice;
  double fee;
  double tax;
  double expressCost;
  int commentCount;
  List<Cart> itemList = [];

  DateTime _dateTime;

  bool deleting = false;

  static DateTime _tParse(json) {
    try {
      return DateFormat("MMMM dd, yyyy hh:mm:ss a").parse(json['orderTime']);
    } on FormatException {
      return DateTime.tryParse(json['orderTime'] ?? "");
    }
  }

  Order.fromJson(Map<String, dynamic> json)
      : ordersId = json['ordersId'],
        orderId = json['orderId'],
        orderNo = (json['orderNo'])?.toString(),
        orderName = json['orderName'],
        orderTime = json['orderTime'],
        _dateTime = _tParse(json),
        updateTime = json['updateTime'],
        userName = json['userName'],
        commentCount = json['commentCount'],
        deliveryAddressId = json['deliveryAddressId'],
        deliveryAddress = json['deliveryAddress'],
        deliveryName = json['deliveryName'],
        deliveryPhone = json['deliveryPhone'],
        itemsPrice = json['itemsPrice'],
        totalPrice = json['totalPrice'],
        orderStatus = json['orderStatus'],
        realityPay = json['realityPay'] + 0.0,
        deliveryFlag = json['deliveryFlag'],
        deliveryTime = json['deliveryTime'],
        expressCost = (json['expressCost']).toDouble(),
        couponId = json['couponId'],
        couponTitle = json['couponTitle'],
        couponPrice = json['couponPrice'],
        fee = json['fee'] + 0.0,
        tax = json['tax'] + 0.0,
        payId = json['payId'],
        payStatus = json['payStatus'],
        userId = json['userId'],
        itemList = (json['itemOrderList'] as Iterable)
            .map((f) => Cart.fromJson(f))
            .toList(),
        dealTime = json['dealTime'];


  DateTime get getDate => DateTime.tryParse(orderTime);

  String get dFormat =>getDate == null ? orderTime : DateFormat("yyyy-MMM-dd HH:mm:ss").format(getDate.toLocal());

  bool closedByTime(DateTime date) => !getDate.add(Duration(hours: 24)).isAfter(date) && isPending;

  String get status => orderStatus == 0
      ? "Deleted"
      : isPending
          ? "Unpaid"
          : orderStatus == 20
              ? "Paid"
              : orderStatus == 40
                  ? "Shipped"
                  : isSuccess
                      ? "Transaction successful"
                      : isClosed ? "Transaction closed" : "Pending";

  bool get isClosed => orderStatus == 60;

  bool get isSuccess => orderStatus == 50;

  bool get isSuccessWithNonCommentItem => isSuccess && (commentCount == null || commentCount < itemList.length);

  String get date => _dateTime == null
      ? orderTime
      : DateFormat("MMMM dd, yyyy").format(_dateTime);

  bool get isPending => orderStatus == 10;

  bool get hasCoupon =>
      couponId != null && couponPrice != null && couponPrice > 0;

  bool get hasAddress =>deliveryName != null && deliveryAddress != null;

  //@Deprecated("Old version replaced by api key realityPay")
  double get subTotalPriceFromCoupon =>
      hasCoupon ? subTotalPrice - couponPrice : subTotalPrice;

  String get totalPriceString => (totalPrice ?? 0.0).toStringAsFixed(2);

  String get realityPriceString => (realityPay ?? 0.0).toStringAsFixed(2);

  double get subTotalPrice => itemList.fold<double>(0.0, (v, t) => v + t.total);

  String get subTotalPriceString => subTotalPrice.toStringAsFixed(2);
}
