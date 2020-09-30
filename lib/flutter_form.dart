import 'package:afri_shop/payment_card.dart';
import 'package:afri_shop/payment_card_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'Json/User.dart';
import 'Json/country.dart';
import 'Json/flutter_wave.dart';
import 'SuperBase.dart';
import 'input_formatters.dart';

class NewItem {
  bool isExpanded;
  final String header;
  final Widget body;
  final Widget iconpic;
  NewItem(this.isExpanded, this.header, this.body, this.iconpic);
}

double discretevalue = 2.0;
double hospitaldiscretevalue = 25.0;

class FlutterForm extends StatefulWidget {
  final String email;
  final double price;
  final User Function() user;
  final Flutterwave flutterwave;
  const FlutterForm({Key key, @required this.email,@required this.price,@required this.user, this.flutterwave})
      : super(key: key);
  @override
  _FlutterFormState createState() => _FlutterFormState();
}

class _FlutterFormState extends State<FlutterForm> with SuperBase {
  var _cardController = new TextEditingController();
  var _cvvController = new TextEditingController();
  var _emailController = new TextEditingController();
  var _firstController = new TextEditingController();
  var _lastController = new TextEditingController();
  var _monthController = new TextEditingController();
  var _phoneController = new TextEditingController();
  var _yearController = new TextEditingController();


  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();

  var _formKey = new GlobalKey<FormState>();
  TextEditingController _phone = new TextEditingController();
  var _autoValidate = false;
  FocusNode myFocusNode = new FocusNode();


  Country _country;
  var _selectedMethod;
  final List<String> _items = <String>['1', '2', '3'];
  bool _isPhone = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.email != null) {
      _emailController = new TextEditingController(text: widget.email);
    }

    if( widget.flutterwave != null ){
      numberController = new TextEditingController(text: widget.flutterwave.card);
      _cvvController = new TextEditingController(text: widget.flutterwave.cvv);
      _yearController = new TextEditingController(text: "${widget.flutterwave.month}/${widget.flutterwave.year}");
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

  List<NewItem> get items => <NewItem>[
    new NewItem(
        false,
        'Pay with Mobile Money',

        Container(
          child: Column(
            children: [
              Container(
                height: 100,
                width: 500,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15.0),
                      topRight: const Radius.circular(15.0),
                    )),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 140.0),
                      child: ClipRRect(
                        child: Image.asset(
                          "assets/flutterwave.png",
                          width: 60.0,
                          height: 60.0,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Text(
                          "ccfz investment company limited",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 250,
                width: 500,
                color: Color(0xfffdf9e8),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 220.0, top: 10),
                          child: Text(
                            "\$${widget.price}",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 130.0),
                          child: Text(
                            "${widget.email}",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    Container(
                      width: 270,
                      height: 55,
                      color: Colors.white,
                      child: DropdownButton(
                        focusColor: Colors.white,
                        hint: _selectedMethod == null
                            ? Padding(
                          padding:
                          const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'CHOOSE NETWORK',
                            style: TextStyle(fontSize: 13),
                          ),
                        )
                            : Text(
                          _selectedMethod,
                          style: TextStyle(color: Colors.blue),
                        ),
                        isExpanded: true,
                        iconSize: 30.0,
                        underline: Container(
                          height: 0,
                        ),
                        value: _selectedMethod,
                        items: ['MTN', 'ZAMTEL'].map((code) {
                          return DropdownMenuItem<String>(
                              value: code, child: Text(code));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMethod = value;
                          });
                        },
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Container(
                        width: 270,
                        child: TextFormField(
                          controller: _phone,
                          validator: (s) =>
                          s.isEmpty ? "Field required !!" : null,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              hintText: "Phone number",
                              hintStyle:
                              TextStyle(color: Colors.grey),
                              fillColor: Colors.white,
                              filled: true,
                              // border: OutlineInputBorder(borderSide: BorderSide.none)
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                    ),
                    // ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        width: 270,
                        height: 42,
                        child: CupertinoButton(
                            borderRadius: BorderRadius.circular(4),
                            padding: EdgeInsets.zero,
                            child: Text(
                              "Pay \$${widget.price}",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w800),
                            ),
                            onPressed: () => {},
                            color: color),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),ClipRRect(
      child: Image.asset(
        "assets/payment_icon.png",
        width: 20.0,
        height: 20.0,
        fit: BoxFit.fitWidth,
      ),
    )),
    new NewItem(
        true,
        'Pay with Card',
        Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15.0),
                              topRight: const Radius.circular(15.0),
                            )),
                        child: Row(
                          children: [
                            ClipRRect(
                              child: Image.asset(
                                "assets/flutterwave.png",
                                width: 60.0,
                                height: 60.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Spacer(),
                            Text(
                              "ccfz investment company limited",
                              style:
                              TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: double.infinity,
                        color: Color(0xfffdf9e8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      "\$${widget.price}",
                                      style:
                                      TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(right: 0.0),
                                    child: Text(
                                      "${widget.email}",
                                      style:
                                      TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: new TextFormField(
                                focusNode: myFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter
                                      .digitsOnly,
                                  new LengthLimitingTextInputFormatter(
                                      19),
                                  new CardNumberInputFormatter()
                                ],
                                controller: numberController,
                                decoration: new InputDecoration(
                                  // border: const UnderlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  suffixIcon: CardUtils.getCardIcon(
                                      _paymentCard.type),
                                  hintText: '0000 0000 0000 0000',
                                  labelText: 'Card number',
                                  labelStyle: TextStyle(
                                      color: myFocusNode.hasFocus
                                          ? Colors.black54
                                          : Colors.black54),
                                  fillColor: Colors.white,
                                ),
                                onSaved: (String value) {
                                  print('onSaved = $value');
                                  print(
                                      'Num controller has = ${numberController.text}');
                                  _paymentCard.number =
                                      CardUtils.getCleanedNumber(value);
                                },
                                validator: CardUtils.validateCardNum,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0,right: 20, bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: new TextFormField(
                                      controller: _yearController,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter
                                            .digitsOnly,
                                        new LengthLimitingTextInputFormatter(
                                            4),
                                        new CardMonthInputFormatter()
                                      ],
                                      decoration: new InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        border: OutlineInputBorder(
                                            borderSide:
                                            BorderSide.none),
                                        filled: true,
                                        hintText: 'MM/YY',
                                        labelText: 'Expiry Date',
                                        labelStyle: TextStyle(
                                            color: myFocusNode.hasFocus
                                                ? Colors.black54
                                                : Colors.black54),
                                        fillColor: Colors.white,
                                      ),
                                      validator: CardUtils.validateDate,
                                      keyboardType:
                                      TextInputType.number,
                                      onSaved: (value) {
                                        List<String> expiryDate =
                                        CardUtils.getExpiryDate(
                                            value);
                                        _paymentCard.month =
                                        expiryDate[0];
                                        _paymentCard.year =
                                        expiryDate[1];
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 3.0),
                                      child: new TextFormField(
                                        controller: _cvvController,
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter
                                              .digitsOnly,
                                          new LengthLimitingTextInputFormatter(
                                              4),
                                        ],
                                        decoration: new InputDecoration(
                                          filled: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                          fillColor: Colors.white,
                                          hintText:
                                          'Number behind card',
                                          hintStyle:
                                          TextStyle(fontSize: 12.0),
                                          labelText: 'CVV',
                                          labelStyle: TextStyle(
                                              color:
                                              myFocusNode.hasFocus
                                                  ? Colors.black54
                                                  : Colors.black54),
                                          border: OutlineInputBorder(
                                              borderSide:
                                              BorderSide.none),
                                        ),
                                        obscureText: true,
                                        validator:
                                        CardUtils.validateCVV,
                                        keyboardType:
                                        TextInputType.number,
                                        onSaved: (value) {
                                          _paymentCard.cvv =
                                              int.parse(value);
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
                              child: Container(
                                width: double.infinity,
                                height: 42,
                                child: CupertinoButton(
                                    borderRadius:
                                    BorderRadius.circular(4),
                                    padding: EdgeInsets.zero,
                                    child: Text(
                                      "Pay \$${widget.price}",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    onPressed: ()  {
                                      if( _formKey.currentState?.validate() ?? false ){
                                        _paymentCard.number =
                                            CardUtils.getCleanedNumber(numberController.text);
                                        var name = widget.user()?.display() ?? "";

                                        List<String> expiryDate =
                                        CardUtils.getExpiryDate(
                                            _yearController.text);
                                        _paymentCard.month =
                                        expiryDate[0];
                                        _paymentCard.year =
                                        expiryDate[1];
                                        var card = Flutterwave(_paymentCard.number, "RWF", _cvvController.text, widget.email, name, name, _paymentCard.month, _paymentCard.year, widget.user()?.phone ?? "");
                                        Navigator.pop(context,card);
                                      }

                                    },
                                    color: Color(0xffffe707)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: (){},
                  child: Container(
                    width: 500,
                    height: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),ClipRRect(
      child: Image.asset(
        "assets/payment_icon.png",
        width: 20.0,
        height: 20.0,
        fit: BoxFit.fitWidth,
      ),
    )),
    //give all your items here
  ];

  ListView List_Criteria;
  @override
  Widget build(BuildContext context) {
    List_Criteria = new ListView(
      children: [
        new Padding(
          padding: new EdgeInsets.all(10.0),
          child: new ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                items[index].isExpanded = !items[index].isExpanded;
              });
            },
            children: items.map((NewItem item) {
              return new ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return new ListTile(
                      leading: item.iconpic,
                      title: new Text(
                        item.header,
                        textAlign: TextAlign.left,
                        style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ));
                },
                isExpanded: item.isExpanded,
                body: item.body,
              );
            }).toList(),
          ),
        )
      ],
    );

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
      body: List_Criteria
    );
    return scaffold;
  }


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

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true; // Start validating on every change.
      });
    //  _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
    //  _showInSnackBar('Payment card is valid');
    }
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
