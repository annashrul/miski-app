import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
class SecondProductWidget extends StatefulWidget {
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
  SecondProductWidget({
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
  _SecondProductWidgetState createState() => _SecondProductWidgetState();
}

class _SecondProductWidgetState extends State<SecondProductWidget> {

  double width;
  double height;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    double widthSize = MediaQuery.of(context).size.width;
    width=120;
    height=double.infinity;
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 0,
      ),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Container(
            width: scaler.getWidth(35),
            height: height,
            decoration: BoxDecoration(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0)
            ),
            child: WidgetHelper().myPress(
                (){
                  WidgetHelper().myPush(context, DetailProducrScreen(id: widget.id));},
                Column(
                  children: [
                    Container(
                      height:  MediaQuery.of(context).size.height/6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),

                      ),
                      child: WidgetHelper().baseImage(widget.gambar),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            int.parse(widget.disc1)>0?Container(
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: SiteConfig().mainColor,
                                    ),
                                    child: WidgetHelper().textQ("10 %", scaler.getTextSize(8),SiteConfig().secondDarkColor, FontWeight.w600),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: SiteConfig().mainColor
                                    ),
                                    child: WidgetHelper().textQ("+", scaler.getTextSize(8), SiteConfig().secondDarkColor, FontWeight.w600),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: SiteConfig().mainColor
                                    ),
                                    child: WidgetHelper().textQ("10 %", scaler.getTextSize(8), SiteConfig().secondDarkColor, FontWeight.w600),
                                  ),
                                ],
                              ),
                            ):int.parse(widget.stock)>0?Container(
                              padding: EdgeInsets.all(4),
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: SiteConfig().mainColor
                              ),
                              child: WidgetHelper().textQ("${widget.stockSales} Terjual", scaler.getTextSize(9), SiteConfig().secondDarkColor, FontWeight.normal),
                            ):Container(),
                            Container(
                                child: WidgetHelper().textQ(widget.title, scaler.getTextSize(9), Colors.black, FontWeight.normal)
                            ),
                            Container(
                              child: Row(
                                children: [
                                  WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.hargaCoret))}", scaler.getTextSize(9),SiteConfig().moneyColor, FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                                  SizedBox(width: 10.0),
                                  WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.harga))}", scaler.getTextSize(9),SiteConfig().moneyColor, FontWeight.bold)
                                ],
                              ),
                            ),
                            RatingBar.builder(
                                itemSize: 12.0,
                                initialRating: double.parse(widget.rating),
                                direction: Axis.horizontal,
                                itemCount: 5,
                                unratedColor: Colors.grey,
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              color:Colors.black38
            ),
          ),
          int.parse(widget.stock)>0?Container():BadgesQ(val:'Stock habis')
        ],
      ),
    );
  }
}


class SecondProductsWidget extends StatefulWidget {
  List data=[];
  SecondProductsWidget({this.data});
  @override
  _SecondProductsWidgetState createState() => _SecondProductsWidgetState();
}

class _SecondProductsWidgetState extends State<SecondProductsWidget> {
  double width;
  double height;
  @override
  Widget build(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;
    width=120;
    height=double.infinity;
    return ListView.builder(
        scrollDirection: Axis.horizontal,
      itemCount: widget.data.length,
      itemBuilder: (context,index){
        return Padding(
          padding: EdgeInsets.only(
            top: 5,
            bottom: 5,
            left: (index == 0) ? 20 : 0,
            right: (index == widget.data.length) ? 20 : 10,
          ),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Container(
                width: 120,
                height: height,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[600].withOpacity(0.5),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: InkWell(
                  hoverColor: Colors.green,
                  highlightColor: Colors.green,
                  focusColor: Colors.green,
                  onTap: (){
                    WidgetHelper().myPush(context, DetailProducrScreen(id: widget.data[index]['id']));
                  },
                  child: Column(
                    children: [
                      Container(
                        height:  MediaQuery.of(context).size.height/6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF9FA6B0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(widget.data[index]['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              int.parse(widget.data[index]['disc1'])>0?Container(
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: SiteConfig().mainColor,
                                      ),
                                      child: WidgetHelper().textQ("10 %", 10,SiteConfig().secondDarkColor, FontWeight.w600),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: SiteConfig().mainColor
                                      ),
                                      child: WidgetHelper().textQ("+", 10, SiteConfig().secondDarkColor, FontWeight.w600),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      margin: EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: SiteConfig().mainColor
                                      ),
                                      child: WidgetHelper().textQ("10 %", 10, SiteConfig().secondDarkColor, FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ):int.parse(widget.data[index]['stock'])>0?Container(
                                padding: EdgeInsets.all(4),
                                margin: EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: SiteConfig().mainColor
                                ),
                                child: WidgetHelper().textQ("Stock ${widget.data[index]['stock']}", 10, SiteConfig().secondDarkColor, FontWeight.w600),
                              ):Container(),
                              Container(
                                  child: WidgetHelper().textQ(widget.data[index]['name'], 12, Colors.black, FontWeight.w400)
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.data[index]['hargaCoret']))}", 10, Colors.green, FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                                    SizedBox(width: 10.0),
                                    WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(widget.data[index]['harga']))}", 12,Colors.green, FontWeight.normal)
                                  ],
                                ),
                              ),
                              RatingBar.builder(
                                  itemSize: 15.0,
                                  initialRating: double.parse(widget.data[index]['rating']),
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
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              int.parse(widget.data[index]['stock'])>0?Container():BadgesQ(val:'Stock habis')
            ],
          ),
        );
      }
    );
  }
}
