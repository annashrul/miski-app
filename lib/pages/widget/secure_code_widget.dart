import 'dart:async';

import 'package:flutter/material.dart';
import "package:miski_shop/config/app_config.dart" as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/secure_code_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/provider/handle_http.dart';

// ignore: must_be_immutable
class SecureCodeWidget extends StatefulWidget {
  Function(dynamic code) callback;
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
    String desc = 'Masukan kode OTP yang kami kirim melalui pesan ${widget.desc} untuk melanjutkan ke halaman berikutnya ${StringConfig.showCode?widget.code:''}';
    int size = 4;
    if(widget.param!='otp'){
      desc='Masukan kode aktivasi yang kami kirim melalui pesan ${widget.desc} untuk melanjutkan ke halaman berikutnya ${StringConfig.showCode?widget.code:''}';
      // size=6;
    }
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FlatButton(
          onPressed: ()async{
            if(timeUpFlag){
              WidgetHelper().loadingDialog(context);
              var res = await HandleHttp().postProvider("auth/otp",widget.data,context: context);
              if(res!=null){
                Navigator.pop(context);
                WidgetHelper().showFloatingFlushbar(context,"success", "kode ${widget.param} berhasil dikirim");
                if(timeUpFlag){
                  timeUpFlag=!timeUpFlag;
                  timeCounter=10;
                  widget.code = "${res['result']['otp_anying']}";
                  setState(() {});
                  _timerUpdate();
                }
              }
            }

          },
          child:config.MyFont.title(context: context,text:"${!timeUpFlag ?'$timeCounter detik':'kirim ulang kode ${widget.param}'}",color: config.Colors.mainColors)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SecureCodeHelper(
          passLength: size,
          borderColor:  config.Colors.secondDarkColors,
          deskripsi:desc,
          passCodeVerify: (passcode) async {
            String code='';
            for (int i = 0; i < passcode.length; i++) {
              code+= passcode[i].toString();
            }
            widget.callback(code);
            return false;
          },
          onSuccess: () async{
            // widget.callback(context,true);
          }
      ),
    );
  }
}
