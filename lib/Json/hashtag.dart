class Hashtag {
  String id;
  String name;
  int count = 0;

  bool selected = false;

  Hashtag(this.name);

  Hashtag.fromJson(Map<String, dynamic> json)
      : name = json['name'],
  count = json['count'],
        id = json['id'];

  Map<String, dynamic> toJson() => {"name": name, "id": id, "count": count};
}
