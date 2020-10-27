class Poster {
  String poster;
  String linkUrl;
  String id;
  int posterType;
  String title;
  int isShow;

  Poster.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        linkUrl = json['redirectUrl'],
        title = json['postersTitle'],
        posterType = json['postersType'],
        poster = json['postersPicture'],
        isShow =  json['isShow'];
}
