import 'dart:async';

import 'package:flutter/cupertino.dart';

class NowBuilder extends StatefulWidget {
  final DateTime date;
  final bool extended;
  final TextStyle style;

  const NowBuilder(
      {Key key, @required this.date, this.extended: true, this.style})
      : super(key: key);

  @override
  _NowBuilderState createState() => _NowBuilderState();
}

class _NowBuilderState extends State<NowBuilder> {
  Timer _timer;

  Duration get _dur => widget.date == null
      ? Duration(seconds: 0)
      : DateTime.now().difference(widget.date);

  int get _difference => _dur.inSeconds < 60
      ? _dur.inSeconds
      : _dur.inMinutes < 60
          ? _dur.inMinutes
          : _dur.inHours < 24
              ? _dur.inHours
              : _dur.inDays < 7
                  ? _dur.inDays
                  : _weeks < 4 ? _weeks : _months < 12 ? _months : _years;

  String get _label => _dur.inSeconds < 60
      ? "seconds"
      : _dur.inMinutes < 60
          ? _minute(_dur.inMinutes)
          : _dur.inHours < 24
              ? _hour(_dur.inHours)
              : _dur.inDays < 7
                  ? _day(_dur.inDays)
                  : _weeks < 4
                      ? _week(_weeks)
                      : _months < 12 ? _month(_months) : _year(_years);

  String _minute(int x) => x == 1 ? "minute" : "minutes";

  String _hour(int x) => x == 1 ? "hour" : "hours";

  String _day(int x) => x == 1 ? "day" : "days";

  String _week(int x) => x == 1 ? "week" : "weeks";

  String _month(int x) => x == 1 ? "month" : "months";

  String _year(int x) => x == 1 ? "year" : "years";

  String get _label0 => _dur.inSeconds < 60
      ? "sec"
      : _dur.inMinutes < 60
          ? 'min'
          : _dur.inHours < 24
              ? 'hr'
              : _dur.inDays < 7
                  ? "dy"
                  : _weeks < 4 ? "wk" : _months < 12 ? 'mnth' : 'yr';

  int get _months => _dur.inDays ~/ 30;

  int get _weeks => _dur.inDays ~/ 7;

  int get _years => _months ~/ 12;

  String get _diff => "$_difference $_label ago";

  String get _diff0 => "$_difference $_label0";

  void _refresh() {
    if (widget.date == null) return;
    _timer?.cancel();
    Duration _d = _dur.inSeconds < 60
        ? Duration(seconds: 1)
        : _dur.inMinutes < 60
            ? Duration(minutes: 1)
            : _dur.inHours < 24 ? Duration(hours: 1) : Duration(days: 1);
    _timer = Timer(_d, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    this._refresh();
    return Text(widget.date == null ? '...' : widget.extended ? _diff : _diff0,
        style: widget.style);
  }
}
