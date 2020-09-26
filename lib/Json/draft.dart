import 'choice.dart';

class Draft {
  String caption;
  String description;
  List<Choice> files = [];

  Draft(this.caption, this.description, this.files);

  Draft.fromJson(Map<String, dynamic> json)
      : caption = json['caption'],
        files =
            (json['files'] as Iterable).map((f) => Choice.fromJson(f)).toList(),
        description = json['description'];

  Map<String, dynamic> toJson() => {
        "caption": caption,
        "description": description,
        "files": files,
      };
}
