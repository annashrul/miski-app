import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/promo/global_promo_model.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_category_product_model.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';
import 'package:netindo_shop/views/widget/choose_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/icon_appbar_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';

import '../wrapper_screen.dart';

class HomeScreen extends StatefulWidget {
  final String id;
  final String nama;
  HomeScreen({Key key,this.id,this.nama}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver  {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey key = GlobalKey();
  final userRepository = UserHelper();
  ListProductTenantModel productTenantModel;
  GlobalPromoModel globalPromoModel;
  ListGroupProductModel listGroupProductModel;
  ListCategoryProductModel listCategoryProductModel;
  ScrollController controller;
  bool isLoadingCategory=true,isLoadingGroup=true,isLoadingFav=true,isLoading=true,isLoadingSlider=true,isLoadmore=false,isTimeout=false,isShowChild=false;
  int _current=0,perpage=10,totalCart=0,total=0;
  List returnProductLocal = [],returnGroup = [], returnCategory = [],returnBrand = [],resFavoriteProduct = [];
  String q='',group='',category='',brand='';
  Future getProduct()async{
    String url = "barang?page=1&perpage=$perpage&id_tenant=${widget.id}";
    if(group!=""){
      url+="&kelompok=$group";
    }
    if(q!=""){
      url+="&q=$q";
    }
    final data = await HandleHttp().getProvider(url,listProductTenantModelFromJson,context: context,callback: (){
      print("callback product");
    });
    ListProductTenantModel res = ListProductTenantModel.fromJson(data.toJson());
    setState(() {
      productTenantModel = res;
      total=res.result.total;
      isLoading=false;
      isLoadmore=false;
      q="";
    });
  }
  Future getGroup()async{
    String url = "kelompok?page=1";
    final data = await HandleHttp().getProvider(url,listGroupProductModelFromJson,context: context,callback: (){
      print("callback group product");
    });
    ListGroupProductModel res = ListGroupProductModel.fromJson(data.toJson());
    returnGroup.add({"id":"","title":"semua"});
    res.result.data.forEach((element) {
      returnGroup.add({"id":element.id,"title":element.title});
    });
    print("############## KELOMPOK ${returnGroup.length}");
    setState(() {
      listGroupProductModel = res;
      isLoadingGroup=false;
    });
  }
  Future getPromo()async{
    var res = await BaseProvider().getProvider("promo?page=1", globalPromoModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isLoadingSlider=false;
        isTimeout=true;
      });
    }
    else{
      if(res is GlobalPromoModel){
        GlobalPromoModel result =  GlobalPromoModel.fromJson(res.toJson());
        setState(() {
          globalPromoModel = GlobalPromoModel.fromJson(result.toJson());
          isLoadingSlider=false;
          isTimeout=true;
        });
      }
    }

  }
  Future getCategory()async{
    String url = "kategori?page=1&perpage=30";
    final data = await HandleHttp().getProvider(url,listCategoryProductModelFromJson,context: context,callback: (){
      print("callback category product");
    });
    ListCategoryProductModel res = ListCategoryProductModel.fromJson(data.toJson());
    setState(() {
      listCategoryProductModel = res;
      isLoadingCategory=false;
    });
  }

  Future countCart() async{
    final res = await BaseProvider().countCart(widget.id);
    if(this.mounted) setState(() {totalCart = res;});
  }
  Future<void> _handleRefresh()async {
    setState(() {
      isLoadingCategory=true;
      isLoading=true;
      isLoadingGroup=true;
      isLoadingSlider=true;
    });
    returnGroup.clear();
    // await FunctionHelper().getFilterLocal(widget.id);
    await FunctionHelper().handleRefresh((){
      getProduct();
      getGroup();
      getPromo();
      getCategory();
    });
  }


  void _scrollListener() {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perpage<total){
          setState((){
            perpage+=10;
            isLoadmore=true;
            isShowChild=false;
          });
          getProduct();
        }
        else{
          isShowChild=true;
        }
      }
    }
  }
  bool isFetch=false;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);
    getProduct();
    getGroup();
    getPromo();
    getCategory();
    countCart();

    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Scaffold(
      appBar: WidgetHelper().myAppBarNoButton(context, "${widget.nama.toUpperCase()}", <Widget>[
        new CartWidget(
          iconColor: LightColor.lightblack,
          labelColor: totalCart>0?Colors.redAccent:Colors.transparent,
          labelCount: totalCart,
          callback: (){
            if(totalCart>0){
              WidgetHelper().myPushAndLoad(context, CartScreen(idTenant: widget.id), countCart);
            }
          },
        ),
        IconAppBarWidget(
          icon: AntDesign.filter,
          callback: (){
            WidgetHelper().myModal(
                context,
                ModalSearch(idTenant:widget.id,callback:(par){
                  setState(() {q=par;});
                  isLoading=true;
                  getProduct();
                })
            );
          },
        )
      ]),

      key: _scaffoldKey,
      body: buildContents(context),
      backgroundColor:Colors.white,
      floatingActionButton:FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: (){
          controller.animateTo(
            0.0,
            curve: Curves.ease,
            duration: const Duration(milliseconds: 5000),
          );
        },
        child: Icon(AntDesign.totop, size: scaler.getTextSize(15), color:SiteConfig().secondColor),
      )
    );
  }

  Widget buildContents(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return RefreshWidget(
      widget: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Offstage(
                  offstage: false,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        sliderQ(context),
                        isLoadingCategory?LoadingCategory():Container(
                          height: scaler.getHeight(8.5),
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: listCategoryProductModel.result.data.length,
                            itemBuilder: (context, index) => Container(
                                margin: scaler.getMarginLTRB(2, 1, 0, 0),
                                width: scaler.getWidth(13),
                                child: InkWell(
                                  onTap: (){},
                                  child:Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child: Container(
                                          height: scaler.getHeight(5),
                                          color: Colors.grey[200],
                                        ),
                                      ),
                                      Positioned(
                                        top:scaler.getTextSize(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            WidgetHelper().baseImage(
                                              listCategoryProductModel.result.data[index].image,
                                              height: scaler.getHeight(4),
                                              width: scaler.getWidth(10),
                                              fit: BoxFit.cover,
                                            ),
                                            Flexible(
                                              child: WidgetHelper().textQ(listCategoryProductModel.result.data[index].title.toLowerCase(), scaler.getTextSize(9), LightColor.lightblack, FontWeight.bold,maxLines: 2),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        ),
                        Divider(thickness: 3,)
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            SliverStickyHeader(
              header: Container(
                margin: scaler.getMarginLTRB(0,0,0,1),
                color: Colors.white,
                height: scaler.getHeight(3),
                child: isLoadingGroup?LoadingOption():ListView.builder(
                  padding: scaler.getPadding(0,2),
                  itemCount: returnGroup.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    double _marginRight = 2;
                    (index == 5) ? _marginRight = 0 : _marginRight = 2;
                    var val = returnGroup[index];
                    return ChooseWidget(
                      res: {"right":_marginRight,"isActive":group==val["id"],"title":val["title"]},
                      callback: (){
                        setState(() {
                          group=val["id"];
                          isLoading=true;
                        });
                        getProduct();
                      },
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
              sliver:SliverList(
                delegate: SliverChildListDelegate([
                  Offstage(
                    offstage: false,
                    child: Container(
                      // color:widget.mode?SiteConfig().darkMode:Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          isLoading?Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            child: LoadingProductTenant(tot: 10),
                          ):productTenantModel.result.data.length>0?Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              child:new StaggeredGridView.countBuilder(
                                padding: EdgeInsets.all(0.0),
                                primary: false,
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 4,
                                itemCount: productTenantModel.result.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var valProductServer =  productTenantModel.result.data[index];
                                  return ProductWidget(
                                    id: valProductServer.id,
                                    gambar: valProductServer.gambar,
                                    title: valProductServer.title,
                                    harga: valProductServer.harga,
                                    hargaCoret: valProductServer.hargaCoret,
                                    rating: valProductServer.rating,
                                    stock: valProductServer.stock,
                                    stockSales: valProductServer.stockSales,
                                    disc1: valProductServer.disc1,
                                    disc2: valProductServer.disc2,
                                    countCart: (){
                                      countCart();
                                    },
                                  );
                                },
                                staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                                mainAxisSpacing: scaler.getHeight(0.5),
                                crossAxisSpacing:scaler.getWidth(1),
                              )
                          ):EmptyTenant(),
                          isLoadmore?Container(
                            padding: const EdgeInsets.only(left: 20,right:20,top:0,bottom:0),
                            child: LoadingProductTenant(tot: 4),
                          ):Container(),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            )
          ]
      ),
      callback: (){_handleRefresh();},
    );
  }
  Widget sliderQ(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return isLoadingSlider?Padding(
      padding: EdgeInsets.all(10.0),
      child: WidgetHelper().baseLoading(context,Container(
        height: scaler.getHeight(23),
        width: double.infinity,
        color: Colors.white,
      )),
      // child: SkeletonFrame(width: double.infinity,height:250)
    ):Stack(
      alignment: AlignmentDirectional.topStart,
      children: <Widget>[
        CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              height: scaler.getHeight(20),
              onPageChanged: (index,reason) {
                setState(() {
                  _current=index;
                });
              },
            ),
            items:globalPromoModel.result.data.map((e){
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    child:WidgetHelper().myRipple(
                      isRadius: false,
                      child: Image.asset(
                        "assets/img/slide1.jpg",
                        fit: BoxFit.fill,
                        height: scaler.getHeight(20),
                        width:MediaQuery.of(context).size.width,
                      )
                    ),
                  );
                },
              );
            }).toList()
        ),
        Positioned(
          top: scaler.getHeight(17),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: globalPromoModel.result.data.map((e){
                return Container(
                  width: 20.0,
                  height: 3.0,
                  margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      color: _current == globalPromoModel.result.data.indexOf(e)
                          ? Theme.of(context).hintColor
                          : Theme.of(context).hintColor.withOpacity(0.3)),
                  // color: _current ==  detailProductTenantModel.result.listImage.indexOf(e)? Theme.of(context).hintColor : Theme.of(context).hintColor.withOpacity(0.3)),
                );
              }).toList()
          ),
        )
      ],
    );
  }

}



class ModalSearch extends StatefulWidget {
  final String idTenant;
  final Function(String q) callback;
  ModalSearch({this.idTenant,this.callback});
  @override
  _ModalSearchState createState() => _ModalSearchState();
}

class _ModalSearchState extends State<ModalSearch> {
  final qController = TextEditingController();
  Future loadData()async{
    widget.callback(qController.text);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Container(
      decoration: BoxDecoration(
          color:Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).focusColor.withOpacity(0.1),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)
              ],
            ),
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: qController,
              autofocus: true,
              style:GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10)),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20),
                hintText: 'Tulis sesuatu disini ...',
                hintStyle:GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10)),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(right: 30),
                  onPressed: () {
                    if(qController.text!=''){
                      qController.text='';
                      loadData();
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    qController.text==''?AntDesign.search1:AntDesign.close,
                    color:Colors.black,
                    size: 20,
                  ),
                ),
              ),
              onFieldSubmitted: (e){
                widget.callback(qController.text);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}