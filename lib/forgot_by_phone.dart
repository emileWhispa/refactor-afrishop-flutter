import 'dart:convert';

import 'package:afri_shop/reset_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Json/country.dart';
import 'country_picker.dart';

import 'SuperBase.dart';

class ForgotByPhone extends StatefulWidget {
  @override
  _ForgotByPhoneState createState() => _ForgotByPhoneState();
}

class _ForgotByPhoneState extends State<ForgotByPhone> with SuperBase {
  var phone = new TextEditingController();
  var form = new GlobalKey<FormState>();

  String get getPhone => "$_code${phone.text}";

  bool _sending = false;



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

  void _sendCode() async {
    if (!form.currentState.validate()) return;

    setState(() {
      _sending = true;
    });
    this.ajax(
        url: "login/checkAccount?name=$getPhone",
        server: true,
        onValue: (source, v) async {
          print(source);
          var j = jsonDecode(source);
          if (j['code'] == 1 && j['data']['available'] == false) {
            var x = await Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => ResetPassword(
                  phone: getPhone,
                  isEmail: false,
                )));
            if (x != null) {
              Navigator.pop(context,"put data");
            }
          }else{
            showFail("Phone number Not Found");
          }
        },onEnd: (){
      setState(() {
        _sending = false;
      });
    });
  }



  String get _code => _country?.dialingCode ?? "250";

  Country _country;

  bool _valid = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.maybePop(context);
                })
            : null,
        title: Text(
          "Forgot Password",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: form,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Reset Your Password",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "To reset your password, enter your phone number below and follow the instructions in the sms we'll send you.",
              style: TextStyle(color: Color(0xff999999)),
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 48,
                  margin: EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3)),
                  padding: EdgeInsets.all(5),
                  child: CountryPicker(
                    onChanged: (c) {
                      setState(() {
                        _country = c;
                      });
                    },
                    selectedCountry: _country,
                    showFlag: false,
                    showName: false,
                    showDialingCode: true,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: TextFormField(
                      controller: phone,
                      onChanged: (string) {
                        //var p = "0$string";
                        var b = string.length == 9 || string.length == 10 || string.length == 11;
                        if (!_valid && b) {
                          setState(() {
                            _valid = true;
                          });
                        } else if (_valid && !b) {
                          setState(() {
                            _valid = false;
                          });
                        }
                      },
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.phone,
                      validator: (s) =>
                          s.length < 9 ? "Valid phone number required" : null,
                      decoration: InputDecoration(
                          hintText: "Phone number",
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.only(left: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                ),
              ],
            ),
            Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Reset via Email Address",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )),
            SizedBox(
              height: 110,
            ),
            SizedBox(
              width: _sending ? 45 : double.infinity,
              height: 45,
              child: _sending
                  ? Align(alignment: Alignment.center, child: loadBox())
                  : RaisedButton(
                      onPressed: _valid ? _sendCode : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                      elevation: 0.0,
                      color: _valid ? color : Color(0xffCCCCCC),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xff272626).withOpacity(0.5)),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
