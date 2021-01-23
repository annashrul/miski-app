import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/provinsi_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:netindo_shop/views/screen/onboarding_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';

class SplashScreen extends StatefulWidget {
  final mode;
  SplashScreen({this.mode});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final userHelper=UserHelper();
  final DatabaseConfig _db = new DatabaseConfig();
  Future loadData() async{
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    final countTable = await _db.queryRowCount(UserQuery.TABLE_NAME);
    print('##################### SPLASH SCREEN ######################');
    if(countTable==0){
      WidgetHelper().myPushRemove(context, OnboardingScreen());
    }
    else{
      final onBoarding= await userHelper.getDataUser('onboarding');
      final isLogin= await userHelper.getDataUser('is_login');
      print('##################### OBOARDING $onBoarding  ######################');
      print('##################### ISLOGIN $isLogin  ######################');

      if(onBoarding==null&&isLogin==null){
        WidgetHelper().myPushRemove(context, OnboardingScreen());
      }
      else{
        // WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2));

        if(onBoarding=='0'&&isLogin=='0'){
          WidgetHelper().myPushRemove(context, OnboardingScreen());
        }
        else if(onBoarding=='1'&&isLogin=='0'){
          WidgetHelper().myPushRemove(context, SigninScreen());
        }
        else{
          WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,mode:widget.mode));
        }

      }
    }
  }

  Future insertData()async{
    FunctionHelper().getSite();
    final countTableSite = await _db.queryRowCount(SiteQuery.TABLE_NAME);
    if(countTableSite<1){
      await _db.insert(SiteQuery.TABLE_NAME, {"onBoarding":"0","exitApp":"0","mode":"dark"});
    }
    loadData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    insertData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            WidgetHelper().loadingWidget(context),
          ],
        ),
      ),
    );
  }
}
