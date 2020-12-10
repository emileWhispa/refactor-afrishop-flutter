import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:email_validator/email_validator.dart';

import 'Json/Address.dart';
import 'Json/Post.dart';
import 'Json/Product.dart';
import 'Json/User.dart';

class SuperBase {
  // Live connections
//  String server = "http://159.138.48.71:8080/zion/";
  String server = "https://app.afrieshop.com/zion/";
//  String server0 = "http://165.22.82.105:8080/"; //Discover

  //Test Connections
//  String server = "https://dev.diaosaas.com/zion/"; // currently connected on live db
//  String server = "http://165.22.82.105:7000/zion/";

  String get server0 => server; // Discover
  int version = 1; // sliders //0.android 1.IOS 2.PC WEB 3.Mobile Web

  // Those are be used while receiving shared links
  String server001 = "https://afrishop.rw/";
  String server002 = "https://www.afrishop.rw/";
  String server003 = "https://afrieshop.com/";
  String server00 = "https://www.afrieshop.com/";
  String server004 = "http://afrishop.rw/";
  String server005 = "http://www.afrishop.rw/";
  String server006 = "http://afrieshop.com/";
  String server007 = "http://www.afrieshop.com/";
  String server000 = "https://afrieshop.com/";

  String socket = "ws://dev.diaosaas.com/zion/";
  String jwtKey =
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsidGVzdGp3dHJlc291cmNlaWQiXSwidXNlcl9uYW1lIjoiV2hpc3BhIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIl0sImV4cCI6MTU4NjgwNjM0OCwiYXV0aG9yaXRpZXMiOlsiU1RBTkRBUkRfVVNFUiJdLCJqdGkiOiJiOTI3ZTcwNi0yOGNiLTRmN2MtYWEwNS00N2JkNjYxZDg1ZDAiLCJjbGllbnRfaWQiOiJ3aGlzcGFqd3RjbGllbnRpZCJ9.cqBA3timG1yf8Q5wRVKyYlpwu2omdr2chgnLbzpyqh8';
  String idKeyUser = 'id-user-data-BASE64-key-123';
  String idKey = 'user-id-23';
  String jwt = '';
  var formatter = new NumberFormat.decimalPattern("en_US");

  String formatNumber(num value) => formatter.format(value);

  RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  RegExp emailExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  RegExp disableSpecial = RegExp(
      r"[^.@a-zA-Z0-9]");
  RegExp phoneExp = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
  final amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  String validatePassword(String value) {
    if (value.isEmpty) {
      return "Password can not be empty";
    } else if (value.length <= 7) {
      return "8 characters minimum required";
    } else if (!value.contains(new RegExp(r'[a-z]')) &&
        !value.contains(new RegExp(r'[A-Z]'))) {
      return "Password must contain at least a letter";
    } else {
      return null;
    }
  }

  String get dKey => "draft-key";

  String get defAddress => "default-address-key";

  void setDefaultAddress(Address address){
    save(defAddress, address);
  }

  void setDefaultAddressIfEmpty(Address address){
    getDefaultAddress().then((value){
      if( value == null) setDefaultAddress(address);
    });
  }

  Future<Address> getDefaultAddress()async{
    var x = (await prefs).getString(defAddress);
    if( x != null){
      return Address.fromJson(json.decode(x));
    }
    return null;
  }

  String validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{8,14}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Phone number can not be empty";
    } else if (!regExp.hasMatch(value)) {
      return "Please input a valid phone number";
    } else {
      return null;
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return "Email can not be empty";
    } else {
      if (!regex.hasMatch(value)) {
        return "Enter a valid email.";
      }
      {
        final bool isValid = EmailValidator.validate(value);
        if (isValid) {
          return null;
        } else {
          return "Enter a valid email.";
        }
      }
    }
  }

  String get historyLink => "Get-history-link";

  String get historyLinkDiscover => "Get-history-link-discover";
  Function mathFunc = (Match match) => '${match[1]},';

  var platform = MethodChannel('app.channel.shared.data');
  ImageProvider def = AssetImage(
    'assets/boys.jpg',
  );
  ImageProvider defLoader = AssetImage(
    'assets/loading_def.png',
  );
  Widget defImg = Image.asset(
    "assets/boys.jpg",
    fit: BoxFit.cover,
  );
  AssetBundleImageProvider asset = AssetImage("assets/back.jpg");
  final f = new DateFormat('yyyy-MM-dd hh:mm');
  Color color = Color(0xffffe707);

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  void sharePost(Post post, {String subject: "Share post", User user}) {
    if (user != null && !user.invited) {
      platform.invokeMethod("toast", "Member registration not yet done");
      return;
    }
    String sharer =
        user != null && user.code != null ? "?code=${user.code}" : "";
    if (post != null && post.id != null)
      Share.share(_url2("community/${post.id}$sharer"), subject: subject);
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  String url2(String url) => "$server0$url";

  String _url2(String url) => "$server00$url";

  String replacedUrl(String url) => url.contains(server001)
      ? url.replaceAll(server001, server0)
      : url.contains(server002)
          ? url.replaceAll(server002, server0)
          : url.contains(server003)
              ? url.replaceAll(server003, server0)
              : url.contains(server004)
                  ? url.replaceAll(server004, server0)
                  : url.contains(server005)
                      ? url.replaceAll(server005, server0)
                      : url.contains(server006)
                          ? url.replaceAll(server006, server0)
                          : url.contains(server007)
                              ? url.replaceAll(server007, server0)
                              : url.replaceAll(server00, server0);

  String url(String url) => "$server$url";

  String get _favoriteLink => "12-fav-data-implement";

  String get _favoriteLinkPosts => "fav-post-link";

  String get _visitedLink => "visited-link-fav-get-kik";

  String get _visitedLinkProduct => "visited-link-fav-get-product-kit";

  Future<List<Product>> getProductsFav() async {
    var val = (await prefs).getString(_favoriteLink);
    List<Product> _list;
    if (val != null) {
      Iterable map = json.decode(val);
      _list = map.map((f) => Product.fromJson(f)).toList();
    } else
      _list = [];

    return _list;
  }

  Future<List<Post>> getPostsFav() async {
    var val = (await prefs).getString(_favoriteLinkPosts);
    List<Post> _list;
    if (val != null) {
      Iterable map = json.decode(val);
      _list = map.map((f) => Post.fromJson(f)).toList();
    } else
      _list = [];

    return _list;
  }

  Future<List<Post>> getVisitedPost() async {
    var val = (await prefs).getString(_visitedLink);
    List<Post> _list;
    if (val != null) {
      Iterable map = json.decode(val);
      _list = map.map((f) => Post.fromJson(f)).toList();
    } else
      _list = [];

    return _list;
  }

  Future<List<Product>> getVisitedProducts() async {
    var val = (await prefs).getString(_visitedLinkProduct);
    List<Product> _list;
    if (val != null) {
      Iterable map = json.decode(val);
      _list = map.map((f) => Product.fromJson(f)).toList();
    } else
      _list = [];

    return _list;
  }

  void saveFavorite(Product product) async {
    var _list = await getProductsFav();
    _list
      ..removeWhere((p) => p.itemId == product.itemId)
      ..insert(0, product);
    save(_favoriteLink, _list);
  }

  void saveFavoritePost(Post post) async {
    var _list = await getPostsFav();
    _list
      ..removeWhere((p) => p.id == post.id)
      ..insert(0, post);
    save(_favoriteLinkPosts, _list);
  }

  void saveVisited(Post post) async {
    var _list = await getVisitedPost();
    _list
      ..removeWhere((p) => p.id == post.id)
      ..add(post);
    save(_visitedLink, _list);
  }

  void saveVisitedProduct(Product product) async {
    var _list = await getVisitedProducts();
    _list
      ..removeWhere((p) => p.itemId == product.itemId)
      ..add(product);
    save(_visitedLinkProduct, _list);
  }

  void removeVisited(Post post) async {
    var _list = await getVisitedPost();
    _list..removeWhere((p) => p.id == post.id);
    save(_visitedLink, _list);
  }

  void removeVisitedProduct(Product product) async {
    var _list = await getVisitedProducts();
    _list..removeWhere((p) => p.itemId == product.itemId);
    save(_visitedLinkProduct, _list);
  }

  void saveFavoriteList(List<Product> _list) async {
    save(_favoriteLink, _list);
  }

  void saveFavoriteListPost(List<Post> _list) async {
    save(_favoriteLinkPosts, _list);
  }

  void saveVisitedLinkList(List<Post> _list) async {
    save(_visitedLink, _list);
  }

  void saveVisitedLinkProducts(List<Product> _list) async {
    save(_visitedLinkProduct, _list);
  }

  void reqFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  Future<Database> getDatabase() async {
    return openDatabase(
      // Set the path to the database.
      join(await getDatabasesPath(), 'messages-contact.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.db.
        return db.execute(
            "CREATE TABLE cart(itemId TEXT NOT NULL UNIQUE,items int,count int,title TEXT,price double,url TEXT,color TEXT,size TEXT)");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  String fmt(String test) {
    return test.replaceAllMapped(reg, mathFunc);
  }

  String fmtNbr(num test) {
    return fmt(test.toString());
  }

  final scope = const <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
    'https://www.googleapis.com/auth/drive',
  ];

  final contactScope = const <String>[];

  Future<File> writeToGallery(File file) async {
    final directory = await getExternalStorageDirectory();
    final myImagePath = '${directory.path}/AFRIX';
    final myImgDir = await new Directory(myImagePath).create();
    var _file = new File("${myImgDir.path}/$unique${getName(file)}");
    _file.writeAsBytesSync(file.readAsBytesSync());
    return _file;
  }

  String getName(File file) {
    return getBaseName(file.path);
  }

  String getBaseName(String path) {
    return basename(path);
  }

  String getExt(String path) {
    return basename(path);
  }

  String getExtension(String path) {
    return extension(path);
  }

  String get unique => "${DateTime.now().millisecondsSinceEpoch}${Uuid().v4()}";

  double log10(num x) => log(x) / ln10;

  RichText convertHashtag(String text,
      {void Function(String tag) onTap, TextStyle style}) {
    if (text == null) return RichText(text: TextSpan());
    List<String> split = text.split(RegExp("#"));
    List<String> hashtags = split.getRange(1, split.length).fold([], (t, e) {
      var texts = e.split(" ");
      if (texts.length > 1) {
        return List.from(t)
          ..addAll(["#${texts.first}", "${e.substring(texts.first.length)}"]);
      }
      return List.from(t)..add("#${texts.first}");
    });
    return RichText(
      text: TextSpan(
        style: style ?? TextStyle(color: Colors.black87),
        children: [TextSpan(text: split.first)]..addAll(hashtags
            .map((text) => text.contains("#")
                ? WidgetSpan(
                    child: InkWell(
                        onTap: () {
                          if (onTap != null) {
                            onTap(text);
                          }
                        },
                        child:
                            Text(text, style: TextStyle(color: Colors.blue))))
                : TextSpan(text: text))
            .toList()),
      ),
    );
  }

  String readableFileSize(int size) {
    if (size <= 0) return "0";
    final List<String> units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log10(size) ~/ log10(1024)).toInt();
    return new NumberFormat("#,##0.#").format(size / pow(1024, digitGroups)) +
        " " +
        units[digitGroups];
  }

  void signedIn(
      void Function(String token, User user) function, void Function() not) {
    prefs.then((SharedPreferences prf) {
      String b = prf.get(jwtKey);
      String v = prf.get(idKeyUser);

      if (v != null) {
        Map<String, dynamic> _map = json.decode(v);
        function(b, User.fromJson(_map));
      } else
        not();
    });
  }

  void auth(String jwt, String user, String id) {
    prefs.then((SharedPreferences prf) {
      if (jwt != null) prf.setString(jwtKey, jwt);
      if (user != null) prf.setString(idKeyUser, user);
      if (id != null) prf.setString(idKey, id);
    });
  }

  void showSnack(
      {@required String s,
      @required BuildContext context,
      MaterialColor color}) {
    print("$s");
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(s),
      backgroundColor: color != null ? color : Colors.blue,
    ));
  }

  void clear(Function() fn) {
    prefs.then((SharedPreferences prf) {
      prf.clear().then((bool v) {
        if (v) fn();
      });
    });
  }

  Map<String, String> map(String jwt, String id) {
    Map<String, String> headers = new Map<String, String>();
    //headers['secret'] = widget.keyCode;
    headers['tokenKey'] = jwt;
    headers['userId'] = id;

    return headers;
  }

  Widget icon({Color color: Colors.blue, bool deliver: true, bool sent: true}) {
    return Icon(
      deliver ? Icons.done_all : Icons.done,
      size: 14,
      color: color,
    );
  }

  Widget loader({String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text != null ? text : "Loading response ..."),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Center(
            child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 3)),
          ),
        )
      ],
    );
  }

  Widget record({Color color: Colors.green}) {
    return Text(
      "recording audio ...",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: color, fontStyle: FontStyle.italic),
    );
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> localFile(String name) async {
    final path = await localPath;
    return File('$path/$name');
  }

  Widget typing(TickerProvider ticker, {Color color: Colors.green}) {
    return Text(
      "typing ...",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: color, fontStyle: FontStyle.italic),
    );
  }

  String printDuration(Duration duration) {
    if (duration == null) return "";
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String get registered => "get/numbers/";

  String get statusListQ => "save/statues/data/list/";

  Widget loadBox(
      {Color color: Colors.red,
      Color bColor: Colors.white,
      double size: 20,
        double value,
      double width: 3}) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        backgroundColor: bColor,
        strokeWidth: width,
        value: value,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  void save(String key, dynamic val) async {
    this.saveVal(key, jsonEncode(val));
  }

  bool canDecode(String jsonString) {
    var decodeSucceeded = false;
    try {
      json.decode(jsonString);
      decodeSucceeded = true;
    } on FormatException catch (e) {
      print(e.message);
    }
    return decodeSucceeded;
  }

  Future<void> ajax(
      {@required String url,
      String method: "GET",
      FormData data,
      Map<String, dynamic> map,
      bool server: false,
      bool auth: true,
      bool local: false,
      bool base2: false,
      String authKey,
      bool json: true,
      bool absolutePath: false,
      void Function(int count, int total) progress,
      bool localSave: false,
      bool noOptions: false,
      String jsonData,
      responseType: ResponseType.plain,
      void Function(dynamic response, String url) onValue,
      void Function() onEnd,
      void Function(String response, String url) error}) async {
    url = absolutePath
        ? url
        : base2
            ? this.url2(url)
            : this.url(url);

    Map<String, String> headers = new Map<String, String>();

    var prf = await prefs;
    if (auth && authKey != null) {
      headers['Authorization'] = 'Bearer $authKey';
    }

    Options opt = noOptions
        ? null
        : Options(
            responseType: responseType,
            headers: auth ? headers : null,
            contentType: ContentType.json.value,
            receiveDataWhenStatusError: true,
            sendTimeout: 90000,
            receiveTimeout: 90000);

    if (!server) {
      String val = prf.get(url);
      bool t = onValue != null && val != null;
      local = local && t;
      localSave = localSave && t;
      var c = (t && json && canDecode(val)) || !json;
      t = t && c;
      if (t) onValue(val, url);
    }

    if (local) {
      if (onEnd != null) onEnd();
      return Future.value();
    }

    Future<Response> future = method.toUpperCase() == "POST"
        ? Dio().post(url,
            onSendProgress: progress,
            data: jsonData ?? map ?? data,
            options: opt)
        : method.toUpperCase() == "PUT"
            ? Dio().put(url,onSendProgress: progress, data: jsonData ?? map ?? data, options: opt)
            : method.toUpperCase() == "DELETE"
                ? Dio().delete(url, data: jsonData ?? map ?? data, options: opt)
                : Dio().get(url, options: opt);

    try {
      Response response = await future;
      dynamic data = response.data;
      if (response.statusCode == 200) {
        var cond = (data is String && json && canDecode(data)) || !json;
        if (cond) this.saveVal(url, data);

        if (onValue != null && !localSave)
          onValue(data, url);
        else if (error != null) error(data.toString(), url);
      } else if (error != null) {
        error(data, url);
      }
    } on DioError catch (e) {
      //if (e.response != null) {
      String resp = e.response != null ? e.response.data.toString() : e.message;
      if (error != null) error(resp, url);
      //}
    }

    if (onEnd != null) onEnd();
    return Future.value();
  }

  void saveVal(String key, String value) {
    prefs.then((SharedPreferences val) => val.setString(key, value));
  }

  void deletePost(Post post, String key) {
    this.ajax(
      url: "discover/post/delete/post/${post.id}",
      authKey: key,
      server: true,
      error: (s, v) => print(s),
      onValue: (s, v) => print(s),
    );
  }

  void deleteVal(String key) {
    prefs.then((SharedPreferences val) => val.remove(key));
  }
}

class RegExInputFormatter implements TextInputFormatter {
  final RegExp _regExp;

  RegExInputFormatter._(this._regExp);

  factory RegExInputFormatter.withRegex(String regexString) {
    try {
      final regex = RegExp(regexString);
      return RegExInputFormatter._(regex);
    } catch (e) {
      // Something not right with regex string.
      assert(false, e.toString());
      return null;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final oldValueValid = _isValid(oldValue.text);
    final newValueValid = _isValid(newValue.text);
    if (oldValueValid && !newValueValid) {
      return oldValue;
    }
    return newValue;
  }

  bool _isValid(String value) {
    try {
      final matches = _regExp.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }
}
