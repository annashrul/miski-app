import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/widget/product/porduct_list_widget.dart';
import 'package:netindo_shop/pages/widget/review/form_review_widget.dart';

class ListProductReviewWidget extends StatefulWidget {
  final List data;
  ListProductReviewWidget({this.data});
  @override
  _ListProductReviewWidgetState createState() => _ListProductReviewWidgetState();
}

class _ListProductReviewWidgetState extends State<ListProductReviewWidget> {

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return Container(
      padding: scaler.getPadding(1,2),
      child: ListView.separated(
        padding: scaler.getPadding(1,2),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: false,
        itemCount:  widget.data.length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          final res =  widget.data[index];
          print(res);
          return WidgetHelper().titleQ(context, res["barang"],
            image: res["gambar"],
            callback: (){
              WidgetHelper().myModal(context, FormReviewWidget(data: res));
            }
          );
        },
      ),
    );
  }
}
