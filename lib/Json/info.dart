class Info {
  String contactId;
  String contactWay;
  String contactDetail;
  int enableFlag;

  Info.fromJson(Map<String, dynamic> json)
      : contactId = json['contactId'],
        contactWay = json['contactWay'],
        contactDetail = json['contactDetail'],
        enableFlag = json['enableFlag'];
}
