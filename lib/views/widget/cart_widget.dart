import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/ui_icons.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              UiIcons.shopping_cart,
              color: this.iconColor,
              size: 28,
            ),
          ),
          Container(
            child: Text(
              this.labelCount.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption.merge(
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 10),
              ),
            ),
            padding: EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: this.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
          ),
        ],
      ),
      color: Colors.transparent,
    );
  }
}
