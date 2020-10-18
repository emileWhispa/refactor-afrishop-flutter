import 'package:intl/intl.dart';

class Evaluation {
  String feedbackId;
  String question;
  int enableFlag;
  String createTime;
  DateTime createParsed;
  int questionType;
  int sort;

  Evaluation.fromJson(Map<String, dynamic> json)
      : feedbackId = json['feedbackId'],
        question = json['question'],
        createTime = json['createTime'],
        createParsed = DateTime.tryParse(json['createTime']),
        questionType = json['questionType'],
        sort = json['sort'],
        enableFlag = json['enableFlag'];

  String get formatted => createParsed == null ? createTime : DateFormat("yyyy-MMM-dd").format(createParsed);
}
