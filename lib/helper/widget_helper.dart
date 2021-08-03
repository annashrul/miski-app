import 'dart:async';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/screen_util_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

class WidgetHelper{
  rating(String rating){
    return  RatingBar.builder(
      itemSize: 15.0,
      initialRating: double.parse(rating),
      direction: Axis.horizontal,
      itemCount: 5,
      itemPadding: EdgeInsets.only(right: 4.0),
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.red,
            );
          case 1:
            return Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.redAccent,
            );
          case 2:
            return Icon(
              Icons.sentiment_neutral,
              color: Colors.amber,
            );
          case 3:
            return Icon(
              Icons.sentiment_satisfied,
              color: Colors.lightGreen,
            );
          case 4:
            return Icon(
              Icons.sentiment_very_satisfied,
              color: Colors.green,
            );
          default:
            return Container();
        }
      },
      onRatingUpdate:null,
    );
  }


  animShakeWidget(BuildContext context,Widget child,{bool enable=true}){

    return ShakeAnimatedWidget(
        enabled: enable,
        duration: Duration(milliseconds: 1500),
        shakeAngle: Rotation.deg(z: 10),
        curve: Curves.linear,
        child:child
    );
  }
  animScaleWidget(BuildContext context,Widget child,{bool enable=true}){
    return ScaleAnimatedWidget.tween(
      enabled: true,
      duration: Duration(milliseconds: 600),
      scaleDisabled: 0.5,
      scaleEnabled: 1,
      //your widget
      child: child,
    );
  }
  void myRefresh(Key key,Widget widget, Function callback){
    LiquidPullToRefresh(
      child: widget,
      backgroundColor:SiteConfig().mainColor,
      color: Colors.white,
      key: key,
      onRefresh: callback,
      showChildOpacityTransition: false,
    );
  }

  myStatus(BuildContext context, int param){
    ScreenScaler scaler = ScreenScaler()..init(context);
    Color color;
    String txt="";
    if(param==0){
      color = Colors.red;
      txt = "Belum dibayar";
    }
    if(param==1){
      color = Color(0xFFF7AD17);
      txt = "Menunggu konfirmasi";
    }
    if(param==2){
      color = Color(0xFF1cbac8);
      txt = "Barang sedang dikemas";
    }
    if(param==3){
      color = Colors.greenAccent;
      txt = "Dikirim";
    }
    if(param==4){
      color = Colors.green;
      txt = "Selesai";
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: color)
      ),
      child: WidgetHelper().textQ(txt, scaler.getTextSize(9),color,FontWeight.bold),
    );
  }


  void showFloatingFlushbar(BuildContext context,String param, String desc) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin:EdgeInsets.only(top: 50),
      borderRadius: 0,
      backgroundGradient: LinearGradient(
        colors: param=='success'?[SiteConfig().mainColor, SiteConfig().mainColor]:[Colors.red, Colors.red],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      icon: Icon(
        param=='success'?Icons.check_circle_outline:Icons.info_outline,
        color:config.Colors.secondDarkColors,
      ),
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: param=='success'?Colors.blue[300]:Colors.red[300],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      messageText: config.MyFont.title(context: context,text:desc,color: config.Colors.secondDarkColors),

    )..show(context);
  }
  myModal(BuildContext context,Widget child){
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: child,
        )
    );
  }
  myRating(int rating){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0,0.0,0.0,0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(10, (index) {
          if(index < rating){
            return Flexible(child: Icon(Icons.star,color: Colors.amberAccent,size: 20));
          }else{
            return Flexible(child: Icon(Icons.star_border));
          }
        }),
      ),
    );

  }
  fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
  myPushRemove(BuildContext context, Widget widget){
    return  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        new CupertinoPageRoute(builder: (BuildContext context)=>widget), (Route<dynamic> route) => false
    );
  }
  myPush(BuildContext context, Widget widget){
    return Navigator.push(context, CupertinoPageRoute(builder: (context) => widget));
  }
  myPushAndLoad(BuildContext context, Widget widget,Function callback){
    return Navigator.push(context, CupertinoPageRoute(builder: (context) => widget)).whenComplete(callback);
  }
  loadingDialog(BuildContext context,{Color color=Colors.black,title='tunggu sebentar'}){
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100.0),
            child: AlertDialog(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitFadingGrid(color:SiteConfig().mainColor, shape: BoxShape.circle),
                  // SpinKitCubeGrid(size: 80.0, color: Constant().mainColor),
                  // textQ(title,14,Constant().mainColor,FontWeight.bold,letterSpacing: 5.0)
                ],
              ),

            )
        );
      },
    );
  }
  loadingWidget(BuildContext context,{Color color=Colors.black}){
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SpinKitFadingGrid(color:  SiteConfig().mainColor, shape: BoxShape.circle),
          // CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey), semanticsLabel: 'tunggu sebentar', backgroundColor: Colors.black),
          // SizedBox(width:10.0),
          // textQ("tunggu sebentar ...", 12,Colors.grey,FontWeight.bold)
          // RichText(text: TextSpan(text:'Tunggu Sebentar ...', style: TextStyle(fontWeight:FontWeight.bold,color:Theme.of(context).primaryColorDark, fontSize: 14)))
        ],
      ),
    );
  }
  baseLoading(BuildContext context,Widget widget){
    return Shimmer.fromColors(
      baseColor: Theme.of(context).unselectedWidgetColor,
      highlightColor: Colors.grey[100],
      enabled: true,
      child: widget,
    );
  }
  shimmer({BuildContext context,double width}){
    final scaler = config.ScreenScale(context).scaler;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).unselectedWidgetColor,
      highlightColor: Colors.grey[100],
      enabled: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).textSelectionColor,
        ),
        height: scaler.getHeight(1),
        width: scaler.getWidth(width),
      ),
    );
  }

  textQ(String txt,double size,Color color,FontWeight fontWeight,{double letterSpacing=0,TextDecoration textDecoration,TextAlign textAlign = TextAlign.left,int maxLines=2}){
    TextStyle myText = GoogleFonts.robotoCondensed();
    return RichText(
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        text: TextSpan(
          text:txt,
          style: myText.copyWith(
              letterSpacing:letterSpacing,
              decoration: textDecoration,
              fontSize:size,
              color: color,
              fontWeight:fontWeight
          )
          // style: TextStyle(letterSpacing:letterSpacing,decoration: textDecoration, fontSize:size,color: color,fontFamily:SiteConfig().fontStyle,fontWeight:fontWeight,),
        )
    );
  }
  notifOneBtnDialog(BuildContext context,title,desc,Function callback1,{titleBtn1='Oke'}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              title:textQ(title,scaler.getTextSize(9),LightColor.black,FontWeight.bold),
              content:textQ(desc,scaler.getTextSize(9),LightColor.black,FontWeight.normal,maxLines:100),
              actions: <Widget>[
                FlatButton(
                  onPressed:callback1,
                  child:textQ(titleBtn1,scaler.getTextSize(10),LightColor.black,FontWeight.bold),
                ),
              ],
            ),
          );
        }
    );
  }
  notifDialog(BuildContext context,title,desc,Function callback1, Function callback2,{titleBtn1='Batal',titleBtn2='Oke'}){
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              title:textQ(title,14,Colors.black,FontWeight.bold),
              content:textQ(desc,12,Colors.black,FontWeight.bold),
              // content:RichText(overflow: TextOverflow.ellipsis, text: TextSpan(style: Theme.of(context).textTheme.caption, children: [TextSpan(text:widget.wrongPassContent),],),),
              actions: <Widget>[
                FlatButton(
                  onPressed:callback1,
                  child:textQ(titleBtn1,12,Colors.black,FontWeight.bold),
                ),
                FlatButton(
                  onPressed:callback2,
                  child:textQ(titleBtn2,12,Colors.black,FontWeight.bold),
                )
              ],
            ),
          );
        }
    );
  }
  titleQ(BuildContext context,String txt,{FontWeight fontWeight = FontWeight.normal,EdgeInsetsGeometry padding=const EdgeInsets.symmetric(horizontal: 10, vertical: 0),Color color=Colors.white,String param, Function callback,IconData icon, TextAlign textAlign=TextAlign.left}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return InkWell(
      onTap:callback,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: LightColor.black,
                  size: scaler.getTextSize(12),
                ),
                SizedBox(width: scaler.getWidth(1)),
                WidgetHelper().textQ(txt, scaler.getTextSize(10), LightColor.black,fontWeight,textAlign: textAlign)
              ],
            ),
          ),
          param==''?Text(''):Align(
            alignment: Alignment.centerRight,
            child: Icon(Octicons.triangle_right,color:LightColor.black,size: scaler.getTextSize(12)),
          )
        ],
      ),
    );
  }

  appBarWithButton(BuildContext context, title,Function callback,List<Widget> widget,{String param="",Brightness brightness=Brightness.light}){
    ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
    ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false)..init(context);
    ScreenScaler scaler = ScreenScaler()..init(context);
    return  AppBar(
      titleSpacing: 0.0,
      automaticallyImplyLeading: false,
      toolbarHeight: scaler.getHeight(4),
      elevation: 0.0,
      brightness: brightness,
      title:Row(
        children: [
          myRipple(
            callback: ()=>param=="default"?Navigator.pop(context):callback(),
              isRadius: true,
              radius: 100,
              child:Container(
                padding: scaler.getPadding(0.5, 2),
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        child: Icon(AntDesign.back,color: Theme.of(context).hintColor)
                    ),
                  ],
                ),
              )
          ),
          SizedBox(width: scaler.getWidth(1)),
          config.MyFont.title(context: context,text:title)
        ],
      ),
      actions:widget,// status bar brightness
    );
  }
  myAppBarNoButton(BuildContext context,String title,List<Widget> widget){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return AppBar(
      toolbarHeight: scaler.getHeight(4),
      automaticallyImplyLeading: false,
      title:textQ(title.toUpperCase(),scaler.getTextSize(10),LightColor.black,FontWeight.bold),
      elevation: 0,
      actions:widget,
    );

  }
  pembatas(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 5.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:  BorderRadius.circular(10.0),
      ),
    );
  }
  buttonQ(BuildContext context,Function callback,String title,{isColor=false,Color color}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return FlatButton(
      shape: StadiumBorder(),
      color:SiteConfig().mainColor,
      onPressed: callback,
      child: Center(
        child: WidgetHelper().textQ(title,scaler.getTextSize(10),Colors.white, FontWeight.bold,letterSpacing: 2),
      )
    );
    return InkWell(
      onTap: callback,
      child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: !isColor?SiteConfig().mainColor:color,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
              ]),
          child: Center(
            child: WidgetHelper().textQ(title,14,Colors.white, FontWeight.bold),
          )
      ),
    );
  }
  myRipple({Widget child,Function callback,bool isRadius=true,double radius=10}){
    return TouchRippleEffect(
      backgroundColor: Colors.transparent,
      borderRadius: BorderRadius.circular(isRadius?radius:0),
      rippleColor: Color(0xFFD3D3D3),
      onTap: callback,
      child: child,

    );
  }
  myPress(Function callback,Widget child,{Color color=Colors.black26}){
    return InkWell(
      highlightColor:color,
      splashColor:color,
      borderRadius: BorderRadius.circular(10),
      onTap: ()async{
        await Future.delayed(Duration(milliseconds: 90));
        callback();
      },
      child: child,
    );
  }
  myImage(String img,double width, double height, BoxFit boxFit){
    return CachedNetworkImage(
      width: width,
      height: height,
      fit: boxFit,
      imageUrl: img,
      progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
  baseImage(String img,{double width, double height,BoxFit fit = BoxFit.contain}){

    return CachedNetworkImage(
      imageUrl:img,
      width: width,
      height: height,
      fit:fit,
      placeholder: (context, url) => Image.asset(SiteConfig().localAssets+'logo.jpeg',fit:BoxFit.contain),
      errorWidget: (context, url, error) => Image.asset(SiteConfig().localAssets+'logo.jpeg',fit:BoxFit.contain),
    );
  }
  textSpaceBetween(BuildContext context,String title,String desc,{FontWeight fontWeightTitle = FontWeight.normal,FontWeight fontWeightDesc = FontWeight.normal,MainAxisAlignment mainAxisAlignment=MainAxisAlignment.spaceBetween,Color titleColor=Colors.black,Color descColor}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Row(
      mainAxisAlignment:mainAxisAlignment,
      children: [
        WidgetHelper().textQ(title,scaler.getTextSize(9),titleColor, fontWeightTitle),
        WidgetHelper().textQ(desc,scaler.getTextSize(9),descColor, fontWeightDesc),
      ],
    );
  }
  iconAppbar({BuildContext context,Function callback,IconData icon,String title=''}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      margin: scaler.getMarginLTRB(0, 0, 1, 0),
      child: WidgetHelper().myRipple(
          isRadius: true,
          radius: 100,
          callback: callback,
          child: Container(
            padding: scaler.getPadding(0,2.5),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: icon!=null?Icon(icon,color:Theme.of(context).hintColor):config.MyFont.title(context: context,text: title)
                ),
              ],
            ),
          )
      ),
    );
  }

  iconAppBarBadges({BuildContext context,Function callback,IconData icon,bool isActive=true}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      margin: scaler.getMarginLTRB(0, 0, 0, 0),
      child: myRipple(
        callback:callback,
        isRadius: true,
        radius: 100,
        child: Container(
          padding: scaler.getPadding(0,2.5),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Positioned(
                left: scaler.getTextSize(9),
                top: scaler.getTextSize(7),
                child: Container(
                  decoration: BoxDecoration(color: isActive?Colors.red:Colors.transparent, borderRadius: BorderRadius.all(Radius.circular(10))),
                  constraints: BoxConstraints(minWidth: scaler.getTextSize(8), maxWidth: scaler.getTextSize(8), minHeight: scaler.getTextSize(8), maxHeight: scaler.getTextSize(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}