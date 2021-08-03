import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;

class SearchBarWidget extends StatelessWidget {
  SearchBarWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
        ],
      ),
      child: TextField(
        style: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color,fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          contentPadding: scaler.getPadding(1,2),
          hintText: "cari produk ..",
          hintStyle: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color,fontWeight: FontWeight.normal),
          prefixIcon: Icon(FlutterIcons.search1_ant,color:  Theme.of(context).textTheme.headline1.color,size: scaler.getTextSize(11),),
          border: UnderlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
