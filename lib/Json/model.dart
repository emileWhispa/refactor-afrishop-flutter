import 'package:intl/intl.dart';

class Model{
  var f = new NumberFormat.decimalPattern("en_US");

  String format(num value)=>f.format(value);
}