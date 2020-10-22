class Slide {
  String image;
  String imgName;
  int imgType;
  String linkUrl;
  String isShow;
  Slide.fromJson(Map<String, dynamic> json)
      : image = json['imgUrl'],
        imgName = json['imgName'],
        imgType = json['imgType'],
        linkUrl = json['linkUrl'],
        isShow = json['isShow'];


}
