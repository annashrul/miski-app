import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/checkout/function_checkout.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/bank/bank_model.dart';
import 'package:netindo_shop/pages/component/address/address_component.dart';
import 'package:netindo_shop/pages/widget/checkout/modal_bank_widget.dart';
import 'package:netindo_shop/pages/widget/checkout/section_address_widget.dart';
import 'package:netindo_shop/pages/widget/checkout/section_product_widget.dart';
import 'package:netindo_shop/pages/widget/checkout/section_shipping_widget.dart';


class CheckoutComponent extends StatefulWidget {
  @override
  _CheckoutComponentState createState() => _CheckoutComponentState();
}

class _CheckoutComponentState extends State<CheckoutComponent> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List product = [];
  String codePromo="-";
  BankModel bankModel;
  Map<String,Object> detail = {};
  Map<String,Object> address = {};
  dynamic shippingKurir = {};
  dynamic shippingLayanan = {};
  dynamic loadingShipping = {"kurir":true,"layanan":true};
  Map<String,Object> indexShipping = {"kurir":0,"layanan":0};
  bool isLoading=true;
  int indexAddress=0,indexBank=0,cost=0,subtotal=0,grandTotal=0,diskonVoucher=0;
  Future loadData(String type)async{
    final resDetail = await FunctionCheckout().loadData(context: context,type: type,ongkos: cost);
    if(resDetail==StringConfig.errNoData){
      WidgetHelper().notifOneBtnDialog(context,"Informasi","Silahkan buat alamat terlebih dahulu",(){
        Navigator.of(context).pop();
        WidgetHelper().myPushAndLoad(context,AddressComponent(),(){
          loadData("all");
        });
      });
      return;
    }

    detail.addAll(resDetail);

    if(type=="all"){
      address = resDetail["address"]["data"][indexAddress];
      shippingKurir.addAll({"arr":resDetail["shipping"]["kurir"]["result"],"obj":resDetail["shipping"]["kurir"]["result"][0]});
      shippingLayanan.addAll({"arr":resDetail["shipping"]["layanan"]["ongkir"]["ongkir"],"obj":resDetail["shipping"]["layanan"]["ongkir"]["ongkir"][0]});
      loadingShipping.addAll({"kurir":false,"layanan":false});
      cost=resDetail["shipping"]["layanan"]["ongkir"]["ongkir"][0]["cost"];
      bankModel = resDetail["bank"];
      isLoading=false;
    }
    else{
      cost=cost;
    }
    subtotal = resDetail["subTotal"];
    grandTotal = resDetail["grandTotal"];
    product = resDetail["productDetail"];
    if(this.mounted)setState(() {});
  }

  Future handleShipping(i,type)async{
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
    else if(type=="layanan"){
      indexShipping["layanan"] = i;
      cost = shippingLayanan["arr"][i]["cost"];
    }
    else{
      codePromo = type["kode"];
      int disc = FunctionHelper().percentToRp(type["disc"], grandTotal);
      int max = int.parse(type["max_disc"]);
      diskonVoucher = disc > max?max:disc;
      WidgetHelper().showFloatingFlushbar(context, "success", "selamat, anda mendapat potongan sebesar $diskonVoucher");
    }
    grandTotal = (subtotal+cost)-diskonVoucher;
    if(this.mounted)setState(() {});

  }

  Future checkout(int indexBank)async{
    var detailBarang=[];
    product.forEach((element){
      detailBarang.add({
        "kode_barang":element["kode_barang"],
        "id_varian":element["id_varian"],
        "id_subvarian":element["id_subvarian"],
        "qty":element["qty"],
        "harga_jual":"${element["harga_jual"]}",
        "disc":"${element["disc"]}",
        "subtotal":"${element["subtotal"]}",
        "tax":"${element["tax"]}"
      });
    });
   var data ={
      "id_tenant":detail["idTenant"],
      "id_member":detail["idUser"],
      "subtotal":"$subtotal",
      "ongkir":"$cost",
      "disc":"0",
      "tax":"0",
      "grandtotal":"$grandTotal",
      "kurir":shippingKurir["obj"]["kurir"],
      "service":shippingLayanan["obj"]["service"],
      "metode_pembayaran":"transfer",
      "kode_voucher":"$codePromo",
      "id_alamat_member":address["id"],
      "id_bank_tujuan":bankModel.result.data[indexBank].id,
      "atas_nama":bankModel.result.data[indexBank].atasNama,
      "no_rek":bankModel.result.data[indexBank].noRekening,
      "detail":"$detailBarang"
    };
    FunctionCheckout().storeCheckout(context: context,data: data);
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData("all");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context,"Pembayaran", (){}, <Widget>[],param: "default"),
      bottomNavigationBar: buildBottomNavigationBar(context),
      body: ListView(
        physics:AlwaysScrollableScrollPhysics(),
        children: [
          SectionAddressWidget(
            isLoading: isLoading,
            address: address,
            callback: (data)async{
              setState(() {
                loadingShipping["layanan"]=true;
                address=data;
              });
              final ongkir = await FunctionCheckout().loadOngkir(context: context,kodeKecamatan: data["kd_kec"],kurir: shippingKurir["arr"][indexShipping["kurir"]]["kurir"]);
              shippingLayanan["obj"] = ongkir["ongkir"]["ongkir"][0];
              cost = shippingLayanan["obj"]["cost"];
              grandTotal = subtotal+cost;
              loadingShipping["layanan"]=false;
              if(this.mounted)this.setState((){});
            },
          ),
          Divider(),
          SectionShippingWidget(
            index:indexShipping,
            isLoading: loadingShipping,
            kurir:shippingKurir,
            layanan:shippingLayanan,
            callback:(i,type)async{
              Navigator.of(context).pop();
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
  
  
  Widget buildBottomNavigationBar(BuildContext context){
    final scaler = config.ScreenScale(context).scaler;
    return WidgetHelper().chip(
      ctx: context,
      colors: Theme.of(context).primaryColor,
      padding: scaler.getPadding(1,2),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - scaler.getWidth(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildRowBottomBar(context: context,title: "Subtotal",desc: "$subtotal"),
            SizedBox(height: scaler.getHeight(0.5)),
            buildRowBottomBar(context: context,title: "Ongkos kirim",desc: "$cost"),
            SizedBox(height: scaler.getHeight(0.5)),
            buildRowBottomBar(context: context,title: "Diskon voucher",desc: "$diskonVoucher"),
            SizedBox(height: scaler.getHeight(0.5)),
            WidgetHelper().myRipple(
              isRadius: true,
              radius: 100,
              callback: (){
                WidgetHelper().myModal(context,ModalBankWidget(bankModel: bankModel,callback: (i){
                 WidgetHelper().notifDialog(context, "Perhatian","pastikan data yang anda isi sudah benar", (){
                   Navigator.pop(context);
                 }, ()async{
                   await checkout(i);
                 });
                }));
              },
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
                      child:config.MyFont.title(context: context,text:'Bayar',fontWeight: FontWeight.bold,color:  Theme.of(context).primaryColor)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child:config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(grandTotal)}',color: config.Colors.moneyColors)
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }

  Widget buildRowBottomBar({BuildContext context,String title, var desc}){
    return Row(
      children: <Widget>[
        Expanded(child:config.MyFont.title(context: context,text:title)),
        config.MyFont.title(context: context,text:'${FunctionHelper().formatter.format(int.parse(desc))}',color: config.Colors.moneyColors),
      ],
    );
  }

}
