import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/detail/function_detail.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/pages/widget/brand/brand_widget.dart';
import 'package:netindo_shop/pages/widget/drawer_widget.dart';
import 'package:netindo_shop/pages/widget/product/detail/bottom_bar_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/detail/tab_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
class BrandComponent extends StatefulWidget {
  @override
  _BrandComponentState createState() => _BrandComponentState();
}

class _BrandComponentState extends State<BrandComponent>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(),
     appBar: WidgetHelper().appBarWithButton(context,"Brand",(){
       _scaffoldKey.currentState.openDrawer();
     },<Widget>[],icon:Icons.sort),

      body: SingleChildScrollView(
        padding: scaler.getPadding(1,2),
        child: Wrap(
          children: <Widget>[
            BrandWidget(),
          ],
        ),
      ),
    );
  }


}
