import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:netindo_shop/views/screen/splash_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final DatabaseConfig _db = new DatabaseConfig();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // insertData();
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };
    OneSignal.shared.init(SiteConfig().oneSignalId, iOSSettings: settings);
    _db.openDB();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // darkTheme: ThemeData(
      //   fontFamily: SiteConfig().fontStyle,
      //   primaryColor: Colors.white,
      //   brightness: Brightness.dark,
      //   scaffoldBackgroundColor: Color(0xFF2C2C2C),
      //   accentColor: config.Colors().mainDarkColor(1),
      //   hintColor: config.Colors().secondDarkColor(1),
      //   focusColor: config.Colors().accentDarkColor(1),
      //   textTheme: TextTheme(
      //     button: TextStyle(color: Color(0xFF252525)),
      //     headline: TextStyle(fontSize: 20.0, color: config.Colors().secondDarkColor(1)),
      //     display1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
      //     display2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
      //     display3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().mainDarkColor(1)),
      //     display4: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w300, color: config.Colors().secondDarkColor(1)),
      //     subhead: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: config.Colors().secondDarkColor(1)),
      //     title: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: config.Colors().mainDarkColor(1)),
      //     body1: TextStyle(fontSize: 12.0, color: config.Colors().secondDarkColor(1)),
      //     body2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
      //     caption: TextStyle(fontSize: 12.0, color: config.Colors().secondDarkColor(0.7)),
      //   ),
      // ),
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: SiteConfig().fontStyle,
        primaryColor: Colors.white,
        brightness: Brightness.light,
        accentColor: config.Colors().mainColor(1),
        focusColor: config.Colors().accentColor(1),
        hintColor: config.Colors().secondColor(1),
        // textTheme: TextTheme(
        //   button: TextStyle(color: Colors.white),
        //   headline: TextStyle(fontSize: 20.0, color: config.Colors().secondColor(1)),
        //   display1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
        //   display2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
        //   display3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().mainColor(1)),
        //   display4: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w300, color: config.Colors().secondColor(1)),
        //   subhead: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: config.Colors().secondColor(1)),
        //   title: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: config.Colors().mainColor(1)),
        //   body1: TextStyle(fontSize: 12.0, color: config.Colors().secondColor(1)),
        //   body2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
        //   caption: TextStyle(fontSize: 12.0, color: config.Colors().secondColor(0.6)),
        // ),
      ),
      home:  SplashScreen(),
    );

  }

}