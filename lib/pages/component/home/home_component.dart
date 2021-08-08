import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/home/function_home.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/slider/ListSliderModel.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/pages/component/main_component.dart';
import 'package:netindo_shop/pages/widget/product/filter_product_slider_widget.dart';
import 'package:netindo_shop/pages/widget/product/product_grid_widget.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
import 'package:netindo_shop/pages/widget/slider_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

// ignore: must_be_immutable
class HomeComponent extends StatefulWidget {
  @override
  _HomeComponentState createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent>{
  Animation animationOpacity;
  AnimationController animationController;
  ListProductTenantModel listProductTenantModel;
  ListSliderModel listSliderModel;
  List resFilter=[];
  bool isLoadingSlider=true,isLoadingProduct=true,isLoadingGroup=true;
  Future loadProduct(id)async{
    final res = await FunctionHome().loadProduct(context: context,idKelompok:id);
    listProductTenantModel=res;
    isLoadingProduct=false;
    if(this.mounted){this.setState(() {});}
  }
  Future loadGroup()async{
    final res = await FunctionHome().loadGroup(context: context);
    resFilter=res;
    isLoadingGroup=false;
    if(this.mounted){this.setState(() {});}
  }
  Future loadSlider()async{
    final res = await FunctionHome().loadSlider(context: context);
    listSliderModel = res;
    isLoadingSlider=false;
    if(this.mounted){this.setState(() {});}
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSlider();
    loadProduct("");
    loadGroup();
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
          isLoadingSlider?WidgetHelper().baseLoading(context,Container(
            padding: scaler.getPadding(1,2),
            child: WidgetHelper().shimmer(context: context,height: 20,width: MediaQuery.of(context).size.width/1),
          )):Container(
            padding: scaler.getPaddingLTRB(0,0,0,1),
            child: SliderWidget(data: listSliderModel.result.data),
          ),
          StickyHeader(
            header: isLoadingGroup?WidgetHelper().baseLoading(context,Container(
              padding: scaler.getPadding(0,2),
              child: WidgetHelper().shimmer(context: context,height: 2,width: MediaQuery.of(context).size.width/1),
            )):FilterProductSliderWidget(
                heroTag: 'home_categories_1',
                data: resFilter,
                onChanged: (id) {
                  this.setState(() {
                    isLoadingProduct=true;
                  });
                  loadProduct(id);
                }),
            content:Container(
              padding: scaler.getPadding(0.5,2),
              child: Wrap(
                children: [
                  WidgetHelper().titleQ(context,"Barang pilihan untuk kamu",icon: UiIcons.heart,padding: scaler.getPaddingLTRB(0,0,0,0.5),),
                  isLoadingProduct?LoadingProductTenant(tot: 10,):listProductTenantModel.result.data.length<1?Container(height:scaler.getHeight(30),child:EmptyTenant()):new StaggeredGridView.countBuilder(
                    primary: false,
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    itemCount:listProductTenantModel.result.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final res=listProductTenantModel.result.data[index];
                      return ProductGridWidget(
                        productId: res.id,
                        productName: res.title,
                        productImage: res.gambar,
                        productPrice: res.harga,
                        productSales: res.stockSales,
                        productRate: res.rating,
                        heroTag: 'categorized_products_grid_${res.id}',
                        callback: (){
                          // widget.callback("norefresh");
                        },
                      );
                    },
                    staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: 15.0,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      callback: (){
        this.setState(() {
          isLoadingSlider=true;
          isLoadingProduct=true;
          isLoadingGroup=true;
        });
        loadSlider();
        loadProduct('');
        loadGroup();
      },
    );
  }
}
