import 'dart:async';

import 'package:flutter/material.dart';
import "package:netindo_shop/config/app_config.dart" as config;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/secure_code_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';

// ignore: must_be_immutable
class SecureCodeWidget extends StatefulWidget {
  final Function(BuildContext context, bool isTrue) callback;
   String code;
  final String param;
  final String desc;
  final Map<String, Object> data;
  SecureCodeWidget({this.callback,this.code,this.param,this.desc,this.data});
  @override
  _SecureCodeWidgetState createState() => _SecureCodeWidgetState();
}

class _SecureCodeWidgetState extends State<SecureCodeWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var cek;
  Future cekOtp() async{
    setState(() {
      cek = widget.code.split('');
    });
    print("############## OTP ABI = $cek #######################");
  }
  int timeCounter = 0;
  bool timeUpFlag = false;

  _timerUpdate() {
    Timer(const Duration(seconds: 1), () async {
      if(this.mounted){
        setState(() {
          timeCounter--;
        });
      }
      if (timeCounter != 0)
        _timerUpdate();
      else
        timeUpFlag = true;
    });
  }
  @override
  void initState() {
    super.initState();
    timeCounter = 10;
    _timerUpdate();
  }



  bool isLoadingReOtp=false;
  @override
  Widget build(BuildContext context) {
    String desc = 'Masukan Kode OTP Yang Kami Kirim Melalui Pesan ${widget.desc} Untuk Melanjutkan Ke Halaman Berikutnya ${SiteConfig().showCode?widget.code:''}';
    int size = 4;
    if(widget.param!='otp'){
      desc='Masukan PIN Anda Untuk Melanjutkan Ke Halaman Berikutnya';
      size=6;
    }
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FlatButton(
          onPressed: ()async{
            WidgetHelper().loadingDialog(context);
            var res = await HandleHttp().postProvider("auth/otp",widget.data,context: context);
            if(res!=null){
              Navigator.pop(context);
              WidgetHelper().showFloatingFlushbar(context,"success", "kode otp berhasil dikirim");
              if(timeUpFlag){
                timeUpFlag=!timeUpFlag;
                timeCounter=10;
                widget.code = "${res['result']['otp']}";
                setState(() {});
                _timerUpdate();
              }
            }
          },
          child:config.MyFont.title(context: context,text:"${!timeUpFlag ?'$timeCounter detik':'kirim ulang otp'}",color: config.Colors.mainColors)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SecureCodeHelper(
          passLength: size,
          borderColor:  config.Colors.secondDarkColors,
          deskripsi:desc,
          passCodeVerify: (passcode) async {
            var code = widget.code.split('');
            for (int i = 0; i < code.length; i++) {
              if (passcode[i] != int.parse(code[i])) {
                return false;
              }
            }
            return true;
          },
          onSuccess: () async{
            widget.callback(context,true);
          }
      ),
    );
  }
}
