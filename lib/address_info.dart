import 'dart:convert';

import 'package:afri_shop/CreateAddressInfo.dart';
import 'package:afri_shop/Json/Address.dart';
import 'package:afri_shop/edit_address_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Json/User.dart';
import 'SuperBase.dart';

class AddressInfo extends StatefulWidget {
  final User Function() user;
  final String title;
  final bool select;
  final Address defaultAd;

  const AddressInfo(
      {Key key, @required this.user, this.title, this.select: false, this.defaultAd})
      : super(key: key);

  @override
  _AddressInfoState createState() => _AddressInfoState();
}

class _AddressInfoState extends State<AddressInfo> with SuperBase {
  List<Address> _list = [];

  Address _address;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _address = widget.defaultAd;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
      this.getDefault(server: widget.defaultAd != null);
    });
  }

  void load(){
    refreshKey.currentState?.show(atTop: true);
  }

  var refreshKey = new GlobalKey<RefreshIndicatorState>();


  void _deletePop(Address address)async{
    showCupertinoModalPopup(context: context, builder: (context)=>new CupertinoAlertDialog(
      title: new Text("Confirm To Delete"),
      content: new Text("Delete This Address ?"),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text("Cancel"),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: (){
            Navigator.pop(context);
            _delete(address);
          },
          child: Text("Confirm"),
        )
      ],
    ));
  }

  void getDefault({bool server:false}) {
    this.ajax(
        url: "address/default",
        authKey: widget.user()?.token,
        auth: true,
        server: server,
        onValue: (source, url) {
          var data = json.decode(source)['data'];
          if (data == null) return;
          setState(() {
            _address = Address.fromJson(data);
          });
        });
  }

  Future<void> loadAddresses() {
    return this.ajax(
        url: "address?load-ad",
        auth: true,
        authKey: widget.user()?.token,
        onValue: (source, url) {
          Iterable map = json.decode(source)['data'];
          if (map != null) {
            setState(() {
              _list = map.map((json) => Address.fromJson(json)).toList();
            });
          }
        });
  }

  void _newAddress() async {
    Address address =
        await Navigator.of(context).push(CupertinoPageRoute<Address>(
            builder: (context) => CreateAddressInfo(
                  user: widget.user,
                )));
    if (address != null) {
      setState(() {
        _list.add(address);
      });
      this.load();
    }
  }

  void _delete(Address address) {
    setState(() {
      address.sending = true;
    });
    this.ajax(
        url: "address/${address.addressId}",
        method: "DELETE",
        server: true,
        auth: true,
        authKey: widget.user().token,
        onValue: (source, url) {
          setState(() {
            _list.removeWhere((f) => f.addressId == address.addressId);
          });
          this.load();
        },
        error: (source, url) {
          print(source);
        },
        onEnd: () {
          setState(() {
            address.sending = false;
          });
        });
  }

  void _setDefault(Address address) {
    setState(() {
      address.sending = true;
    });
    this.ajax(
        url: "address/default/${address.addressId}",
        method: "PUT",
        server: true,
        auth: true,
        authKey: widget.user().token,
        onValue: (source, url) {
          setState(() {
            _address = address;
          });
          if(widget.select){
            Navigator.of(context).pop(address);
          }else {
            this.load();
            this.getDefault();
          }
        },
        error: (source, url) {
          print(source);
        },
        onEnd: () {
          setState(() {
            address.sending = false;
          });
        });
  }

  int _selected = 0;

  bool _select = false;

  Address get address => _address != null ? _address : _list.isNotEmpty ? _selected < _list.length ? _list[_selected] : _list.first : null;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: ()async{

        Navigator.pop(context,address);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context,address);
                  })
              : null,
          title: Text(widget.title ?? "Address"),
          centerTitle: true,
          actions: <Widget>[
            _list.isEmpty
                ? SizedBox.shrink()
                : _select
                    ? FlatButton(
                        onPressed: () {
                          setState(() {
                            _select = false;
                          });
                        },
                        child: Text("Complete"))
                    : FlatButton(
                        onPressed: () {
                          setState(() {
                            _select = true;
                          });
                        },
                        child: Text("Management"))
          ],
        ),
        backgroundColor: Colors.grey.shade200,
        body: Column(
          children: <Widget>[
            Expanded(
              child: RefreshIndicator(
                key: refreshKey,
                onRefresh: loadAddresses,
                child: _list.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          var ad = _list[index];
                          var dip = Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: Text("${ad.address}"),
                          );
                          var cont = Container(
                            padding: EdgeInsets.all(7),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 5)
                                            .copyWith(top: 0),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              "${ad.delivery}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Text(
                                                "${ad.phone}",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                      ),
                                      _address?.addressId == ad.addressId ? Padding(
                                        padding: const EdgeInsets.symmetric(horizontal:8.0),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade200,
                                                borderRadius: BorderRadius.circular(3)
                                              ),
                                              padding: EdgeInsets.all(2.5),
                                              child: Text("default",style: TextStyle(color: Colors.red),),
                                            ),
                                            dip
                                          ],
                                        ),
                                      ) : dip,
                                    ],
                                  ),
                                ),
                                _select
                                    ? ad.sending
                                        ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CupertinoActivityIndicator(),
                                        )
                                        : InkWell(
                                            onTap: () => this._deletePop(ad),
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 17,
                                            ))
                                    : InkWell(onTap: ()async{
                                  await Navigator.of(context).push(CupertinoPageRoute(
                                      builder: (context) => EditAddressInfo(
                                          user: widget.user, address: ad)));
                                  load();
                                },child: Image.asset("assets/account_edit.png",height: 20))
                              ],
                            ),
                          );

                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white.withOpacity(0.4)),
                            child: _address?.addressId == ad.addressId ? cont : Column(
                              children: <Widget>[
                                cont,
                                Padding(
                                  padding: const EdgeInsets.all(8.0).copyWith(left: 13),
                                  child: Row(
                                    children: <Widget>[
                                      ad.sending ? CupertinoActivityIndicator() : InkWell(
                                        onTap: () async {
                                          setState(() {
                                            _selected = index;
                                          });
                                          _setDefault(ad);
                                          return;
                                        },
                                        child: Container(height: 24,width: 24,decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.shade400)
                                        ),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left:8.0),
                                        child: Text("Set to the default address"),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        itemCount: _list.length,
                      )
                    : ListView(
                        children: <Widget>[
                          SizedBox(height: 90),
                          Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 50.0),
                                    child: Image(
                                      image: AssetImage("assets/empty.png"),
                                      height: 170,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text("It Was Empty"),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: 42,
                child: CupertinoButton(
                    borderRadius: BorderRadius.circular(4),
                    padding: EdgeInsets.zero,
                    child: Text(
                      "Add A New Address",
                      style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w800),
                    ),
                    onPressed: _newAddress,
                    color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
