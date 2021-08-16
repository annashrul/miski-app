import 'dart:async';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenComponent extends StatefulWidget {
  @override
  _SplashScreenComponentState createState() => _SplashScreenComponentState();
}

class _SplashScreenComponentState extends State<SplashScreenComponent> {
  final userHelper = UserHelper();
  final DatabaseConfig _db = new DatabaseConfig();
  Future loadData() async {
    SharedPreferences sess = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    final countTable = await _db.queryRowCount(UserQuery.TABLE_NAME);
    final result = await FunctionHelper().getConfig();
    sess.setString(StringConfig.loginType, result["type"]);
    sess.setBool(StringConfig.isTenant, true);
    if (!result["multitenant"]) {
      print('##################### TENANT $result ######################');
      sess.setStringList("tenant", [
        result["tenant"]["id"],
        result["tenant"]["nama"],
        result["tenant"]["email"],
        result["tenant"]["telp"],
        result["tenant"]["alamat"],
        result["tenant"]["logo"]
      ]);
      sess.setBool(StringConfig.isTenant, false);
    }
    if (countTable == 0) {
      Navigator.pushNamedAndRemoveUntil(
          context, "/${StringConfig.onBoarding}", (route) => false);
      print(
          '##################### USER BARU INSTALL APLIKASI ######################');
    } else {
      final onBoarding = await userHelper.getDataUser(StringConfig.onboarding);
      final isLogin = await userHelper.getDataUser(StringConfig.is_login);

      print("onboarding $onBoarding");
      print("onboarding $isLogin");

      if (onBoarding == null && isLogin == null) {
        Navigator.pushNamedAndRemoveUntil(
            context, "/${StringConfig.onBoarding}", (route) => false);
        print(
            '##################### USER SUDAH INSTALL APLIKASI DAN BELUM LOGIN ######################');
      } else {
        if (onBoarding == '0' && isLogin == '0') {
          // if(onBoarding!='0'&&isLogin!='0'){
          Navigator.pushNamedAndRemoveUntil(
              context, "/${StringConfig.onBoarding}", (route) => false);
          print(
              '##################### USER SUDAH INSTALL APLIKASI DAN BELUM LOGIN ######################');
        } else if (onBoarding == '1' && isLogin == '0') {
          // else if(onBoarding!='1'&&isLogin!='0'){
          Navigator.pushNamedAndRemoveUntil(
              context, "/${StringConfig.signIn}", (route) => false);
          print(
              '##################### USER MELAKUKAN LOGOUT DAN KEMBALI BUKA APLIKASI ######################');
        } else {
          print(
              '##################### USER MASUK KEHALAMAN UTAMA APLIKASI ######################');
          Navigator.pushNamedAndRemoveUntil(
              context, "/${StringConfig.main}", (route) => false,
              arguments: StringConfig.defaultTab);
        }
      }
    }
  }

  AssetImage assetImage;
  @override
  void initState() {
    super.initState();
    loadData();
    assetImage = AssetImage("assets/img/splash.gif");
  }

 

  @override
  void didChangeDependencies() {
    precacheImage(assetImage, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(image: assetImage)
        ),
      ),
    );
  }

}
