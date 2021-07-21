import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
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
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/product/second_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';

class CartScreen extends StatefulWidget {
  final String idTenant;
  CartScreen({this.idTenant});
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseConfig _helper = new DatabaseConfig();
  bool isLoading=false, isError=false;
  bool checkAll = false,checkOne=false;
  int subtotal=0,diskonTotal=0,grandTotal=0,qty=0;
  String id='';
  CartModel cartModel;
  HargaBertingkatModel hargaBertingkatModel;
  List resRecomendedProduct = [];
  List resFavoriteProduct = [];
  final userRepository = UserHelper();

  Future loadCart()async{
    // var res = await BaseProvider().getCart(widget.idTenant);
    var res = await BaseProvider().getProvider("cart/${widget.idTenant}",cartModelFromJson);
    if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
      setState(() {
        isLoading=false;
        isError=true;
      });
    }
    else{
      if(res is CartModel){
        CartModel result = res;
        setState(() {
          cartModel = CartModel.fromJson(result.toJson());
          isLoading=false;
        });
        getSubtotal();
      }
    }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    loadCart();
    getProductRecomended();
    getFavorite();
  }
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  @override
  Widget build(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;
    ScreenScaler scaler = ScreenScaler()..init(context);

    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: WidgetHelper().appBarWithButton(context,"Daftar Belanjaan",(){Navigator.pop(context);},<Widget>[
          Container(
            margin: scaler.getMargin(0,2),
            child: isLoading?Text(''):cartModel.result.length>0?WidgetHelper().iconAppbar(context,(){
              if(cartModel.result.length>0){
                deleted(widget.idTenant,'all');
              }
            }, FontAwesome.trash):Text(''),
          )
        ],brightness:Brightness.light),
        body: isError?TimeoutWidget(callback: (){
          setState(() {
            isLoading=true;
            isError=false;
          });
          loadCart();
        }):RefreshWidget(
          widget: Container(
            child: SingleChildScrollView(
              // padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  isLoading?LoadingCart(total: 2):cartModel.result.length>0?Padding(
                    padding: scaler.getPadding(0,2),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: cartModel.result.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        return Stack(
                          // alignment: AlignmentDirectional.bottomEnd,
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

                              child: Container(
                                child: IconButton(
                                  onPressed: (){
                                    deleted(cartModel.result[index].id,'');
                                  },
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(FontAwesome.trash,color: SiteConfig().mainColor),
                                ),
                                color: Theme.of(context).focusColor.withOpacity(0.2),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ):EmptyDataWidget(
                    iconData: AntDesign.shoppingcart,
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
                    height: scaler.getHeight(35),
                    width: widthSize,
                    padding: EdgeInsets.only(left: 0,right:0,bottom:0),
                    child: Column(
                      children: [
                        Padding(
                          padding: scaler.getPadding(1, 2),
                          child: WidgetHelper().titleQ(context,"Wujudkan Barang Favorite Kamu",param: '',callback: (){},icon:AntDesign.hearto,color: SiteConfig().secondColor),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.all(0.0),
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
                  isLoading?Container():resRecomendedProduct.length>0?Padding(
                    padding: scaler.getPadding(1, 2),
                    child: WidgetHelper().titleQ(context,"Kamu Sempat Lihat Barang Barang ini",param: '',callback: (){},icon: FontAwesome.eye,color: SiteConfig().secondColor),
                  ):Container(),
                  isLoading?Padding(
                    padding: EdgeInsets.only(left:20.0,right:20.0,top:10.0),
                    child: LoadingProductTenant(tot: 4),
                  ):resRecomendedProduct.length>0?Padding(
                    padding: scaler.getPadding(0, 2),
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
                      mainAxisSpacing: scaler.getWidth(1),
                      crossAxisSpacing:scaler.getWidth(1),
                    ),
                  ):Container(),
                ],
              ),
            ),
          ),
          callback:(){ _handleRefresh();},
        ),
        bottomNavigationBar:isLoading?Text(''):isError?Text(''):cartModel.result.length>0?Container(
          // color: Colors.transparent,
          // height: scaler.getHeight(4),
          // padding:scaler.getPadding(0,2),
          // child: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: <Widget>[
          //     Column(
          //       mainAxisSize: MainAxisSize.min,
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: <Widget>[
          //         WidgetHelper().textQ("Total Tagihan",scaler.getTextSize(10),SiteConfig().secondColor, FontWeight.bold),
          //         WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(subtotal)+" .-",scaler.getTextSize(10),SiteConfig().moneyColor, FontWeight.bold),
          //       ],
          //     ),
          //     WidgetHelper().buttonQ(context,(){
          //       WidgetHelper().myPush(context,CheckoutScreen(idTenant: widget.idTenant));
          //     },"Bayar")
          //
          //   ],
          // ),
          padding:scaler.getPadding(0,0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: scaler.getMarginLTRB(2,0,0,0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    WidgetHelper().textQ("Total Tagihan",scaler.getTextSize(10),SiteConfig().secondColor, FontWeight.bold),
                    WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(subtotal)+" .-",scaler.getTextSize(10),SiteConfig().moneyColor, FontWeight.bold),
                    // WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(subtotal)+" .-",scaler.getTextSize(10),SiteConfig().moneyColor, FontWeight.bold),
                  ],
                ),
              ),
              FlatButton(
                  padding:scaler.getPadding(1,0),
                  color: SiteConfig().secondColor,
                  onPressed: (){WidgetHelper().myPush(context,CheckoutScreen(idTenant: widget.idTenant));},
                  child: WidgetHelper().textQ("Bayar", scaler.getTextSize(10), Colors.white,FontWeight.bold)
              )
            ],
          ),
        ):Text(''),

    );
  }
  Widget buildContent(BuildContext context,index,id,idBarang,kodeBarang,image,name,price,hargaCoret,idVarian,idSubVarian,varian,subVarian,qty,harga,disc1,disc2,bool isTrue,hargaMaster,hargaVarian,hargaSubVarian) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    int anying=int.parse(qty);
    return WidgetHelper().myPress(
            ()async{
              await FunctionHelper().storeClickProduct(idBarang);
              WidgetHelper().myPushAndLoad(context, DetailProducrScreen(id:idBarang),(){
                loadCart();
                // getFavorite();
                getProductRecomended();
              });
        },
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).focusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: scaler.getWidth(20),
                child: WidgetHelper().baseImage(image),
                // child: CachedNetworkImage(
                //   imageUrl: image,
                //   width: double.infinity ,
                //   fit:BoxFit.contain,
                //   placeholder: (context, url) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
                //   errorWidget: (context, url, error) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
                // ),
              ),
              SizedBox(width: scaler.getWidth(1)),

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
                              Expanded(child: WidgetHelper().textQ("$name", scaler.getTextSize(9),SiteConfig().darkMode, FontWeight.normal)),
                              int.parse(disc1)==0?Container():SizedBox(width: 5),
                              int.parse(disc1)==0?Container():WidgetHelper().textQ("( diskon $disc1 + $disc2 )", scaler.getTextSize(9),Colors.grey,FontWeight.bold),
                            ],
                          ),
                          SizedBox(height: scaler.getHeight(0.5)),
                          Row(
                            children: [
                              WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(hargaCoret))}", scaler.getTextSize(9),SiteConfig().moneyColor,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                              SizedBox(width: scaler.getWidth(1)),
                              Expanded(child: WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(price))}", scaler.getTextSize(9),SiteConfig().moneyColor,FontWeight.bold),)
                            ],
                          ),
                          varian==null?Container():WidgetHelper().textQ("warna $varian,ukuran $subVarian", scaler.getTextSize(9),SiteConfig().darkMode, FontWeight.normal),
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
                        WidgetHelper().textQ('$qty', scaler.getTextSize(9), SiteConfig().secondColor, FontWeight.bold),
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
        color:Colors.black38
    );
  }

}
