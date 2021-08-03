import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;

class BottomBarDetailProductWidget extends StatelessWidget {
  final Function() callback;
  BottomBarDetailProductWidget({this.callback});
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      padding: scaler.getPadding(0.8,2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
              onPressed: () {},
              padding:scaler.getPadding(0.5,0),
              color: Theme.of(context).accentColor,
              shape: StadiumBorder(),
              child: Icon(
                FlutterIcons.heart_circle_outline_mco,
                color: Theme.of(context).primaryColor,
                size: scaler.getTextSize(14)
              )),
          SizedBox(width: 10),
          FlatButton(
            padding:scaler.getPadding(0.5,0),
            onPressed: () {
              callback();
            },
            color: Theme.of(context).accentColor,
            shape: StadiumBorder(),
            child: Container(
              width: scaler.getWidth(50),
              padding:scaler.getPaddingLTRB(2,0,2,0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: config.MyFont.title(context: context,text:"Add to cart",color: Theme.of(context).primaryColor),
                  ),
                  Icon(FlutterIcons.plus_circle_outline_mco,color: Theme.of(context).primaryColor,size: scaler.getTextSize(14),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

