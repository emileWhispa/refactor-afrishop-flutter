class Category {
  String id;
  String name;
  String url;
  String isShow;

  Category.fromJson(Map<String, dynamic> json)
      : id = json['goodtypeId'],
        name = json['classTitle'],
        url = json['picture'],
        isShow = json['isShow'];

  Category.fromJson2(Map<String, dynamic> json)
      :
        name = json['name'],
        url = json['url'],
        isShow = json['isShow'];

  Map<String, dynamic> toJson() => {"goodtypeId": id, "classTitle": name, "picture": url, "isShow":isShow};
}
