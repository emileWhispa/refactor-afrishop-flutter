
import 'package:flutter/material.dart';
import 'package:afri_shop/payment_card_validation.dart';
import 'package:flutter/cupertino.dart';

class CardPayment extends StatefulWidget {
  CardPayment({Key key, this.title, this.email, this.price}) : super(key: key);
  final String title;
  final String email;
  final double price;

  @override
  _CardPaymentState createState() => new _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidate = false;

  var _card = new PaymentCard();
  FocusNode myFocusNode = new FocusNode();
  bool _isCard = true;

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    //numberController.addListener(_getCardTypeFrmNumber);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }



}
