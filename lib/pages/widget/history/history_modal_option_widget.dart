import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/checkout/resi_model.dart';
import 'package:miski_shop/pages/component/history/resi_component.dart';
import 'package:miski_shop/pages/widget/review/list_product_review_widget.dart';
import 'package:miski_shop/provider/handle_http.dart';

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
      WidgetHelper().myPush(context,ResiComponent(resiModel: resiModel));
    }
  }

  Future done()async{
    final result=widget.val.toJson();
    String kdTrx=FunctionHelper.getEncode(result["kd_trx"]);
    WidgetHelper().notifDialog(context, "Informasi","Tekan oke untuk menyelesaikan pesanan anda", (){}, ()async{
      Navigator.of(context).pop();
      WidgetHelper().loadingDialog(context);
      final res=await HandleHttp().putProvider("transaction/$kdTrx", {});
      Navigator.of(context).pop();
      if(res!=null){
        WidgetHelper().notifOneBtnDialog(context,"Berhasil", "Terimakasih,pesanan anda sudah selesai", ()=>Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final val = widget.val;
    print(FunctionHelper.getEncode(val.kdTrx));
    final scaler=config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPadding(1, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildOption(context: context,title: "Detail pembelian",callback: ()=>Navigator.of(context).pushNamed("/${StringConfig.detailHistoryOrder}",arguments: FunctionHelper.getEncode(val.kdTrx))),
          Divider(),
          if(widget.barang.length==1)buildOption(context: context,title: "Beli lagi",callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
              "heroTag":"cart",
              "id":widget.barang[0].idBarang,
              "image":widget.barang[0].gambar,
            });
          }),
          if(widget.barang.length==1)Divider(),

          if(val.status==4)buildOption(context: context,title: "Beri ulasan",callback: ()=>WidgetHelper().myModal(context, ListProductReviewWidget(data: val.toJson()["detail"]))),
          if(val.status==4)Divider(),

          if(val.resi!="-")buildOption(context: context,title: "Lacak resi",callback: (){checkResi();}),
          if(val.resi!="-")Divider(),
          buildOption(context: context,title: "Tanya penjual",callback: ()=>Navigator.of(context).pushNamed("/${StringConfig.main}", arguments: 3)),
          // Divider(),
          // if(val.status==0) buildOption(context: context,title: "Upload bukti transfer",callback: (){
          //   Navigator.of(context).pushNamed("/${StringConfig.successCheckout}",arguments: {
          //     "invoice_no":"${val.kdTrx}",
          //     "grandtotal":"${val.grandtotal}",
          //     "kode_unik":"${val.kodeUnik}",
          //     "total_transfer":"${int.parse(val.jumlahTf)}",
          //     "bank_logo":"${val.logo}",
          //     "bank_name":"${val.bankTujuan}",
          //     "bank_atas_nama":"${val.atasNama}",
          //     "bank_acc":"${val.rekeningTujuan}",
          //     "bank_code":"${val.bankCode}",
          //   });
          // }),
          if(val.status==3) Divider(),
          if(val.status==3) buildOption(context: context,title: "Selesaikan pesanan",callback: ()=>done()),

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
