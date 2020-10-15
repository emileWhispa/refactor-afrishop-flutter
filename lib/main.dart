import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

import 'Json/User.dart';
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
          inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(fontFamily: 'SF UI Display'),counterStyle: TextStyle(fontFamily: 'SF UI Display')),
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

  Future<void> showLoginModel()async{
   var user = await showModalBottomSheet<User>(context: context,shape:
    RoundedRectangleBorder(
   borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),isScrollControlled: true, builder: (context){
      return Container(
        width: double.infinity,
        constraints:
        BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100),
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(color: Colors.grey.shade100,borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color:Colors.grey.shade100,
                borderRadius: BorderRadius.only(topRight: Radius.circular(6),topLeft: Radius.circular(6))
            ),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: AccountScreen(
              partial: true,
              user: ()=>_user,
              canPop: true,
              callback: _addUser,
              cartState: _cartState,
            ),
          ),
        ),
      );
    });

   if( user != null ){
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

  void _loadVersions(){
    this.ajax(url: "version/getVersionCode",server: true,onValue: (source,url){
      setState(() {
        _versions = (json.decode(source) as Iterable).map((e) => Version.fromJson(e)).where((element) => element.versionSort == version).toList();
        if( _list.isNotEmpty && _versions.first.versionCode != _version){

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
    if( user != null && user.requestHomePage){
      user.requestHomePage = false;
      setState(() {
        _currentTabIndex = 0;
      });
    }else if( user == null ){
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
          user: ()=>_user,
          key: _homePageKey,
          callback: _addUser,
        ),
//        Center(
//          child: Text(
//            "DEVELOPING...",
//            style: TextStyle(fontWeight: FontWeight.bold),
//          ),
//        ),
        Discover(key: _discoverKey,user: ()=>_user,callback: _addUser,cartState: _cartState,showModal: showLoginModel,),
        CartScreen(
          user: ()=>_user,
          key: _cartState,
          goToHome: (){
            setState(() {
              _currentTabIndex = 0;
            });
          },
          callback: _addUser,
        ),
        AccountScreen(
          key: _accountKey,
          user: ()=>_user,
          callback: _addUser,
          cartState: _cartState,
          jumpTo: (index){
            setState(() {
              _currentTabIndex = index;
            });
            if( index == 1){
              _discoverKey.currentState.refreshFollow();
            }
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: IndexedStack(
        children: _list,
        index: _currentTabIndex,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  offset: Offset(-1.2, 0.5),
                  blurRadius: 2.8)
            ]
        ),
        child: SafeArea(
          child: Container(
            height: 49,
            child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.black,
                unselectedLabelStyle:TextStyle(fontFamily: 'DIN Alternate',fontWeight: FontWeight.bold),
                selectedLabelStyle:TextStyle(fontFamily: 'DIN Alternate',fontWeight: FontWeight.bold),
                unselectedItemColor: Colors.grey,
                iconSize: 18,
                unselectedFontSize: 9.4,
                selectedFontSize: 9.4,
                elevation: 0.0,
                currentIndex: _currentTabIndex,
                onTap: (index) async {
                  //_firebaseNotifications?.sendToToken();


                  setState(() {

                    if( _currentTabIndex  == index){
                      switch(index){
                        case 0:{
                          _homePageKey.currentState?.goToTop();
                          break;
                        }
                        case 1:{
                          _discoverKey.currentState?.goToTop();
                          break;
                        }
                        case 2:{
                          _cartState.currentState?.goToTop();
                          break;
                        }
                      }
                    }

                    _currentTabIndex = index;
                  });


                  var cond = index == 2 || index == 3;

                  if( cond && _user == null){
                    await showLoginModel();
                  }

                  if( cond && _user == null ) {
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
                      title: Text("CART",)),
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
  }
}
