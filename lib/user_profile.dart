import 'dart:convert';

import 'package:afri_shop/personal_edit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:afri_shop/Json/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

import 'SuperBase.dart';

class UserProfile extends StatefulWidget {
  final String password;
  final String country;
  final String mobile;
  final User Function() user;
  final void Function(User user) callback;
  final void Function(User user) saveNickName;

  const UserProfile(
      {Key key,
      this.password,
      this.country,
      this.mobile,
      this.user,
      @required this.callback,
      this.saveNickName})
      : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with SuperBase {
  String _mobile;
  String _email;
  String _avatar;
  String _nickname;
  String _gender;
  String _date;
  bool _saving = false;
  User _user;

  var pKey = new GlobalKey<PersonalEditState>();

  @override
  void initState() {
    super.initState();
    var _user = widget.user();
    if (_user != null) {
      _mobile = _user.phone;
      _nickname = _user.nickname;
      _email = _user.email;
      _avatar = _user.avatar;
      _date = _user.formatDate;
      _gender = _user.sex == 1
          ? "male"
          : _user.sex == 2
              ? "female"
              : "unknown";
      this._user = _user;
    } else {
      _mobile = widget.mobile;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void loadInfo() {
    this.ajax(
        url: "user/",
        authKey: widget.user()?.token,
        server: true,
        auth: true,
        onValue: (source, url) {
          setState(() {
            _user = User.fromJson(json.decode(source)['data']);
            setState(() {
              _avatar = _user?.avatar;
            });
          });
        });
  }

  Future<void> saveUser({String nickName}) {
    setState(() {
      _saving = true;
    });
    var gnd = _gender == "male"
        ? 1
        : _gender == "female"
            ? 2
            : 0;
    print(gnd);
    print(_gender);
    return this.ajax(
        url: "user",
        method: "PUT",
        server: true,
        map: {
          "userId": widget.user()?.id,
          "email": _email,
          "sex": gnd,
          "birthday": _date,
          "username": _nickname,
          "nick": nickName ?? _nickname,
          "country": widget.country,
          "avatar": _avatar,
          "phone": _mobile,
          "password": widget.password
        },
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          print(source);
          var map = json.decode(source);
          if (map['code'] == 1) {
            var user = widget.user();
            user.birthDay = map['data']['birthday'];
            user.sex = map['data']['sex'];
            user.avatar = map['data']['avatar'];
            user.nickname = map['data']['nick'];
            pKey.currentState?.doError("done", true);
            this.auth(jwt, jsonEncode(user), user.id);
            platform.invokeMethod("toast", "Modify Success");
            widget.callback(user);
            if (pKey.currentState == null) Navigator.pop(context);
            if (widget.saveNickName != null) {
              widget.saveNickName(user);
            }
          } else {
            _showSnack(map['message']);
          }
        },
        error: (source, url) {
          _showSnack(source);
        },
        onEnd: () {
          setState(() {
            _saving = false;
          });
        });
  }

  Future<String> showValueChoose(
      {String hint, Widget Function(BuildContext context) widget}) async {
    return showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return _ValueChoose(
            hint: hint,
            widget: widget,
          );
        });
  }

  void _showDialog(String fill) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(25),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image(
                        image: AssetImage("assets/img_fill.png"),
                        height: 120,
                      ),
                      Text(
                        "Fill in $fill Please go to Account Security",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Account > Support > Account security",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                      color: color,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK")),
                )
              ],
            ),
          );
        });
  }

  void _showSnack(String data) {
    pKey.currentState?.doError(data, false);
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(data)));
  }

  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var style = TextStyle(fontSize: 15, color: Color(0xff272626));
    var decoration = BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)));
    var padding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.maybePop(context);
                })
            : null,
        title: Text(
          "Personal Information",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          _saving
              ? IconButton(icon: loadBox(), onPressed: null)
              : FlatButton(onPressed: saveUser, child: Text("Save"))
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 15),
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${_user?.username}",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Signed in ${_user.lastLoginTime}",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )),
                InkWell(
                  onTap: () {
                    showGeneralDialog(
                        context: context,
                        barrierColor: Colors.black12.withOpacity(0.6),
                        // background color
                        barrierDismissible: true,
                        // should dialog be dismissed when tapped outside
                        barrierLabel: "Dialog",
                        // label for barrier
                        transitionDuration: Duration(milliseconds: 400),
                        // how long it takes to popup dialog after button click
                        pageBuilder: (_, __, ___) {
                          return Center(
                            child: FadeInImage(
                                image: _avatar != null
                                    ? CachedNetworkImageProvider(_avatar)
                                    : AssetImage("assets/account_user.png"),
                                placeholder: defLoader,
                                fit: BoxFit.contain),
                          );
                        },
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var wasCompleted = false;
                          if (animation.status == AnimationStatus.completed) {
                            wasCompleted = true;
                          }

                          if (wasCompleted) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          } else {
                            return SlideTransition(
                              position: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ).drive(Tween<Offset>(
                                  begin: Offset(0, -1.0), end: Offset.zero)),
                              child: child,
                            );
                          }
                        });
                  },
                  child: CircleAvatar(
                    radius: 34,
                    backgroundImage: _avatar != null
                        ? CachedNetworkImageProvider(_avatar)
                        : AssetImage("assets/account_user.png"),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: padding,
            decoration: decoration,
            child: InkWell(
              onTap: () async {
                var s = await showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return _UploadWidget(
                        user: widget.user(),
                      );
                    });
                if (s != null) {
                  setState(() {
                    _avatar = s;
                  });
                  saveUser();
                }
              },
              child: Row(
                children: <Widget>[
                  Text(
                    "My Photo",
                    style: style,
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: CircleAvatar(
                        radius: 18,
                        backgroundImage: _avatar != null
                            ? CachedNetworkImageProvider(_avatar)
                            : AssetImage("assets/account_user.png")),
                  ),
                  Icon(Icons.arrow_forward_ios)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              var s = await Navigator.push(
                  context,
                  CupertinoPageRoute<String>(
                      builder: (context) => PersonalEdit(
                            key: pKey,
                            nickname: _nickname,
                            saveName: (s) => this.saveUser(nickName: s),
                          )));
              if (s != null) {
                setState(() {
                  _nickname = s;
                });
              }
            },
            child: Container(
              padding: padding,
              decoration: decoration,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Nickname",
                      style: style,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "${_nickname ?? _user?.nickname ?? "Not Bound"}",
                    style: style,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              if (_mobile == null) _showDialog("mobile");
            },
            child: Container(
              padding: padding,
              decoration: decoration,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Mobile",
                      style: style,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _mobile ?? "Not Bound",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              if (_email == null) _showDialog("mailbox");
              // String string =
              //   await showValueChoose(hint: "Enter email address");
              //setState(() {
              // _email = string ?? _email;
              //});
            },
            child: Container(
              padding: padding,
              decoration: decoration,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Email",
                      style: style,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _email ?? "Not Bound",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              String string = await showValueChoose(widget: (context) {
                String _x;
                return Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        FlatButton(
                          onPressed: () => Navigator.pop(context, _x ?? "male"),
                          child: Text(
                            "Apply",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Icon(Icons.close, color: Colors.grey))
                      ],
                    ),
                    Expanded(
                      child: CupertinoPicker.builder(
                        backgroundColor: Colors.white,
                        onSelectedItemChanged: (index) {
                          _x = index == 0
                              ? "male"
                              : index == 1
                                  ? "female"
                                  : "unknown";
                        },
                        childCount: 3,
                        itemExtent: 36.0,
                        itemBuilder: (context, index) {
                          var s = index == 0
                              ? "Male"
                              : index == 1
                                  ? "Female"
                                  : "Unknown";
                          return Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "$s",
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              });
              setState(() {
                _gender = string ?? _gender;
              });
            },
            child: Container(
              padding: padding,
              decoration: decoration,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Gender",
                      style: style,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _gender?.toUpperCase() ?? "Not Selected",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
//              final DateTime picked = await showDatePicker(
//                context: context,
//                initialDate: DateTime.now(),
//                firstDate: DateTime(1950, 8),
//                lastDate: DateTime.now(),
//              );
              final DateTime picked = await showModalBottomSheet<DateTime>(
                  context: context,
                  builder: (context) {
                    return _CupertinoPicker();
                  });
              setState(() {
                _date = picked == null
                    ? _date
                    : DateFormat("yyyy-MMM-dd").format(picked) ?? _date;
              });
            },
            child: Container(
              padding: padding,
              decoration: decoration,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Birthday",
                      style: style,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _date ?? "Not Selected",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueChoose extends StatefulWidget {
  final String hint;
  final Widget Function(BuildContext context) widget;

  const _ValueChoose({Key key, this.hint, this.widget}) : super(key: key);

  @override
  __ValueChooseState createState() => __ValueChooseState();
}

class __ValueChooseState extends State<_ValueChoose> {
  var _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: widget.widget == null
          ? Column(
              children: <Widget>[
                TextFormField(
                  controller: _controller,
                  decoration:
                      InputDecoration(hintText: widget.hint ?? "Enter text"),
                ),
                SizedBox(height: 10),
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_controller.text);
                  },
                  child: Text("Confirm"),
                )
              ],
            )
          : widget.widget(context),
    );
  }
}

class _UploadWidget extends StatefulWidget {
  final User user;

  const _UploadWidget({Key key, @required this.user}) : super(key: key);

  @override
  __UploadWidgetState createState() => __UploadWidgetState();
}

class __UploadWidgetState extends State<_UploadWidget> with SuperBase {
  void showFail() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image(
                    height: 120,
                    fit: BoxFit.cover,
                    image: AssetImage("assets/logo_black.png")),
                SizedBox(height: 20),
                Text("Upload Fail",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19))
              ],
            ),
          );
        });
  }

  void showSuccess() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image(
                    height: 120,
                    fit: BoxFit.cover,
                    image: AssetImage("assets/logo_circle.png")),
                SizedBox(height: 20),
                Text("Upload Success",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19))
              ],
            ),
          );
        });
  }

  bool _uploading = false;

  void upload({ImageSource source: ImageSource.gallery}) async {
    var file = await ImagePicker.pickImage(source: source);
    if (file != null) {
      print(file.path);
      setState(() {
        _uploading = true;
      });
      List<int> imageBytes = file.readAsBytesSync();
      //print(imageBytes);
      String base64Image = base64Encode(imageBytes);

      this.ajax(
          url: "api/upload/uploadFile",
          method: "POST",
          auth: true,
          server: true,
          authKey: widget.user?.token,
          jsonData: "\"data:${lookupMimeType(file.path)};base64,$base64Image\"",
          onValue: (source, url) {
            var d = json.decode(source)['data'];
            Navigator.of(context).pop(d);
            showSuccess();
          },
          error: (s, v) {
            print(s);
            showFail();
          },
          onEnd: () {
            setState(() {
              _uploading = false;
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6))),
      padding: EdgeInsets.all(16),
      child: _uploading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () => upload(source: ImageSource.camera),
                    color: color,
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    elevation: 0.7,
                    child: Text(
                      "Take a Photo",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: upload,
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(6)),
                    elevation: 0.2,
                    child: Text(
                      "Upload a Picture",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 25),
                  width: double.infinity,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CupertinoPicker extends StatefulWidget {
  @override
  __CupertinoPickerState createState() => __CupertinoPickerState();
}

class __CupertinoPickerState extends State<_CupertinoPicker> {
  DateTime _dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            InkWell(
              onTap: () => Navigator.pop(context, _dateTime),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
                child: Text(
                  "Apply",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Spacer(),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.grey))
          ],
        ),
        Expanded(
          child: CupertinoDatePicker(
            minuteInterval: 1,
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            maximumDate: DateTime.now(),
            onDateTimeChanged: (DateTime dateTime) {
              setState(() {
                _dateTime = dateTime;
              });
            },
          ),
        ),
      ],
    );
  }
}
