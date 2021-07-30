import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/provinsi_model.dart';
import 'package:netindo_shop/model/tenant/list_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/auth/login_screen.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:netindo_shop/views/screen/onboarding_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final userHelper=UserHelper();
  final DatabaseConfig _db = new DatabaseConfig();
  ListTenantModel listTenantModel;
  Future loadData() async{
    var result= await FunctionHelper().getConfig();
    print('##################### SPLASH SCREEN ${result["multitenant"]} ######################');
    SharedPreferences sess = await SharedPreferences.getInstance();
    sess.setBool("isTenant", true);
    if(result["multitenant"]){
      sess.setString("namaTenant",result["tenant"][["nama"]]);
      sess.setString("idTenant",result["tenant"][["id"]]);
      sess.setBool("isTenant", false);
    }
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
        if(onBoarding=='0'&&isLogin=='0'){
          WidgetHelper().myPushRemove(context, OnboardingScreen());
        }
        else if(onBoarding=='1'&&isLogin=='0'){
          WidgetHelper().myPushRemove(context, LoginScreen());
        }
        else{

          WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
        }

      }
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    // insertData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            WidgetHelper().loadingWidget(context,color: SiteConfig().mainColor),
          ],
        ),
      ),
    );
  }
}
