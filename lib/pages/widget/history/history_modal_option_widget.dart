import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class HistoryModalOptionWIdget extends StatefulWidget {
  final dynamic val;
  HistoryModalOptionWIdget({this.val});
  @override
  _HistoryModalOptionWIdgetState createState() => _HistoryModalOptionWIdgetState();
}

class _HistoryModalOptionWIdgetState extends State<HistoryModalOptionWIdget> {
  @override
  Widget build(BuildContext context) {
    final val = widget.val;
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
          if(val.status==4)buildOption(context: context,title: "Beri ulasan",callback: (){}),
          if(val.status==4)Divider(),
          if(val.resi!="-")buildOption(context: context,title: "Lacak resi",callback: (){}),
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
