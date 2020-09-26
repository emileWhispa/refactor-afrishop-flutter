import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirebaseInfo extends StatefulWidget{
  final String url;
  final String uid;
  final String email;
  final String name;

  const FirebaseInfo({Key key,@required this.url,@required this.uid,@required this.email,@required this.name}) : super(key: key);
  @override
  _FirebaseInfoState createState() => _FirebaseInfoState();
}

class _FirebaseInfoState extends State<FirebaseInfo> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase info"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.url),radius: 50,),
            SizedBox(height: 20),
            Text("Email : ${widget.email ?? "--"}"),
            SizedBox(height: 20),
            Text("Names : ${widget.name}"),
            SizedBox(height: 20),
            Text("Uid : ${widget.uid}"),
          ],
        ),
      ),
    );
  }
}