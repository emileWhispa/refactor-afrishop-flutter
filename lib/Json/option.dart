class Option {
  String categoryId;
  String categoryName;
  String selected;
  int orderNum;

  List<SubOption> list = [];

  Option(this.categoryId, this.categoryName, this.list);

  Option.fromJson(Map<String, dynamic> map)
      : categoryId = map['categoryId'],
        orderNum = map['orderNum'],
        categoryName = map['categoryName'],
        list = subList(map['optionList']);

  static List<SubOption> subList(Iterable iterable) {
    if (iterable == null) return [];

    return iterable.map((f) => SubOption.fromJson(f)).toList();
  }
}

class SubOption {
  String optionId;
  String optionName;
  String optiionSpecies;
  String itemId;
  String cid;
  int delFlag;
  String createTime;
  String updateTime;

  SubOption(this.optionId, this.optiionSpecies, this.optionName);

  SubOption.fromJson(Map<String, dynamic> json)
      : optionId = json['optionId'],
        optionName = json['optionName'],
        optiionSpecies = json['optiionSpecies'],
        cid = json['cid'],
        createTime = json['createTime'],
        updateTime = json['updateTime'],
        itemId = json['itemId'];
}
