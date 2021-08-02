import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({
    this.iconColor,
    this.labelColor,
    this.labelCount = 0,
    this.callback,
    Key key,
  }) : super(key: key);

  final Color iconColor;
  final Color labelColor;
  final int labelCount;
  final Function callback;



  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return WidgetHelper().myRipple(
      callback:callback,
      isRadius: true,
      radius: 100,
      child: Container(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Icon(
                AntDesign.shoppingcart,
                color: this.iconColor,
              ),
            ),
            Positioned(
              left: scaler.getTextSize(9),
              top: scaler.getTextSize(7),
              child: Container(
                decoration: BoxDecoration(color: this.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
                constraints: BoxConstraints(minWidth: scaler.getTextSize(8), maxWidth: scaler.getTextSize(8), minHeight: scaler.getTextSize(8), maxHeight: scaler.getTextSize(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

