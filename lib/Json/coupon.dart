import 'package:intl/intl.dart';

class Coupon {
  String id;
  String couponCategoryId;
  String couponCategoryName;
  String couponUse;
  String couponTitle;
  String couponIcon;
  String withStationId;
  double _withAmount;
  double _deductAmount;
  int quato;
  int takeCount;
  int usedCount;
  String startTime;
  String endTime;
  String toitableId;
  String validStartTime;
  DateTime _start;
  DateTime _end;
  String validEndTime;
  int status;
  String createUserId;
  String createTime;
  String updateUserId;
  String updateTime;
  int couponVaild;

  Coupon.fromJson(Map<String, dynamic> json)
      : id = json['couponId'],
        couponCategoryId = json['couponCategoryId'],
        couponUse = json['couponUse'],
        couponTitle = json['couponTitle'],
        couponIcon = json['couponIcon'],
        toitableId = json['toitableId'],
        withStationId = json['withStationId'],
        _withAmount = json['withAmount'],
        _deductAmount = json['deductAmount'],
        quato = json['quato'],
        takeCount = json['takeCount'],
        usedCount = json['usedCount'],
        startTime = json['startTime'],
        endTime = json['endTime'],
        validStartTime = json['validStartTime'],
        _start = _format(json['validStartTime']),
        _end = _format(json['validEndTime']),
        validEndTime = json['validEndTime'],
        status = json['status'],
        createUserId = json['createUserId'],
        createTime = json['createTime'],
        updateUserId = json['updateUserId'],
        updateTime = json['updateTime'],
        couponVaild = json['couponVaild'],
        couponCategoryName = json['couponCategoryName'];

  static DateTime _format(String input) {
    try {
      return DateTime.parse(input);
    } catch (e) {
      return null;
    }
  }

  int get withAmount => _withAmount?.toInt() ?? 0;

  int get deductAmount => _deductAmount?.toInt() ?? 0;

  String get parseStart => _start != null
      ? DateFormat("dd/MM/yy").format(_start)
      : validStartTime ?? "";

  String get parseEnd =>
      _end != null ? DateFormat("dd/MM/yy").format(_end) : validEndTime ?? "";
}
