class Logistic {
  String time;
  String content;

  Logistic.fromJson(Map<String, dynamic> json)
      : time = json['time'],
        content = json['content'];

  Map<String,dynamic> toJson()=>{};
}
