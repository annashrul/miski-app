import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/route_generator.dart';
import 'package:netindo_shop/views/screen/splash_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main(){
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseConfig _db = new DatabaseConfig();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
    TextStyle style = GoogleFonts.robotoCondensed();
    // ScreenScaler scaler = ScreenScaler()..init(context);

    return MaterialApp(
      title: 'n-shop',
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        primaryColor: Color(0xFF252525),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF2C2C2C),
        accentColor: config.Colors().mainDarkColor(1),
        hintColor: config.Colors().secondDarkColor(1),
        focusColor: config.Colors().accentDarkColor(1),
        textTheme: TextTheme(
          button: style.copyWith(color: Color(0xFF252525)),
          headline1: style.copyWith(fontSize: 10.0, fontWeight: FontWeight.w500,color: config.Colors().secondDarkColor(1)),
          headline2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1)),
          headline3: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1)),
          headline4: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w300, color: config.Colors().mainDarkColor(1)),
          headline5: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w200, color: config.Colors().secondDarkColor(1)),
          subtitle1: style.copyWith(fontSize: 10.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
          subtitle2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w500, color: config.Colors().mainDarkColor(1)),
          bodyText1: style.copyWith(fontSize: 9.0, color: config.Colors().secondDarkColor(1)),
          bodyText2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
          caption: style.copyWith(fontSize: 9.0, color: config.Colors().secondDarkColor(0.7)),
        ),
      ),
      theme: ThemeData(
        primaryColor: Colors.white,
        brightness: Brightness.light,
        accentColor: config.Colors().mainColor(1),
        focusColor: config.Colors().accentColor(1),
        hintColor: config.Colors().secondColor(1),
        textTheme: TextTheme(
          button: style.copyWith(color: Colors.white),
          headline1: style.copyWith(fontSize: 10.0, fontWeight: FontWeight.w400,color: config.Colors().secondColor(1)),
          headline2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1)),
          headline3: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1)),
          headline4: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w300, color: config.Colors().mainColor(1)),
          headline5: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w200, color: config.Colors().secondColor(1)),
          subtitle1: style.copyWith(fontSize: 10.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
          subtitle2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w500, color: config.Colors().mainColor(1)),
          bodyText1: style.copyWith(fontSize: 9.0, color: config.Colors().secondColor(1)),
          bodyText2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
          caption: style.copyWith(fontSize: 9.0, color: config.Colors().secondColor(0.7)),
        ),
      ),
    );
    return MaterialApp(
      title:"NSHOP",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dialogBackgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: SiteConfig().fontStyle,
        primaryColor: Colors.white,
        brightness:Brightness.light,
        accentColor: config.Colors().mainColor(1),
        focusColor: config.Colors().accentColor(1),
        hintColor: config.Colors().secondColor(1),
      ),
      home:  SplashScreen(),
    );
  }
}

