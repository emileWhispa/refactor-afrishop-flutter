class Slide {
  String image;
  String imgName;
  int imgType;
  String linkUrl;

  Slide.fromJson(Map<String, dynamic> json)
      : image = json['imgUrl'],
        imgName = json['imgName'],
        imgType = json['imgType'],
        linkUrl = json['linkUrl'];


}
