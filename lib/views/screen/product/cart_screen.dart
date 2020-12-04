import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/cart/harga_bertingkat_model.dart';
import 'package:netindo_shop/model/general_id_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/checkout_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/product/second_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';

class CartScreen extends StatefulWidget {
  final String idTenant;
  CartScreen({this.idTenant});
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseConfig _helper = new DatabaseConfig();
  bool isLoading=false;
  bool checkAll = false,checkOne=false;
  int subtotal=0,diskonTotal=0,grandTotal=0,qty=0;
  String id='';
  CartModel cartModel;
  HargaBertingkatModel hargaBertingkatModel;
  List resRecomendedProduct = [];
  List resFavoriteProduct = [];
  final userRepository = UserHelper();

  Future loadCart()async{
    var res = await BaseProvider().getCart(widget.idTenant);
    setState(() {
      cartModel = CartModel.fromJson(res.toJson());
      isLoading=false;
    });
    getSubtotal();
  }
  Future checkingPrice(idTenant,id,kode,idVarian,idSubVarian,qty,harga,disc1,disc2,bool isTrue,hargaMaster, hargaVarian, hargaSubVarian)async{
    WidgetHelper().loadingDialog(context,title: 'pengecekan harga bertingkat');
    var res = await FunctionHelper().checkingPriceComplex(idTenant, id, kode, idVarian, idSubVarian, qty, harga, disc1, disc2, isTrue, hargaMaster, hargaVarian, hargaSubVarian);
    print(res);
    loadCart();
    setState(() {Navigator.pop(context);});
  }


  getSubtotal(){
    int st = 0;
    for(var i=0;i<cartModel.result.length;i++){
      st = st+int.parse(cartModel.result[i].hargaJual)*int.parse(cartModel.result[i].qty);
    }
    subtotal = st;

  }
  Future getProductRecomended()async{
    final res = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME,widget.idTenant,"is_click","true");

    // var data = await _helper.getDataLimit(ProductQuery.TABLE_NAME.TABLE_NAME,'10');
    setState(() {
      resRecomendedProduct = res;
    });
    print("RECOMENDED PRODUCT $resRecomendedProduct");
  }
  Future getFavorite()async{
    final res = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME,widget.idTenant,"is_favorite","true");
    setState(() {
      resFavoriteProduct = res;
    });
    print("FAVORITE PRODUCT $resFavoriteProduct");

  }
  Future deleted(id,param)async{
    WidgetHelper().notifDialog(context, 'Perhatian', 'Anda yakin akan menghapus data ini ?', ()async{
      Navigator.pop(context);
    }, ()async{
      Navigator.pop(context);
      WidgetHelper().loadingDialog(context);
      var url='';
      if(param=='all'){
        url+='cart/$id?all=true';
      }
      else{
        url+='cart/$id';
      }
      var res = await BaseProvider().deleteProvider(url, generalFromJson);
      if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
        Navigator.pop(context);
        WidgetHelper().showFloatingFlushbar(context,"failed","terjadi kesalahan");
      }
      else{
        if(res is General){
          General result = res;
          if(result.status=='success'){
            loadCart();
            Navigator.pop(context);
            WidgetHelper().showFloatingFlushbar(context,"success","barang berhasil dihapus");
            setState(() {});
          }
          else{
            Navigator.pop(context);
            WidgetHelper().showFloatingFlushbar(context,"failed","barang gagal dihapus");
          }
        }
      }

    });

  }

  Future<void> _handleRefresh()async {
    await FunctionHelper().handleRefresh(()=>loadCart());
  }
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    getSite();
    loadCart();
    getProductRecomended();
    getFavorite();
  }
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  @override
  Widget build(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;

    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: site?SiteConfig().darkMode:Colors.white,
        appBar: WidgetHelper().appBarWithButton(context,"Daftar Belanjaan",(){Navigator.pop(context);},<Widget>[
          Container(
            // width: 30,
              height: 30,
              margin: EdgeInsets.only(top: 12.5, bottom: 12.5, right: 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      if(cartModel.result.length>0){
                        deleted(widget.idTenant,'all');
                      }
                    },
                    iconSize: 30,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    icon: Icon(UiIcons.trash),
                    color: site?Colors.white:Theme.of(context).hintColor,
                  )
                ],
              )
          ),
        ],brightness: site?Brightness.dark:Brightness.light),
        body: RefreshWidget(
          widget: Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  isLoading?LoadingCart(total: 2):cartModel.result.length>0?Padding(
                    padding: EdgeInsets.only(left:20.0,right:20.0,top:10,bottom:10),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: cartModel.result.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        return Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [
                            buildContent(
                              context,
                              index,
                              cartModel.result[index].id,
                              cartModel.result[index].idBarang,
                              cartModel.result[index].kodeBarang,
                              cartModel.result[index].gambar,
                              "${cartModel.result[index].barang}",
                              cartModel.result[index].hargaJual,
                              cartModel.result[index].hargaCoret,
                              cartModel.result[index].idVarian,
                              cartModel.result[index].idSubvarian,
                              cartModel.result[index].varian,
                              cartModel.result[index].subvarian,
                              cartModel.result[index].qty,
                              cartModel.result[index].hargaJual,
                              cartModel.result[index].disc1,
                              cartModel.result[index].disc2,
                              cartModel.result[index].bertingkat,
                              cartModel.result[index].hargaMaster,
                              cartModel.result[index].varianHarga,
                              cartModel.result[index].subvarianHarga,
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: IconButton(
                                onPressed: (){
                                  deleted(cartModel.result[index].id,'');
                                },
                                iconSize: 30,
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                icon: Icon(UiIcons.trash_1),
                                color: Theme.of(context).hintColor,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ):EmptyDataWidget(
                    iconData: UiIcons.shopping_cart,
                    title: "Wah, keranjang belanjaan mu kosong, yuk, isi barang barang impianmu",
                    callback: (){WidgetHelper().myPush(context,WrapperScreen(currentTab: 2));},
                    isFunction: true,
                    txtFunction: "Mulai Belanja",
                  ),
                  isLoading?Container(
                    height: MediaQuery.of(context).size.height/2.3,
                    width: widthSize,
                    padding: EdgeInsets.only(left: 0,right:0,bottom:25),
                    child:LoadingSecondProduct()
                  ): resFavoriteProduct.length>0?Container(
                    height: MediaQuery.of(context).size.height/2.3,
                    width: widthSize,
                    padding: EdgeInsets.only(left: 0,right:0,bottom:25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          site?SiteConfig().darkMode:Colors.grey[100],
                          site?SiteConfig().darkMode:SiteConfig().secondColor.withOpacity(0.2),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        WidgetHelper().titleQ("Wujudkan Barang Favorite Kamu",param: '',callback: (){},icon: Icon(
                          UiIcons.heart,
                          color: site?Colors.white:SiteConfig().secondColor,
                        ),color: site?Colors.white:SiteConfig().secondColor),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: resFavoriteProduct.length,
                            itemBuilder: (_, index) {
                              return SecondProductWidget(
                                  id:resFavoriteProduct[index]['id_product'],
                                  gambar:resFavoriteProduct[index]['gambar'],
                                  title:resFavoriteProduct[index]['title'],
                                  harga:resFavoriteProduct[index]['harga'],
                                  hargaCoret:resFavoriteProduct[index]['harga_coret'],
                                  rating:resFavoriteProduct[index]['rating'],
                                  stock:resFavoriteProduct[index]['stock'],
                                  stockSales:resFavoriteProduct[index]['stock_sales'],
                                  disc1:resFavoriteProduct[index]['disc1'],
                                  disc2:resFavoriteProduct[index]['disc2'],
                                  countCart:(){}
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ):Container(),

                  isLoading?Container():resRecomendedProduct.length>0?WidgetHelper().titleQ("Kamu Sempat Lihat Barang Barang ini",param: '',callback: (){},icon: Icon(
                    UiIcons.favorites,
                    color: site?Colors.white:Theme.of(context).hintColor,
                  ),color: site?Colors.white:SiteConfig().secondColor):Container(),
                  isLoading?LoadingProductTenant(tot: 4):resRecomendedProduct.length>0?Padding(
                    padding: EdgeInsets.only(left:20.0,right:20.0,top:10.0),
                    child: new StaggeredGridView.countBuilder(
                      primary: false,
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      itemCount: resRecomendedProduct.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ProductWidget(
                          id: resRecomendedProduct[index]['id_product'],
                          gambar: resRecomendedProduct[index]['gambar'],
                          title: resRecomendedProduct[index]['title'],
                          harga: resRecomendedProduct[index]['harga'],
                          hargaCoret: resRecomendedProduct[index]['harga_coret'],
                          rating: resRecomendedProduct[index]['rating'],
                          stock: resRecomendedProduct[index]['stock'],
                          stockSales: resRecomendedProduct[index]['stock_sales'],
                          disc1: resRecomendedProduct[index]['disc1'],
                          disc2: resRecomendedProduct[index]['disc2'],
                          countCart: (){},
                        );
                      },
                      staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                      mainAxisSpacing: 15.0,
                      crossAxisSpacing: 15.0,
                    ),
                  ):Container(),
                ],
              ),
            ),
          ),
          callback:(){ _handleRefresh();},
        ),
        // bottomNavigationBar:Container(
        //   height: MediaQuery.of(context).size.height/6,
        //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        //   decoration: BoxDecoration(
        //       color: Theme.of(context).primaryColor,
        //       borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        //       boxShadow: [
        //         BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
        //       ]),
        //   child: SizedBox(
        //     width: MediaQuery.of(context).size.width - 40,
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       mainAxisSize: MainAxisSize.max,
        //       children: <Widget>[
        //         Row(
        //           children: <Widget>[
        //             Expanded(
        //               child: WidgetHelper().textQ('Subtotal', 12, SiteConfig().secondColor, FontWeight.bold),
        //             ),
        //             WidgetHelper().textQ('${FunctionHelper().formatter.format(subtotal)}', 12, SiteConfig().secondColor, FontWeight.bold)
        //           ],
        //         ),
        //
        //         SizedBox(height: 10),
        //         Stack(
        //           fit: StackFit.loose,
        //           alignment: AlignmentDirectional.centerEnd,
        //           children: <Widget>[
        //             SizedBox(
        //               width: MediaQuery.of(context).size.width - 40,
        //               child: FlatButton(
        //                 onPressed: () {
        //                   WidgetHelper().myPush(context,CheckoutScreen(idTenant: widget.idTenant));
        //                 },
        //                 padding: EdgeInsets.symmetric(vertical: 14),
        //                 color: Theme.of(context).accentColor,
        //                 shape: StadiumBorder(),
        //                 child: WidgetHelper().textQ('Checkout', 12, SiteConfig().secondDarkColor, FontWeight.bold),
        //               ),
        //             ),
        //
        //           ],
        //         ),
        //       ],
        //     ),
        //   ),
        // )
        bottomNavigationBar:Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
          color: site?SiteConfig().darkMode:Colors.grey[200],
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, -2)),],
        ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: Cro,
            children: <Widget>[

              Container(
                width: MediaQuery.of(context).size.width/2.5,
                child: FlatButton(
                    onPressed: () {},
                    color: Theme.of(context).accentColor,
                    shape: StadiumBorder(),
                    child:WidgetHelper().textQ(FunctionHelper().formatter.format(subtotal),12, Theme.of(context).primaryColor, FontWeight.bold)
                  // child:Text("abus")
                ),
              ),

              Container(
                width: MediaQuery.of(context).size.width/2.5,
                child: FlatButton(
                  onPressed: () {
                    WidgetHelper().myPush(context,CheckoutScreen(idTenant: widget.idTenant));
                  },
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child: WidgetHelper().textQ("Chekout", 14, SiteConfig().secondDarkColor, FontWeight.bold),
                ),
              )
            ],
          ),
        ),

    );
  }
  Widget buildContent(BuildContext context,index,id,idBarang,kodeBarang,image,name,price,hargaCoret,idVarian,idSubVarian,varian,subVarian,qty,harga,disc1,disc2,bool isTrue,hargaMaster,hargaVarian,hargaSubVarian) {
    int anying=int.parse(qty);
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        // Navigator.of(context).pushNamed('/Product', arguments: RouteArgument(id: widget.product.id, argumentsList: [widget.product, widget.heroTag]));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: site?Colors.white:Theme.of(context).focusColor.withOpacity(0.4),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: id,
              child: Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            WidgetHelper().textQ("$name", 12, SiteConfig().darkMode, FontWeight.bold),
                            int.parse(disc1)==0?Container():SizedBox(width: 5),
                            int.parse(disc1)==0?Container():WidgetHelper().textQ("( diskon $disc1 + $disc2 )", 10,Colors.grey,FontWeight.bold),
                          ],
                        ),
                        Row(
                          children: [
                            WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(hargaCoret))}", 10,Colors.green,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                            SizedBox(width: 5),
                            WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(price))}", 12,Colors.green,FontWeight.bold),
                          ],
                        ),
                        varian==null?Container():WidgetHelper().textQ("warna $varian,ukuran $subVarian", 12, Colors.grey, FontWeight.normal),
                        // int.parse(disc1)==0?Container():WidgetHelper().textQ("${int.parse(cartModel.result[index].disc1)>0?"diskon 1 = ${cartModel.result[index].disc1} %\ndiskon 2 = ${cartModel.result[index].disc2} %":0}", 12,Colors.grey, FontWeight.bold),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        onPressed: (){
                          setState(() {
                            anying+=1;
                            // cartModel.result[index].qty = anying.toString();
                            getSubtotal();
                          });
                          checkingPrice(
                              widget.idTenant,
                              idBarang,
                              kodeBarang,
                              idVarian,
                              idSubVarian,
                              anying.toString(),
                              harga,
                              disc1,
                              disc2,
                              isTrue,
                              hargaMaster,
                              hargaVarian,
                              hargaSubVarian
                          );
                        },
                        iconSize: 30,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        icon: Icon(Icons.add_circle_outline),
                        color: Theme.of(context).hintColor,
                      ),
                      WidgetHelper().textQ('$qty', 12, SiteConfig().secondColor, FontWeight.bold),
                      IconButton(
                        onPressed: () async {
                          if(int.parse(cartModel.result[index].qty)>1){
                            anying-=1;
                            cartModel.result[index].qty = anying.toString();
                            getSubtotal();
                            checkingPrice(
                                widget.idTenant,
                                idBarang,
                                kodeBarang,
                                idVarian,
                                idSubVarian,
                                anying.toString(),
                                harga,
                                disc1,
                                disc2,
                                isTrue,
                                hargaMaster,
                                hargaVarian,
                                hargaSubVarian
                            );
                          }
                          setState(() {});
                        },
                        iconSize: 30,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        icon: Icon(Icons.remove_circle_outline),
                        color: Theme.of(context).hintColor,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
