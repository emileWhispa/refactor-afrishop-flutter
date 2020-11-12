import 'package:afri_shop/payment_card.dart';
import 'package:afri_shop/payment_card_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'Json/User.dart';
import 'Json/flutter_wave.dart';
import 'SuperBase.dart';
import 'input_formatters.dart';

class NewItem {
  bool isExpanded;
  final String header;
  final String iconpic;
  final int index;

  NewItem(this.index, this.isExpanded, this.header, this.iconpic);
}

double discretevalue = 2.0;
double hospitaldiscretevalue = 25.0;

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class FlutterForm extends StatefulWidget {
  final String email;
  final double price;
  final double priceZmk;
  final User Function() user;
  final Flutterwave flutterwave;

  const FlutterForm(
      {Key key,
      @required this.email,
      @required this.price,
      @required this.user,
      this.flutterwave,@required this.priceZmk})
      : super(key: key);

  @override
  _FlutterFormState createState() => _FlutterFormState();
}

class _FlutterFormState extends State<FlutterForm> with SuperBase {
  var _cvvController = new TextEditingController();
  var _phoneController = new TextEditingController();
  var _yearController = new TextEditingController();

  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();

  var _formKey = new GlobalKey<FormState>();
  FocusNode myFocusNode = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.flutterwave != null && !widget.flutterwave.isPhone ) {
      numberController =
          new TextEditingController(text: widget.flutterwave.card);
      _cvvController = new TextEditingController(text: widget.flutterwave.cvv);
      _yearController = new TextEditingController(
          text: "${widget.flutterwave.month}/${widget.flutterwave.year}");
    }

    if (widget.flutterwave != null && widget.flutterwave.isPhone ) {
      _phoneController =
          new TextEditingController(text: widget.flutterwave.phone);
    }else{

      _phoneController =
      new TextEditingController(text: "260");
    }

    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  void useCard() async {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                CardPayment(price: widget.price, email: widget.email)));
  }



  FocusNode focusNode = new FocusNode();
  FocusNode focusNode1 = new FocusNode();
  FocusNode focusNode2 = new FocusNode();
  FocusNode focusNode3 = new FocusNode();


  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = new Scaffold(
        appBar: new AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.maybePop(context);
                  })
              : null,
          title: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Image.asset(
                  "assets/afrishop_logo@3x.png",
                  width: 70,
                  fit: BoxFit.fitWidth,
                ),
              ),
              Expanded(
                  child: Text(
                "Flutterwave",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
            ],
          ),
        ),
        backgroundColor: Colors.grey.shade200,
        body: Center(
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              shrinkWrap: true,
              children: [
                Card(
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage("assets/rave-logo.png"),
                                radius: 30,
                              ),
                              Spacer(),
                              Text(
                                "Afrishop".toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: Color(0xfffef6e9)),
                          padding: EdgeInsets.all(30),
                          child: _selectedIndex == 0 ? phoneWidget : cardWidget,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = _selectedIndex == 0 ? 1 : 0;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Image.asset("assets/rave-small.png"),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(_selectedIndex == 1
                                      ? "Pay with Mobile Money"
                                      : "Pay with Card"),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4)
                      ),
                      margin: EdgeInsets.symmetric(vertical: 30),
                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                        child:Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/secure-rave.png"),
                            Padding(
                              padding: const EdgeInsets.only(left:8.0),
                              child: Text("SECURED BY FLUTTERWAVE",style: TextStyle(
                                color: Color(0xfff5a623),
                                fontWeight: FontWeight.bold
                              ),),
                            )
                          ],
                        )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
    return scaffold;
  }

  int _selectedIndex = 0;

  GlobalKey _toolTipKey = GlobalKey();

  Widget get phoneWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(style: TextStyle(color: Colors.black), children: [
            TextSpan(text: "ZMK", style: TextStyle(fontSize: 13)),
            TextSpan(
                text: " ${widget.priceZmk}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ])),
          Text("${widget.email}"),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () => focusNode.requestFocus(),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade400,
                        offset: Offset(0.4, 0.4),
                        blurRadius: 0.4)
                  ]),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PHONE NUMBER"),
                  TextFormField(
                    focusNode: focusNode,
                    controller: _phoneController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration.collapsed(
                        hintText: "",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5))),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 45,
            margin: EdgeInsets.only(top: 15),
            child: RaisedButton(
              onPressed: () {
                if( validateMobile(_phoneController.text) != null ){
                  platform.invokeMethod("toast","Invalid mobile phone");
                  return;
                }
                var name = widget.user()?.username;
                var card = Flutterwave(
                    _paymentCard.number,
                    "RWF",
                    _cvvController.text,
                    widget.email,
                    name,
                    name,
                    _paymentCard.month,
                    _paymentCard.year,
                    _phoneController.text ?? widget.user()?.phone ?? "");

                card.isPhone = true;

                Navigator.pop(context, card);
              },
              elevation: 1.6,
              color: Color(0xffecb356),
              textColor: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    "Pay ZMK ${widget.priceZmk}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  )
                ],
              ),
            ),
          ),
        ],
      );


  Widget get cardWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(style: TextStyle(color: Colors.black), children: [
            TextSpan(text: "USD", style: TextStyle(fontSize: 13)),
            TextSpan(
                text: " \$${widget.price}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ])),
          Text("${widget.email}"),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () => focusNode1.requestFocus(),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(3),
                      topLeft: Radius.circular(3)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade400,
                        offset: Offset(0.4, 0.4),
                        blurRadius: 0.4)
                  ]),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("CARD NUMBER"),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: focusNode1,
                          controller: numberController,
                          validator: CardUtils.validateCardNum,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(19),
                            new CardNumberInputFormatter()
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration.collapsed(
                              hintText: "0000 0000 0000 0000",

                              hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ),
                      CardUtils.getCardIcon(_paymentCard.type)
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => focusNode2.requestFocus(),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(3)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade400,
                              offset: Offset(0.4, 0.4),
                              blurRadius: 0.4)
                        ]),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("VALID TILL"),
                        TextFormField(
                          focusNode: focusNode2,
                          controller: _yearController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(4),
                            new CardMonthInputFormatter()
                          ],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration.collapsed(
                              hintText: "MM / YY",
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5))),
                          validator: CardUtils.validateDate,
                          onSaved: (value) {
                            List<String> expiryDate =
                            CardUtils.getExpiryDate(value);
                            _paymentCard.month = expiryDate[0];
                            _paymentCard.year = expiryDate[1];
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    focusNode3.requestFocus();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(3)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade400,
                              offset: Offset(0.4, 0.4),
                              blurRadius: 0.4)
                        ]),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text("CVV")),
                            GestureDetector(
                              onTap: () {
                                final dynamic tooltip =
                                    _toolTipKey.currentState;
                                tooltip?.ensureTooltipVisible();
                              },
                              child: Tooltip(
                                  key: _toolTipKey,
                                  message:
                                      "The CVV is a 3 digit security code located at the back of your card.",
                                  child: Text(
                                    "What is this ?",
                                    style: TextStyle(fontSize: 12),
                                  )),
                            )
                          ],
                        ),
                        TextFormField(
                          focusNode: focusNode3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            new LengthLimitingTextInputFormatter(4),
                          ],
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration.collapsed(
                              hintText: "123",
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(5))),
                          validator: CardUtils.validateCVV,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 45,
            margin: EdgeInsets.only(top: 15),
            child: RaisedButton(
              onPressed: () {
                if( CardUtils.validateCardNum(numberController.text) != null){
                  focusNode1.requestFocus();
                  platform.invokeMethod("toast","Invalid Card number");
                  return;
                }
                if( CardUtils.validateDate(_yearController.text) != null){
                  focusNode2.requestFocus();
                  platform.invokeMethod("toast","Invalid Card Expiry Date");
                  return;
                }
                if( CardUtils.validateCVV(_cvvController.text) != null){
                  focusNode3.requestFocus();
                  platform.invokeMethod("toast","Invalid CVV number");
                  return;
                }

                _paymentCard.number =
                    CardUtils.getCleanedNumber(
                        numberController.text);
                var name = widget.user()?.display() ?? "";

                List<String> expiryDate =
                CardUtils.getExpiryDate(
                    _yearController.text);
                _paymentCard.month = expiryDate[0];
                _paymentCard.year = expiryDate[1];
                var card = Flutterwave(
                    _paymentCard.number,
                    "RWF",
                    _cvvController.text,
                    widget.email,
                    name,
                    name,
                    _paymentCard.month,
                    _paymentCard.year,
                    widget.user()?.phone ?? "");

                card.isPhone = false;

                Navigator.pop(context, card);
              },
              elevation: 1.6,
              color: Color(0xffecb356),
              textColor: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Text(
                    "Pay USD \$${widget.price}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  )),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  )
                ],
              ),
            ),
          ),
        ],
      );

  Widget build2(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () => useCard(),
                  child: Container(
                    width: 500,
                    height: 60,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0, top: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            child: Image.asset(
                              "assets/payment_icon.png",
                              width: 20.0,
                              height: 20.0,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Pay with Card'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }



//  Widget _getPayButton() {
//    if (Platform.isIOS) {
//      return new CupertinoButton(
//        onPressed: _validateInputs,
//        color: CupertinoColors.activeBlue,
//        child: const Text(
//          Strings.pay,
//          style: const TextStyle(fontSize: 17.0),
//        ),
//      );
//    } else {
//      return new RaisedButton(
//        onPressed: _validateInputs,
//        color: Colors.deepOrangeAccent,
//        splashColor: Colors.deepPurple,
//        shape: RoundedRectangleBorder(
//          borderRadius: const BorderRadius.all(const Radius.circular(100.0)),
//        ),
//        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
//        textColor: Colors.white,
//        child: new Text(
//          Strings.pay.toUpperCase(),
//          style: const TextStyle(fontSize: 17.0),
//        ),
//      );
//    }
//  }

//  void _showInSnackBar(String value) {
//    _scaffoldKey.currentState.showSnackBar(new SnackBar(
//      content: new Text(value),
//      duration: new Duration(seconds: 3),
//    ));
//  }
}
