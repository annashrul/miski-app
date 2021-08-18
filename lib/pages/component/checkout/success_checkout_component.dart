import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/widget/upload_image_widget.dart';
import 'package:miski_shop/provider/handle_http.dart';

class SuccessCheckoutComponent extends StatefulWidget {
  final Map<String,Object> data;
  SuccessCheckoutComponent({this.data});
  @override
  _SuccessCheckoutComponentState createState() => _SuccessCheckoutComponentState();
}

class _SuccessCheckoutComponentState extends State<SuccessCheckoutComponent> {
  var key = GlobalKey<ScaffoldState>();
  String fileName="",url = '',image='';


  var hari  = DateFormat.d().format( DateTime.now().add(Duration(days: 3)));
  var bulan = DateFormat.M().format( DateTime.now());
  var tahun = DateFormat.y().format( DateTime.now());
  Future upload(encoded,img)async{
    WidgetHelper().loadingDialog(context);
    var res = await HandleHttp().putProvider("transaction/deposit/$encoded", {"bukti":img,},context: context);
    if(res!=null){
      Navigator.pop(context);
      WidgetHelper().notifOneBtnDialog(context, StringConfig.titleMsgSuccessTrx,StringConfig.descMsgSuccessTrx,(){
        Navigator.pushNamedAndRemoveUntil(context,"/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      key: key,
      bottomNavigationBar: _bottomNavBarBeli(context),
      body: Scrollbar(
          child: ListView(
            padding: scaler.getPaddingLTRB(2,5,2,1),
            children: <Widget>[
              Icon(UiIcons.checked,size: scaler.getTextSize(20)),
              SizedBox(height: scaler.getHeight(1)),
              config.MyFont.title(context: context,text:"Silahkan transfer tepat sebesar :"),
              SizedBox(height: scaler.getHeight(1)),
              WidgetHelper().chip(
                ctx: context,
                child: config.MyFont.title(context: context,text: "Rp ${config.MyFont.toMoney("${widget.data["total_transfer"]}")} .-",color: config.Colors.moneyColors,fontSize: 14,textAlign: TextAlign.center)
              ),
              SizedBox(height: scaler.getHeight(1)),
              config.MyFont.title(context: context,text:"Pembayaran dapat dilakukan ke rekening berikut :"),
              SizedBox(height: scaler.getHeight(1)),
              WidgetHelper().chip(
                   padding: scaler.getPaddingLTRB(0,0,2,0),
                  ctx: context,
                  child:WidgetHelper().titleQ(
                    context,
                    widget.data["bank_name"],
                    image: widget.data["bank_logo"],
                    subtitle: "${widget.data["bank_acc"]} a/n ${widget.data["bank_atas_nama"]}",
                    padding: scaler.getPaddingLTRB(0,1,2,1),
                    callback: (){
                      Clipboard.setData(new ClipboardData(text: "${widget.data["bank_acc"]}"));
                      WidgetHelper().showFloatingFlushbar(context,"success"," no rekening berhasil disalin");
                    },
                    iconAct: UiIcons.file,
                    param: "-"
                  ),
              ),
              SizedBox(height: scaler.getHeight(1)),
              config.MyFont.title(context: context,text:"Verifikasi penerimaan transfer anda akan diproses selama 5 s/d 10 menit"),
              SizedBox(height: scaler.getHeight(1)),
              RichText(
                text: TextSpan(
                    text: 'Anda dapat melakukan transfer menggunakan ATM, Mobile Banking atau SMS Banking dengan memasukan kode bank',
                    style: config.MyFont.textStyle.copyWith(color: Theme.of(context).textTheme.caption.color),
                    children: <TextSpan>[
                      TextSpan(text: ' ${widget.data["bank_name"]} (${widget.data["bank_code"]})',style:config.MyFont.textStyle.copyWith(color: Theme.of(context).textTheme.headline1.color)),
                      TextSpan(text: ' di depan No.Rekening atas nama',style:config.MyFont.textStyle.copyWith(color: Theme.of(context).textTheme.caption.color)),
                      TextSpan(text: ' ${widget.data["bank_atas_nama"]}',style:config.MyFont.textStyle.copyWith(color: Theme.of(context).textTheme.headline1.color)),
                    ]
                ),
              ),
              SizedBox(height: scaler.getHeight(1)),
              config.MyFont.title(context: context,text:"Mohon transfer tepat hingga 3 digit terakhir agar tidak menghambat proses verifikasi"),
              SizedBox(height: scaler.getHeight(1)),
              RichText(
                text: TextSpan(
                    text: 'Pastikan anda transfer sebelum tanggal',
                    style: config.MyFont.textStyle.copyWith(color: Theme.of(context).textTheme.caption.color),
                    children: <TextSpan>[
                      TextSpan(text: ' $hari-$bulan-$tahun 23:00 WIB',style:config.MyFont.textStyle.copyWith(color: Theme.of(context).textTheme.headline1.color)),
                      TextSpan(text: ' atau transaksi anda otomatis dibatalkan oleh sistem. jika sudah melakukan transfer segera upload bukti transfer disini atau di halaman detail riwayat pembelian',style:config.MyFont.textStyle.copyWith(color: Theme.of(context).textTheme.caption.color)),
                    ]
                ),
              ),
              WidgetHelper().myRipple(
                callback: (){
                  Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
                },
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: config.MyFont.subtitle(context: context,text:"Kembali kehalaman utama",color:config.Colors.mainColors,textAlign: TextAlign.right,textDecoration: TextDecoration.underline),
                )
              ),
            ],
          )
      ),
    );
  }

  Widget _bottomNavBarBeli(BuildContext context){
    final scaler = config.ScreenScale(context).scaler;
    return WidgetHelper().chip(
        ctx: context,
        colors: Theme.of(context).primaryColor,
        padding: scaler.getPadding(1,2),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - scaler.getWidth(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              WidgetHelper().myRipple(
                isRadius: true,
                radius: 100,
                callback: (){
                  WidgetHelper().myModal(context, UploadImageWidget(
                    callback: (String img)async{
                      setState(() {
                        url = base64.encode(utf8.encode(widget.data["invoice_no"]));
                        image = img;
                      });
                      upload(url,image);
                    },
                  ));
                },
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
                          child:config.MyFont.title(context: context,text:'Saya sudah transfer',fontWeight: FontWeight.bold,color:  Theme.of(context).primaryColor)
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );

  }

}
