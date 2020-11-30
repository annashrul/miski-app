import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/model/tenant/slider_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/product/second_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:netindo_shop/views/widget/slider_widget.dart';

class PrivateHomeScreen extends StatefulWidget {
  final String id;
  final String nama;
  PrivateHomeScreen({this.id,this.nama});
  @override
  _PrivateHomeScreenState createState() => _PrivateHomeScreenState();
}

class _PrivateHomeScreenState extends State<PrivateHomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();
  int perpage=10;
  final userRepository = UserHelper();
  ListProductTenantModel productTenantModel;
  SliderModel sliderModel;
  int totalCart=0;
  ScrollController controller;
  bool isLoading=false,isLoadingSlider=false,isLoadmore=false,isTimeout=false,isShowChild=false;
  int total=0;
  AnimationController colorAnimationController;
  Animation appBarColorTween, iconColorTween, fieldColorTween;
  Brightness brightnessCutom = Brightness.light;
  GlobalKey key = GlobalKey();
  GlobalKey key1 = GlobalKey();
  ScrollController scrollControlllerSingle;
  int current = 0;
  bool secondAppBar = false;
  int selectedkategori = 0;
  double containerHeight = 80;
  List returnGroup = [];
  String qGroup='';
  List resFavoriteProduct = [];
  final DatabaseConfig _helper = new DatabaseConfig();
  List returnProductLocal = [];
  Future loadGroup()async{
    var group = await _helper.getData(GroupQuery.TABLE_NAME);
    List groups = [];
    group.forEach((element) {
      groups.add({
        "id": element['id_groups'],
        "title": element['title'],
        "id_kategori":element['id_category'],
        "kategori":element['category'],
        "status": element['status'],
        "image": element['image'],
        "isSelected":false
      });
    });
    setState(() {
      returnGroup=groups;
    });
  }
  Future getProduct()async{
    String col = '';
    if(qGroup!=''){
      col = 'kelompok';
    }
    final resProductLocal = await _helper.getDataByTenantLimit(ProductQuery.TABLE_NAME,widget.id,"$perpage");
    final resTotalProductLocal = await _helper.getDataByTenant(ProductQuery.TABLE_NAME,widget.id);
    if(resProductLocal.length>0){
      setState(() {
        returnProductLocal = resProductLocal;
        total=resTotalProductLocal.length;
        isLoading=false;
        isLoadmore=false;
      });
      return;
    }
    else{
      var resProduct = await FunctionHelper().baseProduct('perpage=$perpage&tenant=${widget.id}');
      if(resProduct.length>0){
        setState(() {
          productTenantModel = resProduct[0]['data'];
          total=resProduct[0]['total'];
          isLoading=false;
          isLoadmore=false;
        });
        await FunctionHelper().insertProduct(widget.id);
      }
      else{
        setState(() {
          isLoading=false;
          isTimeout=true;
        });
      }
    }

  }
  Future getSlider()async{
    var resSlider = await BaseProvider().getProvider('slider?page=1', sliderModelFromJson);
    if(resSlider is SliderModel){
      setState(() {
        sliderModel = SliderModel.fromJson(resSlider.toJson());
        isLoadingSlider=false;
      });
    }
  }
  Future getFavorite()async{
    final res = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME,widget.id,"is_favorite","true");
    res.forEach((element) {
      resFavoriteProduct.add({
        "id":element['id_product'],
        "image":element["gambar"],
        "disc1":element["disc1"],
        "disc2":element["disc2"],
        "stock":element["stock"],
        "name":element["title"],
        "hargaCoret":element["harga_coret"],
        "harga":element["harga"],
        "rating":element["rating"],
      });
    });
    setState(() {

    });
    print("FAVORITE PRODUCT $resFavoriteProduct");

  }
  Future countCart() async{
    final res = await BaseProvider().countCart(widget.id);
    setState(() {
      totalCart = res;
    });
    await getFavorite();
  }
  Future loadData()async{
    setState(() {
      isTimeout=false;
      isLoading=true;
      isLoadingSlider=true;
    });
    await getProduct();
    await getFavorite();
    await getSlider();
    await countCart();
    await FunctionHelper().setSession("id_tenant", widget.id);
  }
  Future<void> _handleRefresh()async {
    await _helper.deleteProductOtherByTenant(ProductQuery.TABLE_NAME,widget.id,"false","false");
    print('hapus produk lokal sukses');
    await FunctionHelper().getFilterLocal(widget.id);
    await FunctionHelper().handleRefresh(()=>loadData());
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
  bool scrollListener(ScrollNotification scrollInfo) {
    RenderBox box = key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    double y = position.dy;
    if (scrollInfo.metrics.axis == Axis.vertical) {
      colorAnimationController.animateTo(scrollInfo.metrics.pixels / 100);
      if (y > 83) {
        setState(() {
          secondAppBar = false;
        });
        if (scrollInfo.metrics.pixels > 100) {
          setState(() {
            brightnessCutom = Brightness.dark;
          });
        } else {
          setState(() {
            brightnessCutom = Brightness.light;
          });
        }
      } else if (y < 83) {
        setState(() {
          secondAppBar = true;
        });

        if (y > 50) {
          setState(() {
            containerHeight = 80;
          });
        } else if (y < 20) {
          setState(() {
            containerHeight = 60;
          });
        }
      }

      return true;
    }
    return null;
  }
  static bool site=false;
  Color appBar = site?SiteConfig().darkMode:Colors.white;
  Color titleBar = site?Colors.white:Colors.transparent;
  Color iconBar = site?Colors.white:SiteConfig().secondColor;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      appBar = res?SiteConfig().darkMode:Colors.white;
      titleBar = res?Colors.white:Colors.transparent;
      iconBar = res?Colors.white:SiteConfig().secondColor;
      site = res;
    });
  }
  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    loadGroup();
    loadData();
    getSite();
    controller = new ScrollController()..addListener(_scrollListener);
    colorAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 0));
    appBarColorTween = ColorTween(begin: Colors.transparent, end: appBar).animate(colorAnimationController);
    fieldColorTween = ColorTween(begin: Colors.transparent, end: Colors.transparent).animate(colorAnimationController);
    iconColorTween = ColorTween(begin: Colors.white, end: iconBar).animate(colorAnimationController);

    // countCart();
  }

  Widget child;
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    // print(list);
    return buildItem(context);
  }
  Widget buildItem(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: brightnessCutom),
      child: Scaffold(
        key: _scaffoldKey,
        body: NotificationListener<ScrollNotification>(
          onNotification: scrollListener,
          child: RefreshWidget(
            widget: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Color(0xFF05AA10),
                          ),
                          child: SliderWidget(),
                        ),
                        // isLoading?Container(
                        //     height: MediaQuery.of(context).size.height/3.0,
                        //     width: widthSize,
                        //     padding: EdgeInsets.only(top:10),
                        //     child:LoadingSecondProduct()
                        // ):resFavoriteProduct.length>0?Container(
                        //   height: MediaQuery.of(context).size.height/2.3,
                        //   width: widthSize,
                        //   padding: EdgeInsets.only(left: 0,right:0,bottom:0),
                        //   child: Column(
                        //     children: [
                        //       WidgetHelper().titleQ("Wujudkan Barang Favorite Kamu",param: '',callback: (){},icon: Icon(
                        //         UiIcons.heart,
                        //         color: site?Colors.white:Theme.of(context).hintColor,
                        //       ),color: site?Colors.white:SiteConfig().secondColor),
                        //       Expanded(
                        //         child:SecondProductsWidget(data: resFavoriteProduct),
                        //       )
                        //     ],
                        //   ),
                        // ):Container(),
                        isLoading?Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: LoadingProductTenant(tot: 10),
                        ):returnProductLocal.length>0?Container(
                            key: key,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            child:new StaggeredGridView.countBuilder(
                              primary: false,
                              shrinkWrap: true,
                              crossAxisCount: 4,
                              itemCount: returnProductLocal.length,
                              itemBuilder: (BuildContext context, int index) {
                                var valProductServer =  returnProductLocal[index];
                                return ProductWidget(
                                  id: valProductServer['id_product'],
                                  gambar: valProductServer['gambar'],
                                  title: valProductServer['title'],
                                  harga: valProductServer['harga'],
                                  hargaCoret: valProductServer['harga_coret'],
                                  rating: valProductServer['rating'].toString(),
                                  stock: valProductServer['stock'].toString(),
                                  stockSales: valProductServer['stock_sales'].toString(),
                                  disc1: valProductServer['disc1'].toString(),
                                  disc2: valProductServer['disc2'].toString(),
                                  countCart: countCart,
                                );
                              },
                              staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                              mainAxisSpacing: 15.0,
                              crossAxisSpacing: 15.0,
                            )
                        ):Container(
                            padding: const EdgeInsets.only(left: 20,right:20,top:0,bottom:0),
                            child:!isLoading?LoadingProductTenant(tot: 10):productTenantModel.result.data.length>0?new StaggeredGridView.countBuilder(
                              primary: false,
                              shrinkWrap: true,
                              crossAxisCount: 4,
                              itemCount: productTenantModel.result.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ProductWidget(
                                  id: productTenantModel.result.data[index].id,
                                  gambar: productTenantModel.result.data[index].gambar,
                                  title: productTenantModel.result.data[index].title,
                                  harga: productTenantModel.result.data[index].harga,
                                  hargaCoret: productTenantModel.result.data[index].hargaCoret,
                                  rating: productTenantModel.result.data[index].rating.toString(),
                                  stock: productTenantModel.result.data[index].stock.toString(),
                                  stockSales: productTenantModel.result.data[index].stockSales.toString(),
                                  disc1: productTenantModel.result.data[index].disc1.toString(),
                                  disc2: productTenantModel.result.data[index].disc2.toString(),
                                  countCart: countCart,
                                );
                              },
                              staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                              mainAxisSpacing: 15.0,
                              crossAxisSpacing: 15.0,
                            ):EmptyTenant()
                        ),
                        isLoadmore?Container(
                          padding: const EdgeInsets.only(left: 20,right:20,top:0,bottom:0),
                          child: LoadingProductTenant(tot: 4),
                        ):Container(),

                      ],
                    ),
                  ),
                ),
                createAppBarAnimation(),

              ],
            ),
            callback: (){_handleRefresh();},
          ),
        ),
        backgroundColor: site?SiteConfig().darkMode:Colors.white,
      ),
    );
  }
  // NOTE: AppBar Animation
  Widget createAppBarAnimation() => AnimatedBuilder(
    animation: colorAnimationController,
    builder: (context, child) => Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: appBarColorTween.value,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 20, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.58,
                    height: 40,
                    decoration: BoxDecoration(
                      color: fieldColorTween.value,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Row(
                          children: [
                            new IconButton(
                              icon: new Icon(UiIcons.home, color:iconColorTween.value),
                              onPressed:null,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            WidgetHelper().textQ("${widget.nama}", 16,iconColorTween.value,FontWeight.bold)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        InkWell(
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                  height: 24,
                                  width: 24,
                                  child:Icon(UiIcons.shopping_cart, size: 24, color: iconColorTween.value)
                              ),
                              Positioned(
                                top: 0,
                                right: 0,

                                child: Container(
                                  child:WidgetHelper().textQ("$totalCart", 10, Theme.of(context).primaryColor, FontWeight.bold),
                                  padding: EdgeInsets.only(left:4.0),
                                  decoration: BoxDecoration(color:SiteConfig().mainColor, borderRadius: BorderRadius.all(Radius.circular(10))),
                                  constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
                                ),
                              ),
                            ],
                          ),
                          onTap: (){
                            if(totalCart>0){
                              WidgetHelper().myPushAndLoad(context, CartScreen(idTenant: widget.id), countCart);
                            }
                          },
                        ),
                        SizedBox(width: 10.0),
                        Container(
                          height: 24,
                          width: 24,
                          child: FlatButton(
                              padding: EdgeInsets.only(right:10),
                              onPressed: () => _scaffoldKey.currentState.openEndDrawer(),
                              child: Icon(UiIcons.filter, size: 24, color: iconColorTween.value)
                              // child: UiIcons.filter
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
class KategoriCard extends StatelessWidget {
  final String namaKategori;

  final List<Color> color;
  final Function onTap;
  final bool isSelected;
  final double width;

  KategoriCard(
      {this.namaKategori,
        this.color,
        this.onTap,
        this.isSelected = false,
        this.width = 70});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        width: width,
        height: double.infinity,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: color,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 2,
              width: 20,
              margin: EdgeInsets.only(bottom: 5),
              color: (isSelected == true) ? Colors.white : Colors.transparent,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Text(
                  namaKategori,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
