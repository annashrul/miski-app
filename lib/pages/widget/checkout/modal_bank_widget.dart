import 'package:flutter/material.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/checkout/function_checkout.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/model/bank/bank_model.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ModalBankWidget extends StatefulWidget {
  final BankModel bankModel;
  final Function(int index) callback;
  ModalBankWidget({this.bankModel,this.callback});

  @override
  _ModalBankWidgetState createState() => _ModalBankWidgetState();
}

class _ModalBankWidgetState extends State<ModalBankWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    int i = Provider.of<ManageStateCheckout>(context).indexBank;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: scaler.getPadding(1,2),
            child:Column(
              children: [
                WidgetHelper().titleQ(context, "pilih bank tujuan transfer",icon: UiIcons.information,fontSize: 9),
                Divider()
              ],
            )
        ),
        ListView.separated(
          addRepaintBoundaries: true,
          primary: false,
          shrinkWrap: true,
          padding:scaler.getPaddingLTRB(2,0,2,1),
          itemCount: widget.bankModel.result.data.length,
          itemBuilder: (context,index){
            final res=widget.bankModel.result.data[index];
            return WidgetHelper().titleQ(context,
                res.bankName,
                callback: (){
                  Provider.of<ManageStateCheckout>(context,listen:false).setBank(index);
                  widget.callback(index);
                },
                fontSize: 9,
                subtitle: res.atasNama,
                param: i==index?"-":"",
                image:res.logo.replaceAll(" ",""),
                iconAct: i==index?UiIcons.checked:null
            );
          },
          separatorBuilder: (context, index) {return Divider(height:scaler.getHeight(0.5));},
        )
      ],
    );
  }
}
