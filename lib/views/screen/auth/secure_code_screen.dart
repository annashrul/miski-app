import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/secure_code_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/provider/base_provider.dart';


class SecureCodeScreen extends StatefulWidget {
  final Function(BuildContext context, bool isTrue) callback;
  String code;
  final String param;
  final String desc;
  final Map<String, Object> data;
  // final Widget child;

  SecureCodeScreen({this.callback,this.code,this.param,this.desc,this.data});
  @override
  _SecureCodeScreenState createState() => _SecureCodeScreenState();
}

class _SecureCodeScreenState extends State<SecureCodeScreen> {
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
      setState(() {
        timeCounter--;
      });
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
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      bottomNavigationBar:!timeUpFlag?Container(
        padding: EdgeInsets.all(10.0),

        child: FlatButton(
            color: SiteConfig().mainColor,
            onPressed: ()async{
              WidgetHelper().showFloatingFlushbar(context,"failed","proses pengiriman otp sedang berlangsung");
            },
            child: WidgetHelper().textQ("$timeCounter detik", 12,Colors.white,FontWeight.bold)
        ),
      ):Container(
        padding: EdgeInsets.all(10.0),
        child: FlatButton(
            color: SiteConfig().mainColor,
            onPressed: ()async{
              print(timeUpFlag);
              WidgetHelper().loadingDialog(context);
              var res = await BaseProvider().postProvider("auth/otp",widget.data);
              if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
                Navigator.pop(context);
                setState(() {
                  timeUpFlag=true;
                });
                WidgetHelper().showFloatingFlushbar(context,"failed","Terjadi kesalahan jaringan");
              }
              else{
                print("result ${res['result']['otp']}");
                Navigator.pop(context);
                if(timeUpFlag){
                  setState(() {
                    timeUpFlag=!timeUpFlag;
                    timeCounter=10;
                    widget.code = "${res['result']['otp']}";
                  });
                  _timerUpdate();
                }
                else{
                  print('false');
                }
              }

            },
            child: WidgetHelper().textQ("${!timeUpFlag ?'$timeCounter detik':'kirim ulang otp'}", 12,Colors.white,FontWeight.bold)
        ),
      ),
      body: widget.param=='otp'?SecureCodeHelper(
          showFingerPass: false,
          forgotPin: 'Lupa OTP ? Klik Disini',
          title: "Keamanan",
          passLength: 4,
          bgImage: "assets/images/bg.jpg",
          borderColor:  SiteConfig().mainColor,
          showWrongPassDialog: true,
          wrongPassContent: "OTP Tidak Sesuai",
          wrongPassTitle: "Opps!",
          wrongPassCancelButtonText: "Batal",
          deskripsi: 'Masukan Kode OTP Yang Kami Kirim Melalui Pesan ${widget.desc} Untuk Melanjutkan Ke Halaman Berikutnya ${SiteConfig().showCode?widget.code:''}',
          passCodeVerify: (passcode) async {
            print(passcode);
            print(widget.code.split(''));
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
      ):SecureCodeHelper(
          showFingerPass: true,
          forgotPin: 'Lupa PIN ? Klik Disini',
          title: "Keamanan",
          passLength: 4,
          bgImage: "assets/images/bg.jpg",
          borderColor: Colors.black,
          showWrongPassDialog: true,
          wrongPassContent: "Pin Tidak Sesuai",
          wrongPassTitle: "Opps!",
          wrongPassCancelButtonText: "Batal",
          deskripsi: 'Masukan PIN Anda Untuk Melanjutkan Ke Halaman Berikutnya',
          passCodeVerify: (passcode) async {
            print(passcode);
            print(widget.code.split(''));
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
