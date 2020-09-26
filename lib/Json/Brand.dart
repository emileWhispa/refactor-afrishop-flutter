class Brand {
  String storeId;
  String storeCode;
  String storeName;
  String storeImg;
  String storeUrl;
  String itemImg1;
  String itemImg2;
  String createTime;
  String platformName;
  String platformCode;
  int enableFlag;


  Brand.fromJson(Map<String, dynamic> json)
      : storeId = json['storeId'],
        storeCode = json['storeCode'],
        storeImg = json['storeImg'],
        storeUrl = json['storeUrl'],
        itemImg1 = json['itemImg1'],
        itemImg2 = json['itemImg2'],
        createTime = json['createTime'],
        platformCode = json['platformCode'],
        platformName = json['platformName'],
        enableFlag = json['enableFlag'],
        storeName = json['storeName'];

}
