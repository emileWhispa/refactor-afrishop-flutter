import 'dart:convert';

import 'package:afri_shop/feedback_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class FeedbackScreen extends StatefulWidget {
  final User user;

  const FeedbackScreen({Key key,@required this.user}) : super(key: key);
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SuperBase {
  TextEditingController _controller = new TextEditingController();
  var _formKey = new GlobalKey<FormState>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _sending = false;


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
                Text("Feedback submitted successfully",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
              ],
            ),
          );
        });
  }


  void sendFeedback() {
    if( !_formKey.currentState.validate() ) return;
    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "feedback",
        method: "POST",
        auth: true,
        authKey: widget.user?.token,
        server: true,
        map:{"feedbackId": unique, "question": _controller.text},
        onValue: (source, url) {
          var data = json.decode(source);
          //_showSnack(data['message']);
          _controller.clear();
          showSuccess();
        },
        error: (s, v) {
          print(s);
        },onEnd: (){

      setState(() {
        _sending = false;
      });
    });
  }

  void _showSnack(String data){
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(data)));
  }

  void goList(){
    Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>FeedbackList(user: widget.user)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text(
          "Feedback",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.format_list_numbered_rtl), onPressed: goList)
        ],
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: new BorderRadius.vertical(
                      bottom: new Radius.elliptical(
                          MediaQuery.of(context).size.width, 33.0)),),
              ),
              Form(
                key: _formKey,
                child: Card(
                  margin: EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "Tell Us About Your Experience",
                            style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Color(0xff272626)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(width: 1.5, color: Colors.grey),
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight: 250.0, minHeight: 200),
                                  child: new Scrollbar(
                                    child: new SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: TextFormField(
                                        validator: (s)=>s.trim().isEmpty ? "Field is required !!!":null,
                                          enabled: true,
                                          maxLines: null,
                                          textAlign: TextAlign.left,
                                          controller: _controller,
                                          decoration: InputDecoration.collapsed(
                                              hintText:
                                                  "Describe your experience adding to cart",hintStyle: TextStyle(color: Color(0xffCCCCCC)))),
                                    ),
                                  ),
                                ))),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Questions about your order will not be answeredhere, Please contact CustomerService",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Feel free to email official@afrieshop.com with furtherdetails or screenshots of errors or bugs",style: TextStyle(color: Colors.grey),),
                        SizedBox(height: 40),
                        Container(
                            width: double.infinity,
                            child: _sending ? CupertinoActivityIndicator() : RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              color: color,
                              elevation: 0.0,
                              onPressed: sendFeedback,
                              child: Text(
                                "Submit",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
