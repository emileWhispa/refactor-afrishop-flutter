import 'dart:io';

import 'position.dart';

class Choice {
  String tag;
  File file;
  File thumb;
  bool isImage;
  bool selected = false;

  Choice(this.tag, this.file, this.isImage);

  List<Position> list = [];

  Map<String, dynamic> toJsonOld() => {
        // "tag":tag??"",
        "list": list,
        "image": isImage
      };

  Map<String, dynamic> toJson() => {
        // "tag":tag??"",
        "list": list,
        "file": file.path,
        "thumb": thumb?.path,
        "tag": tag,
        "image": isImage
      };

  Choice.fromJson(Map<String, dynamic> json)
      : list = (json['list'] as Iterable)
            .map((f) => Position.fromJson2(f))
            .toList(),
        file = new File(json['file']),
        tag = json['tag'],
        isImage = json['image'],
        thumb = json['thumb'] == null ? null : new File(json['thumb']);
}
