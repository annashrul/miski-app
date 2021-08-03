import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';

// ignore: must_be_immutable
class TabProductWidget extends StatelessWidget {
  DetailProductTenantModel detailProductTenantModel;
  final bool isLoading;
  TabProductWidget({this.detailProductTenantModel,this.isLoading});
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:scaler.getPaddingLTRB(2,1,2,0.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: isLoading?WidgetHelper().shimmer(context:context,width: 30):config.MyFont.subtitle(context: context,text:detailProductTenantModel.result.title,fontSize: 9),
              ),
              if(!isLoading)Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  config.MyFont.subtitle(context: context,text:detailProductTenantModel.result.rating,fontSize: 8,color: Colors.yellow),
                  Icon(
                    Icons.star_border,
                    color: Colors.yellow,
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
              isLoading?WidgetHelper().shimmer(context:context,width: 20):config.MyFont.title(context: context,text:"${FunctionHelper().formatter.format(int.parse(detailProductTenantModel.result.harga))}",color: config.Colors.mainColors),
              SizedBox(width: 10),
              isLoading?WidgetHelper().shimmer(context:context,width: 10):config.MyFont.title(
                context: context,
                text:int.parse(detailProductTenantModel.result.hargaCoret)<1?"":"${FunctionHelper().formatter.format(int.parse(detailProductTenantModel.result.hargaCoret))}",
                textDecoration: TextDecoration.lineThrough,
                fontSize: 8
              ),
              SizedBox(width: 10),
              isLoading?WidgetHelper().shimmer(context:context,width: 10):Expanded(
                child: config.MyFont.subtitle(context: context,text:"${detailProductTenantModel.result.stockSales} terjual",fontSize: 9,textAlign: TextAlign.right),
              )
            ],
          ),
        ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            leading: Icon(
              FlutterIcons.reproduction_mco,
              color: Theme.of(context).hintColor,
            ),
            title: Text(
              'Related Poducts',
              style: Theme.of(context).textTheme.display1,
            ),
          ),
        ),
        // FlashSalesCarouselWidget(heroTag: 'product_related_products', productsList: widget._productsList.flashSalesList),
      ],
    );
  }

}
