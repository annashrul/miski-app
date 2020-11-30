import 'package:flutter/material.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/secure_code_helper.dart';


class SecureCodeScreen extends StatefulWidget {
  final Function(BuildContext context, bool isTrue) callback;
  final String code;
  final String param;
  final String desc;
  SecureCodeScreen({this.callback,this.code,this.param,this.desc});
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: widget.param=='otp'?SecureCodeHelper(
          showFingerPass: false,
          forgotPin: 'Lupa OTP ? Klik Disini',
          title: "Keamanan",
          passLength: 4,
          bgImage: "assets/images/bg.jpg",
          borderColor:  Colors.grey,
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
