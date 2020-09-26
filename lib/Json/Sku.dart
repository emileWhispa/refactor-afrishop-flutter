class Sku {
  String id;
  String image;
  double price;
  int count;
  String skuCode;
  List<SubSku> list = [];


  Sku(this.price,this.count,this.skuCode,this.list);

  String selected;

  Sku.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        image = json['skuImg'],
        price = (json['price'] ?? 0) + 0.0,
        count = json['count'] ?? 0,
        skuCode = json['skuCode'],
  list = skuList(json['skus']);

  static List<SubSku> skuList(Iterable iterable){
    if( iterable == null ) return [];

    return iterable.map((f)=>SubSku.fromJson(f)).toList();
  }
}


class SubSku{

  String name;
  String description;

  SubSku(this.name,this.description);

  SubSku.fromJson(Map<String, dynamic> json)
      :name = json['skuName'],
        description = json['skuDesc'];
}