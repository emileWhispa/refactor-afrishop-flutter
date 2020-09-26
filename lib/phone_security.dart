import 'dart:async';
import 'dart:convert';

import 'package:afri_shop/Json/country.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Json/User.dart';
import 'country_picker.dart';

import 'SuperBase.dart';

class PhoneSecurity extends StatefulWidget {
    final User Function() user;
    final void Function(User user) callback;

    const PhoneSecurity({Key key,@required this.user,@required this.callback}) : super(key: key);

    @override
    _PhoneSecurityState createState() => _PhoneSecurityState();
}

class _PhoneSecurityState extends State<PhoneSecurity> with SuperBase {
    Country _country;
    Duration _duration = new Duration(seconds: 0);
    Timer _timer;
    bool _valid = false;
    bool _sending = false;
    bool _sending2 = false;
    TextEditingController _controller = new TextEditingController();
    TextEditingController _phoneController = new TextEditingController();

    String phone;


    void showSuccess() async {
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
                            Text("Phone changed successfully",
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))
                        ],
                    ),
                );
            });
        Navigator.of(context).pop();
    }

    void _change() {
        setState(() {
            _sending2 = true;
        });
        reqFocus(context);
        this.ajax(
            url:
            "user/bindPhoneOrEmail?code=${_controller.text}&phone=$phone",
            server: true,
            method: "PUT",
            authKey: widget.user()?.token,
            auth: true,
            onValue: (source, url) {
                var js = json.decode(source);
                if( js['code'] == 1){
                    User user = User.fromJson(js['data']);
                    user.token = widget.user()?.token;
                    print(source);
                    widget.callback(user);
                    this.auth(jwt, jsonEncode(user), user.id);
                    showSuccess();
                }else{
                    platform.invokeMethod("toast",js['message']);
                }
            },onEnd: (){
            setState(() {
                _sending2 = false;
            });
        });
    }

    String get sendPhone => "${_country?.dialingCode ?? "250"}${_phoneController.text}";

    void _getTheCode() {
        setState(() {
            _sending = true;
        });
        this.ajax(
            url: "user/identifyCode/$sendPhone",
            server: true,
            auth: true,
            authKey: widget.user()?.token,
            onValue: (source, url) async {
                var js = jsonDecode(source);
                if( js['code'] == 1) {
                    phone = sendPhone;
                    setState(() {
                        _duration = new Duration(seconds: 60);
                        _timer?.cancel();
                        _timer = Timer.periodic(Duration(seconds: 1), (t) {
                            if (_duration.inSeconds <= 0) {
                                t.cancel();
                            }
                            setState(() {
                                _duration =
                                    Duration(seconds: _duration.inSeconds - 1);
                            });
                        });
                    });
                }else{
                    platform.invokeMethod("toast",js['message']);
                }
            },
            onEnd: () {
                setState(() {
                    _sending = false;
                });
            });
    }


    @override
    void dispose() {
        // TODO: implement dispose
        super.dispose();
        _timer?.cancel();
    }

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
                    "Phone",
                    style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
            ),
            body: ListView(
                padding: EdgeInsets.all(15),
                children: <Widget>[
                    Row(
                        children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white,
                                ),
                                padding: EdgeInsets.all(4),
                                margin: EdgeInsets.only(right: 6),
                                child: CountryPicker(
                                    onChanged: (c) {
                                        setState(() {
                                            _country = c;
                                        });
                                    },
                                    showFlag: false,
                                    showName: false,
                                    showDialingCode: true,
                                    selectedCountry: _country,
                                )),
                            Expanded(
                                child: Container(
                                    height: 43,
                                    child: TextFormField(
                                        controller: _phoneController,
                                        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                            filled: true,
                                            hintText: "Phone number",
                                            contentPadding: EdgeInsets.only(left: 7),
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.circular(5))),
                                    )),
                            ),
                        ],
                    ),
                    SizedBox(height: 10),
                    Container(
                        height: 45,
                        child: TextFormField(
                            controller: _controller,
                            onChanged: (string) {
                                if (string.length == 6) {
                                    setState(() {
                                        _valid = true;
                                    });
                                } else if (_valid) {
                                    setState(() {
                                        _valid = false;
                                    });
                                }
                            },
                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "Code",
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: EdgeInsets.only(left: 10),
                                suffixIcon: _sending
                                    ? CupertinoActivityIndicator()
                                    : Container(
                                    height: 40,
                                    padding: EdgeInsets.all(7),
                                    child: RaisedButton(
                                        onPressed:
                                        _duration.inSeconds > 0 ? () {} : _getTheCode,
                                        color: color.withOpacity(0.2),
                                        padding: EdgeInsets.all(0),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: color,
                                            ),
                                            borderRadius: BorderRadius.circular(6)),
                                        elevation: 0.0,
                                        child: Text(
                                            _duration.inSeconds > 0
                                                ? "${_duration.inSeconds}"
                                                : "Get the code",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                    ),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide.none)),
                        ),
                    ),
                    SizedBox(height: 90),
                    _sending2 ? CupertinoActivityIndicator() : RaisedButton(
                        elevation: 0.0,
                        child: Text(
                            "Submit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: _change,
                        color: color,
                    )
                ],
            ),
        );
    }
}
