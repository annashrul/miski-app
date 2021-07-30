import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:geolocator/geolocator.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/skeleton_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/promo/global_promo_model.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart' as Prefix;
import 'package:netindo_shop/model/tenant/list_brand_product_model.dart';
import 'package:netindo_shop/model/tenant/list_category_product_model.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/provider/product_provider.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/screen/product/product_detail_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/product/second_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:async/async.dart' show AsyncMemoizer;

class HomeScreen extends StatefulWidget {
  final String id;
  final String nama;
  HomeScreen({Key key,this.id,this.nama}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin  {
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
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getProduct();
    getGroup();
    getPromo();
    getCategory();
    countCart();
    controller = new ScrollController()..addListener(_scrollListener);
  }
  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: WidgetHelper().textQ("${widget.nama.toUpperCase()}",  scaler.getTextSize(10),SiteConfig().secondColor,FontWeight.bold),
        actions: <Widget>[
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
          IconButton(
            icon: Icon(
                AntDesign.filter,color: LightColor.lightblack
            ),
            onPressed: () {
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
        ],
      ),
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
        // backgroundColor:SiteConfig().mainColor,
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
                          // alignment: Alignment.,
                          height: scaler.getHeight(8.5),
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: listCategoryProductModel.result.data.length,
                            itemBuilder: (context, index) => Container(
                                margin: scaler.getMarginLTRB(1, 1, 0, 0),
                                width: scaler.getWidth(13),
                                child: InkWell(
                                  onTap: (){},
                                  child:Stack(
                                    alignment: Alignment.topCenter,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5.0),
                                        child: Container(
                                          height: 50.0,
                                          color: Colors.grey[200],
                                        ),
                                      ),
                                      Positioned(
                                        top: 20.0,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            WidgetHelper().baseImage(
                                              listCategoryProductModel.result.data[index].image,
                                              height: 40.0,
                                              width: 40.0,
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
                color: Colors.white,
                height: scaler.getHeight(5),
                child: isLoadingGroup?LoadingOption():ListView.builder(
                  padding: EdgeInsets.only(left:0.0,top:0,bottom:0),
                  itemCount: returnGroup.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    double _marginLeft = 0;
                    (index == 0) ? _marginLeft = 10 : _marginLeft = 0;
                    var val = returnGroup[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      margin: EdgeInsets.only(left:_marginLeft,right: 5, top: 15, bottom: 15),
                      child: WidgetHelper().myRipple(
                        callback: (){
                          setState(() {
                            group=val["id"];
                            isLoading=true;
                          });
                          getProduct();
                        },
                        child: AnimatedContainer(
                          height: scaler.getHeight(5) ,
                          duration: Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.only(left: 10,right:10),
                          decoration: BoxDecoration(
                            border: Border.all(width:group==val["id"]?2.0:1.0,color: group==val["id"]?LightColor.mainColor:LightColor.lightblack),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: <Widget>[
                              AnimatedSize(
                                duration: Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                                vsync: this,
                                child: WidgetHelper().textQ("${val["title"]}".toLowerCase(),scaler.getTextSize(9), group==val["id"]?LightColor.mainColor:LightColor.lightblack,FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      ),
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
  bool mode;
  String idTenant;
  Function(String q) callback;
  ModalSearch({this.mode,this.idTenant,this.callback});
  @override
  _ModalSearchState createState() => _ModalSearchState();
}

class _ModalSearchState extends State<ModalSearch> {
  DatabaseConfig db= DatabaseConfig();
  final qController = TextEditingController();
  List resProduct=[];
  List resSearch=[];
  List resClick=[];
  Future loadData()async{
    widget.callback(qController.text);
    // if(qController.text!=''){
    //   var res = await db.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%${qController.text}%' or deskripsi LIKE '%${qController.text}%'",[widget.idTenant]);
    //   // var res = await db.readData(ProductQuery.TABLE_NAME, widget.idTenant,colWhere: ['title'],valWhere: ['${qController.text}']);
    //   setState(() {
    //     resProduct=res;
    //   });
    // }else{
    //   setState(() {
    //     resProduct=[];
    //   });
    //   loadSearch();
    // }
  }
  Future loadSearch()async{
    var res = await db.getRow("SELECT * FROM ${SearchingQuery.TABLE_NAME} ORDER BY title DESC");
    // var res = await db.getData(SearchingQuery.TABLE_NAME,orderBy: 'title');
    setState(() {
      resSearch = res;
    });
  }
  Future loadClick()async{
    var res = await db.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and is_click=?",["${widget.idTenant}","true"]);
    setState(() {
      resClick=res;
    });
  }
  String idProduct='';
  Future store()async{
    if(qController.text!=''){
      final check = await db.getWhere(SearchingQuery.TABLE_NAME, "id_product","$idProduct", '');
      if(check.length>0){
        await db.delete(SearchingQuery.TABLE_NAME,"id_product","$idProduct");
        await db.insert(SearchingQuery.TABLE_NAME,{"id_product":"${idProduct.toString()}","title":"${qController.text.toString()}"});
      }
      else{
        await db.insert(SearchingQuery.TABLE_NAME,{"id_product":"${idProduct.toString()}","title":"${qController.text.toString()}"});
      }
    }

    loadSearch();
    Navigator.of(context).pop();
    // WidgetHelper().myPush(context, DetailProducrScreen(id: idProduct));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadClick();
    loadSearch();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height/2.0,
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
              // color:widget.mode?Theme.of(context).focusColor.withOpacity(0.15):SiteConfig().secondColor,
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)
              ],
            ),
            child: TextFormField(
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.multiline,
              cursorColor: Theme.of(context).focusColor.withOpacity(0.8),
              controller: qController,
              autofocus: true,
              style:TextStyle(color: Colors.black,fontFamily: SiteConfig().fontStyle),
              decoration: InputDecoration(

                contentPadding: EdgeInsets.all(20),
                hintText: 'Tulis sesuatu disini ...',
                hintStyle: TextStyle(color: Colors.black,fontFamily: SiteConfig().fontStyle),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(right: 30),
                  onPressed: () {
                    // replyTicket();
                    // _scrollToBottom();
                    if(qController.text!=''){
                      setState(() {
                        qController.text='';
                      });
                      loadData();
                    }
                  },
                  icon: Icon(
                    qController.text==''?AntDesign.search1:AntDesign.close,
                    color:Colors.black,
                    size: 20,
                  ),
                ),
              ),
              onChanged: (e)async{
                loadData();
              },
              onFieldSubmitted: (e){
                widget.callback(qController.text);
                store();
              },
            ),
          ),
          // resProduct.length>0?Expanded(
          //     flex: 1,
          //     child: Scrollbar(child: ListView.separated(
          //         itemBuilder: (context,index){
          //           return ListTile(
          //             onTap: ()async{
          //               setState(() {
          //                 qController.text = resProduct[index]['title'];
          //                 idProduct = resProduct[index]['id_product'];
          //               });
          //               loadData();
          //               widget.callback(resProduct[index]['title']);
          //               store();
          //
          //             },
          //             title: WidgetHelper().textQ("${resProduct[index]['title']}",10,Colors.black87,FontWeight.normal),
          //           );
          //         },
          //         separatorBuilder:(context,index){
          //           return  Divider(height: 1);
          //         },
          //         itemCount: resProduct.length
          //     ))
          // ):
          // (resSearch.length>0?Expanded(
          //     flex: 1,
          //     child: ListView.separated(
          //         itemBuilder: (context,index){
          //           return ListTile(
          //             onTap: (){
          //               setState(() {
          //                 qController.text = resSearch[index]['title'];
          //                 idProduct = resSearch[index]['id_product'];
          //               });
          //               loadData();
          //               widget.callback(resSearch[index]['title']);
          //               store();
          //             },
          //             trailing: IconButton(
          //                 icon: Icon(AntDesign.close,color:Colors.grey),
          //                 onPressed:()async{
          //                   await db.delete(SearchingQuery.TABLE_NAME,"id",resSearch[index]['id']);
          //                   loadSearch();
          //                 }
          //             ),
          //             title: WidgetHelper().textQ("${resSearch[index]['title']}",10,Colors.black87,FontWeight.normal),
          //           );
          //         },
          //         separatorBuilder:(context,index){
          //           return  Divider(height: 1);
          //         },
          //         itemCount: resSearch.length
          //     )
          // ):Expanded(
          //   child: ListView(
          //     children: [
          //       EmptyTenant()
          //     ],
          //   ),
          // )),
          // resClick.length>0?WidgetHelper().titleQ("Barang yang pernah dilihat",param: ""):Container(),
          // Expanded(
          //     flex: 13,
          //     child: ListView.separated(
          //         itemBuilder: (context,index){
          //           var val = resClick[index];
          //           return Padding(
          //             padding: EdgeInsets.only(bottom: 10.0),
          //             child: Stack(
          //               alignment: AlignmentDirectional.topEnd,
          //               children: [
          //                 InkWell(
          //                   onTap: (){
          //                     WidgetHelper().myPush(context,DetailProducrScreen(id: val['id_product']));
          //                   },
          //                   child: Container(
          //                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          //                     decoration: BoxDecoration(
          //                       color: Theme.of(context).focusColor.withOpacity(0.15),
          //                       boxShadow: [
          //                         BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          //                       ],
          //                       // borderRadius: BorderRadius.circular(10.0)
          //                     ),
          //                     child: Row(
          //                       mainAxisAlignment: MainAxisAlignment.start,
          //                       children: <Widget>[
          //                         Hero(
          //                           tag: "${val['id']}${val['id_product']}${val['id_tenant']}",
          //                           child: Container(
          //                             height: 90,
          //                             width: 90,
          //                             decoration: BoxDecoration(
          //                               borderRadius: BorderRadius.all(Radius.circular(5)),
          //                               image: DecorationImage(image: NetworkImage(val['gambar']), fit: BoxFit.cover),
          //                             ),
          //                           ),
          //                         ),
          //                         SizedBox(width: 15),
          //                         Flexible(
          //                           child: Row(
          //                             crossAxisAlignment: CrossAxisAlignment.center,
          //                             children: <Widget>[
          //                               Expanded(
          //                                 child: Column(
          //                                   crossAxisAlignment: CrossAxisAlignment.start,
          //                                   children: <Widget>[
          //                                     Stack(
          //                                       alignment: AlignmentDirectional.topEnd,
          //                                       children: [
          //                                         Container(
          //                                           padding: EdgeInsets.only(right:10.0),
          //                                           child: WidgetHelper().textQ("${val['tenant']}", 12, SiteConfig().mainColor, FontWeight.normal),
          //                                         ),
          //                                         Positioned(
          //                                           child:Icon(UiIcons.home,color:SiteConfig().mainColor,size: 8),
          //                                         )
          //                                       ],
          //                                     ),
          //                                     Row(
          //                                       children: [
          //                                         Expanded(child: WidgetHelper().textQ("${val['title']}", 12, widget.mode?Colors.white:SiteConfig().darkMode, FontWeight.normal)),
          //                                         int.parse(val['disc1'])==0?Container():SizedBox(width: 5),
          //                                         int.parse(val['disc1'])==0?Container():WidgetHelper().textQ("( diskon ${val['disc1']} + ${val['disc2']} )", 10,Colors.grey,FontWeight.normal),
          //                                       ],
          //                                     ),
          //                                     Row(
          //                                       children: [
          //                                         WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga_coret']))}", 10,Colors.green,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
          //                                         SizedBox(width: 5),
          //                                         WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga']))}", 12,Colors.green,FontWeight.normal),
          //                                       ],
          //                                     ),
          //                                   ],
          //                                 ),
          //                               ),
          //
          //                             ],
          //                           ),
          //                         )
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           );
          //         },
          //         separatorBuilder: (context,index){return Divider(height: 1);},
          //         itemCount: resClick.length
          //     )
          // )

        ],
      ),
    );
  }
}