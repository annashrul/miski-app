import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
class BadgesQ extends StatelessWidget {
  final String val;
  BadgesQ({this.val});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 6,
      right: 10,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Theme.of(context).accentColor),
        alignment: AlignmentDirectional.topEnd,
        child: WidgetHelper().textQ(val, 10,Colors.white,FontWeight.bold),
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
    Random random = new Random();
    int random_number = random.nextInt(10000000);
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
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[600].withOpacity(0.5),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: InkWell(
            onTap: () async{
              await insertProductClick();
              WidgetHelper().myPushAndLoad(context, DetailProducrScreen(id: widget.id), widget.countCart);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height:  MediaQuery.of(context).size.height/6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.gambar),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: EdgeInsets.all(1.5),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: WidgetHelper().textQ(widget.title, 12,SiteConfig().secondColor,FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.hargaCoret))}", 10,Colors.green,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                      SizedBox(width: 5),
                      WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.harga))}", 12,Colors.green,FontWeight.bold),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                  child: WidgetHelper().textQ("${widget.stockSales} terjual", 12,Colors.grey,FontWeight.bold),
                ),
                double.parse(widget.rating)>0?Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
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
            ),
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
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).accentColor.withOpacity(0.08),
          onTap: () async{
            await insertProductClick();
            WidgetHelper().myPushAndLoad(context, DetailProducrScreen(id: widget.id), widget.countCart);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
              ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: WidgetHelper().textQ(widget.title, 12,SiteConfig().secondColor,FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      int.parse(widget.stock)<0?Container():WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.hargaCoret))}", 10,SiteConfig().accentDarkColor,FontWeight.bold,textDecoration: TextDecoration.lineThrough),
                      int.parse(widget.stock)<0?Container():SizedBox(width: 5),
                      WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.harga))}", 12,Colors.green,FontWeight.bold),
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
        ),
        child
      ],
    );
  }

}

