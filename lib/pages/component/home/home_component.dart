import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/home/function_home.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/promo/global_promo_model.dart';
import 'package:miski_shop/model/slider/ListSliderModel.dart';
import 'package:miski_shop/model/tenant/list_product_tenant_model.dart';
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
    final slider = Provider.of<SliderProvider>(context, listen: false);
    final promo = Provider.of<PromoProvider>(context, listen: false);
    final group = Provider.of<GroupProvider>(context, listen: false);
    group.read(context);
    promo.read(context);
    slider.read(context);
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
    final slider = Provider.of<SliderProvider>(context);
    final group = Provider.of<GroupProvider>(context);
    final promo = Provider.of<PromoProvider>(context);
    final scaler = config.ScreenScale(context).scaler;
    return RefreshWidget(
      widget: ListView(
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
          slider.isLoading?WidgetHelper().baseLoading(context,Container(
            padding: scaler.getPadding(1,2),
            child: WidgetHelper().shimmer(context: context,height: 20,width: MediaQuery.of(context).size.width/1),
          )):Container(
            padding: scaler.getPaddingLTRB(0,0,0,1),
            child: SliderWidget(data:slider.listSliderModel.result.data),
          ),
          buildPromo(context),
          StickyHeader(
            header: group.isLoading?WidgetHelper().baseLoading(context,Container(
              padding: scaler.getPadding(0,2),
              child: WidgetHelper().shimmer(context: context,height: 2,width: MediaQuery.of(context).size.width/1),
            )):group.listGroupProductModel.result.data.length>0?FilterProductSliderWidget(
                heroTag: 'home_categories_1',
                data: group.listGroupProductModel,
                onChanged: (id) {
                  product.perPage=StringConfig.perpage;
                  product.setKelompok(id);
                  product.read(context: context);
                }):SizedBox(),
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
                          print("callback ${cart.isActiveCart}");
                          cart.getCartData(context);
                        },
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
      callback: (){
        slider.reload(context);
        product.reload(context);
        group.reload(context);
        promo.reload(context);
      },
    );
  }


  Widget buildPromo(BuildContext context) {
    final promo = Provider.of<PromoProvider>(context);
    final scaler=config.ScreenScale(context).scaler;
    return promo.isLoading?WidgetHelper().baseLoading(context,Padding(
      padding: scaler.getPadding(1, 2),
      child:  WidgetHelper().shimmer(
          context: context,height: 10,width: 30
      ),
    )): promo.globalPromoModel.result.data.length<1?SizedBox():Container(
      padding: scaler.getPaddingLTRB(2,0,0,1.5),
      height: scaler.getHeight(15),
      child: Column(
        children: <Widget>[
          WidgetHelper().titleQ(context,"Promo spesial untuk kamu",icon: UiIcons.gift,padding: scaler.getPaddingLTRB(0,0,0,1),),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: promo.globalPromoModel.result.data.length ,
              itemBuilder: (context, index){
                print(promo.globalPromoModel.result.data.length);
                print(index);
                return Container(
                  margin: scaler.getMarginLTRB(index==0?0:2, 0,index+1==promo.globalPromoModel.result.data.length?2:0, 0),
                  child: WidgetHelper().myRipple(
                      callback: (){
                        WidgetHelper().myPush(context,DetailPromoWidget(id: promo.globalPromoModel.result.data[index].id));
                      },
                      child: Container(
                        padding: scaler.getPadding(0, 0),
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                          // border: Border.all(color: config.Colors.mainColors, width: 2.0),
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            onError: (Object exception, StackTrace stackTrace) {
                              return Center(child: Icon(Icons.error));
                            },
                            fit: BoxFit.cover,
                            image: NetworkImage(promo.globalPromoModel.result.data[index].gambar)
                          )
                        ),
                        // child: Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: <Widget>[
                        //     Flexible(
                        //       child: Column(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: <Widget>[
                        //           Padding(
                        //             padding:scaler.getPadding(0,0),
                        //             child: Column(
                        //               mainAxisAlignment: MainAxisAlignment.center,
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: <Widget>[
                        //                 config.MyFont.subtitle(context: context,text:promo.globalPromoModel.result.data[index].title,fontWeight: FontWeight.bold,maxLines: 2),
                        //                 config.MyFont.subtitle(context: context,text:promo.globalPromoModel.result.data[index].deskripsi,maxLines:3),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     Hero(
                        //         tag: "${promo.globalPromoModel.result.data[index].title}${promo.globalPromoModel.result.data[index].id}",
                        //         child:WidgetHelper().baseImage(
                        //             promo.globalPromoModel.result.data[index].gambar,
                        //           height: scaler.getHeight(6),
                        //           width: scaler.getWidth(15),
                        //           shape: BoxShape.circle
                        //         )
                        //     )
                        //   ],
                        // ),
                      )
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }

}
