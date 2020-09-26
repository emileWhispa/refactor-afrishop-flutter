class Country {
  String name;
  String flag;
  String alphaCode;
  String dialingCode;

  Country(this.dialingCode,this.name);

  Country.fromJson(Map<String, dynamic> json)
      : name = json['name'],
      alphaCode = json['alpha2Code'],
      dialingCode = json['callingCodes'][0],
        flag = json['flag'];


  int get compare => dialingCode == "250" || dialingCode == "86" || dialingCode == "260" ? 0 : 1;
}
