import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({
    Key key,
    @required this.productId,
    @required this.productName,
    @required this.productImage,
    @required this.productPrice,
    @required this.productSales,
    @required this.productRate,
    @required this.productStock,
    @required this.heroTag,
  }) : super(key: key);
  final String productId;
  final String productName;
  final String productImage;
  final String productPrice;
  final String productSales;
  final String productRate;
  final String productStock;
  final String heroTag;
  @override
  Widget build(BuildContext context) {
    return buildListCarouse(context);
  }


  Widget buildListCarouse(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return  InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
      },
      child: Container(
        padding: scaler.getPaddingLTRB(0,0,2,0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + productId,
              child: Container(
                height: scaler.getHeight(5),
                width: scaler.getWidth(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(image: NetworkImage(productImage), fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        config.MyFont.title(context: context,text:productName,fontSize: 9),

                        Row(
                          children: <Widget>[
                            config.MyFont.title(context: context,text:'$productSales terjual',fontSize: 8),
                            SizedBox(width: 10),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: scaler.getTextSize(10),
                            ),
                            config.MyFont.title(context: context,text:'$productRate',fontSize: 8),

                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(int.parse(productPrice))}',fontSize: 9,color:  Theme.of(context).textTheme.display1.color),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}


class ProductListCarouselWidget extends StatelessWidget {
  const ProductListCarouselWidget({
    Key key,
    @required this.productId,
    @required this.productName,
    @required this.productImage,
    @required this.productPrice,
    @required this.productSales,
    @required this.productRate,
    @required this.productStock,
    @required this.heroTag,
  }) : super(key: key);
  final String productId;
  final String productName;
  final String productImage;
  final String productPrice;
  final String productSales;
  final String productRate;
  final String productStock;
  final String heroTag;
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      margin:scaler.getMarginLTRB(0.5,0,2,0),
      child: WidgetHelper().myRipple(
          callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
              "heroTag":this.heroTag,
              "id":this.productId,
              "image":this.productImage,
            });
          },
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Hero(
                tag: heroTag + productId,
                child: Container(
                  width: scaler.getWidth(34),
                  height: scaler.getHeight(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(productImage),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 10,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)), color: Theme.of(context).accentColor),
                    alignment: AlignmentDirectional.topEnd,
                    child:config.MyFont.title(context: context,text:"50 %",fontSize: 9,color: Theme.of(context).primaryColor)
                ),
              ),
              Container(
                margin: scaler.getMarginLTRB(0,17, 0, 0),
                padding: scaler.getPadding(1,1),
                width: scaler.getWidth(28),
                height: scaler.getHeight(11),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    config.MyFont.title(context: context,text:productName,fontSize: 9,maxLines: 2),

                    Row(
                      children: <Widget>[
                        // The title of the product
                        Expanded(
                          child:config.MyFont.title(context: context,text:'$productSales terjual',fontSize: 8,maxLines: 2),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: scaler.getTextSize(10),
                        ),
                        config.MyFont.title(context: context,text:'$productRate',fontSize: 8,maxLines: 2),

                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                    SizedBox(height: scaler.getHeight(0.7)),
                    config.MyFont.title(context: context,text: '${FunctionHelper().formatter.format(int.parse(productStock))} Available',fontSize: 8,maxLines: 2),
                    Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: scaler.getHeight(0.3),
                          decoration: BoxDecoration(color: Theme.of(context).focusColor, borderRadius: BorderRadius.circular(6)),
                        ),
                        Container(
                          width: double.parse(productStock),
                          height: scaler.getHeight(0.3),
                          decoration: BoxDecoration(
                              color: double.parse(productStock) > 30 ? Theme.of(context).accentColor : Colors.deepOrange,
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          )
      ),
    );
  }
}

