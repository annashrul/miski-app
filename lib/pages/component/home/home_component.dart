import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/model/slider/ListSliderModel.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/pages/component/main_component.dart';
import 'package:netindo_shop/pages/widget/product/filter_product_slider_widget.dart';
import 'package:netindo_shop/pages/widget/product/product_grid_widget.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
import 'package:netindo_shop/pages/widget/slider_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

// ignore: must_be_immutable
class HomeComponent extends StatefulWidget {
  final Function(String id) callback;
  ListProductTenantModel product;
  ListSliderModel slider;
  final List kelompok;

  HomeComponent({this.callback,this.product,this.kelompok,this.slider});
  @override
  _HomeComponentState createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent>{
  Animation animationOpacity;
  AnimationController animationController;
  ListGroupProductModel listGroupProductModel;
  List resSlider=[];
  List resFilter=[];
  List resProduct=[];
  bool isLoadingGroup=false;
  Future loadFilter()async{
    resFilter=widget.kelompok;
    if(this.mounted) this.setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFilter();
    isLoadingGroup=true;
  }
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return RefreshWidget(
      widget: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          Padding(
            padding: scaler.getPadding(0,2),
            child: SearchBarWidget(),
          ),
          SliderWidget(data: widget.slider.result.data),
          Padding(
            padding: scaler.getPadding(0,2),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.all(0),
              leading: Icon(
                UiIcons.heart,
                color: Theme.of(context).hintColor,
              ),
              title:config.MyFont.title(context: context,text: "Recomended for you"),
            ),
          ),
          StickyHeader(
            header: FilterProductSliderWidget(
                heroTag: 'home_categories_1',
                data: resFilter,
                onChanged: (id) {
                  widget.callback(id);
                }),
            content:Container(
              padding: scaler.getPadding(1,2),
              child:  widget.product.result.data.length<1?Container(height:scaler.getHeight(30),child:EmptyTenant()):new StaggeredGridView.countBuilder(
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 4,
                itemCount: widget.product.result.data.length,
                itemBuilder: (BuildContext context, int index) {
                  final res=widget.product.result.data[index];
                  return ProductGridWidget(
                    productId: res.id,
                    productName: res.title,
                    productImage: res.gambar,
                    productPrice: res.harga,
                    productSales: res.stockSales,
                    productRate: res.rating,
                    heroTag: 'categorized_products_grid_${res.id}',
                    callback: (){
                      widget.callback("norefresh");
                    },
                  );
                },
                staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
              ),
            ),
          ),
          // // Heading (Brands)
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          //   child: ListTile(
          //     dense: true,
          //     contentPadding: EdgeInsets.symmetric(vertical: 0),
          //     leading: Icon(
          //       UiIcons.flag,
          //       color: Theme.of(context).hintColor,
          //     ),
          //     title: Text(
          //       'Brands',
          //       style: Theme.of(context).textTheme.display1,
          //     ),
          //   ),
          // ),
          // StickyHeader(
          //   header: BrandsIconsCarouselWidget(
          //       heroTag: 'home_brand_1',
          //       brandsList: _brandsList,
          //       onChanged: (id) {
          //         setState(() {
          //           animationController.reverse().then((f) {
          //             _productsOfBrandList = _brandsList.list.firstWhere((brand) {
          //               return brand.id == id;
          //             }).products;
          //             animationController.forward();
          //           });
          //         });
          //       }),
          //   content: CategorizedProductsWidget(animationOpacity: animationOpacity, productsList: _productsOfBrandList),
          // ),
        ],
      ),
      callback: (){
        Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: 2);
      },
    );
  }
}
