import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/cart/cart_model.dart';
import 'package:miski_shop/model/general_model.dart';
import 'package:miski_shop/provider/cart_provider.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:provider/provider.dart';
import '../../empty_widget.dart';
import '../../loading_widget.dart';

class CartWidget extends StatefulWidget {
  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.getCartData(context);
    cart.getSubtotal();
  }


  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Keranjang belanja anda",(){}, <Widget>[
        if(!cart.loading && !cart.isError)
          WidgetHelper().iconAppbar(context: context,icon: UiIcons.trash,callback: ()=>cart.deleteCartData(context, "all",""))
      ],param: "default"),
      bottomNavigationBar: !cart.loading && !cart.isError?WidgetHelper().chip(
          ctx: context,
          colors: Theme.of(context).primaryColor,
          padding: scaler.getPadding(1, 2),
          child: SizedBox(
            width: MediaQuery.of(context).size.width - scaler.getWidth(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child:config.MyFont.title(context: context,text:'Subtotal',fontWeight: FontWeight.normal)),
                    config.MyFont.title(context: context,text:config.MyFont.toMoney("${cart.subtotal}"),fontWeight: FontWeight.normal,color: config.Colors.mainColors),
                  ],
                ),
                SizedBox(height: scaler.getHeight(0.5)),
                WidgetHelper().myRipple(
                  isRadius: true,
                  radius: 100,
                  callback: ()=>Navigator.of(context).pushNamed('/${StringConfig.checkout}'),
                  child: Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                            ),
                            child: config.MyFont.title(
                                context: context,
                                text: 'Bayar',
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: config.MyFont.title(
                              context: context,
                              text:config.MyFont.toMoney("${cart.subtotal}"),
                              color:config.Colors.secondDarkColors
                          )
                      )
                    ],
                  ),
                )
              ],
            ),
          )
      ):Text(""),
      body: cart.isError?EmptyDataWidget(
        iconData: UiIcons.shopping_cart,
        title: "Keranjang kosong",
        callback: (){
          Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
        },
        isFunction: true,
        txtFunction: "Belanja sekarang",
      ): cart.loading?LoadingCart(total: 6):Scrollbar(
          child: ListView.separated(
            padding:scaler.getPadding(1,2),
            scrollDirection: Axis.vertical,
            itemCount: cart.cart.result.length,
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemBuilder: (context, index) {
              return buildItem(context: context,index: index);
            },
          )
      ),
    );
  }

  Widget buildItem({BuildContext context,int index}){
    final cart = Provider.of<CartProvider>(context);
    final res=cart.cart.result[index];
    int anying=int.parse(res.qty);
    dynamic data={};
    data["id"]=res.idBarang;
    data["kode"]=res.kodeBarang;
    data["id_varian"]=res.idVarian;
    data["id_sub_varian"]=res.idSubvarian;
    data["harga"]=res.hargaJual;
    data["disc1"]=res.disc1;
    data["disc2"]=res.disc2;
    data["harga_bertingkat"]=res.bertingkat;
    data["harga_master"]=res.hargaMaster;
    data["harga_varian"]=res.varianHarga;
    data["harga_sub_varian"]=res.subvarianHarga;
    final scaler=config.ScreenScale(context).scaler;
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading:Hero(
        tag:"cart" + res.idBarang,
        child: WidgetHelper().baseImage(res.gambar,height:scaler.getHeight(5),width:  scaler.getHeight(5) ),
      ),
      title: config.MyFont.subtitle(context: context,text:res.barang),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              config.MyFont.subtitle(context: context,text:"${config.MyFont.toMoney("${res.hargaJual}")}", color:config.Colors.moneyColors),
              SizedBox(width: scaler.getWidth(1)),
              int.parse(res.hargaCoret)<1?SizedBox():config.MyFont.subtitle(context: context,text:"${FunctionHelper().formatter.format(int.parse(res.hargaCoret))}",textDecoration: TextDecoration.lineThrough,fontSize: 8),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              WidgetHelper().myRipple(
                callback:()=>cart.deleteCartData(context,"item", res.id),
                child: Icon(Ionicons.ios_close_circle_outline,color: Theme.of(context).hintColor,size: scaler.getTextSize(12)),
              ),
              SizedBox(width: scaler.getWidth(1)),
              WidgetHelper().myRipple(
                  callback: (){
                    if(int.parse(res.qty)>1){
                      anying-=1;
                      data["qty"]= anying.toString();
                      cart.getSubtotal();
                      cart.storeCart(context, data);
                    }
                  },
                  child: Icon(Ionicons.ios_remove_circle_outline,color:Theme.of(context).hintColor,size: scaler.getTextSize(12))
              ),
              SizedBox(width: scaler.getWidth(1)),
              config.MyFont.subtitle(context: context,text:"$anying"),
              SizedBox(width: scaler.getWidth(1)),
              WidgetHelper().myRipple(
                  callback: (){
                    anying+=1;
                    data["qty"]=anying.toString();
                    cart.getSubtotal();
                    cart.storeCart(context, data);
                  },
                  child: Icon(Ionicons.ios_add_circle_outline,color:Theme.of(context).hintColor,size: scaler.getTextSize(12),)
              ),
            ],
          ),

        ],
      ),

    );

  }





}
