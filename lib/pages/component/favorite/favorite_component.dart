import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/detail/function_detail.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/detail_cart_model.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/pages/widget/product/detail/bottom_bar_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/detail/tab_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/porduct_list_widget.dart';
import 'package:netindo_shop/pages/widget/product/product_grid_widget.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';

class FavoriteComponent extends StatefulWidget {
  @override
  _FavoriteComponentState createState() => _FavoriteComponentState();
}

class _FavoriteComponentState extends State<FavoriteComponent>{
  String layout = 'grid';
  final DatabaseConfig _helper = new DatabaseConfig();
  ScrollController controller;
  List resFavoriteProduct=[];
  bool isLoading=false,isLoadmore=false;
  int perpage=15;
  int total=0;
  Future deleteFavorite(res)async{
    await _helper.delete(ProductQuery.TABLE_NAME, "id", res["id"]);
    await getFavorite();
    WidgetHelper().showFloatingFlushbar(context,"success","${res["title"]} berhasil dihapus dari wish list anda");
  }

  Future getFavorite()async{
    final countFav = await _helper.getWhere(ProductQuery.TABLE_NAME, "is_favorite","true","");
    final res = await _helper.getWhere(ProductQuery.TABLE_NAME,"is_favorite","true","$perpage");
    setState(() {
      total = countFav.length;
      resFavoriteProduct = res;
      isLoading=false;
      isLoadmore=false;
    });
  }
  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if(perpage<total){
        setState((){
          perpage+=7;
          isLoadmore=true;
        });
        getFavorite();
      }
    }

  }
  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);
    isLoading=true;
    getFavorite();
  }


  @override
  Widget build(BuildContext context) {
    print(layout);
    final scaler=config.ScreenScale(context).scaler;
    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: scaler.getPadding(0,2),
            child: SearchBarWidget(),
          ),
          SizedBox(height: 10),
          Offstage(
            offstage: resFavoriteProduct.isEmpty,
            child: Padding(
              padding: scaler.getPaddingLTRB(2,0,1,0),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  UiIcons.heart,
                  color: Theme.of(context).hintColor,
                ),
                title:config.MyFont.title(context: context,text:"Wish list"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          this.layout = 'list';
                        });
                      },
                      icon: Icon(
                        Icons.format_list_bulleted,
                        color: this.layout == 'list' ? Theme.of(context).accentColor : Theme.of(context).focusColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          this.layout = 'grid';
                        });
                      },
                      icon: Icon(
                        Icons.apps,
                        color: this.layout == 'grid' ? Theme.of(context).accentColor : Theme.of(context).focusColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Offstage(
            offstage: this.layout != 'list' || resFavoriteProduct.isEmpty,
            child: ListView.separated(
              padding: scaler.getPadding(0,2),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: resFavoriteProduct.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final res = resFavoriteProduct[index];
                return Dismissible(
                    key: Key(res["id"].hashCode.toString()),
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(
                            UiIcons.trash,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      deleteFavorite(res);
                    },
                    child: ProductListWidget(
                      heroTag: 'favorites_list',
                      productId: res["id_product"],
                      productName: res["title"],
                      productImage: res["gambar"],
                      productPrice: res["harga"],
                      productSales: res["stock_sales"],
                      productRate: res["rating"],
                      productStock: res["stock"],
                    )
                );
              },
            ),
          ),
          Offstage(
            offstage: this.layout != 'grid' || resFavoriteProduct.isEmpty,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: new StaggeredGridView.countBuilder(
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 4,
                itemCount: resFavoriteProduct.length,
                itemBuilder: (BuildContext context, int index) {
                  final res = resFavoriteProduct[index];
                  return ProductGridWidget(
                    productId: res["id_product"],
                    productName: res["title"],
                    productImage: res["gambar"],
                    productPrice: res["harga"],
                    productSales: res["stock_sales"],
                    productRate: res["rating"],
                    heroTag: 'favorites_grid',
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
            offstage: resFavoriteProduct.isNotEmpty,
            child: EmptyDataWidget(
              iconData: UiIcons.heart,
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
