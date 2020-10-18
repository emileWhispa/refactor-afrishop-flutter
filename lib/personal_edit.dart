import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class PersonalEdit extends StatefulWidget {
  final String nickname;
  final Future<void>  Function(String name) saveName;

  const PersonalEdit({Key key, this.nickname,@required this.saveName}) : super(key: key);
  @override
  PersonalEditState createState() => PersonalEditState();
}

class PersonalEditState extends State<PersonalEdit> with SuperBase {
  TextEditingController _controller;
  var _key = new GlobalKey<ScaffoldState>();

  bool _saving = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new TextEditingController(text: widget.nickname);
  }

  void doError(String s,bool ok){
    if( ok ){
      Navigator.pop(context,_controller.text);
    }else{
      _key.currentState?.showSnackBar(SnackBar(content: Text(s)));
    }
  }

  var _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: Navigator.canPop(context) ? IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){
          Navigator.maybePop(context);
        }) : null,
        title: Text("Personal Information"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: _controller,
              validator: (s)=>s.length > 1 && s.length <= 25 ? null : "Username vary between 2-25",
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(20),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide.none),
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.white),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: _saving ? CupertinoActivityIndicator() : CupertinoButton(
                child: Text(
                  "SAVE",
                  style:
                      TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if( !(_formKey.currentState?.validate() ?? false) ) return;
                  setState(() {
                    _saving = true;
                  });
                  await widget.saveName(_controller.text);
                  setState(() {
                    _saving = false;
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
