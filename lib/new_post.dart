import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:afri_shop/Json/draft.dart';
import 'package:afri_shop/Json/hashtag.dart';
import 'package:afri_shop/new_tag_screen.dart';
import 'package:afri_shop/product_tag.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';

import 'Json/User.dart';
import 'Json/choice.dart';
import 'SuperBase.dart';

class NewPostScreen extends StatefulWidget {
  final User Function() user;
  final void Function(User user) callback;
  final void Function(FormData data, List<Choice> list) uploadFile;

  const NewPostScreen(
      {Key key, @required this.user, @required this.callback, @required this.uploadFile})
      : super(key: key);

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> with SuperBase {
  var _controller = new TextEditingController();
  var _titleController = new TextEditingController();
  var _formKey = new GlobalKey<FormState>();
  var _list = <Choice>[];
  var _hashtags = <Hashtag>[];
  var _loaded = <Hashtag>[];
  var _sending = false;
  var _loadingHashTag = false;
  FocusNode _focusNode = new FocusNode();
  ScrollController _scrollController = new ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var str = (await prefs).getString(dKey);
      if (str != null) {
        var drf = Draft.fromJson(json.decode(str));
        _titleController.text = drf.caption;
        _controller.text = drf.description;
        setState(() {
          _list = drf.files;
        });
      }
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _loadingHashTag) {
        setState(() {
          _loadingHashTag = false;
        });
      }
    });
    _controller.addListener(() {
      var str = _controller.text;
      var s = str.isNotEmpty ? str.substring(str.length - 1) : str;
      if (s == "#") {
        setState(() {
          _loadingHashTag = true;
        });
      } else if (s.trim() == "") {
        checkTags(str);
      } else if (_loadingHashTag) {
        _searchHash(str
            .split("#")
            .last);
      }
    });
    _titleController.addListener(() {
      var str = _titleController.text;
      var s = str.isNotEmpty ? str.substring(str.length - 1) : str;
      if (s == "#") {
        setState(() {
          _loadingHashTag = true;
        });
      } else if (s.trim() == "") {
        checkTags(str);
      } else if (_loadingHashTag) {
        _searchHash(str
            .split("#")
            .last);
      }
    });
  }

  var _currentQuery = "";

  void _searchHash(String query) {
    setState(() {
      _currentQuery = query;
      _loadingHashTag = true;
      _loaded.clear();
    });
    this.ajax(
        url: "searchHashtags/${Uri.encodeComponent(query)}?pageNo=0&pageSize=8",
        authKey: widget
            .user()
            ?.token,
        server: true,
        onValue: (source, url) {
          Iterable map = json.decode(source);
          setState(() {
            _loaded = map.map((f) => Hashtag.fromJson(f)).toList();
          });
        },
        error: (s, v) => print(s));
  }

  List<Hashtag> findHashtags(String searchText) =>
      RegExp(r"\B#\w\w+")
          .allMatches(searchText)
          .map((f) => Hashtag(f.group(0)))
          .toList();

  Future<bool> willPop() async {
    if (_controller.text
        .trim()
        .isNotEmpty ||
        _titleController.text
            .trim()
            .isNotEmpty ||
        _list.isNotEmpty) {
      await showCupertinoModalPopup(
          context: context,
          builder: (context) =>
          new CupertinoAlertDialog(
            title: new Text("Confirm To Save Draft"),
            content: new Text("Do you want to save a draft ?"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  save(
                      dKey,
                      Draft(_titleController.text, _controller.text,
                          _list.toList()));
                  Navigator.pop(context);
                },
                child: Text("Confirm"),
              )
            ],
          ));
      if (!_sending) Navigator.pop(context);
      return false;
    }

    return true;
  }


  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

  Future<File> func(File file) async {
    Directory appDocumentDir = await getTemporaryDirectory();
    String rawDocumentPath = appDocumentDir.path;
    String outputPath =  "$rawDocumentPath/$unique.mp4";
    await _flutterFFmpeg.execute("-i ${file.path} -c:v mpeg4 $outputPath");
    return new File(outputPath);
  }

  Future<File> writeToFile(ByteData data, {String extension: ""}) async {
    final buffer = data.buffer;

    final directory = await getApplicationDocumentsDirectory();
    final myImagePath = '${directory.path}/afri_shop';
    final myImgDir = await new Directory(myImagePath).create();
    var _file = new File("${myImgDir.path}/$unique$extension");
    _file.createSync();
    _file.writeAsBytesSync(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return _file;
  }

  void pickMulti() async {
    var num = 9 - _list.length;
    Choice choice;
    if (num > 0) {
      var list = await MultiImagePicker.pickImages(maxImages: num);
      var x = 0;
      for (var f in list) {
        var file = await writeToFile(await f.getByteData());
        print(file.lengthSync());
        try{
         var _file =
          file.lengthSync() > 500000 ? await FlutterNativeImage.compressImage(
              file.path) : file;
         file = _file == null ? file : _file;
        }catch(e){

        }
        print(file.lengthSync());
        var c = Choice("#dribble", file, true);
        _list.add(c);

        if (x == 0) choice = c;

        x++;
      }
      if (choice != null) {
        _navToTag(choice, 0);
      }
      setState(() {});
    }
  }


  void sendPost() {
    if (!_formKey.currentState.validate()) return;

    if (_list.where((element) => element.file != null).isEmpty) {
      platform.invokeMethod("toast", "Select photos");
      return;
    }


    reqFocus(context);

    var data = new FormData();

    data.files.addAll(_list
        .map((f) => f.file)
        .map((f) =>
        MapEntry(
            "files",
            MultipartFile.fromFileSync(f.path,
                filename: "$unique${getName(f)}")))
        .toList());

    data.files.addAll(_list
        .where((f) => f.thumb != null)
        .map((f) => f.thumb)
        .map((f) =>
        MapEntry(
            "thumbs",
            MultipartFile.fromFileSync(f.path,
                filename: "$unique${getName(f)}")))
        .toList());

    widget.user().toServerModel().forEach((key, value) {
      data.fields.add(MapEntry(key, "$value"));
    });
    data.fields.add(MapEntry("title", _titleController.text));
    data.fields.add(MapEntry("description", _controller.text));
    data.fields.add(MapEntry("hashtags", jsonEncode(_hashtags)));
    data.fields.add(MapEntry("category", "images"));
    data.fields.add(
        MapEntry("tags", jsonEncode(_list.map((f) => f.toJsonOld()).toList())));

    if (widget.uploadFile != null)
      widget.uploadFile(data, _list);

//    var map = {
//      "title": _titleController.text,
//      "description": _controller.text,
//      "hashtags": ,
//      "category": "images",
//    };
    //_scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

  }


  Future<File> writeToGallery(File file) async {
    final directory = await getExternalStorageDirectory();
    final myImagePath = '${directory.path}/afri_shop';
    final myImgDir = await new Directory(myImagePath).create();
    var _file = new File("${myImgDir.path}/$unique${getName(file)}");
    _file.writeAsBytesSync(file.readAsBytesSync());
    _file.createSync();
    return _file;
  }

  Future<void> _shareImage() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Post Created Successfully, Share On instagram"),
            content: Image.asset("assets/insta.png", height: 70),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: Text("CANCEL")),
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (await Permission.storage
                        .request()
                        .isGranted) {
                      try {
                        if (_list.isEmpty) return;

                        final result = await writeToGallery(_list[0].file);

                        platform.invokeMethod('shareFile', {
                          "file": result.path,
                          "type": _list[0].isImage ? "image/*" : "video/*",
                        });
                      } catch (e) {
                        print('Share error: $e');
                      }
                    }
                  },
                  child: Text("SHARE")),
            ],
          );
        });
    return Future.value();
  }

  void _delete() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) =>
        new CupertinoAlertDialog(
          title: new Text("Confirm To Delete"),
          content: new Text("Delete This Address ?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _list.removeWhere((f) => f.selected);
                });
              },
              child: Text("Confirm"),
            )
          ],
        ));
  }

  Widget get _area =>
      Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          margin: EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              border: Border(
                  bottom: new BorderSide(color: Colors.grey.shade300))),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 250.0, minHeight: 170),
            child: new Scrollbar(
              child: new SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: TextFormField(
                    validator: (s) =>
                    s
                        .trim()
                        .isEmpty ? "Field is required !!!" : null,
                    enabled: true,
                    maxLines: null,
                    textAlign: TextAlign.left,
                    onChanged: (s) {
                      setState(() {});
                    },
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration:
                    InputDecoration.collapsed(hintText: "Add description")),
              ),
            ),
          ));

  String replaceLast(String string, String from, String to) {
    int lastIndex = string.lastIndexOf(from);
    if (lastIndex < 0) return string;
    String tail = string.substring(lastIndex).replaceFirst(from, to);
    return string.substring(0, lastIndex) + tail;
  }

  void _appendCharacters(String char) {
    String oldText = _controller.text;
    String newText = oldText + " ";
    newText = replaceLast(newText, '#$_currentQuery', char);
    var newValue = _controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: oldText.length, //offset to Last Character
      ),
      composing: TextRange.empty,
    );

    _controller.value = newValue;
    checkTags(newText);
  }

  void checkTags(String str) {
    setState(() {
      _loadingHashTag = false;
    });
    var list = findHashtags(str);
    setState(() {
      list.forEach((f) {
        if (!_hashtags.any((x) => x.name == f.name)) {
          _hashtags.add(f);
        }
      });
      _hashtags =
      _hashtags.length > 9 ? _hashtags.sublist(0, 9).toList() : _hashtags;
    });
  }

  void _navToTag(Choice choice, index) async {
    if (_sending) return;
    var c = await Navigator.push(
        context,
        CupertinoPageRoute<Choice>(
            builder: (context) =>
                ProductTag(
                  choice: choice,
                  list: [],
                  user: widget.user,
                  callback: widget.callback,
                )));
    if (c != null) {
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
      onWillPop: willPop,
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () async {
                var b = await willPop();
                if (b) {
                  Navigator.pop(context);
                }
              })
              : null,
          title: Text("New Post",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: <Widget>[
            _list
                .where((f) => f.selected)
                .isNotEmpty
                ? FlatButton(
              onPressed: _delete,
              child: Text("Delete"),
              textColor: Colors.red,
            )
                : FlatButton(onPressed: sendPost, child: Text("Release"))
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3),
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(5),
                    itemCount: _list.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _list.length) {
                        return InkWell(
                            onTap: () async {
                              if (_sending) return;

                              if (_list.length > 8) {
                                platform.invokeMethod(
                                    "toast", "Can't exceed 9 photos");
                                return;
                              }

                              var source = await showModalBottomSheet<bool>(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6))),
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            child: RaisedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              color: color,
                                              padding: EdgeInsets.all(10),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(6)),
                                              elevation: 0.7,
                                              child: Text(
                                                "Picture",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 15),
                                            width: double.infinity,
                                            child: RaisedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              color: Colors.white,
                                              padding: EdgeInsets.all(10),
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(6)),
                                              elevation: 0.2,
                                              child: Text(
                                                "Video",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
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
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });

                              if (source == null) return;

                              if (source) {
                                pickMulti();
                                return;
                              }

                              var filePath = await ImagePicker().getVideo(
                                source: ImageSource.gallery,
                                maxDuration: Duration(seconds: 300),
                              );


                              var x = await filePath.readAsBytes();

                              var file = await writeToFile(
                                  x.buffer.asByteData(),
                                  extension: ".mp4");

                              if (file == null) return;
                              var choice = Choice(null, file, source);
                              if (!source) {
                                final uint8list =
                                await VideoCompress.getFileThumbnail(
                                  file.path,
                                );
                                //choice.file = ;
                                setState(() {
                                  _sending = true;
                                });
                                print(file.lengthSync());
                                choice.file = await func(file);
                                choice.file = choice.file == null ? file : choice.file;
                                setState(() {
                                  _sending = false;
                                });
                                print(choice.file.lengthSync());
                                choice.thumb = uint8list;
                              }


                              if (source) {
                                choice = await Navigator.of(context)
                                    .push(CupertinoPageRoute<Choice>(
                                    builder: (context) =>
                                        ProductTag(
                                          choice: choice,
                                          list: [],
                                          user: widget.user,
                                          callback: widget.callback,
                                        )));
                              }
                              setState(() {
                                _list.add(choice);
                              });
                            },
                            child: Container(
                                child: Image(
                                    image: AssetImage("assets/add_photo.png"),
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover)));
                      }

                      var choice = _list[index];

                      var cont = Container(
                        padding: choice.selected ? EdgeInsets.all(5) : null,
                        child: InkWell(
                            onLongPress: () {
                              setState(() {
                                choice.selected = !choice.selected;
                              });
                            },
                            onTap: () async {
                              if (_list
                                  .where((f) => f.selected)
                                  .isNotEmpty) {
                                setState(() {
                                  choice.selected = !choice.selected;
                                });

                                return;
                              }

                              if (!choice.isImage) return;

                              _navToTag(choice, index);
                            },
                            child: choice.isImage
                                ? Image(
                              image: FileImage(choice.file),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                                : Container(
                              decoration: BoxDecoration(
                                image: choice.thumb != null
                                    ? DecorationImage(
                                    image: FileImage(choice.thumb),
                                    fit: BoxFit.cover)
                                    : null,
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Center(
                                child: Icon(Icons.videocam),
                              ),
                            )),
                      );

                      return choice.selected
                          ? Stack(
                        children: <Widget>[
                          cont,
                          Positioned(
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      choice.selected = false;
                                    });
                                  },
                                  child: Center(
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  )))
                        ],
                      )
                          : cont;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        TextFormField(
                          controller: _titleController,
                          maxLength: 50,
                          validator: (s) =>
                          s
                              .trim()
                              .isEmpty ? "Required !!!" : null,
                          decoration: InputDecoration(
                              hintText: "Add title ...",
                              enabledBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      color: Colors.grey.shade300))),
                        ),
                        _loadingHashTag
                            ? Positioned(
                          child: Center(
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 2,
                                child: _loaded.isNotEmpty
                                    ? Container(
                                  height: 100,
                                  child: ListView(
                                    children: _loaded
                                        .map((f) =>
                                        InkWell(
                                          onTap: () =>
                                              this
                                                  ._appendCharacters(
                                                  f.name),
                                          child: Container(
                                              padding: EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                  10,
                                                  vertical: 5),
                                              child: Text(
                                                  "${f.name}")),
                                        ))
                                        .toList(),
                                  ),
                                )
                                    : Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: <Widget>[
                                      CupertinoActivityIndicator(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0),
                                        child: Text("Loading hashtags"),
                                      )
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    border: Border.all(
                                        color: Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(5)),
                              )),
                          bottom: 0,
                        )
                            : SizedBox.shrink()
                      ],
                    ),
                    _area,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("${_controller.text.length}/50000",
                          style: TextStyle(color: Colors.grey, fontSize: 12.1)),
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: FlatButton(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4)),
                            onPressed: () async {
                              if (_sending) return;

                              var ls = await Navigator.of(context)
                                  .push(CupertinoPageRoute<List<Hashtag>>(
                                  builder: (context) =>
                                      NewTagScreen(
                                        selected: _hashtags,
                                        user: widget.user,
                                      )));
                              if (ls != null) {
                                setState(() {
                                  _hashtags = ls;
                                });
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.add),
                                ),
                                Text("Add Tag"),
                              ],
                            ))),
//                  IconButton(
//                      onPressed: _shareImage,
//                      icon: Image.asset(
//                        "assets/insta.png",
//                        height: 35,
//                      )),
                    Text(
                      "${_hashtags.map((f) => f.name).join(", ")}",
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xff999999),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
