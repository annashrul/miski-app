import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netindo_shop/config/site_config.dart';




TextStyle myText = GoogleFonts.poppins();

ThemeData appPrimaryTheme() => ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  accentColor: SiteConfig().mainColor,
  scaffoldBackgroundColor: Colors.white,
  buttonColor: SiteConfig().mainColor,
  cardColor: Colors.white,
  snackBarTheme: SnackBarThemeData(
    backgroundColor: SiteConfig().mainColor,
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    elevation: 1.0,
    actionsIconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  dividerColor: Colors.grey[300],
  dividerTheme: DividerThemeData(thickness: 0.5),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.black,
    unselectedLabelColor: Colors.grey,
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: myText.copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
    ),
    unselectedLabelStyle: myText.copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
    ),
  ),
  textTheme: TextTheme(
    headline3: myText.copyWith(
      fontSize: 42.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    headline4: myText.copyWith(
      fontSize: 25.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    headline5: myText.copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    headline6: myText.copyWith(
      fontSize: 20.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    subtitle1:myText.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    subtitle2: myText.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),

    bodyText1: myText.copyWith(
      fontSize: 15.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyText2: myText.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    button: myText.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  ),
);
headeLine3(BuildContext context,String txt,{TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=12.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.headline3.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
headeLine4(BuildContext context,String txt,{TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=11.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.headline4.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
headeLine5(BuildContext context,String txt,{TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=10.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.headline5.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
headeLine6(BuildContext context,String txt,{TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=9.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.headline6.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
subtitle1(BuildContext context,String txt,{TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=9.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.subtitle1.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
subtitle2(BuildContext context,String txt,{TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=8.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.subtitle2.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
bodyText1(BuildContext context,String txt,{int maxLines=10,TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=9.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.bodyText1.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
bodyText2(BuildContext context,String txt,{TextAlign textAlign=TextAlign.left,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=9.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}
button(BuildContext context,String txt,{TextAlign textAlign=TextAlign.center,Color colors=Colors.black,FontWeight fontWeight=FontWeight.normal,double fontSize=12.0}){
  ScreenScaler scaler = ScreenScaler()..init(context);
  return RichText(
      maxLines: 10,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      text: TextSpan(
        text:txt,
        style: Theme.of(context).textTheme.button.copyWith(
            color: colors,
            fontWeight: fontWeight,
            fontSize: scaler.getTextSize(fontSize)
        ),
      )
  );
}

