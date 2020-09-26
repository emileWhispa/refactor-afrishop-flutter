class SubSubCategory {
  String id;
  String twoId;
  String name;
  String image;

  SubSubCategory(this.id,this.name,this.image);

  SubSubCategory.fromJson(Map<String, dynamic> json)
      : id = json['descripitionId'], twoId = json['goodstwotypeId'],name = json['descripitionName'],image = json['image'];
}
