
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/promo/detail_global_promo_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class ModalVoucherWidget extends StatefulWidget {
  final Function(dynamic data) callback;
  ModalVoucherWidget({this.callback});
  @override
  _ModalVoucherWidgetState createState() => _ModalVoucherWidgetState();
}

class _ModalVoucherWidgetState extends State<ModalVoucherWidget> {
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
    print("############################### RESPONSE KODE VOUCHER $res");
    // final res=await HandleHttp().getProvider("promo/check/W1K2GEUP/${tenant[StringConfig.idTenant]}",null,context: context);
    Navigator.pop(context);
    if(res!=null){
      widget.callback({"kode":res["result"]["kode"],"disc":res["result"]["disc"],"max_disc":res["result"]["max_disc"]});
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
