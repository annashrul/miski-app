import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/screen/product/product_detail_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
class BadgesQ extends StatelessWidget {
  final String val;
  BadgesQ({this.val});
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Positioned(
      top: 6,
      right: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Theme.of(context).accentColor),
        alignment: AlignmentDirectional.topEnd,
        child: WidgetHelper().textQ(val, scaler.getTextSize(9),Colors.white,FontWeight.bold),
      ),
    );
  }
}


class ProductWidget extends StatefulWidget {
  final String id;
  final String gambar;
  final String title;
  final String harga;
  final String hargaCoret;
  final String rating;
  final String stock;
  final String stockSales;
  final String disc1;
  final String disc2;
  final Function countCart;
  ProductWidget({
    this.id,
    this.gambar,
    this.title,
    this.harga,
    this.hargaCoret,
    this.rating,
    this.stock,
    this.stockSales,
    this.disc1,
    this.disc2,
    this.countCart
  });
  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  Widget child;
  final DatabaseConfig _helper = new DatabaseConfig();
  Future insertProductClick()async{
    await FunctionHelper().storeClickProduct(widget.id);
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Random random = new Random();
    if(int.parse(widget.stock)>0){
      child=Container();
      if(int.parse(widget.disc1)!=0&&int.parse(widget.disc2)!=0){
        child = BadgesQ(val:'${widget.disc1} + ${widget.disc2} %');
      }
      else if(int.parse(widget.disc1)!=0){
        child = BadgesQ(val:'${widget.disc1}');
      }
    }
    else{
      child = BadgesQ(val: 'Stock habis',);
    }
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200],
                spreadRadius: 0,
                blurRadius: 5,
              ),
            ],
          ),
          child: WidgetHelper().myRipple(
            callback: ()async{
              await insertProductClick();
              WidgetHelper().myPushAndLoad(context, ProductDetailPage(id: widget.id), widget.countCart);
            },
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: WidgetHelper().baseImage(widget.gambar),
                ),
                SizedBox(height: 12),
                Padding(
                  padding:scaler.getPadding(0,1),
                  child: WidgetHelper().textQ(widget.title, scaler.getTextSize(9),LightColor.lightblack,FontWeight.bold,maxLines:3 ),
                ),
                Padding(
                  padding: scaler.getPadding(0,1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      int.parse(widget.hargaCoret)<1?SizedBox():WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.hargaCoret))}",  scaler.getTextSize(9),SiteConfig().accentDarkColor,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                      SizedBox(width: int.parse(widget.hargaCoret)<1?0:5),
                      WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(widget.harga))}",  scaler.getTextSize(9),LightColor.orange,FontWeight.bold),
                    ],
                  ),
                ),
                if(widget.stockSales!='') Padding(
                  padding:scaler.getPadding(0,1),
                  child: WidgetHelper().textQ("${widget.stockSales} terjual",  scaler.getTextSize(9),Colors.grey,FontWeight.normal),
                ),
                double.parse(widget.rating)>0?Padding(
                  padding:scaler.getPadding(0,1),
                  child:  RatingBar.builder(
                    itemSize: 15.0,
                    initialRating: double.parse(widget.rating),
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemPadding: EdgeInsets.only(right: 4.0),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return Icon(
                            Icons.sentiment_very_dissatisfied,
                            color: Colors.red,
                          );
                        case 1:
                          return Icon(
                            Icons.sentiment_dissatisfied,
                            color: Colors.redAccent,
                          );
                        case 2:
                          return Icon(
                            Icons.sentiment_neutral,
                            color: Colors.amber,
                          );
                        case 3:
                          return Icon(
                            Icons.sentiment_satisfied,
                            color: Colors.lightGreen,
                          );
                        case 4:
                          return Icon(
                            Icons.sentiment_very_satisfied,
                            color: Colors.green,
                          );
                        default:
                          return Container();
                      }
                    },
                    onRatingUpdate:null,
                  ),
                ):Container(),
                SizedBox(height: 15),
              ],
            )
          ),
        ),

        child
      ],
    );
  }
}


class FirstProductWidget extends StatefulWidget {
  final String id;
  final String gambar;
  final String title;
  final String harga;
  final String hargaCoret;
  final String rating;
  final String stock;
  final String stockSales;
  var disc1;
  var disc2;
  final Function countCart;
  FirstProductWidget({
    this.id,
    this.gambar,
    this.title,
    this.harga,
    this.hargaCoret,
    this.rating,
    this.stock,
    this.stockSales,
    this.disc1,
    this.disc2,
    this.countCart
  });
  @override
  _FirstProductWidgetState createState() => _FirstProductWidgetState();
}

class _FirstProductWidgetState extends State<FirstProductWidget> {
  Widget child;
  final DatabaseConfig _helper = new DatabaseConfig();
  Future insertProductClick()async{
    final idTenant = await FunctionHelper().getSession("id_tenant");
    final idUser = await UserHelper().getDataUser("name");
    await _helper.updateData(ProductQuery.TABLE_NAME,"is_click", "true", idTenant, widget.id.toString());
    print("update product sukses");
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    Random random = new Random();
    int random_number = random.nextInt(10000000);
    print(widget.stock);
    print(widget.disc1);
    print(widget.disc2);
    if(int.parse(widget.stock)>0){
      child=Container();
      if(widget.disc1!=0||widget.disc1!="0"||widget.disc1!=null&&widget.disc2!=0||widget.disc2!="0"||widget.disc2!=null){
        child = BadgesQ(val:'${widget.disc1} + ${widget.disc2}');
      }
      else if(widget.disc1!=0||widget.disc1!="0"||widget.disc1!=null){
        child = BadgesQ(val:'${widget.disc1}');
      }
    }
    else{
      if(int.parse(widget.stock)==SiteConfig().noDataCode){
        print("abus");
        if(widget.disc1=="-"&&widget.disc2=="-"){
          child=Container();
        }
        else{
          child = BadgesQ(val:'${widget.disc1}, ${widget.disc2}');
        }
      }
      else{
        child = BadgesQ(val: 'Stock habis',);
      }
    }
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        WidgetHelper().myPress(
            ()async{
              // print(widget.id);
              // await insertProductClick();
              // WidgetHelper().myPushAndLoad(context, DetailProducrScreen(id: widget.id), widget.countCart);
            },
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).focusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(width:1.0,color: mode?Colors.white10:Colors.grey[200])
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: 'HEROPRODUCT${widget.id}$random_number',
                    child: Image.network(widget.gambar),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding:scaler.getPadding(0,1),
                    child: WidgetHelper().textQ(widget.title, scaler.getTextSize(8),SiteConfig().secondColor,FontWeight.normal),
                  ),
                  Padding(
                    padding:scaler.getPadding(0.5,1),
                    child: Row(
                      children: [
                        int.parse(widget.stock)<0?Container():WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.hargaCoret))}",  scaler.getTextSize(8),SiteConfig().accentDarkColor,FontWeight.bold,textDecoration: TextDecoration.lineThrough),
                        int.parse(widget.stock)<0?Container():SizedBox(width: 5),
                        WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.harga))}",  scaler.getTextSize(8),Colors.green,FontWeight.normal),
                      ],
                    ),
                  ),
                  int.parse(widget.stock)>0?Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child:WidgetHelper().textQ("${widget.stockSales} terjual", 12,Colors.grey,FontWeight.bold),
                  ):Container(),
                  int.parse(widget.rating)>0?Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                    child:RatingBar.builder(
                        itemSize: 15.0,
                        initialRating: double.parse(widget.rating),
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemPadding: EdgeInsets.only(right: 4.0),
                        itemBuilder: (context,index){
                          switch (index) {
                            case 0:
                              return Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent,
                              );
                            case 2:
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                              );
                            case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                            default:
                              return Container();
                          }
                        },
                        onRatingUpdate: null
                    ),
                  ):Container(),
                  SizedBox(height: 15),
                ],
              ),
            ),
            color: Colors.black38
        ),
        child
      ],
    );
  }

}

