import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/address/function_address.dart';
import 'package:netindo_shop/helper/checkout/function_checkout.dart';
import 'package:netindo_shop/helper/detail/function_detail.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/list_address_model.dart';
import 'package:netindo_shop/pages/widget/checkout/section_address_widget.dart';
import 'package:netindo_shop/pages/widget/checkout/section_product_widget.dart';
import 'package:netindo_shop/pages/widget/checkout/section_shipping_widget.dart';
import 'package:netindo_shop/views/screen/address/address_screen.dart';

class CheckoutComponent extends StatefulWidget {
  @override
  _CheckoutComponentState createState() => _CheckoutComponentState();
}

class _CheckoutComponentState extends State<CheckoutComponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List product = [];
  Map<String,Object> address = {};
  dynamic shippingKurir = {};
  dynamic shippingLayanan = {};
  dynamic loadingShipping = {"kurir":true,"layanan":true};
  Map<String,Object> indexShipping = {"kurir":0,"layanan":0};
  bool isLoading=true;
  int indexAddress=0,cost=0,subtotal=0;
  Future loadData(String type)async{
    final resDetail = await FunctionCheckout().loadData(context: context,type: type,ongkos: cost);
    if(type=="all"){
      address = resDetail["address"]["data"][indexAddress];
      shippingKurir.addAll({"arr":resDetail["shipping"]["kurir"]["result"],"obj":resDetail["shipping"]["kurir"]["result"][0]});
      shippingLayanan.addAll({"arr":resDetail["shipping"]["layanan"]["ongkir"]["ongkir"],"obj":resDetail["shipping"]["layanan"]["ongkir"]["ongkir"][0]});
      loadingShipping.addAll({"kurir":false,"layanan":false});
      isLoading=false;
      cost=resDetail["shipping"]["layanan"]["ongkir"]["ongkir"][0]["cost"];
    }else{
      cost=cost;
    }
    subtotal = resDetail["subTotal"];
    product = resDetail["productDetail"];
    if(this.mounted)setState(() {});
    // print("RESPONSE DETAIL $product");
  }

  Future handleShipping(i,type)async{
    Navigator.of(context).pop();
    if(type=="kurir"){
      indexShipping["kurir"] = i;
      indexShipping["layanan"] = 0;
      loadingShipping["layanan"]=true;
      final ongkir = await FunctionCheckout().loadOngkir(context: context,kodeKecamatan: address["kd_kec"],kurir: shippingKurir["arr"][i]["kurir"]);
      loadingShipping["layanan"]=false;
      shippingLayanan["arr"] = ongkir["ongkir"]["ongkir"];
      shippingLayanan["obj"] = ongkir["ongkir"]["ongkir"][0];
      cost = shippingLayanan["obj"]["cost"];
    }
    else{
      print("ongkir ${shippingLayanan["arr"][i]}");
      indexShipping["layanan"] = i;
      cost = shippingLayanan["arr"][i]["cost"];
    }
    if(this.mounted)setState(() {});

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData("all");
  }



  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    print("onglos $cost");

    return Scaffold(
      key: _scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context,"Checkout", (){}, <Widget>[],param: "default"),
      bottomNavigationBar: Container(
        padding: scaler.getPadding(1,2),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
            ]),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - scaler.getWidth(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child:config.MyFont.title(context: context,text:'Subtotal')),
                  config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(subtotal)}',color: config.Colors.mainColors),
                ],
              ),
              SizedBox(height: scaler.getHeight(0.5)),
              Row(
                children: <Widget>[
                  Expanded(child:config.MyFont.title(context: context,text:'Ongkos kirim')),
                  config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(cost)}',color: config.Colors.mainColors),
                ],
              ),
              SizedBox(height: scaler.getHeight(0.5)),
              Row(
                children: <Widget>[
                  Expanded(child:config.MyFont.title(context: context,text:'Diskon voucher')),
                  config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(0)}',color: config.Colors.mainColors),
                ],
              ),
              SizedBox(height: scaler.getHeight(0.5)),
              Stack(
                fit: StackFit.loose,
                alignment: AlignmentDirectional.centerEnd,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 30,
                    child: FlatButton(
                        onPressed: () {},
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
      body: ListView(
        physics:AlwaysScrollableScrollPhysics(),
        children: [
          SectionAddressWidget(
            isLoading: isLoading,
            address: address,
            callback: (data){if(this.mounted)this.setState(()=>address=data);},
          ),
          Divider(),
          SectionShippingWidget(
              index:indexShipping,
              isLoading: loadingShipping,
              kurir:shippingKurir,
              layanan:shippingLayanan,
              callback:(i,type)async{
                handleShipping(i,type);
              }
          ),
          Divider(),
          SectionProductWidget(data: product,callback: (){
            loadData("cart");
          }),
        ],
      ),
    );
  }
}
