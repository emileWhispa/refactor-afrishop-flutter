class CrawlSku {
  String skuStr;
  int quantity;

  CrawlSku.fromJson(Map<String, dynamic> map) : skuStr = map['skuStr'] , quantity = map['sellableQuantity'];
}
