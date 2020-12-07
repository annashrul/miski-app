import 'dart:async';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/screen_util_helper.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/helper/user_helper.dart';

class WidgetHelper{
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
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)), color:color),
      child: WidgetHelper().textQ(txt, 10,Colors.white,FontWeight.bold),
    );
  }


  void showFloatingFlushbar(BuildContext context,String param, String desc) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      padding: EdgeInsets.all(10),
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
        size: 28.0,
        color: SiteConfig().secondDarkColor,
      ),
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: param=='success'?Colors.blue[300]:Colors.red[300],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      messageText: textQ(desc,12,SiteConfig().secondDarkColor, FontWeight.bold),
    )..show(context);
  }
  myModal(BuildContext context,Widget child){
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
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

    // return Navigator.push(context, CupertinoPageRoute(builder: (context) => widget)).whenComplete(() => callback);
  }
  loadingDialog(BuildContext context,{title='tunggu sebentar'}){
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100.0),
            child: AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey), semanticsLabel: 'tunggu sebentar', backgroundColor: Colors.black),
                  SizedBox(width:10.0),
                  textQ(title, 12, Colors.grey,FontWeight.bold)
                  // RichText(text: TextSpan(text:'Tunggu Sebentar ...', style: TextStyle(fontWeight:FontWeight.bold,color:Theme.of(context).primaryColorDark, fontSize: 14)))
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
          CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey), semanticsLabel: 'tunggu sebentar', backgroundColor: Colors.black),
          SizedBox(width:10.0),
          textQ("tunggu sebentar ...", 12,Colors.grey,FontWeight.bold)
          // RichText(text: TextSpan(text:'Tunggu Sebentar ...', style: TextStyle(fontWeight:FontWeight.bold,color:Theme.of(context).primaryColorDark, fontSize: 14)))
        ],
      ),
    );
  }
  textQ(String txt,double size,Color color,FontWeight fontWeight,{TextDecoration textDecoration,TextAlign textAlign = TextAlign.left,int maxLines=2}){
    return RichText(
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        text: TextSpan(
          text:txt,
          style: TextStyle(decoration: textDecoration, fontSize:size,color: color,fontFamily:SiteConfig().fontStyle,fontWeight:fontWeight,),
        )
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
  titleQ(String txt,{Color color=Colors.white,String param, Function callback,Icon icon, TextAlign textAlign=TextAlign.left}){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 0),
        leading: icon,
        title: WidgetHelper().textQ(txt, 12, color,FontWeight.bold,textAlign: textAlign),
        trailing: param==''?Text(''):InkWell(
            child: WidgetHelper().textQ("$param", 12, color,FontWeight.bold),
            onTap: callback
        ),
      ),
    );
  }
  appBarWithButton(BuildContext context, title,Function callback,List<Widget> widget,{Brightness brightness=Brightness.light}){
    ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
    ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false)..init(context);
    print("TEMA ${brightness.index}");
    return  AppBar(
      elevation: 1.0,
      backgroundColor: brightness.index==1?Colors.white:Color(0xFF2C2C2C), // status bar color
      brightness: brightness,
      title:textQ(title,16,brightness.index==1?SiteConfig().secondColor:Colors.white,FontWeight.bold),
      leading: IconButton(
        icon: new Icon(UiIcons.return_icon, color:brightness.index==1?SiteConfig().secondColor:Colors.white),
        onPressed: (){
          callback();
        },
      ),
      actions:widget,// status bar brightness
    );
  }
  myAppBar(BuildContext context, title,Function callback,List<Widget> widget){
    ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
    ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false)..init(context);
    return AppBar(
      automaticallyImplyLeading: false,
      leading: new IconButton(
        icon: new Icon(UiIcons.return_icon, color: Theme.of(context).hintColor),
        onPressed: callback,
      ),
      backgroundColor: Colors.white,
      elevation: 1.0,
      title: textQ(title,16,Theme.of(context).hintColor,FontWeight.bold),
      actions:widget,
    );
  }

  myAppBarNoButton(BuildContext context,String title,List<Widget> widget,{Brightness brightness=Brightness.light}){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: brightness.index==0?SiteConfig().darkMode:Colors.white, // status bar color
      brightness: brightness,
      title:textQ(title,16,brightness.index==0?Colors.white:SiteConfig().secondColor,FontWeight.bold),
      elevation: 0,
      leading:Padding(
        padding: EdgeInsets.only(left:20.0,top:10.0,bottom:10.0),
        child:  CircleAvatar(
          backgroundImage:NetworkImage('http://ptnetindo.com:6700/images/customer/default.png',scale: 10.0),
        ),
      ),
      actions:widget,
    );

  }
  pembatas(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 2.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:  BorderRadius.circular(10.0),
      ),
    );
  }

  buttonQ(BuildContext context,Function callback,String title,{isColor=false,Color color}){
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

  myPress(Function callback,Widget child,{Color color=Colors.black38}){
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

}