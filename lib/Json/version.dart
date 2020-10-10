import 'package:html/parser.dart' as parser;

class Version {
  String versionId;
  String versionCode;
  String versionLink;
  String versionDetail;
  int versionSort;

  Version.fromJson(Map<String, dynamic> json)
      : versionId = json['versionId'],
        versionCode = json['versionCode'],
        versionDetail = parse(json['versionDetail']),
        versionSort = json['versionSort'],
  versionLink = json['versionLike'];

  static String parse(String data) {
    var d = parser.parse(data);
    return d.children.map((f) => f.text).join(" ");
  }
}
