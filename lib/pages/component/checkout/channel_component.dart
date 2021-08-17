import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/checkout/function_checkout.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/channel_model.dart';
import 'package:netindo_shop/model/checkout/detail_checkout_virtual_account_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class ChannelComponent extends StatefulWidget {
  final dynamic data;
  const ChannelComponent({Key key, this.data}) : super(key: key);
  @override
  _ChannelComponentState createState() => _ChannelComponentState();
}

class _ChannelComponentState extends State<ChannelComponent> {
  List data = [];
  bool isLoading = true;
  Future loadData() async {
    final res = await HandleHttp().getProvider("transaction/payment/channel", channelModelFromJson,context: context);
    if (res != null) {
      ChannelModel result = ChannelModel.fromJson(res.toJson());
      result.result.data.forEach((element) {
        if (element.active) data.add(element.toJson());
      });
      isLoading = false;
      if (this.mounted) this.setState(() {});
    }
  }

  Future checkout(code) async {
    dynamic data = widget.data;
    data.addAll({"channel": code});
    WidgetHelper().loadingDialog(context);
    final res = await HandleHttp().postProvider("transaction", data,context: context);
    print("res  = $res");
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
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final scale = config.ScreenScale(context).scaler;
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Halaman pembayaran", () {}, <Widget>[],param: "default"),
      body: isLoading? WidgetHelper().loadingWidget(context): ListView.separated(
        padding: scale.getPadding(1, 2),
        itemCount: data.length,
        separatorBuilder: (context, index) {return Divider();},
        itemBuilder: (context, index) {
          final res = data[index];
          int fee = int.parse(res["fee_customer"]["flat"].toString());
          return WidgetHelper().titleQ(
            context, res["name"],
            subtitle: fee > 0 ? fee : "",
            fontWeight: FontWeight.normal,
            fontSize: 9,
            param: "-",
            padding: scale.getPadding(0.5, 0),
            callback: () {checkout(res["code"]);}
          );
        },
      )
    );
  }
}
