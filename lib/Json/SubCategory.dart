class SubCategory {
  String id;
  String name;
  String url;

  SubCategory(this.id,this.name,this.url);

  SubCategory.fromJson(Map<String, dynamic> json)
      : id = json['goodstwotypeId'],
        name = json['goodstwotypeTitle'],
        url = json['goodstwotypeUrl'];

  Map<String, dynamic> toJson() => {"goodstwotypeId": id, "goodstwotypeTitle": name, "goodstwotypeUrl": url};
}
