import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/home/function_home.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/promo/global_promo_model.dart';
import 'package:netindo_shop/model/slider/ListSliderModel.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/pages/component/main_component.dart';
import 'package:netindo_shop/pages/widget/product/filter_product_slider_widget.dart';
import 'package:netindo_shop/pages/widget/product/product_grid_widget.dart';
import 'package:netindo_shop/pages/widget/promo/detail_promo_widget.dart';
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
  GlobalPromoModel globalPromoModel;
  String any="",idKelompok="";
  List resFilter=[];
  bool isLoadingSlider=true,isLoadingProduct=true,isLoadingGroup=true,isLoadingPromo=true,isLoadmore=false;
  ScrollController controller;
  int perpage=StringConfig.perpage,total=0;

  Future loadProduct(id)async{
    String where="&perpage=$perpage";
    if(id!=""){where+="&kelompok=$id";}
    if(any!=""){where+="&q=$any";}
    final res = await FunctionHome().loadProduct(context: context,where: where);
    listProductTenantModel=res;
    total=res.result.total;
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
  Future loadPromo()async{
    final res = await FunctionHome().loadPromo(context: context);
    globalPromoModel = res;
    isLoadingPromo=false;
    if(this.mounted){this.setState(() {});}
  }
  void _scrollListener() {
    if (!isLoadingProduct) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perpage<total){
          setState((){
            perpage+=perpage;
            isLoadmore=true;
          });
          loadProduct(idKelompok);
        }else{
          setState((){
            isLoadmore=false;
          });
        }
      }
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);
    loadSlider();
    loadProduct("");
    loadGroup();
    loadPromo();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.removeListener(_scrollListener);
  }
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return RefreshWidget(
      widget: ListView(
        controller: controller,
        padding: EdgeInsets.all(0),
        children: <Widget>[
          Padding(
            padding: scaler.getPadding(0,2),
            child: SearchBarWidget(callback: (e){
              print(e);
              this.setState(() {
                any=e;
              });
              loadProduct(idKelompok);
            }),
          ),
          isLoadingSlider?WidgetHelper().baseLoading(context,Container(
            padding: scaler.getPadding(1,2),
            child: WidgetHelper().shimmer(context: context,height: 20,width: MediaQuery.of(context).size.width/1),
          )):Container(
            padding: scaler.getPaddingLTRB(0,0,0,1),
            child: SliderWidget(data: listSliderModel.result.data),
          ),
          buildPromo(context),
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
                    idKelompok=id;
                  });
                  loadProduct(id);
                }),
            content:Container(
              padding: scaler.getPadding(1,2),
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
                  ),
                  isLoadmore?Container(
                    padding: scaler.getPaddingLTRB(0,0,0,0.5),
                    child: LoadingProductTenant(tot: 4),
                  ):Container(),
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


  Widget buildPromo(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return isLoadingPromo?WidgetHelper().baseLoading(context,Padding(
      padding: scaler.getPadding(1, 2),
      child:  WidgetHelper().shimmer(
          context: context,height: 10,width: 30
      ),
    )): globalPromoModel.result.data.length<1?SizedBox():Container(
      padding: scaler.getPaddingLTRB(0,0,0,1),
      height: 200.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: scaler.getPaddingLTRB(1,0,1,0),
            child:  Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                WidgetHelper().icons(ctx: context,icon:Icons.arrow_downward),
                config.MyFont.title(context: context,text:"Promo spesial untuk kamu"),
                WidgetHelper().icons(ctx: context,icon:Icons.arrow_downward),
              ],
            ),
          ),
          SizedBox(height: scaler.getHeight(0.5)),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: globalPromoModel.result.data.length ,
              itemBuilder: (context, index){
                return WidgetHelper().myRipple(
                  callback: (){
                    WidgetHelper().myPush(context,DetailPromoWidget(id: globalPromoModel.result.data[index].id));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width / 1.2,
                    decoration: BoxDecoration(
                      // color: Colors.orange[100],
                      border: Border.all(color: config.Colors.mainColors, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding:scaler.getPadding(0,0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    config.MyFont.subtitle(context: context,text:globalPromoModel.result.data[index].title,color: Theme.of(context).textTheme.headline6.color,fontWeight: FontWeight.bold,maxLines: 2),
                                    config.MyFont.subtitle(context: context,text:globalPromoModel.result.data[index].deskripsi,color: Theme.of(context).textTheme.bodyText1.color,fontSize: 8,maxLines: 2),

                                  ],
                                ),
                              ),
                              Padding(
                                padding:scaler.getPadding(0,0),
                                child: WidgetHelper().myRipple(
                                  callback: (){WidgetHelper().myPush(context,DetailPromoWidget(id: globalPromoModel.result.data[index].id));},
                                  child: config.MyFont.subtitle(context: context,text:"lihat promo",color: config.Colors.mainColors),
                                ),
                              )

                            ],
                          ),
                        ),
                        Hero(
                          tag: "${globalPromoModel.result.data[index].title}${globalPromoModel.result.data[index].id}",
                          child:WidgetHelper().baseImage(
                              globalPromoModel.result.data[index].gambar,
                              height: scaler.getHeight(9),
                              width: scaler.getWidth(22),
                            shape: BoxShape.circle
                          )
                          // child: Image.network(
                          //   StringConfig.noImage,
                          //   height: 90.0,
                          //   width: 90.0,
                          // ),
                        )
                      ],
                    ),
                  )
                );
              }
            ),
          )
        ],
      ),
    );
  }

}
