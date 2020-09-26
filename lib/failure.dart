import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class PayFailure extends StatefulWidget{
  @override
  _PayFailureState createState() => _PayFailureState();
}

class _PayFailureState extends State<PayFailure> with SuperBase {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.pop(context);
        }) : null,
        title: Text(
          "Pay",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 250,
                  color: color,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image(image: AssetImage("assets/pay-failure.png"),height: 150),
                        SizedBox(height: 15),
                        Text(
                          "Payment fail",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RaisedButton(
                                    onPressed: () {},
                                    color: Colors.white,
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(6)
                                    ),
                                    elevation: 0.7,
                                    child: Text(
                                      "Back To Home",
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                                    ),
                                  ),
                                )),
                            Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RaisedButton(
                                    onPressed: () {},
                                    color: color,
                                    padding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(6)
                                    ),
                                    elevation: 0.7,
                                    child: Text(
                                      "View Order",
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                                    ),
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}