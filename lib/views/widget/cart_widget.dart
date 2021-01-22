import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
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
    return FlatButton(
      onPressed:callback,
      child: Stack(
        alignment: AlignmentDirectional.topEnd,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Icon(
              UiIcons.shopping_cart,
              color: this.iconColor,
              size: 28,
            ),
          ),
          Container(
            // child:WidgetHelper().textQ(this.labelCount.toString(), 10, Colors.white,FontWeight.bold,textAlign: TextAlign.center,),
            // padding: EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: this.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            constraints: BoxConstraints(minWidth: 10, maxWidth: 10, minHeight: 10, maxHeight: 10),
          ),
        ],
      ),
      color: Colors.transparent,
    );
  }
}

