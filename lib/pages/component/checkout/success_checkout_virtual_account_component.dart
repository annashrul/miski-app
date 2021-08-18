import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:getwidget/components/accordion/gf_accordion.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/detail_checkout_virtual_account_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';

// ignore: must_be_immutable
class SuccessCheckoutVirtualAccountComponent extends StatefulWidget {
  DetailCheckoutVirtualAccountModel detailCheckoutVirtualAccountModel;
  SuccessCheckoutVirtualAccountComponent({this.detailCheckoutVirtualAccountModel});
  @override
  _SuccessCheckoutVirtualAccountComponentState createState() => _SuccessCheckoutVirtualAccountComponentState();
}

class _SuccessCheckoutVirtualAccountComponentState extends State<SuccessCheckoutVirtualAccountComponent> with TickerProviderStateMixin {
  int _counter = 0;
  AnimationController _controller;
  int levelClock = 86400;
  dynamic resStatus={"img":"","title":""};
  loadStatus(status){
    final funcStatus = FunctionHelper.statusCheckout(status);
    resStatus.addAll(funcStatus);
    this.setState(() {});
  }
 Future checkStatus()async{
   WidgetHelper().loadingDialog(context);
   String kdTrx=FunctionHelper.getEncode(widget.detailCheckoutVirtualAccountModel.result.invoiceNo);
   final res = await HandleHttp().getProvider("transaction/payment/check/$kdTrx", null,context: context);
   Navigator.of(context).pop();
   int status = res["result"]["status"];
   final funcStatus = FunctionHelper.statusCheckout(status);
   if(status!=0){
     WidgetHelper().notifOneBtnDialog(context, "Informasi", "Transaksi anda sudah ${funcStatus["title"]}", ()=>FunctionHelper.toHome(context));
   }else{
     loadStatus(status);
   }
 }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds:levelClock)
    );
    _controller.forward();
    loadStatus(0);
  }


  @override
  Widget build(BuildContext context) {
    final scale = config.ScreenScale(context).scaler;


    return WillPopScope(
        child:  Scaffold(
          appBar: WidgetHelper().appBarWithButton(context, "Virtual account (VA)", (){
            Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
          }, <Widget>[]),
          body: ListView(
            padding: scale.getPadding(1,0),
            children: [
              Padding(
                padding: scale.getPadding(0,2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: config.MyFont.subtitle(context: context,text:"Sisa waktu pembayaran")),
                    Center(child: Countdown(animation: StepTween(begin: levelClock, end: 0).animate(_controller))),
                    SizedBox(height: scale.getHeight(1)),
                    Container(
                      alignment: Alignment.center,
                      height: scale.getHeight(3),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(resStatus["img"])
                        )
                      ),
                    ),
                    SizedBox(height: scale.getHeight(0.2)),
                    Center(
                      child: config.MyFont.title(context:context,text:resStatus["title"],textAlign: TextAlign.center,color: config.Colors.mainColors,fontSize: 12),
                    ),
                    SizedBox(height: scale.getHeight(1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        config.MyFont.subtitle(context: context,text:widget.detailCheckoutVirtualAccountModel.result.paymentMethod),
                        config.MyFont.subtitle(context: context,text:widget.detailCheckoutVirtualAccountModel.result.paymentName),
                      ],
                    ),
                    SizedBox(height: scale.getHeight(1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        config.MyFont.subtitle(context: context,text:"Total pembayaran"),
                        config.MyFont.subtitle(context: context,text:config.MyFont.toMoney("${widget.detailCheckoutVirtualAccountModel.result.totalPay}"),color: config.Colors.moneyColors),
                      ],
                    ),
                    SizedBox(height: scale.getHeight(1)),
                    Divider(thickness: scale.getHeight(0.5)),
                    SizedBox(height: scale.getHeight(1)),
                    widget.detailCheckoutVirtualAccountModel.result.instruction.length<1?Text(""):config.MyFont.subtitle(context: context,text:"Petunjuk pembayaran"),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: ScrollPhysics(),
                    itemCount: widget.detailCheckoutVirtualAccountModel.result.instruction.length,
                    itemBuilder: (context,index){
                      final resParent= widget.detailCheckoutVirtualAccountModel.result.instruction[index];
                      return GFAccordion(
                          contentBorderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft:Radius.circular(10)),
                          textStyle: config.MyFont.style(context: context,style: Theme.of(context).textTheme.headline1),
                          collapsedTitleBackgroundColor:config.Colors.secondColors,
                          contentBackgroundColor:Colors.transparent ,
                          expandedTitleBackgroundColor: config.Colors.secondColors,
                          titleChild: config.MyFont.subtitle(context: context,text:resParent.title,color: config.Colors.secondDarkColors),
                          contentChild: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: ScrollPhysics(),
                            itemCount: resParent.steps.length,
                            itemBuilder: (c,i){
                              final resChild=resParent.steps[i];
                              return Html(
                                data: resChild,
                                defaultTextStyle: config.MyFont.style(context: context,color:Theme.of(context).textTheme.caption.color,style: Theme.of(context).textTheme.subtitle1,fontWeight: FontWeight.normal),
                                onLinkTap: (String url){},
                              );
                            },
                            separatorBuilder: (c,i){return Divider(color:Theme.of(context).textTheme.caption.color);},
                          )
                      );
                    }
                ),
              ),
              Padding(
                padding: scale.getPadding(1,2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(thickness: scale.getHeight(0.5)),
                    SizedBox(height: scale.getHeight(1)),

                    Center(
                        child: config.MyFont.subtitle(context: context,text:"Sistem akan otomatis mem-verifikasi hasil pembayaran dalam 30 menit setelah anda selesaikan pembayaran, silahkan perhatikan status pemesanan",textAlign: TextAlign.center)
                    )
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              WidgetHelper().myRipple(
                callback: ()=>checkStatus(),
                child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                    ),
                    child: config.MyFont.title(
                        context: context,
                        text: 'Refresh',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)
                ),
              )
            ],
          ),
        ),
        onWillPop: (){
          Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
          return;
        }
    );
  }
}
// ignore: must_be_immutable
class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);
    String timerText = '${clockTimer.inHours.remainder(60).toString()} : ${clockTimer.inMinutes.remainder(60).toString()} : ${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return config.MyFont.title(context: context,text:"$timerText",fontSize: 12);
  }
}