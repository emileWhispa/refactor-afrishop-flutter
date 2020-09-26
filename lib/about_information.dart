import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class AboutInformation extends StatefulWidget{
  @override
  _AboutInformationState createState() => _AboutInformationState();
}

class _AboutInformationState extends State<AboutInformation> with SuperBase{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text("About Afrishop",style: TextStyle(fontWeight: FontWeight.w700),),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(25).copyWith(bottom: 0),child: Image(image: AssetImage("assets/about_logo.png"),height: 140,),),
                Text("Afrishop",style: TextStyle(fontWeight: FontWeight.w700),),
                SizedBox(height: 10,),
                Text("Version 1.1.0",style: TextStyle(color: Colors.grey),)
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            color: Colors.white.withOpacity(0.7),
            child: ListTile(
              leading: Icon(Icons.refresh),
              trailing: Icon(Icons.arrow_forward_ios,color: Colors.grey,size: 18,),
              title: Text("Version Update",style: TextStyle(fontWeight: FontWeight.w700),),
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        elevation: 0.0,
                        content: Stack(
                          children: <Widget>[
                            Container(
                              constraints: BoxConstraints(
                                  minHeight: 200, minWidth: double.infinity),
                              margin: EdgeInsets.only(top: 200),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(height: 50),
                                  Text(
                                    "Find A New Version",
                                    style: Theme.of(context)
                                        .textTheme
                                        .title
                                        .copyWith(fontWeight: FontWeight.w900),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Atest Version 1.0.8",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                  Text(
                                    "Update Content:",
                                    style: TextStyle(fontWeight: FontWeight.w900,height: 2.5),
                                  ),
                                  Text(
                                    "1. Expository, textExpository, textExpository, textExpository",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey,fontSize: 14,height: 1.3),
                                  ),
                                  Text(
                                    "1. Expository, textExpository, textExpository, textExpository",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey,fontSize: 14,height: 1.3),
                                  ),
                                  Text(
                                    "1. Expository, textExpository, textExpository, textExpository",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey,fontSize: 14,height: 1.3),
                                  ),
                                  Text(
                                    "1. Expository, textExpository, textExpository, textExpository",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey,fontSize: 14,height: 1.3),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: RaisedButton(
                                            onPressed: () {
                                            },
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
                                              "Cancel",
                                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
                                            ),
                                          )),
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left:5.0),
                                            child: RaisedButton(
                                              onPressed: () {

                                                Navigator.of(context).pop();
                                                showDialog(context: context,builder: (context){
                                                  return AlertDialog(
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Image(height: 120,fit: BoxFit.cover,image: AssetImage("assets/logo_circle.png")),
                                                        SizedBox(height: 20),
                                                        Text("This Is The Latest Version",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 19))
                                                      ],
                                                    ),
                                                  );
                                                });
                                              },
                                              color: color,
                                              padding: EdgeInsets.all(10),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6)
                                              ),
                                              elevation: 0.0,
                                              child: Text(
                                                "Update Now",
                                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
                                              ),
                                            ),
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("assets/log_bg.png"),
                                      fit: BoxFit.fitWidth)),
                              height: 300,
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}