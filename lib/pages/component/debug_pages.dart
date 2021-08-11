import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/detail/function_detail.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/pages/widget/product/detail/bottom_bar_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/detail/tab_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/review/form_review_widget.dart';
import 'package:netindo_shop/pages/widget/user/image_user_widget.dart';
class DebugPages extends StatefulWidget {
  final List data;
  DebugPages({this.data});
  @override
  _DebugPagesState createState() => _DebugPagesState();
}

class _DebugPagesState extends State<DebugPages> {
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return Container(
      padding: scaler.getPadding(1,2),
      child: ListView.separated(
        padding: scaler.getPadding(0,0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: false,
        itemCount:  widget.data.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          final res =  widget.data[index];
          print("list product review");
          return ListTile(
            onTap: (){
              WidgetHelper().myModal(context, FormReviewWidget(data: res));
            },
            contentPadding: EdgeInsets.all(0),
            leading: WidgetHelper().baseImage(res["gambar"],height: scaler.getHeight(4),width: scaler.getWidth(10),shape: BoxShape.circle),
            title: config.MyFont.title(context: context,text: res["barang"]),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: WidgetHelper().myRating(context:context,rating:res["rating"].toString()),
            ),
          );
          return WidgetHelper().titleQ(context, res["barang"],
              image: res["gambar"],
              subtitle: res["gambar"],
              callback: (){
                WidgetHelper().myModal(context, FormReviewWidget(data: res));
              }
          );
        },
      ),
    );
  }
}
