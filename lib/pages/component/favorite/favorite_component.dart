
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/database_config.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/database_helper.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/widget/product/porduct_list_widget.dart';
import 'package:miski_shop/pages/widget/product/product_grid_widget.dart';
import 'package:miski_shop/pages/widget/searchbar_widget.dart';
import 'package:miski_shop/provider/favorite_provider.dart';
import 'package:provider/provider.dart';
import '../../widget/empty_widget.dart';
import '../../widget/loading_widget.dart';

class FavoriteComponent extends StatefulWidget {
  @override
  _FavoriteComponentState createState() => _FavoriteComponentState();
}

class _FavoriteComponentState extends State<FavoriteComponent>{

  @override
  void dispose() {
    final fav = Provider.of<FavoriteProvider>(context, listen: false);
    fav.controller.removeListener(fav.scrollListener);
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    final fav = Provider.of<FavoriteProvider>(context, listen: false);
    fav.read();
    fav.controller = new ScrollController()..addListener(fav.scrollListener);
  }


  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    final fav = Provider.of<FavoriteProvider>(context);
    return fav.isLoading?Padding(
      padding: scaler.getPadding(0, 2),
      child: LoadingProductTenant(tot: 10),
    ):SingleChildScrollView(
      controller: fav.controller,
      physics:AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: scaler.getPadding(0,2),
            child: SearchBarWidget(callback: (e){
              fav.setAny(e);
              fav.read();
            }),
          ),
          SizedBox(height: 10),
          Offstage(
            offstage: fav.resFavoriteProduct.isEmpty,
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
                      onPressed: () => fav.setLayout("list"),
                      icon: Icon(
                        Icons.format_list_bulleted,
                        color: fav.layout == 'list' ? Theme.of(context).accentColor : Theme.of(context).focusColor,
                      ),
                    ),
                    IconButton(
                      onPressed: ()=>fav.setLayout("grid"),
                      icon: Icon(
                        Icons.apps,
                        color:fav.layout == 'grid' ? Theme.of(context).accentColor : Theme.of(context).focusColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Offstage(
            offstage: fav.layout != 'list' || fav.resFavoriteProduct.isEmpty,
            child: ListView.separated(
              padding: scaler.getPadding(0,2),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: fav.resFavoriteProduct.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final res = fav.resFavoriteProduct[index];
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
                      fav.delete(res);
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
            offstage: fav.layout != 'grid' || fav.resFavoriteProduct.isEmpty,
            child: Container(
              padding: scaler.getPadding(0,2),
              child: new StaggeredGridView.countBuilder(
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 4,
                itemCount: fav.resFavoriteProduct.length,
                itemBuilder: (BuildContext context, int index) {
                  final res = fav.resFavoriteProduct[index];
                  return ProductGridWidget(
                    productId: res["id_product"],
                    productName: res["title"],
                    productImage: res["gambar"],
                    productPrice: res["harga"],
                    productSales: res["stock_sales"],
                    productStock: res["stock"],
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
            offstage: fav.resFavoriteProduct.isNotEmpty,
            child: EmptyDataWidget(
              iconData: UiIcons.heart,
              title: StringConfig.noData,
              isFunction: false,
            ),
          ),
          if(fav.isLoadMore)Center(child: CupertinoActivityIndicator())

        ],
      ),
    );
  }






}
