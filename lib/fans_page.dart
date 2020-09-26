import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FanScreen extends StatefulWidget {
  @override
  _FanScreenState createState() => _FanScreenState();
}

class _FanScreenState extends State<FanScreen> {
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
          "My Fans",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0.0
      ),
      body: ListView.builder(itemCount: 3,itemBuilder: (context,index){
        return Container(
          decoration: BoxDecoration(
            color: Colors.white
          ),
          margin: EdgeInsets.only(bottom: 6),
          padding: EdgeInsets.all(15),
          child: Row(
            children: <Widget>[
              CircleAvatar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("MVP",style: TextStyle(fontWeight: FontWeight.bold),),
                      Text("Registration time:2020-05-25",style: TextStyle(color: Colors.grey,fontSize: 12),),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
