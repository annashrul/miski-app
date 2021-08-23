import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/widget/home/promo_home_widget.dart';
import 'package:miski_shop/pages/widget/home/slider_home_widget.dart';
import 'package:miski_shop/pages/widget/product/filter_product_slider_widget.dart';
import 'package:miski_shop/pages/widget/product/product_grid_widget.dart';
import 'package:miski_shop/pages/widget/promo/detail_promo_widget.dart';
import 'package:miski_shop/pages/widget/searchbar_widget.dart';
import 'package:miski_shop/pages/widget/slider_widget.dart';
import 'package:miski_shop/provider/cart_provider.dart';
import 'package:miski_shop/provider/group_provider.dart';
import 'package:miski_shop/provider/product_provider.dart';
import 'package:miski_shop/provider/promo_provider.dart';
import 'package:miski_shop/provider/slider_provider.dart';
import 'package:provider/provider.dart';
import '../../widget/empty_widget.dart';
import '../../widget/loading_widget.dart';
import '../../widget/refresh_widget.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

// ignore: must_be_immutable
class HomeComponent extends StatefulWidget {

  @override
  _HomeComponentState createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent>{
  Animation animationOpacity;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    final product = Provider.of<ProductProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false);
    group.read(context);
    product.read(context: context);
    product.controller = new ScrollController()..addListener(product.scrollListener);
  }
  @override
  void dispose() {
    super.dispose();
    final product = Provider.of<ProductProvider>(context, listen: false);
    product.controller.removeListener(product.scrollListener);
  }
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final product = Provider.of<ProductProvider>(context);
    final group = Provider.of<GroupProvider>(context);
    final scaler = config.ScreenScale(context).scaler;
    return Scrollbar(
        child: RefreshWidget(
          widget: Stack(
            fit: StackFit.passthrough,
            children: [
              ListView(
                controller: product.controller,
                padding: EdgeInsets.all(0),
                children: <Widget>[
                  Padding(
                    padding: scaler.getPadding(0,2),
                    child: SearchBarWidget(callback: (e){
                      product.setQ(e);
                      product.read(context: context);
                    }),
                  ),
                  SliderHomeWidget(),
                  PromoHomeWidget(),
                  StickyHeader(
                    header: group.isLoading?WidgetHelper().baseLoading(context,Container(
                      padding: scaler.getPadding(0,2),
                      child: WidgetHelper().shimmer(context: context,height: 2,width: MediaQuery.of(context).size.width/1),
                    )):group.listGroupProductModel.result.data.length>0?FilterProductSliderWidget(
                      heroTag: 'home_categories_1',
                      data: group.listGroupProductModel,
                      onChanged: (id) {
                        product.perPage=StringConfig.perpage;
                        product.setGroup(id);
                        product.read(context: context);
                      }
                    ):SizedBox(),
                    content:Container(
                      padding: scaler.getPaddingLTRB(2,1,2,0),
                      child: Wrap(
                        children: [
                          WidgetHelper().titleQ(context,"Barang pilihan untuk kamu",icon: UiIcons.heart,padding: scaler.getPaddingLTRB(0,0,0,1),),
                          product.isLoading?LoadingProductTenant(tot: 10,):product.listProductTenantModel.result.data.length<1?Container(height:scaler.getHeight(30),child:EmptyTenant()):new StaggeredGridView.countBuilder(
                            primary: false,
                            shrinkWrap: true,
                            crossAxisCount: 4,
                            itemCount:product.listProductTenantModel.result.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final res=product.listProductTenantModel.result.data[index];
                              return ProductGridWidget(
                                productId: res.id,
                                productName: res.title,
                                productImage: res.gambar,
                                productPrice: res.harga,
                                productSales: res.stockSales,
                                productRate: res.rating,
                                productStock: res.stock,
                                heroTag: 'categorized_products_grid_${res.id}',
                                callback: (){
                                  cart.getCartData(context);
                                  // product.setGroup("");
                                  // product.read(context: context);
                                },
                                index: index,
                              );
                            },
                            staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                            mainAxisSpacing: 15.0,
                            crossAxisSpacing: 15.0,
                          ),
                          product.isLoadMore?Container(
                            alignment: Alignment.center,
                            padding: scaler.getPaddingLTRB(0,0,0,1),
                            child:CupertinoActivityIndicator()
                          ):SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              new Positioned(
                bottom: 10,
                right: scaler.getWidth(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: config.Colors.mainColors.withOpacity(0.9),
                  ),
                  child: WidgetHelper().myRipple(
                    radius: 100,
                      callback: ()=>product.toTop(),
                      child: new Container(
                          padding: scaler.getPadding(0.7, 2),
                          alignment: AlignmentDirectional.centerEnd,
                          child: Icon(AntDesign.totop,color: config.Colors.secondDarkColors,)
                      )
                  ),
                )
              )
            ],
          ),
          callback: (){
            product.reload(context);
            group.reload(context);
          },
        )
    );
  }



}
