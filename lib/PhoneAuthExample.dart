
import 'dart:async';

import 'package:afri_shop/Json/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';

import 'SuperBase.dart';

class PhoneAuthExample extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool login;
  final void Function(FirebaseUser user) onLog;

  const PhoneAuthExample(
      {Key key, @required this.scaffoldKey, this.login: false, this.onLog })
      : super(key: key);

  @override
  _PhoneAuthExampleState createState() => _PhoneAuthExampleState();
}

class _PhoneAuthExampleState extends State<PhoneAuthExample> with SuperBase {
  var phoneNumController = new TextEditingController();

  /// will get an AuthCredential object that will help with logging into Firebase.
  void _verificationComplete(authCredential) {
    FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .then((authResult) async {
      setState(() {
        _loading = false;
      });
      var text = "Success!!! UUID is: ${authResult.user.uid}";
     // var token = (await authResult.user.getIdToken()).token;
      widget.onLog(authResult.user);
      showSnackBar(text);
    }).catchError((v) {
      showSnackBar("Verification failed, wrong code !!!");
      setState(() {
        _loading = false;
        _verify = false;
      });
    });
  }


  void openModal(String verificationId) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return _VerificationWidget(
            verificationId: verificationId,
            callback: _verificationComplete,
          );
        });
  }

  var _code = "";

  int _count = 0;

  var _loading = false;
  var _verify = false;

  String get phoneNumber =>
      "+${_selected?.dialingCode??"250"}${phoneNumController.text}";

  var _verificationId;

  void _inputCode() {
    var _credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _code);
    setState(() {
      _loading = true;
    });
    reqFocus(context);
    _verificationComplete(_credential);
  }


  Timer _timer;

  void _smsCodeSent(String verificationId, List<int> code) {
    // set the verification code so that we can use it to log the user in
    //openModal(verificationId);
    _timer?.cancel();
    setState(() {
      _loading = false;
      _verify = true;
      _verificationId = verificationId;
      _count = 60;
    });
    showSnackBar("SMS code sent");

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _count <= 0) {
        setState(() {
          _verify = false;
        });
      } else if (mounted) {
        setState(() {
          _count = _count - 1;
        });
      } else if (_count <= 0) {
        timer.cancel();
      }else{
        _count = _count - 1;
      }
    });
  }



  void _verifyPhoneNumber(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    reqFocus(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    setState(() {
      _loading = true;
    });
    await _auth.verifyPhoneNumber(
        phoneNumber: '+$phoneNumber',
        timeout: Duration(seconds: 5),
        verificationCompleted: (authCredential) =>
            _verificationComplete(authCredential),
        verificationFailed: (authException) =>
            _verificationFailed(authException, context),
        codeAutoRetrievalTimeout: (verificationId) =>
            _codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [code]) =>
            _smsCodeSent(verificationId, [code]));
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    showSnackBar('time out $verificationId');
    setState(() {
      _loading = false;
      _verify = true;
    });
  }

  void _verificationFailed(authException, BuildContext context) {
    var text = authException.message.toString();
    print("Exception");
    showSnackBar(text);
    print(text);
    setState(() {
      _loading = false;
      _verify = false;
    });
  }




  void showSnackBar(String snackBar) {
    widget.scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text(snackBar)));
  }

  Country _selected = Country.RW;

  var _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:15.0),
          child: Column(
            children: <Widget>[
//              Center(
//                child: CircleAvatar(
//                  radius: 35,
//                  backgroundImage: AssetImage("assets/boys.jpg"),
//                ),
//              ),
//              SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(

                      color: Color(0xffefeeee),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 7),
                    margin: EdgeInsets.only(right: 5),
                    child: CountryPicker(
                      showFlag: true,
                      showName: false,
                      showDialingCode: true,
                      //displays country name, true by default
                      onChanged: (Country country) =>
                          setState(() => _selected = country),
                      selectedCountry: _selected,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: phoneNumController,
                      keyboardType: TextInputType.phone,
                      validator: (str) =>
                          str.isEmpty ? "Phone number field required" : null,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          filled: true,
                          fillColor: Color(0xffefeeee),
                          hintText: "Phone Number",
                          prefixText: '+${_selected?.dialingCode??"250"}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          )),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              _verify
                  ? Row(
                children: <Widget>[
                  PinCodeTextField(
                    maxLength: 6,
                    pinBoxOuterPadding:
                    EdgeInsets.all(4),
                    pinBoxColor: Colors.black12,
                    pinBoxRadius: 0,
                    pinBoxBorderWidth: 1.2,
                    defaultBorderColor:
                    Colors.black12,
                    wrapAlignment:
                    WrapAlignment.spaceBetween,
                    pinBoxHeight: 30,
                    pinBoxWidth: 30,
                    onDone: (s) => this._inputCode(),
                    onTextChanged: (text) {
                      setState(() {
                        _code = text;
                      });
                    },
                  ),
                  _count > 0
                      ? Expanded(
                        child: Padding(
                    padding:
                    EdgeInsets.only(
                          left: 5),
                    child: Text(
                        "$_count seconds",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle,
                    ),
                  ),
                      )
                      : SizedBox.shrink(),
                ],
              )
                  : SizedBox.shrink(),
              SizedBox(height: 13),
             _loading ? Center(
               child: CircularProgressIndicator(),
             ) : SizedBox(
                height: 42,
                width: double.infinity,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    widget.login
                        ? "SIGN IN"
                        : _verify ? "VERIFY" : "SEND CODE",
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  onPressed: _verify
                      ? _inputCode
                      : () => _verifyPhoneNumber(context),
                  color: color,
                ),
              ),
            ], // Widget
          ),
        ));
  }
}

class _VerificationWidget extends StatefulWidget {
  final String verificationId;
  final void Function(dynamic authCredential) callback;

  const _VerificationWidget(
      {Key key, @required this.verificationId, @required this.callback})
      : super(key: key);

  @override
  __VerificationWidgetState createState() => __VerificationWidgetState();
}

class __VerificationWidgetState extends State<_VerificationWidget> {
  var _controller = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void verify() {

  }

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
      child: Column(
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: InputDecoration(
                labelText: "Verify sent Code",
                prefixText: "code(6)",
                border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              child: RaisedButton(
                onPressed: verify,
                child: Text("Verify"),
              )),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
