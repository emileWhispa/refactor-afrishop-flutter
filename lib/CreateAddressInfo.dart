import 'dart:convert';

import 'package:afri_shop/Json/Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class CreateAddressInfo extends StatefulWidget {
  final User Function() user;

  const CreateAddressInfo({Key key, @required this.user}) : super(key: key);

  @override
  _CreateAddressInfoState createState() => _CreateAddressInfoState();
}

class _CreateAddressInfoState extends State<CreateAddressInfo> with SuperBase {
  TextEditingController _address = new TextEditingController();
  TextEditingController _delivery = new TextEditingController();
  TextEditingController _phone = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  var formKey = new GlobalKey<FormState>();
  var _saving = false;
  Country _country = Country.RW;

  String get phone => "${_country?.dialingCode ?? "250"}${_phone.text}";

  void _saveAddress() {
    setState(() {
      _saving = true;
    });
    this.ajax(
        url: "address",
        method: "POST",
        auth: true,
        authKey: widget.user()?.token,
        server: true,
        map: {
          "addressDetail": _address.text,
          "deliveryName": _delivery.text,
          "email": _email.text,
          "phone": phone
        },
        onValue: (source, url) {
          var mp = jsonDecode(source);
          if (mp['code'] == 1) {
            var address = Address.fromJson(mp['data']);
            Navigator.of(context).pop(address);
            setDefaultAddress(address);
          } else {
            _showSnack(mp['message']);
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

  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnack(String text) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                })
            : null,
        title: Text("Address"),
        centerTitle: true,
        actions: <Widget>[
          _saving
              ? IconButton(icon: loadBox(), onPressed: null)
              : FlatButton(
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      _saveAddress();
                    }
                  },
                  child: Text("Save"))
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.all(7),
          children: <Widget>[
            TextFormField(
              controller: _address,
              validator: (s) => s.isEmpty ? "Field required !!" : null,
              decoration: InputDecoration(
                  hintText: "Address",
                  hintStyle: TextStyle(color: Colors.grey),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
            TextFormField(
              controller: _delivery,
              validator: (s) => s.isEmpty ? "Field required !!" : null,
              decoration: InputDecoration(
                  hintText: "Delivery name",
                  fillColor: Colors.white,
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
            Container(
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      child: CountryPicker(
                        onChanged: (country) {
                          setState(() {
                            _country = country;
                          });
                        },
                        showDialingCode: true,
                        showName: false,
                        showFlag: true,
                        selectedCountry: _country,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _phone,
                      validator: validateMobile,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                          hintText: "Phone number",
                          hintStyle: TextStyle(color: Colors.grey),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
            TextFormField(
              controller: _email,
              validator: (s)=>s.isEmpty ? null : emailExp.hasMatch(s) ? null : "Valid email is required",
              decoration: InputDecoration(
                  hintText: "Email",
                  fillColor: Colors.white,
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderSide: BorderSide.none)),
            ),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
