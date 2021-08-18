import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miski_shop/helper/function_helper.dart';

class AppConfig {
  BuildContext _context;
  double _height;
  double _width;
  double _heightPadding;
  double _widthPadding;

  AppConfig(_context) {
    this._context = _context;
    MediaQueryData _queryData = MediaQuery.of(this._context);
    _height = _queryData.size.height / 100.0;
    _width = _queryData.size.width / 100.0;
    _heightPadding = _height - ((_queryData.padding.top + _queryData.padding.bottom) / 100.0);
    _widthPadding = _width - (_queryData.padding.left + _queryData.padding.right) / 100.0;
  }

  double appHeight(double v) {
    return _height * v;
  }

  double appWidth(double v) {
    return _width * v;
  }

  double appVerticalPadding(double v) {
    return _heightPadding * v;
  }

  double appHorizontalPadding(double v) {
    return _widthPadding * v;
  }
}

class Colors {
  static const Color moneyColors = Color(0xFFff5722);
  static const Color mainColors = Color(0xFF9f8730);
  static const Color mainDarkColors = Color(0xFF9f8730);
  static const Color secondColors = Color(0xFF555f5e);
  static const Color secondDarkColors = Color(0xFFD3D3D3);
  static const Color accentColors = Color(0xFFADC4C8);
  static const Color accentDarkColors = Color(0xFFADC4C8);

  Color mainColor(double opacity) {
    return mainColors.withOpacity(opacity);
  }

  Color secondColor(double opacity) {
    return secondColors.withOpacity(opacity);
  }

  Color accentColor(double opacity) {
    return accentColors.withOpacity(opacity);
  }

  Color mainDarkColor(double opacity) {
    return mainDarkColors.withOpacity(opacity);
  }

  Color secondDarkColor(double opacity) {
    return secondDarkColors.withOpacity(opacity);
  }
  Color accentDarkColor(double opacity) {
    return accentDarkColors.withOpacity(opacity);
  }
}


class ColorsDarkMode  {
  static final backgroundColor = Color(0xFF2C2C2C);
  static final titleColor = Color(0xFF2C2C2C);
  static final contentColor = Color(0xFF2C2C2C);
}


class ColorsLightMode{
  static final backgroundColor = Color(0xFFE7F6F8);
  static final titleColor = Color(0xFF009DB5);
  static final contentColor = Color(0xFF04526B);
}
Color hexToColors(String hexString, {String alphaChannel = 'FF'}) {
  return Color(int.parse(hexString.replaceFirst('#', '0x$alphaChannel')));
}


class MyFont{
  static TextStyle textStyle = GoogleFonts.poppins();
  static style({BuildContext context,TextDecoration textDecoration,TextStyle style,Color color,double fontSize,FontWeight fontWeight}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return style.copyWith(
      decoration: textDecoration,
      fontWeight:fontWeight!=null?fontWeight:style.fontWeight,
      fontSize: scaler.getTextSize(fontSize!=null?fontSize:style.fontSize),
      color: color!=null?color:style.color,
    );
  }
  static core({
    BuildContext context,
    TextStyle themeStyle,
    String text,
    double fontSize,
    TextAlign textAlign = TextAlign.left,
    int maxLines=2,
    Color color,
    TextDecoration textDecoration,
    FontWeight fontWeight
  }){
    return RichText(
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        text: TextSpan(
          text:text,
          style: style(
            context: context,
            style: themeStyle,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            textDecoration: textDecoration
          )
        )
    );
  }

  static title({BuildContext context,TextDecoration textDecoration,TextAlign textAlign = TextAlign.left,String text,int maxLines=10,Color color,double fontSize,FontWeight fontWeight}){
    return core(
      textDecoration: textDecoration,
      context: context,
      themeStyle:  Theme.of(context).textTheme.headline1,
      fontSize:fontSize,
      textAlign: textAlign,
      maxLines: maxLines,
      color: color,
      text: text,
      fontWeight: fontWeight
    );
  }
  static subtitle({BuildContext context,TextStyle themeStyle,TextDecoration textDecoration,TextAlign textAlign = TextAlign.left,String text,int maxLines=10,Color color,double fontSize,FontWeight fontWeight=FontWeight.normal}){
    return core(
        textDecoration: textDecoration,
        context: context,
        themeStyle:  themeStyle!=null?themeStyle:Theme.of(context).textTheme.subtitle1,
        fontSize:fontSize,
        textAlign: textAlign,
        maxLines: maxLines,
        color: color,
        text: text,
        fontWeight: fontWeight

    );
  }

  static fieldStyle({BuildContext context,Color color,FontWeight fontWeight = FontWeight.w500}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return textStyle.copyWith(
        fontWeight:fontWeight,
        fontSize: scaler.getTextSize(11),
        color: color!=null?color:Theme.of(context).accentColor
    );

  }

  static toMoney(res){
    return FunctionHelper().formatter.format(int.parse(res));
  }

}

class ScreenScale{
  BuildContext context;
  ScreenScaler scaler;

  ScreenScale(_context){
    this.context = _context;
    this.scaler = ScreenScaler()..init(context);
  }
}