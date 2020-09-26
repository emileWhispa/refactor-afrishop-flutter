class Tag{
  String id;
  String tagName;
  Tag.fromJson(Map<String,dynamic> json):id=json['id'],tagName=json['tagName'];
}