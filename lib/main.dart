import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/database_config.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/model/cart/cart_model.dart';
import 'package:miski_shop/provider/address_provider.dart';
import 'package:miski_shop/provider/auth_provider.dart';
import 'package:miski_shop/provider/cart_provider.dart';
import 'package:miski_shop/provider/channel_payment_provider.dart';
import 'package:miski_shop/provider/chat_provider.dart';
import 'package:miski_shop/provider/favorite_provider.dart';
import 'package:miski_shop/provider/group_provider.dart';
import 'package:miski_shop/provider/notification_provider.dart';
import 'package:miski_shop/provider/product_provider.dart';
import 'package:miski_shop/provider/promo_provider.dart';
import 'package:miski_shop/provider/room_chat_provider.dart';
import 'package:miski_shop/provider/slider_provider.dart';
import 'package:miski_shop/provider/tenant_provider.dart';
import 'package:miski_shop/provider/user_provider.dart';
import 'package:miski_shop/route_generator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
  ChangeNotifierProvider<SliderProvider>(create: (_) => SliderProvider()),
  ChangeNotifierProvider<PromoProvider>(create: (_) => PromoProvider()),
  ChangeNotifierProvider<GroupProvider>(create: (_) => GroupProvider()),
  ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
  ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider()),
  ChangeNotifierProvider<AddressProvider>(create: (context) => AddressProvider()),
  ChangeNotifierProvider<ChannelPaymentProvider>(create: (context) => ChannelPaymentProvider()),
  ChangeNotifierProvider<NotificationProvider>(create: (context) => NotificationProvider()),
  ChangeNotifierProvider<ChatProvider>(create: (context) => ChatProvider()),
  ChangeNotifierProvider<RoomChatProvider>(create: (context) => RoomChatProvider()),
  ChangeNotifierProvider<TenantProvider>(create: (context) => TenantProvider()),
  ChangeNotifierProvider<FavoriteProvider>(create: (context) => FavoriteProvider()),
];
void  main()  async {
  runApp(
    MultiProvider(
      providers:providers,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseConfig _db = new DatabaseConfig();

  @override
  void initState() {
    super.initState();
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };
    OneSignal.shared.init(StringConfig.oneSignalId, iOSSettings: settings);
    _db.openDB();

  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
    TextStyle style = config.MyFont.textStyle;

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
          textSelectionColor: Color(0xFF252525),
          unselectedWidgetColor: Colors.black26,
          dialogBackgroundColor: Color(0xFF2C2C2C),
          bottomSheetTheme: BottomSheetThemeData(backgroundColor: Color(0xFF252525),modalBackgroundColor: Color(0xFF252525)),
          textTheme: TextTheme(
            button: style.copyWith(color: Color(0xFF252525)),
            headline1: style.copyWith(fontSize: 10.0, fontWeight: FontWeight.bold,color: config.Colors().secondDarkColor(1)),
            headline2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.normal, color: Colors.grey[600]),
            headline3: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1)),
            headline4: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w300, color: config.Colors().mainDarkColor(1)),
            headline5: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w200, color: config.Colors().secondDarkColor(1)),
            subtitle1: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
            subtitle2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w500, color: config.Colors().mainDarkColor(1)),
            bodyText1: style.copyWith(fontSize: 9.0, color: config.Colors().secondDarkColor(1)),
            bodyText2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w600, color: config.Colors().secondDarkColor(1)),
            caption: style.copyWith(fontSize: 14.0, color: config.Colors().secondDarkColor(0.7)),
          ),
        ),
        theme: ThemeData(
          primaryColor: Colors.white,
          brightness: Brightness.light,
          accentColor: config.Colors().mainColor(1),
          focusColor: config.Colors().accentColor(1),
          hintColor: config.Colors().secondColor(1),
          textSelectionColor: Colors.grey[200],
          unselectedWidgetColor: Colors.grey[300],
          bottomSheetTheme: BottomSheetThemeData(backgroundColor:Colors.white,modalBackgroundColor:Colors.white),
          textTheme: TextTheme(
            button: style.copyWith(color: Colors.white),
            headline1: style.copyWith(fontSize: 10.0, fontWeight: FontWeight.bold,color: config.Colors().secondColor(1)),
            headline2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.bold, color: config.Colors.secondColors),
            headline3: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1)),
            headline4: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w300, color: config.Colors().mainColor(1)),
            headline5: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w200, color: config.Colors().secondColor(1)),
            subtitle1: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
            subtitle2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w500, color: config.Colors().mainColor(1)),
            bodyText1: style.copyWith(fontSize: 9.0, color: config.Colors().secondDarkColor(1)),
            bodyText2: style.copyWith(fontSize: 9.0, fontWeight: FontWeight.w600, color: config.Colors().secondColor(1)),
            caption: style.copyWith(fontSize: 9.0, color:Colors.grey),
          ),
        ),
        builder: (BuildContext context, Widget child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 0.8),
            child: child,
          );
        },
      );
  }
}

