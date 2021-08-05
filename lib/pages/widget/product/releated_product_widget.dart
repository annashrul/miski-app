import 'dart:math';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/pages/widget/product/porduct_list_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

// ignore: must_be_immutable
class ReleatedProductWidget extends StatelessWidget {
  ListProductTenantModel data;
  final String heroTag;
  ReleatedProductWidget({this.data,this.heroTag});
  Random random = new Random();

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Column(
      children: [
        Padding(
          padding: scaler.getPadding(0,2),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.all(0),
            leading: Icon(
              UiIcons.box,
              color: Theme.of(context).hintColor,
            ),
            title:config.MyFont.title(context: context,text:"Releated product"),
          ),
        ),
        Container(
            height: scaler.getHeight(30),
            child: data.result.data.length<1?EmptyTenant():ListView.builder(
              padding: scaler.getPadding(0,2),
              itemCount:data.result.data.length ,
              itemBuilder: (context, index) {
                double _marginLeft = 0;
                (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
                final res = data.result.data[index];
                return ProductListCarouselWidget(
                    productId: res.id,
                    productName: res.title,
                    productImage:res.gambar,
                    productPrice:res.harga,
                    productSales: res.stockSales,
                    productRate:res.rating,
                    productStock: res.stock,
                    heroTag:heroTag+"${random.nextInt(100)}"
                );
              },
              scrollDirection: Axis.horizontal,
            )
        )
      ],
    );
  }
}
