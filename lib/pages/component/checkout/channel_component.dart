import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/checkout/function_checkout.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/checkout/channel_model.dart';
import 'package:miski_shop/model/checkout/detail_checkout_virtual_account_model.dart';
import 'package:miski_shop/provider/channel_payment_provider.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:provider/provider.dart';

class ChannelComponent extends StatefulWidget {
  final dynamic data;
  const ChannelComponent({Key key, this.data}) : super(key: key);
  @override
  _ChannelComponentState createState() => _ChannelComponentState();
}

class _ChannelComponentState extends State<ChannelComponent> {
  List data = [];
  bool isLoading = true;

  Future checkout(code) async {
    dynamic data = widget.data;
    data.addAll({"channel": code});
    WidgetHelper().loadingDialog(context);
    final res = await HandleHttp().postProvider("transaction", data,context: context);
    Navigator.of(context).pop();
    if(res!=null){
      final responseCheckout = DetailCheckoutVirtualAccountModel.fromJson(res);
      WidgetHelper().notifDialog(context,StringConfig.titleMsgSuccessTrx, StringConfig.descMsgSuccessTrx, (){
        Navigator.of(context).pop();
      }, (){
        Navigator.of(context).pushNamed("/${StringConfig.successCheckoutVirtualAccount}",arguments: responseCheckout);
      });

    }
  }

  @override
  void initState() {
    super.initState();
    final resChannel = Provider.of<ChannelPaymentProvider>(context, listen: false);
    resChannel.read(context);
  }

  @override
  Widget build(BuildContext context) {
    final resChannel = Provider.of<ChannelPaymentProvider>(context);
    final scale = config.ScreenScale(context).scaler;
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Halaman pembayaran", () {}, <Widget>[],param: "default"),
      body: resChannel.isLoading? ListView.separated(
        padding: scale.getPadding(1, 2),
        itemCount: 15,
        separatorBuilder: (context, index) {return SizedBox(height: scale.getHeight(1));},
        itemBuilder: (context, index) {
          return WidgetHelper().baseLoading(context,WidgetHelper().shimmer(context: context,width: 50,height: 3));
        },
      ): ListView.separated(
        padding: scale.getPadding(1, 2),
        itemCount: resChannel.resChannel.length,
        separatorBuilder: (context, index) {return Divider();},
        itemBuilder: (context, index) {
          final res = resChannel.resChannel[index].toJson();

          // int fee =int.parse(res["fee_customer"]["flat"]);
          dynamic fee = res["fee_customer"]["flat"];
          // if(res["fee_customer"]["flat"].runtimeType == int){
          //   fee =int.parse(res["fee_customer"]["flat"]);
          // }
          print(fee);
          return WidgetHelper().titleQ(
            context, res["name"],
            subtitle: "",
            fontWeight: FontWeight.normal,
            fontSize: 9,
            param: "-",
            padding: scale.getPadding(0.5, 0),
            callback: () {
              WidgetHelper().notifDialog(context,"Informasi !!", "anda yakin akan melakukan proses checkot ?", ()=>Navigator.of(context).pop(), (){
                Navigator.of(context).pop();
                checkout(res["code"]);
              });
            }
          );
        },
      )
    );
  }
}
