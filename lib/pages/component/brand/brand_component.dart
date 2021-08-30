import 'package:flutter/material.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/widget/brand/brand_widget.dart';
class BrandComponent extends StatefulWidget {
  @override
  _BrandComponentState createState() => _BrandComponentState();
}

class _BrandComponentState extends State<BrandComponent>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
     appBar: WidgetHelper().appBarWithButton(context,"Brand",(){},<Widget>[],param: "default"),
      body:  BrandWidget(),
    );
  }


}


