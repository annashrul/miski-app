import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/cart/harga_bertingkat_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/checkout_screen.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/screen/product/product_detail_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
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
    setState((){resRecomendedProduct = res;});
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
    ScreenScaler scaler = ScreenScaler()..init(context);
    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        appBar: WidgetHelper().appBarWithButton(context,"Daftar Belanjaan",(){Navigator.pop(context);},<Widget>[
          !isLoading&&cartModel.result.length>0?Container(
            margin:scaler.getMarginLTRB(0, 0, 2,0),
            child: WidgetHelper().myRipple(
              callback: (){
                if(cartModel.result.length>0){
                  deleted(widget.idTenant,'all');
                }
              },
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                      child: WidgetHelper().textQ("Hapus semua",scaler.getTextSize(9),LightColor.mainColor,FontWeight.bold)
                  ),
                ],
              )
            ),
          ):SizedBox()
        ]),
        body: isError?TimeoutWidget(callback: (){
          setState(() {
            isLoading=true;
            isError=false;
          });
          loadCart();
        }):RefreshWidget(
          widget: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  isLoading?LoadingCart(total: 2):cartModel.result.length>0?Padding(
                    padding: scaler.getPadding(0.5,2),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: cartModel.result.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: scaler.getHeight(0.5));
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

                          ],
                        );
                      },
                    ),
                  ):EmptyDataWidget(
                    iconData: AntDesign.shoppingcart,
                    title: "Wah, keranjang belanjaan mu kosong, yuk, isi barang barang impianmu",
                    callback: (){WidgetHelper().myPush(context,WrapperScreen(currentTab: StringConfig.defaultTab));},
                    isFunction: true,
                    txtFunction: "Mulai Belanja",
                  ),
                ],
              ),
            ),
          ),
          callback:(){ _handleRefresh();},
        ),
        bottomNavigationBar:isLoading?Text(''):isError?Text(''):cartModel.result.length>0?Container(
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
                    WidgetHelper().textQ("Total Tagihan",scaler.getTextSize(10),LightColor.black, FontWeight.bold),
                    WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(subtotal)+" .-",scaler.getTextSize(10),LightColor.orange, FontWeight.bold),
                  ],
                ),
              ),
              FlatButton(
                  padding:scaler.getPadding(1,0),
                  color: SiteConfig().secondColor,
                  onPressed: (){
                    WidgetHelper().myPush(context,CheckoutScreen(idTenant: widget.idTenant));
                  },
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
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200],
            spreadRadius: 0,
            blurRadius: 5,
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: WidgetHelper().myRipple(
        callback: (){
          WidgetHelper().myPushAndLoad(context, ProductDetailPage(id: idBarang), ()=>loadCart());
        },
        child: Container(
          padding: scaler.getPadding(0.5,1),
          child: Row(
            children: <Widget>[
              WidgetHelper().baseImage(image,height: scaler.getHeight(5)),
              SizedBox(width: scaler.getWidth(1)),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetHelper().textQ("$name", scaler.getTextSize(9),LightColor.lightblack, FontWeight.normal),
                        WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(price))}", scaler.getTextSize(10),LightColor.orange,FontWeight.bold),
                        int.parse(hargaCoret)<1?SizedBox():WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(hargaCoret))}", scaler.getTextSize(9),SiteConfig().accentDarkColor,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            WidgetHelper().myRipple(
                              callback:()=>deleted(cartModel.result[index].id,''),
                              child: Icon(Ionicons.ios_close_circle_outline,color: LightColor.lightblack,size: scaler.getTextSize(15)),
                            ),
                            SizedBox(width: scaler.getWidth(1)),
                            WidgetHelper().myRipple(
                                callback: (){
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
                                child: Icon(Ionicons.ios_remove_circle_outline,color: LightColor.lightblack,size: scaler.getTextSize(15))
                            ),
                            SizedBox(width: scaler.getWidth(1)),
                            WidgetHelper().textQ('$qty', scaler.getTextSize(10), LightColor.lightblack, FontWeight.bold),
                            SizedBox(width: scaler.getWidth(1)),
                            WidgetHelper().myRipple(
                                callback: (){
                                  anying+=1;
                                  getSubtotal();
                                  checkingPrice(widget.idTenant,idBarang, kodeBarang,idVarian,idSubVarian,anying.toString(),harga,disc1,disc2,isTrue,hargaMaster,hargaVarian,hargaSubVarian);
                                  setState(() {});
                                },
                                child: Icon(Ionicons.ios_add_circle_outline,color: LightColor.lightblack,size: scaler.getTextSize(15),)
                            ),

                          ],
                        )
                      ],
                    ),
                    // SizedBox(height: scaler.getHeight(0.5)),

                  ],
                ),
              )
            ],
          ),
        )
      ),
    );

  }

}
