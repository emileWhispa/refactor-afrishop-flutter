class History {
  String id;
  String query;
  String date;

  History(this.query, this.date);

  History.fromJson(Map<String, dynamic> json)
      : query = json['searchKeywords'] != null
            ? json['searchKeywords']
            : json['query'],
        id = json['id'],
        date = json['date'];

  Map<String, dynamic> toJson() => {"query": query, "date": date, "id": id};
}
