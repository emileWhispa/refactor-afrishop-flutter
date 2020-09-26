import 'dart:convert';

import 'package:afri_shop/SuperBase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'Json/User.dart';

class WithdrawScreen extends StatefulWidget {
  final User Function() user;

  const WithdrawScreen({Key key, @required this.user}) : super(key: key);

  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> with SuperBase {
  TextEditingController _accountController = new TextEditingController();
  TextEditingController _amountController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _accountNameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey<FormState>();
  var _sending = false;
  User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user();
    _emailController = new TextEditingController(text: _user?.email);
    _nameController = new TextEditingController(text: _user?.nickname);
    _nameController = new TextEditingController(text: _user?.nickname);
    WidgetsBinding.instance.addPostFrameCallback((_)=>this.fetchUser());
  }


  Future<void> fetchUser() {
    return this.ajax(
        url: "user/userById/${_user?.id}",
        authKey: _user?.token,
        onValue: (source, url) {
          var js = json.decode(source);
          if( js['code'] == 1) {
            setState(() {
              _user = User.fromJson2(js['data']);
            });
          }
        });
  }


  void validateAndSave() {
    if (_key.currentState?.validate() ?? false) {
      setState(() {
        _sending = true;
      });
      this.ajax(
          url: "discover/withdraw/saveWithdraw",
          server: true,
          authKey: widget.user()?.token,
          method: "POST",
          data: FormData.fromMap({
            "userInfo": widget.user()?.id,
            "amount": _amountController.text,
            "names": _nameController.text,
            "email": _emailController.text,
            "accountName": _accountNameController.text,
            "account": _accountController.text,
          }),
          onValue: (source, url) {
            var js = json.decode(source);
            if (js['code'] == 1) {
              showSuccess(js['message']);
            } else {
              showFail(js['message']);
            }
          },
          onEnd: () {
            setState(() {
              _sending = false;
            });
          });
    }
  }

  void showFail(String fail) {
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
                Text("$fail",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19))
              ],
            ),
          );
        });
  }

  void showSuccess(String success) async {
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
    Navigator.of(context).pop("data");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.maybePop(context);
                })
            : null,
        title: Text("Withdraw"),
        centerTitle: true,
      ),
      body: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(12),
            children: <Widget>[
              Text(
                  "Please verify your account info,\nthe transfer may take up to 1-3 working days."),
              SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [amountValidator],
                          validator: (s) => s.isEmpty
                              ? "Amount is required"
                              : ((double.tryParse(s) ?? 0.0) >
                              _user?.wallet ?? 0)
                                  ? "Can't excedd ${_user?.wallet?.toStringAsFixed(2) ?? 0.00}"
                                  : (double.tryParse(s) ?? 0.0) <= 0 ? "Amount has to be greater than 0" : null,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Amount (Max : \$${_user?.walletStr ?? 0.00})",
                              contentPadding: EdgeInsets.only(left: 7),
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5)))),
                      SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                          controller: _nameController,
                          validator: (s) => s.isEmpty
                              ? "Beneficially name is required"
                              : null,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Beneficially name",
                              contentPadding: EdgeInsets.only(left: 7),
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5)))),
                      SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                          controller: _accountNameController,
                          validator: (s) =>
                              s.isEmpty ? "Bank Name is required" : null,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Bank Name",
                              contentPadding: EdgeInsets.only(left: 7),
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5)))),
                      SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                          controller: _accountController,
                          keyboardType: TextInputType.number,
                          validator: (s) => s.isEmpty
                              ? "Bank Account Number is required"
                              : null,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Bank Account Number",
                              contentPadding: EdgeInsets.only(left: 7),
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5)))),
                      SizedBox(height: 12),
                      TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (s) =>
                              s.isEmpty ? "Email is required" : null,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Email address",
                              contentPadding: EdgeInsets.only(left: 7),
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5)))),
                      SizedBox(height: 12),
                      TextFormField(
                          initialValue: DateFormat("EEEE, dd-MMMM-yyyy")
                              .format(DateTime.now()),
                          enabled: false,
                          decoration: InputDecoration(
                              filled: true,
                              hintText: "Date",
                              contentPadding: EdgeInsets.only(left: 7),
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5)))),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                  height: 43,
                  child: _sending
                      ? CupertinoActivityIndicator()
                      : RaisedButton(
                          onPressed: validateAndSave,
                          elevation: 0.0,
                          color: color,
                          child: Text("Withdraw"),
                        ))
            ],
          )),
    );
  }
}
