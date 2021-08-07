import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

class CartWidget extends StatefulWidget {
  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  CartModel cartModel;
  bool isLoading=true,isError=false;
  int subtotal=0,qty=0;
  String idTenant="";
  Future loadCart()async{
    final tenant=await FunctionHelper().getTenant();
    final res = await HandleHttp().getProvider("cart/${tenant[StringConfig.idTenant]}", cartModelFromJson,context: context);

    if(res!=null){
      if(res==StringConfig.errNoData){
        isError=true;
        if(this.mounted) setState(() {});
        return;
      }
      idTenant=tenant["id"];
      CartModel result=res;
      cartModel = result;
      isLoading=false;
      getSubtotal();
      if(this.mounted) setState(() {});
    }

  }
  getSubtotal(){
    int st = 0;
    for(var i=0;i<cartModel.result.length;i++){
      st = st+int.parse(cartModel.result[i].hargaJual)*int.parse(cartModel.result[i].qty);
    }
    subtotal = st;
  }
  Future checkingPrice(int index)async{
    final cart=cartModel.result[index];
    WidgetHelper().loadingDialog(context,title: 'pengecekan harga bertingkat');
    var res = await FunctionHelper().checkingPriceComplex(
        cart.idTenant,
        cart.idBarang,
        cart.kodeBarang,
        cart.idVarian,
        cart.idSubvarian,
        cart.qty,
        cart.hargaJual,
        cart.disc1,
        cart.disc2,
        cart.bertingkat,
        cart.hargaMaster,
        cart.varianHarga,
        cart.subvarianHarga
    );
    print(res);
    loadCart();
    setState(() {Navigator.pop(context);});
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
      final res = await HandleHttp().deleteProvider(url, generalFromJson,context: context);
      loadCart();
      Navigator.pop(context);

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCart();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Shopping Cart",(){}, <Widget>[
        if(!isLoading && !isError)
          WidgetHelper().iconAppbar(context: context,icon: UiIcons.trash,callback: (){
            deleted(idTenant,'all');
          })

      ],param: "default"),
      body: isError?EmptyDataWidget(
        iconData: UiIcons.shopping_cart,
        title: "Empty cart",
        callback: (){
          Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
        },
        isFunction: true,
        txtFunction: "Start Exploring",
      ):Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            padding:scaler.getPadding(0,2),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: Container(
                      child: Icon(
                        UiIcons.shopping_cart,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    title: config.MyFont.title(context: context,text:'Verify your quantity and click checkout',fontWeight: FontWeight.normal,fontSize: 9),
                  ),
                  isLoading?LoadingCart(total: 6):ListView.separated(
                    padding: EdgeInsets.all(0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: cartModel.result.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 15);
                    },
                    itemBuilder: (context, index) {
                      return buildItem(context: context,index: index);
                    },
                  ),
                ],
              ),
            ),
          ),
          if(!isLoading &&  cartModel.result.length>0)Positioned(
            bottom: 0,
            child: Container(
              height: scaler.getHeight(17),
              padding: scaler.getPadding(1,4),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - scaler.getWidth(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child:config.MyFont.title(context: context,text:'Subtotal',fontWeight: FontWeight.normal)),
                        config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(subtotal)}',fontWeight: FontWeight.normal,color: config.Colors.mainColors),
                      ],
                    ),

                    SizedBox(height: 10),
                    Stack(
                      fit: StackFit.loose,
                      alignment: AlignmentDirectional.centerEnd,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/${StringConfig.checkout}');
                            },
                            padding: EdgeInsets.symmetric(vertical: 14),
                            color: Theme.of(context).accentColor,
                            shape: StadiumBorder(),
                            child:config.MyFont.title(context: context,text:'Checkout',fontWeight: FontWeight.bold,color:  Theme.of(context).primaryColor)
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(subtotal)}',fontWeight: FontWeight.bold,color:  Theme.of(context).primaryColor)

                        )
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem({BuildContext context,int index}){
    final res=cartModel.result[index];
    int anying=int.parse(res.qty);
    final scaler=config.ScreenScale(context).scaler;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
        ],

        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: WidgetHelper().myRipple(
          callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
              "heroTag":"cart",
              "id":res.idBarang,
              "image":res.gambar,
            }).whenComplete(() => loadCart());
          },
          child: Container(
            padding: scaler.getPadding(0.5,1),
            child: Row(
              children: <Widget>[
                Hero(
                  tag:"cart" + res.idBarang,
                  child: Container(
                    height:  scaler.getHeight(5),
                    width:  scaler.getHeight(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      image: DecorationImage(image: NetworkImage(res.gambar), fit: BoxFit.cover),
                    ),
                  ),
                ),

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
                          config.MyFont.subtitle(context: context,text:res.barang,fontSize: 9),
                          Row(
                            children: [
                              config.MyFont.subtitle(context: context,text:"${FunctionHelper().formatter.format(int.parse(res.hargaJual))}", color:config.Colors.mainColors),
                              SizedBox(width: scaler.getWidth(1)),
                              int.parse(res.hargaCoret)<1?SizedBox():config.MyFont.subtitle(context: context,text:"${FunctionHelper().formatter.format(int.parse(res.hargaCoret))}",textDecoration: TextDecoration.lineThrough,fontSize: 8),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              WidgetHelper().myRipple(
                                callback:()=>deleted(cartModel.result[index].id,''),
                                child: Icon(Ionicons.ios_close_circle_outline,color: Theme.of(context).hintColor,size: scaler.getTextSize(15)),
                              ),
                              SizedBox(width: scaler.getWidth(1)),
                              WidgetHelper().myRipple(
                                  callback: (){
                                    if(int.parse(cartModel.result[index].qty)>1){
                                      anying-=1;
                                      cartModel.result[index].qty = anying.toString();
                                      getSubtotal();
                                      checkingPrice(index);
                                    }
                                    setState(() {});
                                  },
                                  child: Icon(Ionicons.ios_remove_circle_outline,color:Theme.of(context).hintColor,size: scaler.getTextSize(15))
                              ),
                              SizedBox(width: scaler.getWidth(1)),
                              config.MyFont.subtitle(context: context,text:"${res.qty}"),
                              SizedBox(width: scaler.getWidth(1)),
                              WidgetHelper().myRipple(
                                  callback: (){
                                    anying+=1;
                                    getSubtotal();
                                    cartModel.result[index].qty = anying.toString();
                                    checkingPrice(index);
                                    setState(() {});
                                  },
                                  child: Icon(Ionicons.ios_add_circle_outline,color:Theme.of(context).hintColor,size: scaler.getTextSize(15),)
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
