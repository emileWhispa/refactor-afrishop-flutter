import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';

import 'Json/User.dart';
import 'Json/choice.dart';
import 'Json/globals.dart' as globals;
import 'Json/version.dart';
import 'Partial/Sender.dart';
import 'SuperBase.dart';
import 'about_information.dart';
import 'new_account_screen.dart';

//import 'archive/second_homepage.dart';
import 'archive/second_homepage.dart';
import 'cart_page.dart';
import 'discover.dart';
import 'firebase_notification_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      title: 'Afrishop',
      theme: ThemeData(
          primaryColor: Color(0xffffe707),
          primarySwatch: Colors.amber,
          inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(fontFamily: 'SF UI Display'),
              counterStyle: TextStyle(fontFamily: 'SF UI Display')),
          appBarTheme: AppBarTheme(
              elevation: 1.6,
              textTheme: TextTheme(
                title: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              )),
          fontFamily: 'SF UI Display'),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, SuperBase {
  int _currentTabIndex = 0;
  var _cartState = new GlobalKey<CartScreenState>();
  var _homePageKey = new GlobalKey<SecondHomepageState>();
  var _discoverKey = new GlobalKey<DiscoverState>();
  User _user;

  FirebaseNotifications _firebaseNotifications;

  var _globalKey = new GlobalKey<__AutoChangeState>();

  Future<void> showLoginModel() async {
    var user = await showModalBottomSheet<User>(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
        isScrollControlled: true,
        builder: (context) {
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 100),
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(15.0))),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(6),
                        topLeft: Radius.circular(6))),
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AccountScreen(
                  partial: true,
                  user: () => _user,
                  canPop: true,
                  callback: _addUser,
                  cartState: _cartState,
                  uploadFile: null,
                ),
              ),
            ),
          );
        });

    if (user != null) {
      _addUser(user);
    }

    return Future.value();
  }

  @override
  void initState() {
    super.initState();
    _firebaseNotifications = new FirebaseNotifications();
    //Sender.scheduleNotification(title: "top");
    _firebaseNotifications.setUpFirebase().then((value) => globals.fcm = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      position = Offset(7.0, MediaQuery.of(context).padding.top + 7);
      this.signedIn((token, user) => this._addUser(user), () {
        _homePageKey.currentState?.showNewCouponDialog(show: true);
      });

      PackageInfo.fromPlatform().then((value) {
        setState(() {
          _version = value.version;
        });
      });
      _loadVersions();
    });
  }

  String _version = "";

  List<Version> _versions = [];

  void _loadVersions() {
    this.ajax(
        url: "version/getVersionCode",
        server: true,
        onValue: (source, url) {
          setState(() {
            _versions = (json.decode(source) as Iterable)
                .map((e) => Version.fromJson(e))
                .where((element) => element.versionSort == version)
                .toList();
            if (_list.isNotEmpty && _versions.first.versionCode != _version) {
              _homePageKey.currentState?.canPop();

              showDialog(
                  context: context,
                  builder: (context) {
                    return UpdateDialog(version: _versions.first);
                  });
            }
          });
        });
  }

  void _addUser(User user) {
    if (user != null && user.requestHomePage) {
      user.requestHomePage = false;
      setState(() {
        _currentTabIndex = 0;
      });
    } else if (user == null) {
      setState(() {
        _currentTabIndex = 0;
      });
    }
    setState(() {
      _user = user;
      _discoverKey.currentState?.recheck();
      _accountKey.currentState?.populate(user);
      _cartState.currentState?.populate(user);
    });
  }

  var _accountKey = new GlobalKey<AccountScreenState>();

  List<Widget> get _list => [
        SecondHomepage(
          cartState: _cartState,
          user: () => _user,
          key: _homePageKey,
          callback: _addUser,
        ),
//        Center(
//          child: Text(
//            "DEVELOPING...",
//            style: TextStyle(fontWeight: FontWeight.bold),
//          ),
//        ),
        Discover(
          key: _discoverKey,
          user: () => _user,
          callback: _addUser,
          cartState: _cartState,
          showModal: showLoginModel,
          uploadFile: uploadPost,
        ),
        CartScreen(
          user: () => _user,
          key: _cartState,
          goToHome: () {
            setState(() {
              _currentTabIndex = 0;
            });
          },
          callback: _addUser,
        ),
        AccountScreen(
          key: _accountKey,
          user: () => _user,
          uploadFile: uploadPost,
          callback: _addUser,
          cartState: _cartState,
          jumpTo: (index) {
            setState(() {
              _currentTabIndex = index;
            });
            if (index == 1) {
              _discoverKey.currentState.refreshFollow();
            }
          },
        ),
      ];

  File _uploadFile;

  Offset position;

  void uploadPost(FormData data, List<Choice> _list) {
    setState(() {
      _sending = true;
      _currentTabIndex = 1;
      _uploadFile = _list.isNotEmpty ? _list.first.file : null;
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    this.ajax(
        url: "discover/post/upload",
        server: true,
        method: "POST",
        authKey: _user?.token,
        data: data,
        progress: (int data, int total) {
          _globalKey.currentState?.change(data, total);
        },
        onValue: (s, v) async {
          print(s);
          print(v);
          for (var x in _list) {
            try {
              await x.file.delete();
            } catch (e) {
              print(e);
            }
          }
          (await prefs).remove(dKey);
          _discoverKey.currentState?.refreshFollow();
          _discoverKey.currentState?.goToTop();
          await showSuccess("Released successfully");
        },
        error: (s, v) => print(v),
        onEnd: () {
          setState(() {
            _sending = false;
          });
        });
  }

  var _sending = false;

  Future<void> showSuccess(String success) async {
    await showDialog(
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
                Text("$success",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
              ],
            ),
          );
        });
  }

  Widget get drag => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 140,
            width: 110,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black54,
                    offset: Offset(10.2, 10.5),
                    blurRadius: 20.8)
              ],
              image: DecorationImage(
                image: _uploadFile == null ? def : FileImage(_uploadFile),
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.65), BlendMode.darken),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15),
              child: SizedBox(
                height: 80.0,
                width: 80.0,
                child: _AutoChange(
                  key: _globalKey,
                ),
              ),
            ),
          ),
        ],
      );

  Widget get positioned => Positioned(
        child: Draggable(
          dragAnchor: DragAnchor.child,
          onDragEnd: (details) {
            setState(() {
              position = details.offset;
            });
          },
          ignoringFeedbackSemantics: true,
          feedback: drag,
          childWhenDragging: Container(),
          child: drag,
        ),
        left: position.dx,
        top: position.dy,
      );

  Widget get indexedStack => IndexedStack(
        children: _list,
        index: _currentTabIndex,
      );

  Widget get body => Scaffold(
        body: indexedStack,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(-1.2, 0.5),
                    blurRadius: 2.8)
              ]),
          child: SafeArea(
            child: Container(
              height: 49,
              child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.black,
                  unselectedLabelStyle: TextStyle(
                      fontFamily: 'DIN Alternate', fontWeight: FontWeight.bold),
                  selectedLabelStyle: TextStyle(
                      fontFamily: 'DIN Alternate', fontWeight: FontWeight.bold),
                  unselectedItemColor: Colors.grey,
                  iconSize: 18,
                  unselectedFontSize: 9.4,
                  selectedFontSize: 9.4,
                  elevation: 0.0,
                  currentIndex: _currentTabIndex,
                  onTap: (index) async {
                    //_firebaseNotifications?.sendToToken();

                    setState(() {
                      if (_currentTabIndex == index) {
                        switch (index) {
                          case 0:
                            {
                              _homePageKey.currentState?.goToTop();
                              break;
                            }
                          case 1:
                            {
                              _discoverKey.currentState?.goToTop();
                              break;
                            }
                          case 2:
                            {
                              _cartState.currentState?.goToTop();
                              break;
                            }
                        }
                      }

                      _currentTabIndex = index;
                    });

                    var cond = index == 2 || index == 3;

                    if (cond && _user == null) {
                      await showLoginModel();
                    }

                    if (cond && _user == null) {
                      setState(() {
                        _currentTabIndex = 0;
                      });
                    }
                  },
                  items: [
                    BottomNavigationBarItem(
                        icon: Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: Image.asset(
                                "assets/home${_currentTabIndex == 0 ? "_" : ""}.png",
                                width: 21.5,
                                fit: BoxFit.fitHeight,
                                height: 22.5)),
                        title: Text("HOME")),
                    BottomNavigationBarItem(
                        icon: Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: Image.asset(
                                "assets/discover${_currentTabIndex == 1 ? "_" : ""}.png",
                                width: 31,
                                fit: BoxFit.fitHeight,
                                height: 23)),
                        title: Text(
                          "DISCOVER",
                        )),
                    BottomNavigationBarItem(
                        icon: Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: Image.asset(
                                "assets/cart${_currentTabIndex == 2 ? "_" : ""}.png",
                                width: 24,
                                fit: BoxFit.fitHeight,
                                height: 21.5)),
                        title: Text(
                          "CART",
                        )),
                    BottomNavigationBarItem(
                        icon: Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: Image.asset(
                                "assets/account${_currentTabIndex == 3 ? "_" : ""}.png",
                                width: 21.5,
                                height: 21.5)),
                        title: Text(
                          "ACCOUNT",
                        )),
                  ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return _sending ? Stack(children: [body, positioned]) : body;
  }
}

class _AutoChange extends StatefulWidget {
  final bool auto;

  const _AutoChange({Key key, this.auto}) : super(key: key);

  @override
  __AutoChangeState createState() => __AutoChangeState();
}

class __AutoChangeState extends State<_AutoChange> {
  int sent = 0;
  int total = 0;

  double get _progress => total == 0 || total == sent ? null : sent / total;

  void change(int sent, int total) {
    setState(() {
      this.sent = sent;
      this.total = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: new CircularProgressIndicator(
              strokeWidth: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
              value: _progress,
            ),
          ),
        ),
        Center(
          child: Text(
            total == 0
                ? "0%"
                : total == sent
                    ? "100%"
                    : "${((_progress) * 100).round()}%",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                decoration: TextDecoration.none),
          ),
        )
      ],
    );
  }
}
