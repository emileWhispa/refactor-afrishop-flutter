import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'SuperBase.dart';
import 'Json/version.dart';

class AboutInformation extends StatefulWidget{
  @override
  _AboutInformationState createState() => _AboutInformationState();
}

class _AboutInformationState extends State<AboutInformation> with SuperBase{

  String _version = "";

  List<Version> _list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadVersions();
      PackageInfo.fromPlatform().then((value) {
        setState(() {
          _version = value.version;
        });
      });
    });
  }


  void _loadVersions(){
    this.ajax(url: "version/getVersionCode",onValue: (source,url){
      setState(() {
        _list = (jsonDecode(source) as Iterable).map((e) => Version.fromJson(e)).where((element) => element.versionSort == version).toList();
      });
    });
  }

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
                Text("Version $_version",style: TextStyle(color: Colors.grey),)
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


                if( _list.isEmpty ) return;


                if( _version == _list.first.versionCode){

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
                  return;
                }

                showDialog(
                    context: context,
                    builder: (context) {
                      return UpdateDialog(version: _list.first);
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}

class UpdateDialog extends StatefulWidget{
  final Version version;
  final bool hasCancel;

  const UpdateDialog({Key key,@required this.version, this.hasCancel:true}) : super(key: key);
  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> with SuperBase {

  Widget get dialog => AlertDialog(
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
                "Latest Version ${widget.version?.versionCode}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey, fontSize: 14),
              ),
              Text(
                "Update Content:",
                style: TextStyle(fontWeight: FontWeight.w900,height: 2.5),
              ),
              Text(
                "${widget.version?.versionDetail}",
                style: TextStyle(color: Colors.grey,fontSize: 14),
              ),
              Row(
                children: <Widget>[
                  widget.hasCancel ? Expanded(
                      child: RaisedButton(
                        onPressed: (){
                          Navigator.pop(context);
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
                      )) : SizedBox.shrink(),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left:5.0),
                        child: RaisedButton(
                          onPressed: () async {

                            if( await canLaunch(widget.version?.versionLink ?? "") ){
                              launch(widget.version?.versionLink);
                            }
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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.hasCancel ? dialog : WillPopScope(child: dialog, onWillPop: ()=>Future.value(false));
  }
}