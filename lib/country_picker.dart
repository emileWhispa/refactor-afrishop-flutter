import 'dart:convert';

import 'package:afri_shop/Json/country.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SuperBase.dart';

class CountryPicker extends StatefulWidget {
  final bool showName;
  final bool showFlag;
  final bool showDialingCode;
  final Country selectedCountry;
  final void Function(Country country) onChanged;

  const CountryPicker(
      {Key key,
      this.showName: true,
      this.showFlag: false,
      this.onChanged,
      this.showDialingCode: false,
      this.selectedCountry})
      : super(key: key);

  @override
  _CountryPickerState createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> with SuperBase {
  List<Country> _list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => this._loadCountries());
  }

  FixedExtentScrollController _controller = new FixedExtentScrollController();

  void _loadCountries() {
    this.ajax(
        url:
            "https://restcountries.eu/rest/v2/all?fields=name;alpha2Code;callingCodes;flag",
        absolutePath: true,
        localSave: true,
        onValue: (source, url) {
          Iterable iterable = json.decode(source);
          setState(() {
            _list = iterable.map((f) => Country.fromJson(f)).toList()..sort((c,c2)=>c.compare.compareTo(c2.compare));
            _checkSelection();
          });
        });
  }

  int _index = 0;

  void _checkSelection(){
    var cond = (element) => element.dialingCode == widget.selectedCountry.dialingCode;
    if( widget.selectedCountry != null && _list.any(cond) ){
      setState(() {
        widget.onChanged(_list.firstWhere(cond));
        _controller.jumpToItem(_list.indexWhere(cond));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: InkWell(
        onTap: () {
          _checkSelection();
          showModalBottomSheet(
            isScrollControlled: true,
              context: context,
              builder: (context) => SingleChildScrollView(
                child: Container(
                  height: 300,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CupertinoButton(child: Text("Cancel",style: TextStyle(fontSize: 15)), onPressed: ()=>
                              Navigator.pop(context)),
                          Spacer(),
                          CupertinoButton(child: Text("Confirm",style: TextStyle(fontSize: 15)), onPressed: (){
                            if( _list.isNotEmpty && widget.onChanged != null ){
                              _index = _index ?? 0;
                              widget.onChanged(_list[_index]);
                              Navigator.pop(context);
                            }
                          }),
                        ],
                      ),
                      Expanded(
                        child: CupertinoPicker.builder(
                              backgroundColor: Colors.white,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _index = index;
                                });
                              },
                          scrollController: _controller,
                              childCount: _list.length,
                              itemExtent: 56.0,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal:16.0),
                                    child:
                                    Text("${_list[index].name}",style: TextStyle(fontSize: 17),),
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ));
        },
        child: Container(
          margin: EdgeInsets.all(5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("+${widget.selectedCountry?.dialingCode ?? "250"}",style: TextStyle(fontFamily: 'SF UI Display',color: Color(0xff999999)),),
              Padding(
                padding: const EdgeInsets.only(left:16.0),
                child: Icon(Icons.keyboard_arrow_down,color: Color(0xff999999),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
