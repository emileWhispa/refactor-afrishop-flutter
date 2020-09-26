import 'package:flutter/cupertino.dart';

class TouchableOpacity extends StatefulWidget{
  final Widget child;
  final EdgeInsets padding;
  final void Function() onTap;

  const TouchableOpacity({Key key,@required this.child, this.onTap, this.padding}) : super(key: key);
  @override
  _TouchableOpacityState createState() => _TouchableOpacityState();
}

class _TouchableOpacityState extends State<TouchableOpacity> {
  double _opacity = 1;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTapDown: (down)=>setState(()=>_opacity = 0.5),
      onTapUp: (up)=>setState(()=>_opacity = 1),
      onPanCancel: ()=>setState(()=>_opacity = 1),
      onTap: widget.onTap,
      child: Padding(padding: widget.padding ?? EdgeInsets.zero,child: Opacity(opacity: _opacity,child: widget.child),),
    );
  }
}