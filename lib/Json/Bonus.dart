import 'model.dart';

class Bonus extends Model {
  String id;
  double amount;
  String date;
  String _title;
  String url;
  DateTime dateTime;
  bool withDraw = false;
  bool status = false;

  Bonus.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        date = json['date'],
  id = json['id'],
        withDraw = json['isWithdraw'] ?? false,
        status = json['status'] ?? false,
        dateTime = DateTime.tryParse(json['date']),
        _title = json['item'] != null  ? json['item']['itemName'] : "Commission fees",
        url = json['item'] != null  ? json['item']['itemImg'] : null;

  String get _amountStr => format((withDraw ? amount*-1 : amount) ?? 0.0);
  String get amountStr => withDraw ? "-\$$_amountStr" : "$_amountStr";

  String get title => withDraw ? "Withdraw" : _title;
  String get pendingStatus => withDraw ? status ? "approved":"pending" : "";

}
