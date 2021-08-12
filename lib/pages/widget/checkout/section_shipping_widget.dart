import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/promo/detail_global_promo_model.dart';
import 'package:netindo_shop/pages/widget/checkout/modal_kurir_widget.dart';
import 'package:netindo_shop/pages/widget/checkout/modal_layanan_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class SectionShippingWidget extends StatefulWidget {
  final dynamic index;
  final dynamic isLoading;
  final dynamic kurir;
  final dynamic layanan;
  final Function(int i,dynamic type) callback;
  SectionShippingWidget({this.index,this.kurir,this.layanan,this.isLoading,this.callback});
  @override
  _SectionShippingWidgetState createState() => _SectionShippingWidgetState();
}

class _SectionShippingWidgetState extends State<SectionShippingWidget> {
  Map<String, Object> data={};
  String codePromo="-";
  @override
  void initState() {
    super.initState();
    data = widget.kurir["obj"];
  }

  setKurir(obj){
    data.addAll(obj);
  }
  @override
  Widget build(BuildContext context) {

    dynamic resKurir=widget.kurir["obj"];
    dynamic resLayanan=widget.layanan["obj"];
    final scaler = config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPadding(0,2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetHelper().titleQ(context, "Jasa pengiriman",icon: UiIcons.checked),
          SizedBox(height: scaler.getHeight(0.5)),
          jasaPengiriman(context,"Pilih kurir", widget.isLoading["kurir"]?"":"${resKurir["deskripsi"]} ( ${resKurir["title"]} )", (){
            WidgetHelper().myModal(
              context,
              ModalKurirWidget(data: widget.kurir["arr"],callback: (i){
                widget.callback(i,"kurir");
                widget.kurir["obj"] = widget.kurir["arr"][i];
                if(this.mounted)setState(() {});
              },index:widget.index["kurir"])
            );
          },loading: widget.isLoading["kurir"]),
          SizedBox(height: scaler.getHeight(0.5)),
          jasaPengiriman(context,"Pilih layanan",  widget.isLoading["layanan"]?"":"${resLayanan["service"]}  | ${FunctionHelper().formatter.format(resLayanan["cost"])} | ${resLayanan["estimasi"]}", (){
            if(!widget.isLoading["layanan"]){
              WidgetHelper().myModal(
                context,
                ModalLayananWidget(data: widget.layanan["arr"],callback: (i){
                  widget.callback(i,"layanan");
                  widget.layanan["obj"] = widget.layanan["arr"][i];
                  if(this.mounted)setState(() {});
                },index: widget.index["layanan"])
              );
            }
          },loading: widget.isLoading["layanan"]),
          SizedBox(height: scaler.getHeight(0.5)),
          jasaPengiriman(context,"Gunakan voucher", codePromo, (){
            WidgetHelper().myModal(context, ModalVoucher(callback: (data){
              this.setState(() {codePromo=data["kode"];});
              widget.callback(0,data);
            }));
          }),
        ],
      ),
    );
  }

  Widget jasaPengiriman(BuildContext context,String title,String desc,Function callback,{bool loading=false}){
    return WidgetHelper().myRipple(
      callback: callback,
      child: WidgetHelper().chip(
        ctx: context,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                config.MyFont.subtitle(context: context,text:title),
                SizedBox(height: 5.0),
                loading?WidgetHelper().shimmer(context: context,width: 40):config.MyFont.subtitle(context: context,text:desc,color: Theme.of(context).textTheme.caption.color),
              ],
            ),
            WidgetHelper().icons(ctx:context,icon:UiIcons.play_button),
          ],
        )
      )
    );
  }
}


class ModalVoucher extends StatefulWidget {
  final Function(dynamic data) callback;
  ModalVoucher({this.callback});
  @override
  _ModalVoucherState createState() => _ModalVoucherState();
}

class _ModalVoucherState extends State<ModalVoucher> {
  TextEditingController codeController = TextEditingController();
  final FocusNode codeFocus = FocusNode();

  DetailGlobalPromoModel detailGlobalPromoModel;
  Future checkPromo()async{
    if(codeController.text==""){
      codeFocus.requestFocus();
      return;
    }
    final tenant=await FunctionHelper().getTenant();
    WidgetHelper().loadingDialog(context);
    final res=await HandleHttp().getProvider("promo/check/${codeController.text}/${tenant[StringConfig.idTenant]}",null,context: context);
    // final res=await HandleHttp().getProvider("promo/check/W1K2GEUP/${tenant[StringConfig.idTenant]}",null,context: context);
    Navigator.pop(context);
    if(res!=null){
      final result=jsonDecode(res);
      widget.callback({"kode":result["result"]["kode"],"disc":result["result"]["disc"],"max_disc":result["result"]["max_disc"]});
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: scaler.getPadding(1,2),
            child:Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WidgetHelper().titleQ(context, "masukan kode voucher",icon: UiIcons.information,fontSize: 9,callback: (){}),
                    WidgetHelper().myRipple(
                      callback: (){checkPromo();},
                      child: config.MyFont.title(context: context,text:"kirim",color: config.Colors.mainColors,fontSize: 9)
                    )
                  ],
                ),
                Divider(),
                WidgetHelper().field(
                  context: context,
                  title: "masukan kode voucher disini ..",
                  textEditingController: codeController,
                  focusNode: codeFocus,
                  submited: (e){
                    checkPromo();
                  }
                )
              ],
            )
        ),
      ],
    );
  }
}

