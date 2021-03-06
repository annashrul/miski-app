import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/provider/cart_provider.dart';
import 'package:miski_shop/provider/product_provider.dart';
import 'package:provider/provider.dart';

class ProductGridWidget extends StatelessWidget {
  const ProductGridWidget({
    Key key,
    @required this.productId,
    @required this.productName,
    @required this.productImage,
    @required this.productPrice,
    @required this.productSales,
    @required this.productRate,
    @required this.productStock,
    @required this.heroTag,
    this.callback,
    this.index,
  }) : super(key: key);
  final String productId;
  final String productName;
  final String productImage;
  final String productPrice;
  final String productSales;
  final String productRate;
  final String productStock;
  final String heroTag;
  final Function callback;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    final product = Provider.of<ProductProvider>(context);
    print(productStock);
    return WidgetHelper().myRipple(
      callback: (){
        Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
          "heroTag":this.heroTag,
          "id":this.productId,
          "image":this.productImage,
        }).whenComplete(() => this.callback());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: this.heroTag + productId,
              child: WidgetHelper().baseImage(productImage),
            ),
            Padding(
              padding:scaler.getPadding(1,2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  config.MyFont.subtitle(context: context,text:productName,color: Theme.of(context).textTheme.bodyText2.color,fontSize: 9),
                  config.MyFont.title(context: context,text:"${config.MyFont.toMoney("$productPrice")}",color: config.Colors.moneyColors,fontWeight: FontWeight.bold,fontSize: 9),
                  SizedBox(height: scaler.getHeight(0.5)),
                  config.MyFont.subtitle(context: context,text: double.parse("$productStock")>0?'${double.parse(productStock).toStringAsFixed(0)} tersedia':"stok habis",fontSize: 8,maxLines: 2),
                  Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: scaler.getHeight(0.3),
                        decoration: BoxDecoration(color: Theme.of(context).focusColor, borderRadius: BorderRadius.circular(6)),
                      ),
                      Container(
                        width: double.parse("$productStock"),
                        height: scaler.getHeight(0.3),
                        decoration: BoxDecoration(
                            color: double.parse("$productStock") > 30 ? Theme.of(context).accentColor : Colors.deepOrange,
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ],
                  ),
                  SizedBox(height: scaler.getHeight(0.5)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: config.MyFont.title(context: context,text:"$productSales terjual",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8)),
                      WidgetHelper().myRating(context: context,rating: productRate)

                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );


  }
}

