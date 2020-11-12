import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';
import 'failure.dart';

class OrderTimeout extends StatefulWidget {
  @override
  _OrderTimeoutState createState() => _OrderTimeoutState();
}

class _OrderTimeoutState extends State<OrderTimeout> with SuperBase {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image(
                      image: AssetImage("assets/pay-failure.png"), height: 150),
                  SizedBox(height: 25),
                  Text(
                    "Order time out",
                    style: TextStyle(fontSize: 27, color: Colors.red),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white.withOpacity(0.4),
                  border: Border.all(color: Colors.grey.shade400)),
              child: InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 5),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Text(
                                    "Ibirori",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "076856758567856",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Our systems have detected unusual traffic from your computer network. This page checks to see if it's really you sending the requests, and not a robot.",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9.3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.4, 3.2),
                        blurRadius: 3.4)
                  ]),
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Image(
                      height: 90,
                      width: 90,
                      image: AssetImage("assets/imag10.jpg"),
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                    ),
                    Expanded(
                        child: Container(
                      height: 90,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            "_item.name",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          )),
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Color(0xffffe707),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  '\$8.23',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(child: SizedBox.shrink()),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    child:
                                        new Icon(Icons.remove_circle_outline),
                                    onTap: () => setState(() {}),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      '0',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  GestureDetector(
                                    child: new Icon(Icons.add_circle_outline),
                                    onTap: () {
                                      setState(() {});
                                    },
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              margin: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  ListTile(
                    onTap: () {},
                    title: Text("Merchandise Total"),
                    trailing: Text("\$141.11"),
                  ),
                  ListTile(
                    onTap: () {},
                    title: Text("Shipping Fee"),
                    trailing: Text("\$0"),
                  ),
                  ListTile(
                    onTap: () {},
                    title: Text("Handling Fee"),
                    trailing: Text("\$5.65"),
                  ),
                  ListTile(
                    onTap: () {},
                    title: Text("Duty Fee"),
                    trailing: Text("\$22.58"),
                  ),
                  ListTile(
                    onTap: () {},
                    title: Text("Coupon"),
                    trailing: Text("\$0.00"),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: CupertinoButton(
                child: Text(
                  "Delete Order",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                onPressed: () {
                  showDialog(context: context,builder: (context){
                    return AlertDialog(
                      contentPadding: EdgeInsets.all(5),
                      title: Text("Confirm To Delete"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text("Confirm to delete those orders ?",style: TextStyle(color: Colors.grey)),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: RaisedButton(
                                      onPressed: () {

                                        Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>OrderTimeout()));
                                      },
                                      color: Colors.white,
                                      padding: EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Colors.red,
                                          ),
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      elevation: 0.7,
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.red),
                                      ),
                                    ),
                                  )),
                              Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: RaisedButton(
                                      onPressed: () {
                                       // Navigator.of(context).push(CupertinoPageRoute(builder: (context)=>PayFailure()));
                                      },
                                      color: color,
                                      padding: EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      elevation: 0.7,
                                      child: Text(
                                        "Confirm",
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
                                      ),
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ),
                    );
                  });
                },
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }
}
