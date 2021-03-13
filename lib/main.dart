import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/views/screen/auth/login_screen.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:netindo_shop/views/screen/splash_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:firebase_core/firebase_core.dart';

StreamController<bool> isLightTheme = StreamController();

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider<ThemeModel>(
      create: (context) => ThemeModel(),
      child: MyApp(),
    ),
  );
  // runApp(MyApp());
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
  // bool site=false;
  // Future getSite()async{
  //   final res = await FunctionHelper().getSite();
  //   setState(() {
  //     site = res;
  //   });
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // insertData();
    // getSite();
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
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: Provider.of<ThemeModel>(context).currentTheme,
      theme: ThemeData(
        dialogBackgroundColor: Colors.white,
        // splashColor: Colors.black38,
        // highlightColor: Colors.black38,
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
    // return StreamBuilder<bool>(
    //     initialData: true,
    //     stream: isLightTheme.stream,
    //     builder: (context, snapshot) {
    //       return MaterialApp(
    //           theme: snapshot.data ? ThemeData.light() : ThemeData.dark(),
    //           debugShowCheckedModeBanner: false,
    //           home:SplashScreen()
    //       );
    //     }
    // );

  }

}


var darkTheme = ThemeData.dark();
var lightTheme= ThemeData.light();
enum ThemeType { Light, Dark }

class ThemeModel extends ChangeNotifier {
  ThemeData currentTheme = darkTheme;
  ThemeType _themeType = ThemeType.Dark;
  toggleTheme() async{
    if (_themeType == ThemeType.Dark) {
      await FunctionHelper().storeSite(true);
      currentTheme = lightTheme.copyWith(
        scaffoldBackgroundColor: SiteConfig().darkMode,
        backgroundColor: SiteConfig().darkMode,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: SiteConfig().darkMode,
        primaryTextTheme: TextTheme(
          headline1: TextStyle(color: Colors.white)
        ),
        brightness: Brightness.dark,
        accentColor: config.Colors().mainColor(1),
        focusColor: config.Colors().accentColor(1),
        hintColor: config.Colors().secondColor(1),
      );
      _themeType = ThemeType.Light;
      return notifyListeners();
    }

    if (_themeType == ThemeType.Light) {
      await FunctionHelper().storeSite(false);
      currentTheme = darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Colors.white,
        primaryTextTheme: TextTheme(
            headline1: TextStyle(color: SiteConfig().darkMode)
        ),
        brightness:Brightness.light,
        accentColor: config.Colors().mainColor(1),
        focusColor: config.Colors().accentColor(1),
        hintColor: config.Colors().secondColor(1),
      );
      _themeType = ThemeType.Dark;
      return notifyListeners();
    }
  }
}