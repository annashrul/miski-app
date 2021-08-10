import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/resi_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/screen/checkout/resi_screen.dart';
import 'file:///E:/NETINDO/netindo_shop/lib/pages/widget/review/list_product_review_widget.dart';

class HistoryModalOptionWIdget extends StatefulWidget {
  final dynamic val;
  final List barang;
  HistoryModalOptionWIdget({this.val,this.barang});
  @override
  _HistoryModalOptionWIdgetState createState() => _HistoryModalOptionWIdgetState();
}

class _HistoryModalOptionWIdgetState extends State<HistoryModalOptionWIdget> {
  ResiModel resiModel;
  Future checkResi() async{
    WidgetHelper().loadingDialog(context);
    var res = await HandleHttp().postProvider("kurir/cek/resi",{
      "resi":widget.val.resi,
      "kurir":widget.val.kurir,
    });
    if(res!=null){
      Navigator.pop(context);
      setState(() { resiModel = ResiModel.fromJson(res);});
      WidgetHelper().myPush(context,ResiScreen(resiModel: resiModel));
    }
  }
  @override
  Widget build(BuildContext context) {
    final val = widget.val;
    print(val.toJson()["detail"]);
    final scaler=config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPadding(1, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildOption(context: context,title: "Detail pembelian",callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.detailHistoryOrder}",arguments: base64.encode(utf8.encode(val.kdTrx)));
          }),
          Divider(),
          if(widget.barang.length==1)buildOption(context: context,title: "Beli lagi",callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
              "heroTag":"cart",
              "id":widget.barang[0].idBarang,
              "image":widget.barang[0].gambar,
            });
          }),
          if(widget.barang.length==1)Divider(),
          if(val.status!=4)buildOption(context: context,title: "Beri ulasan",callback: (){
            WidgetHelper().myModal(context, ListProductReviewWidget(data: val.toJson()["detail"]));
          }),
          if(val.status!=4)Divider(),
          if(val.resi!="-")buildOption(context: context,title: "Lacak resi",callback: (){checkResi();}),
          if(val.resi!="-")Divider(),
          buildOption(context: context,title: "Tanya penjual",callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.main}", arguments: 3);
          }),
          Divider(),
          if(val.status==0) buildOption(context: context,title: "Upload bukti transfer",callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.successCheckout}",arguments: {
              "invoice_no":"${val.kdTrx}",
              "grandtotal":"${val.grandtotal}",
              "kode_unik":"${val.kodeUnik}",
              "total_transfer":"${int.parse(val.jumlahTf)}",
              "bank_logo":"${StringConfig.noImage}",
              "bank_name":"${val.bankTujuan}",
              "bank_atas_nama":"${val.atasNama}",
              "bank_acc":"${val.rekeningTujuan}",
              "bank_code":"${val.bankCode}",
            });
          }),
        ],
      ),
    );
  }
  Widget buildOption({BuildContext context,String title,Function callback}){
    return WidgetHelper().titleQ(
        context,
        title,
        param: "-",
        fontWeight: FontWeight.normal,
        fontSize: 9,
        callback: ()=>callback()
    );
  }
}
