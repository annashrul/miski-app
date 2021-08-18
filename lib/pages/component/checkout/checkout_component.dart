import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/checkout/function_checkout.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/address/address_component.dart';
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
  String codePromo = "-";
  Map<String, Object> detail = {};
  Map<String, Object> address = {};
  dynamic shippingKurir = {};
  dynamic shippingLayanan = {};
  dynamic loadingShipping = {"kurir": true, "layanan": true};
  Map<String, Object> indexShipping = {"kurir": 0, "layanan": 0};

  bool isLoading = true;
  int indexAddress = 0,cost = 0,subtotal = 0,grandTotal = 0,diskonVoucher = 0;
  Future loadData(String type) async {
    final resDetail = await FunctionCheckout().loadData(context: context, type: type, ongkos: cost);
    if (resDetail == StringConfig.errNoData) {
      WidgetHelper().notifOneBtnDialog(
          context, "Informasi", "Silahkan buat alamat terlebih dahulu", () {
        Navigator.of(context).pop();
        WidgetHelper().myPushAndLoad(context, AddressComponent(), () {
          loadData("all");
        });
      });
      return;
    }
    print("################## ALAMAT $resDetail");
    detail.addAll(resDetail);
    if (type == "all") {
      address = resDetail["address"]["data"][indexAddress];
      shippingKurir.addAll({
        "arr": resDetail["shipping"]["kurir"]["result"],
        "obj": resDetail["shipping"]["kurir"]["result"][0]
      });
      shippingLayanan.addAll({
        "arr": resDetail["shipping"]["layanan"]["ongkir"]["ongkir"],
        "obj": resDetail["shipping"]["layanan"]["ongkir"]["ongkir"][0]
      });
      loadingShipping.addAll({"kurir": false, "layanan": false});
      cost = resDetail["shipping"]["layanan"]["ongkir"]["ongkir"][0]["cost"];
      isLoading = false;
    } else {
      cost = cost;
    }
    subtotal = resDetail["subTotal"];
    grandTotal = resDetail["grandTotal"];
    product = resDetail["productDetail"];
    if (this.mounted) setState(() {});
  }

  Future handleShipping(i, type) async {
    if (type == "kurir") {
      String destination = address["kd_kec"];
      String courier = shippingKurir["arr"][i]["kurir"];
      loadingShipping["layanan"] = true;
      if(address["pinpoint"]!="-"){
        shippingKurir["obj"] = shippingKurir["arr"].last;
        shippingLayanan["obj"] = shippingLayanan["arr"].last;
        indexShipping = {"kurir": shippingKurir["arr"].length-1, "layanan": shippingLayanan["arr"].length-1};
        String latitude   = "${address["pinpoint"]}".split(",")[0];
        String longitude  = "${address["pinpoint"]}".split(",")[1];
        destination = "$latitude,$longitude";
        courier = shippingKurir["arr"][shippingKurir["arr"].length-1]["kurir"];
      }
      else if (address["pinpoint"]!="-"&&courier == "instant") {
        String latitude   = "${address["pinpoint"]}".split(",")[0];
        String longitude  = "${address["pinpoint"]}".split(",")[1];
        destination = "$latitude,$longitude";
      }
      else if(address["pinpoint"]=="-"&&courier == "instant"){
        indexShipping["kurir"] = 0;
        destination = address["kd_kec"];
        courier = shippingKurir["arr"][0]["kurir"];
        shippingKurir["obj"] = shippingKurir["arr"][0];
        shippingLayanan["obj"] = shippingLayanan["arr"][0];
      }

      final ongkir = await FunctionCheckout().loadOngkir(context: context, kodeKecamatan: destination, kurir: courier);
      loadingShipping["layanan"] = false;
      shippingLayanan["arr"] = ongkir["ongkir"]["ongkir"];
      shippingLayanan["obj"] = ongkir["ongkir"]["ongkir"][0];
      cost = shippingLayanan["obj"]["cost"];
    } else if (type == "layanan") {
      indexShipping["layanan"] = i;
      cost = shippingLayanan["arr"][i]["cost"];
    } else {
      codePromo = type["kode"];
      int disc = FunctionHelper().percentToRp(type["disc"], grandTotal);
      int max = int.parse(type["max_disc"]);
      diskonVoucher = disc > max ? max : disc;
      WidgetHelper().showFloatingFlushbar(context, "success","selamat, anda mendapat potongan sebesar $diskonVoucher");
    }
    grandTotal = (subtotal + cost) - diskonVoucher;
    if (this.mounted) setState(() {});
  }

  Future checkout() async {
    var data = {
      "id_tenant": detail["idTenant"],
      "subtotal": "$subtotal",
      "ongkir": "$cost",
      "disc": "0",
      "tax": "0",
      "grandtotal": "$grandTotal",
      "kurir": shippingKurir["obj"]["kurir"],
      "service": shippingLayanan["obj"]["service"],
      "metode_pembayaran": "transfer",
      "kode_voucher": "$codePromo",
      "id_alamat_member": "${address["id"]}",
     
    };
     Navigator.of(context).pushNamed("/${StringConfig.channel}", arguments: data);
    // FunctionCheckout().storeCheckout(context: context, data: data);
  }

  @override
  void initState() {
    super.initState();
    loadData("all");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(
          context, "Pembayaran", () {}, <Widget>[],
          param: "default"),
      bottomNavigationBar: buildBottomNavigationBar(context),
      body: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SectionAddressWidget(
            isLoading: isLoading,
            address: address,
            callback: (data) async {
              setState(() {
                address = data;
              });
              // if(data["pinpoint"]!="-"){
              //   setState(() {
              //     shippingKurir["obj"] = shippingKurir["arr"].last;
              //     shippingLayanan["obj"] = shippingLayanan["arr"].last;
              //     indexShipping = {"kurir": shippingKurir["arr"].length-1, "layanan": shippingLayanan["arr"].length-1};
              //   });
              //   print("###############################");
              //   print(shippingKurir["arr"].length-1);
              //   handleShipping(shippingKurir["arr"].length-1, "kurir");
              // }
              handleShipping(indexShipping["kurir"], "kurir");

            },
          ),
          Divider(),
          SectionShippingWidget(
              address:address,
              index: indexShipping,
              isLoading: loadingShipping,
              kurir: shippingKurir,
              layanan: shippingLayanan,
              callback: (i, type) async {
                Navigator.of(context).pop();
                handleShipping(i, type);
              }),
          Divider(),
          SectionProductWidget(
              data: product,
              callback: () {
                loadData("cart");
              }),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return WidgetHelper().chip(
        ctx: context,
        colors: Theme.of(context).primaryColor,
        padding: scaler.getPadding(1, 2),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - scaler.getWidth(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildRowBottomBar(context: context, title: "Subtotal", desc: "$subtotal"),
              SizedBox(height: scaler.getHeight(0.5)),
              buildRowBottomBar(context: context, title: "Ongkos kirim", desc: "$cost"),
              SizedBox(height: scaler.getHeight(0.5)),
              buildRowBottomBar(context: context,title: "Diskon voucher", desc: "$diskonVoucher"),
              SizedBox(height: scaler.getHeight(0.5)),
              WidgetHelper().myRipple(
                isRadius: true,
                radius: 100,
                callback: ()async => await checkout(),
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
                            text:
                                '${FunctionHelper().formatter.format(grandTotal)}',
                            color: config.Colors.moneyColors))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget buildRowBottomBar({BuildContext context, String title, var desc}) {
    return Row(
      children: <Widget>[
        Expanded(child: config.MyFont.title(context: context, text: title)),
        config.MyFont.title(
            context: context,
            text: '${FunctionHelper().formatter.format(int.parse(desc))}',
            color: config.Colors.moneyColors),
      ],
    );
  }
}
