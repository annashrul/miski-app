import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:netindo_shop/views/screen/onboarding_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final userHelper=UserHelper();
  final DatabaseConfig _db = new DatabaseConfig();
  Future loadData() async{
    final countTableCategory = await _db.queryRowCount(CategoryQuery.TABLE_NAME);
    print("COUNT TABLE CATEGORY $countTableCategory");
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    final countTable = await _db.queryRowCount(UserQuery.TABLE_NAME);
    print("COUNT TABLE USER $countTable");
    if(countTable==0){
      WidgetHelper().myPushRemove(context, OnboardingScreen());
    }
    else{
      final onboarding= await userHelper.getDataUser('onboarding');
      final isLogin= await userHelper.getDataUser('is_login');
      final onsignalId= await userHelper.getDataUser('onsignal_id');
      print("=====> ISLOGIN $isLogin <=====");
      print("=====> ONBOARDING $onboarding <=====");
    //   print("=====> ONSIGNALID $onsignalId <=====");
      if(onboarding==null&&isLogin==null){
        WidgetHelper().myPushRemove(context, OnboardingScreen());
      }
      else{
        if(onboarding=='0'&&isLogin=='0'){
          WidgetHelper().myPushRemove(context, OnboardingScreen());
        }
        else if(onboarding=='1'&&isLogin=='0'){
          print("=====> SIGNUP <=====");
          WidgetHelper().myPushRemove(context, SigninScreen());
        }
        else if(onboarding=='1'&&isLogin=='1'){
          print("=====> HOME <=====");
          WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2));
        }
      }

    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
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
