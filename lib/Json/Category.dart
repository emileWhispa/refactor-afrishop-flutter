class Category {
  String id;
  String name;
  String url;

  Category.fromJson(Map<String, dynamic> json)
      : id = json['goodtypeId'],
        name = json['classTitle'],
        url = json['picture'];

  Category.fromJson2(Map<String, dynamic> json)
      :
        name = json['name'],
        url = json['url'];

  Map<String, dynamic> toJson() => {"goodtypeId": id, "classTitle": name, "picture": url};
}
