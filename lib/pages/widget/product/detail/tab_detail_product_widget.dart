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
                if(!isLoading)Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    config.MyFont.subtitle(context: context,text:data["rating"],fontSize: 8,color:config.Colors.mainColors,),
                    Icon(
                      Icons.star_border,
                      color:  config.Colors.mainColors,
                      size: scaler.getTextSize(9),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding:scaler.getPaddingLTRB(2,0,2,0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isLoading?WidgetHelper().shimmer(context:context,width: 20):config.MyFont.title(context: context,text:"${FunctionHelper().formatter.format(int.parse(data["harga"]))}",color: config.Colors.mainColors),
                SizedBox(width: 10),
                isLoading?WidgetHelper().shimmer(context:context,width: 10):config.MyFont.title(
                    context: context,
                    text:int.parse(data["harga_coret"])<1?"":"${FunctionHelper().formatter.format(int.parse(data["harga_coret"]))}",
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
      padding: scaler.getPaddingLTRB(0, 0, 0, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: scaler.getPadding(0,2),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.all( 0),
              leading: Icon(
                UiIcons.file_2,
                color: Theme.of(context).hintColor,
              ),
              title:config.MyFont.title(context: context,text:"Description"),
            ),
          ),
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
    return isLoading?LoadingHistory(tot: 10):data["review"].length<1?Container( padding: scaler.getPadding(0,2),height: scaler.getHeight(30),child: EmptyTenant()):ListView.separated(
      padding: scaler.getPadding(0,2),
      itemBuilder: (context, index) {
        final res=data["review"][index];
        // return ReviewWidget(
        //   id: "Maria R. Garza",
        //   idMember:"Maria R. Garza",
        //   kdBrg:"Maria R. Garza",
        //   nama:"Maria R. Garza",
        //   caption: "There are a few foods that predate colonization, and the European colonization of the Americas brought about the introduction of a large number of new ingredients",
        //   rate: "3.5",
        //   foto: "",
        //   time: "7 menit yang lalu",
        //   createdAt: "",
        //   updatedAt:""
        // );
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
        return Divider(
          height: 30,
        );
      },
      itemCount: data["review"].length,
      // itemCount:100,
      primary: false,
      shrinkWrap: true,
    );

  }
}






