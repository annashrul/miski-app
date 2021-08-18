import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';

class BrandHomeTabWidget extends StatefulWidget {
  final dynamic data;
  BrandHomeTabWidget({this.data});
  @override
  _BrandHomeTabWidgetState createState() => _BrandHomeTabWidgetState();
}

class _BrandHomeTabWidgetState extends State<BrandHomeTabWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: scaler.getPadding(1, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidgetHelper().titleQ(context, widget.data["title"],icon: UiIcons.flag),
              WidgetHelper().myRating(context: context,rating: widget.data["jumlah_review"])
            ],
          )
        ),
        Padding(
          padding: scaler.getPadding(0, 2),
          child: WidgetHelper().titleQ(context, "Deskripsi",icon: UiIcons.favorites),
        ),
        Padding(
          padding: scaler.getPadding(0.5, 2),
          child: config.MyFont.subtitle(context: context,text:widget.data["deskripsi"],fontWeight: FontWeight.normal,color: Theme.of(context).textTheme.caption.color),
        ),
      ],
    );
  }
}
