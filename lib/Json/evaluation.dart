class Evaluation {
  String feedbackId;
  String question;
  int enableFlag;
  String createTime;
  int questionType;
  int sort;

  Evaluation.fromJson(Map<String, dynamic> json)
      : feedbackId = json['feedbackId'],
        question = json['question'],
        createTime = json['createTime'],
        questionType = json['questionType'],
        sort = json['sort'],
        enableFlag = json['enableFlag'];
}
