import 'package:html/parser.dart' as parser;

class Problem {
  String problemId;
  String question;
  String answer;
  int enableFlag;
  int sort;
  String createTime;

  Problem.fromJson(Map<String, dynamic> json)
      : problemId = json['problemId'],
        question = json['question'],
        enableFlag = json['enableFlag'],
        answer = parse(json['answer']),
        sort = json['sort'],
        createTime = json['createTime'];

  static String parse(String data) {
    var d = parser.parse(data);
    return d.children.map((f) => f.text).join(" ");
  }
}
