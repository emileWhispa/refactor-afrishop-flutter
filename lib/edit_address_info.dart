import 'dart:convert';

import 'package:afri_shop/Json/Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_country_picker/flutter_country_picker.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class EditAddressInfo extends StatefulWidget {
  final User Function() user;
  final Address address;

  const EditAddressInfo({Key key, @required this.user, @required this.address})
      : super(key: key);

  @override
  _EditAddressInfoState createState() => _EditAddressInfoState();
}

class _EditAddressInfoState extends State<EditAddressInfo> with SuperBase {
  TextEditingController _address;
  TextEditingController _delivery;
  TextEditingController _phone;
  TextEditingController _email;
  var formKey = new GlobalKey<FormState>();
  var _saving = false;
  Country _country;

  String get phone => "${_country?.dialingCode??""}${_phone.text}";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _address = new TextEditingController(text: widget.address.address);
    _phone = new TextEditingController(text: widget.address.phone);
    _delivery = new TextEditingController(text: widget.address.delivery);
    _email = new TextEditingController(text: widget.address.email);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Country.ALL.forEach((el) {
        if( widget.address?.isoCode == el.isoCode){
          setState(() {
            _country = el;
            _phone = new TextEditingController(text: _phone.text.replaceFirst(el.dialingCode, ""));
          });
        }
      });
      if( _country == null){
        setState(() {
          _country = Country.RW;
        });
      }
    });
  }

  void _saveAddress() {
    setState(() {
      _saving = true;
    });
    this.ajax(
        url: "address/${widget.address.addressId}",
        method: "PUT",
        auth: true,
        authKey: widget.user()?.token,
        server: true,
        map: {
          "addressDetail": _address.text,
          "deliveryName": _delivery.text,
          "email": _email.text,
          "isoCode": _country?.isoCode,
          "phone": phone
        },
        onValue: (source, url) {
          var mp = jsonDecode(source);
          if (mp['code'] == 1) {
            Navigator.of(context).pop(Address(_address.text.trim(),
                _delivery.text.trim(), phone, _email.text.trim()));
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
              validator: (s) => s.trim().isEmpty ? "Field required !!" : null,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Align(
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
              validator: validateEmail,
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
