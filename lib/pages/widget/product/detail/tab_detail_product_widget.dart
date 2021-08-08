import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/widget/product/releated_product_widget.dart';
import 'package:netindo_shop/pages/widget/review/review_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

// ignore: must_be_immutable
class TabProductWidget extends StatelessWidget {
  dynamic  data;
  final bool isLoading;
  final String id;
  TabProductWidget({this.id,this.data,this.isLoading});
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPaddingLTRB(0, 0, 0, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding:scaler.getPaddingLTRB(2,1,2,0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: isLoading?WidgetHelper().shimmer(context:context,width: 30):config.MyFont.subtitle(context: context,text:data["title"],fontSize: 9),
                ),
                if(!isLoading)WidgetHelper().myRating(context: context,rating: data["rating"])
              ],
            ),
          ),
          Padding(
            padding:scaler.getPaddingLTRB(2,0,2,0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isLoading?WidgetHelper().shimmer(context:context,width: 20):config.MyFont.title(context: context,text:"${config.MyFont.toMoney("${data["harga"]}")}",color: config.Colors.moneyColors),
                SizedBox(width: 10),
                isLoading?WidgetHelper().shimmer(context:context,width: 10):config.MyFont.subtitle(
                    context: context,
                    text:int.parse(data["harga_coret"])<1?"":"${config.MyFont.toMoney("${data["harga_coret"]}")}",
                    textDecoration: TextDecoration.lineThrough,
                    fontSize: 8
                ),
                SizedBox(width: 10),
                isLoading?WidgetHelper().shimmer(context:context,width: 10):Expanded(
                  child: config.MyFont.subtitle(context: context,text:"${data["stock_sales"]} terjual",fontSize: 9,textAlign: TextAlign.right),
                )
              ],
            ),
          ),
          if(!isLoading)
            if(data["is_varian"])
              Container(
                width: double.infinity,
                padding:scaler.getPaddingLTRB(2,1,2,0.5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: config.MyFont.subtitle(context: context,text:"Select color",fontSize: 9),
                        ),
                        WidgetHelper().myRipple(
                            callback: (){},
                            child: Container(
                              child: config.MyFont.subtitle(context: context,text:"clear all",fontSize: 9,color: config.Colors.mainColors),
                            )
                        )

                      ],
                    ),
                    SizedBox(height: 10),
                    // SelectColorWidget()
                  ],
                ),
              ),
          if(!isLoading)
            if(data["is_varian"])
              Container(
                width: double.infinity,
                padding:scaler.getPaddingLTRB(2,1,2,0.5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: config.MyFont.subtitle(context: context,text:"Select sizes",fontSize: 9),
                        ),
                        WidgetHelper().myRipple(
                            callback: (){},
                            child: Container(
                              child: config.MyFont.subtitle(context: context,text:"clear all",fontSize: 9,color: config.Colors.mainColors),
                            )
                        )

                      ],
                    ),
                    SizedBox(height: 10),
                    // SelectColorWidget()
                  ],
                ),
              ),
          isLoading?Container(
            height: scaler.getHeight(30),
            child: LoadingReleatedProduct(),
          ):ReleatedProductWidget(data: data["product_by_group"],heroTag: "product_related_products",)
        ],
      ),
    );
  }

}


// ignore: must_be_immutable
class TabDescProductWidget extends StatelessWidget {
  dynamic  data;
  final bool isLoading;
  TabDescProductWidget({this.data,this.isLoading});
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;

    return Container(
      padding: scaler.getPaddingLTRB(0, 1, 0, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Padding(
            padding: scaler.getPadding(0,2),
            child:config.MyFont.subtitle(context: context,text:data["deskripsi"],fontSize: 9),
            // child: Text('We’re all going somewhere. And whether it’s the podcast blaring from your headphones as you walk down the street or the essay that encourages you to take on that big project, there’s a real joy in getting lost in the kind of story that feels like a destination unto itself.'),
          ),
          isLoading?Container(
            height: scaler.getHeight(30),
            child: LoadingReleatedProduct(),
          ):ReleatedProductWidget(data: data["product_by_group"],heroTag: "product_details_related_products",)
        ],
      ),
    );
  }
}


// ignore: must_be_immutable
class TabReviewProductWidget extends StatelessWidget {
  dynamic data;
  bool isLoading;
  TabReviewProductWidget({this.data,this.isLoading});
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return isLoading?Container(
        padding: scaler.getPadding(0,2),
      child: LoadingHistory(tot: 10),
    ):data["review"].length<1?Container( padding: scaler.getPadding(0,2),height: scaler.getHeight(30),child: EmptyTenant()):ListView.separated(
      padding: scaler.getPadding(0,2),
      itemBuilder: (context, index) {
        final res=data["review"][index];
        return ReviewWidget(
          id: res["id"],
          idMember: res["idMember"],
          kdBrg: res["kdBrg"],
          nama: res["nama"],
          caption: res["caption"],
          rate: res["rate"],
          foto: res["foto"],
          time: res["time"],
          createdAt: res["createdAt"],
          updatedAt: res["updatedAt"],
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
      itemCount: data["review"].length,
      // itemCount:100,
      primary: false,
      shrinkWrap: true,
    );

  }
}






