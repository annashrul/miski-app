import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/tenant/list_product_tenant_model.dart';
import 'package:miski_shop/pages/widget/product/porduct_list_widget.dart';
import 'package:miski_shop/pages/widget/product/product_grid_widget.dart';
import 'empty_widget.dart';


// ignore: must_be_immutable
class CategoryProductTabWidget extends StatefulWidget {
  ListProductTenantModel listProductTenantModel;
  dynamic category;
  CategoryProductTabWidget({this.listProductTenantModel,this.category});
  @override
  _CategoryProductTabWidgetState createState() => _CategoryProductTabWidgetState();
}

class _CategoryProductTabWidgetState extends State<CategoryProductTabWidget> {
  String layout = 'grid';


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.category["index"]);
    final scaler=config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPadding(0,0),
      child: Wrap(
        children: [
          Padding(
            padding: scaler.getPadding(0,2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WidgetHelper().titleQ(context,"Kategori ${widget.category["title"]}",icon: UiIcons.box),
                Row(
                  children: [
                    WidgetHelper().myRipple(
                        callback: (){
                          setState(() {
                            this.layout = 'list';
                          });
                        },
                        child: WidgetHelper().icons(ctx: context,icon: Icons.format_list_bulleted,color: this.layout == 'list' ? Theme.of(context).accentColor : Theme.of(context).focusColor)
                    ),
                    SizedBox(width: scaler.getWidth(2)),
                    WidgetHelper().myRipple(
                        callback: (){
                          setState(() {
                            this.layout = 'grid';
                          });
                        },
                        child: WidgetHelper().icons(ctx: context,icon: Icons.apps,color:  this.layout == 'grid' ? Theme.of(context).accentColor : Theme.of(context).focusColor)
                    ),
                  ],
                )
              ],
            ),
          ),

         Offstage(
            offstage: this.layout != 'list' || widget.listProductTenantModel.result.data.isEmpty,
            child: ListView.separated(
              padding: scaler.getPadding(1,2),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount:  widget.listProductTenantModel.result.data.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final res =  widget.listProductTenantModel.result.data[index];
                return ProductListWidget(
                  heroTag: 'categort_product_list',
                  productId: res.id,
                  productName: res.title,
                  productImage: res.gambar,
                  productPrice: res.harga,
                  productSales: res.stockSales.toString(),
                  productRate: res.rating,
                  productStock: res.stock,
                );
              },
            ),
          ),
          Offstage(
            offstage: this.layout != 'grid' ||  widget.listProductTenantModel.result.data.isEmpty,
            child: Container(
              padding: scaler.getPadding(1,2),
              child: new StaggeredGridView.countBuilder(
                padding: EdgeInsets.all(0),
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 4,
                itemCount:  widget.listProductTenantModel.result.data.length,
                itemBuilder: (BuildContext context, int index) {
                  final res = widget.listProductTenantModel.result.data[index];
                  return ProductGridWidget(
                    productId: res.id,
                    productName: res.title,
                    productImage: res.gambar,
                    productPrice: res.harga,
                    productSales: res.stockSales.toString(),
                    productRate: res.rating,
                    heroTag: 'category_product_grid',
                    callback: (){},
                  );
                },
                staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
              ),
            ),
          ),
         Offstage(
            offstage: widget.listProductTenantModel.result.data.isNotEmpty,
            child: EmptyDataWidget(
              iconData: UiIcons.box,
              title: 'D\'ont have any item in the wish list',
              callback: (){},
              isFunction: true,
              txtFunction: "Start Exploring",
            ),
          )
        ],
      ),
    );
  }
}
