import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class ProductGridWidget extends StatelessWidget {
  const ProductGridWidget({
    Key key,
    @required this.productId,
    @required this.productName,
    @required this.productImage,
    @required this.productPrice,
    @required this.productSales,
    @required this.productRate,
    @required this.heroTag,
    this.callback,
  }) : super(key: key);
  final String productId;
  final String productName;
  final String productImage;
  final String productPrice;
  final String productSales;
  final String productRate;
  final String heroTag;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
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
              child: Image.network(productImage),
            ),
            SizedBox(height: 12),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child:config.MyFont.subtitle(context: context,text:productName,color: Theme.of(context).textTheme.bodyText2.color,fontSize: 9)
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child:config.MyFont.title(context: context,text:"${FunctionHelper().formatter.format(int.parse(productPrice))}",color: Theme.of(context).textTheme.subtitle2.color,fontWeight: FontWeight.bold,fontSize: 9)
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: config.MyFont.title(context: context,text:"$productSales terjual",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8)),
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: scaler.getTextSize(9),
                  ),
                  config.MyFont.title(context: context,text:productRate,color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8)
                ],
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      )
    );


  }
}

