import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class ChooseWidget extends StatefulWidget {
  final dynamic res;
  final Function callback;
  ChooseWidget({this.res,this.callback});
  @override
  _ChooseWidgetState createState() => _ChooseWidgetState();
}

class _ChooseWidgetState extends State<ChooseWidget> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    var val = widget.res;
    return Container(
      margin: scaler.getMarginLTRB(0, 0, val["right"], 0),
      child: WidgetHelper().myRipple(
        callback: widget.callback,
        child: AnimatedContainer(
          height: scaler.getHeight(5) ,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: scaler.getPadding(0,2),
          decoration: BoxDecoration(
            border: Border.all(width:2,color: val["isActive"]?LightColor.mainColor:LightColor.lightblack),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: <Widget>[
              AnimatedSize(
                duration: Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                vsync: this,
                child: WidgetHelper().textQ("${val["title"]}".toLowerCase(),scaler.getTextSize(9),val["isActive"]?LightColor.mainColor:LightColor.lightblack,FontWeight.bold),
              )
            ],
          ),
        )
      )
    );
  }
}
