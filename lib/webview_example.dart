import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:afri_shop/PaymentSuccess.dart';
import 'package:afri_shop/SuperBase.dart';
import 'package:afri_shop/failure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'Json/User.dart';
import 'Json/order.dart';

class WebViewExample extends StatefulWidget {
  final String url;
  final String title;
  final User Function() user;
  final Order order;
  final bool isDpo;
  final void Function(User user) callback;

  const WebViewExample(
      {Key key, @required this.url, this.title,@required this.user, this.order,@required this.callback, this.isDpo:false})
      : super(key: key);

  @override
  _WebViewExampleState createState() => new _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> with SuperBase {
  String _url;
  double progress = 0;
  bool _loading = false;
  WebViewController _controller;

  void showMd() async {
    //Timer(Duration(seconds: 8), ()=>this.canPop());
    setState(() {
      _loading = true;
    });
    await showGeneralDialog(
        transitionDuration: Duration(seconds: 2),
        barrierDismissible: false,
        context: context,
        barrierColor: Colors.black38,
        pageBuilder: (context, _, __) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            content: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(7)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void goFailure(){
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => PayFailure(user: widget.user,order: widget.order,callback: widget.callback,)));
  }

  bool dpoMatch(String url) => url.contains("dpo/notify") && widget.isDpo;

  void listenChange(String url) async {
    print(url);
    var isMatch = dpoMatch(url);
    if (isMatch) {
      showMd();
      this.ajax(
          url: url,
          absolutePath: true,
          authKey: widget.user()?.token,
          auth: true,
          server: true,
          onValue: (source, url) async {
            var body = json.decode(source);
            Navigator.popUntil(context, (c) => c.isFirst);
            setState(() {
              _loading = true;
            });
            print(source);
            if (body['code'] == 1){
              platform.invokeMethod('logPurchase', <Object, dynamic>{
                "currency":"USD",
                "purchaseAmount":widget.order.totalPrice
              });
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => PaymentSuccess(
                        user: widget.user, order: widget.order,callback: widget.callback,)));}
            else{
              goFailure();
            }
          },
          error: (source, url) {
            Navigator.popUntil(context, (c) => c.isFirst);
            setState(() {
              _loading = true;
            });
            goFailure();
          });
    }



    //String s = await _controller.evaluateJavascript("window.document.getElementsByTagName('body')[0].textContent;");

    //print(s);
    //if(canDecode(s)) print(jsonDecode(s));

//    bool isPureJson = canDecode(s);
//
//    bool isJson = isPureJson && (s.contains('failed') || s.contains('successful') || s.contains('Transaction Failed-AUTHENTICATION_ATTEMPTED'));
//
//
//    var isMatch2 = url.contains("app/loading.html?res");
//    var isMatch3 = url.contains("message=Approved") && url.contains("submitting_mock_form");
    if( !widget.isDpo && url.contains("flutterwave/notify") ){
      showMd();
      verifyFlutterPay(canError: true);
    }
  }


  void verifyFlutterPay({bool canError:false}){
    ajax(
        url: "flutterwave/verifyPay?orderId=${widget.order.orderId}",
        method: "POST",
        server: true,
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) async {
          var body = json.decode(source);
          Navigator.popUntil(context, (c) => c.isFirst);
          setState(() {
            _loading = true;
          });
          if (body['code'] == 1){
            platform.invokeMethod('logPurchase', <Object, dynamic>{
              "currency":"USD",
              "purchaseAmount":widget.order.totalPrice
            });
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => PaymentSuccess(
                      user: widget.user, order: widget.order,callback: widget.callback,)));
          } else if( canError ){
            goFailure();
          }
        },
        error: (source, url) {
          if(canError)
            goFailure();
        });
  }

  @override
  void initState() {
    _url = widget.url;
    super.initState();

//    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//    });
   // flutterWebviewPlugin.onUrlChanged.listen();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            })
            : null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 0.0),
              child: Image.asset(
                "assets/afrishop_logo@3x.png",
                width: 70,
                fit: BoxFit.fitWidth,
              ),
            ),
            Spacer(),
            Expanded(
              child: Text(
                widget.title ?? "Webview",
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            Spacer(),
            IconButton(icon: Icon(Icons.home), onPressed: () {})
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
               // flutterWebviewPlugin.reload();
              })
        ],
      ),
          body: _loading ? Center(
            child: Image.asset("assets/about_logo.png",height: 170,),
          ) : WebView(

              initialUrl: _url,
            onPageFinished: listenChange,
            navigationDelegate: (NavigationRequest request){
//                print(request.url);
//                if( dpoMatch(request.url) ){
//                  return NavigationDecision.prevent;
//                }
//
//                if( _loading && !widget.isDpo){
//                  return NavigationDecision.prevent;
//                }

                return NavigationDecision.navigate;
            },
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
            },
            // TODO(iskakaushik): Remove this when collection literals makes it to stable.
            // ignore: prefer_collection_literals
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            ),
        );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
