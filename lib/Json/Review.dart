class Review {
  String id;
  String itemReview;
  String username;
  String time;
  String avatar;
  int likeNum;
  int itemScore;
  int priceScore;
  int logisticsScore;
  int serviceScore;
  bool liked = false;

  Review.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        itemReview = json['itemReview'],
        likeNum = json['likeNum'],
        avatar = json['avatar'],
        itemScore = json['itemScore'],
        priceScore = json['priceScore'],
        logisticsScore = json['logisticsScore'],
        serviceScore = json['serviceScore'],
        time = json['createTime'],
        liked = json['isLike'] ?? false,
        username = json['userName'];


  int get average => ((serviceScore + logisticsScore + priceScore + itemScore) * 5) ~/ 20;
}
