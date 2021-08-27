import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/screen_util_helper.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:shimmer/shimmer.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

class WidgetHelper{

  static qr({BuildContext context,String data}){
    final scale = config.ScreenScale(context).scaler;
    print(data);
    return PrettyQr(
      image: AssetImage(StringConfig.localAssets+"ic_launcher.png"),
      typeNumber: 3,
      size: scale.getHeight(30),
      data: data,
      errorCorrectLevel: 1,
      roundEdges: true,
      elementColor: config.Colors.mainColors,
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

  myStatus(BuildContext context, int param){
    String txt="";
    if(param==0){
      txt = "Belum dibayar";
    }
    if(param==1){
      txt = "Menunggu konfirmasi";
    }
    if(param==2){
      txt = "Barang sedang dikemas";
    }
    if(param==3){
      txt = "Dikirim";
    }
    if(param==4){
      txt = "Selesai";
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).textTheme.caption.color)
      ),
      child:config.MyFont.subtitle(context: context,text:txt,fontSize: 8,fontWeight: FontWeight.normal),
      // child: WidgetHelper().textQ(txt, scaler.getTextSize(9),color,FontWeight.bold),
    );
  }
 showFloatingFlushbar(BuildContext context,String param, String desc) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,

      margin:EdgeInsets.only(top: 50),
      borderRadius: 0,
      backgroundGradient: LinearGradient(
        colors: param=='success'?[config.Colors.mainColors, config.Colors.mainColors]:[Colors.red, Colors.red],
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
      messageText: config.MyFont.title(context: context,text:desc,color: config.Colors.secondDarkColors,fontSize: 8),
    )..show(context);
  }
  myModal(BuildContext context,Widget child){
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: child,
        )
    );
  }
  myRating({BuildContext context,String rating="0"}){
    final scaler = config.ScreenScale(context).scaler;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: scaler.getTextSize(10),
        ),
        config.MyFont.subtitle(context: context,text:'${double.parse(rating).toStringAsFixed(1)}',fontSize: 8)
      ],
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
                  SpinKitFadingGrid(color:config.Colors.mainColors, shape: BoxShape.circle),
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
          SpinKitFadingGrid(color: config.Colors.mainColors, shape: BoxShape.circle),
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
  shimmer({BuildContext context,double width,double height=1}){
    final scaler = config.ScreenScale(context).scaler;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).unselectedWidgetColor,
      highlightColor: Colors.grey[100],
      enabled: true,
      child: Container(
        margin: scaler.getMarginLTRB(0, 0, 0, 0.1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).textSelectionColor,
        ),
        height: scaler.getHeight(height),
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
        )
    );
  }
  notifOneBtnDialog(BuildContext context,title,desc,Function callback1,{titleBtn1='Oke'}){
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: AlertDialog(
              title:config.MyFont.title(context: context,text:title,color:config.Colors.mainColors),
              content:config.MyFont.title(context: context,text:desc,fontSize: 9),
              actions: <Widget>[
                FlatButton(
                  onPressed:callback1,
                  child:config.MyFont.title(context: context,text:titleBtn1,color:config.Colors.mainColors)
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
              title:config.MyFont.title(context: context,text:title,color:config.Colors.mainColors),
              content:config.MyFont.title(context: context,text:desc,fontSize: 9),

              // title:config.MyFont.title(context: context,text:title,color:config.Colors.mainColors),
              // content:config.MyFont.title(context: context,text:desc,color:Colors.black,fontSize: 9),
              actions: <Widget>[
                FlatButton(
                  onPressed:callback1,
                  child:config.MyFont.title(context: context,text:titleBtn1)
                  // child:textQ(titleBtn1,12,Colors.black,FontWeight.bold),
                ),
                FlatButton(
                  onPressed:callback2,
                    child:config.MyFont.title(context: context,text:titleBtn2,color:config.Colors.mainColors)
                )
              ],
            ),
          );
        }
    );
  }
  titleQ(BuildContext context,String txt,{Color colorTitle,double radius=10,FontWeight fontWeight=FontWeight.bold,EdgeInsetsGeometry padding,String param="", Function callback,IconData icon,double fontSize,String image="",IconData iconAct=UiIcons.play_button,String subtitle=""}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return myRipple(
      radius: radius,
      callback:callback,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: padding==null?scaler.getPadding(0,0):padding,
            child: Row(
              children: [
                if(image!=""||icon!=null)image!=""?Container(
                  height: scaler.getHeight(3),
                  width: scaler.getWidth(7.5),
                  child: baseImage(image,fit: BoxFit.contain),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                ):icons(ctx: context,icon: icon,color: colorTitle),
                if(image!=""||icon!=null)SizedBox(width: scaler.getWidth(1.5)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    config.MyFont.title(context: context,text:txt,fontSize: fontSize,fontWeight:fontWeight,color: colorTitle==null?Theme.of(context).textTheme.headline1.color:colorTitle),
                    if(subtitle!="") Container(
                      child: config.MyFont.subtitle(context: context,text:subtitle,fontSize: 8,color: Theme.of(context).textTheme.caption.color),
                    )
                  ],
                )
              ],
            ),
          ),
          param==''?Text(''):Align(
            alignment: Alignment.centerRight,
            child:icons(ctx: context,icon:iconAct==null?UiIcons.play_button:iconAct),
          )
        ],
      ),
    );
  }
  appBarWithButton(BuildContext context, title,Function callback,List<Widget> widget,{IconData icon=UiIcons.return_icon,String param="",Brightness brightness=Brightness.light}){
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
                        child: Icon(icon,color: Theme.of(context).hintColor)
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
      title: config.MyFont.title(context: context,text:title),
      elevation: 0,
      actions:widget,
    );

  }
  myRipple({Widget child,Function callback,bool isRadius=true,double radius=10}){
    return TouchRippleEffect(
      backgroundColor: Colors.transparent,
      borderRadius: BorderRadius.circular(radius!=null?radius:0),
      rippleColor: Color(0xFFD3D3D3),
      onTap: callback,
      child: child,

    );
  }
  baseImage(String img,{double width, double height,BoxFit fit = BoxFit.contain,BoxShape shape}){
    return shape!=null?ClipOval(
      child: Image.network(
        img,
        height: height,
        width: width,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
          return Center(child: Icon(Icons.error));
        },
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            child: child,
            opacity: 1,
            duration: const Duration(seconds: 3),
            curve: Curves.easeOut,
          );
        },
        loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null ?
              loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes: null,
            ),
          );
        },
      ),
    ):Image.network(
      img,
      height: height,
      width: width,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
        return Center(child: Icon(Icons.error));
      },
      frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          child: child,
          opacity: 1,
          duration: const Duration(seconds: 3),
          curve: Curves.easeOut,
        );
      },
      loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null ?
            loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes: null,
          ),
        );
      },
    );


  }
  iconAppbar({BuildContext context,Function callback,IconData icon,String title='',Color color}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      margin: scaler.getMarginLTRB(0, 0, 0, 0),
      child: WidgetHelper().myRipple(
          isRadius: true,
          radius: 100,
          callback: callback,
          child: Container(
            padding: scaler.getPadding(0,2),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: icon!=null?Icon(icon,color:color!=null?color:Theme.of(context).hintColor):config.MyFont.title(context: context,text: title)
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
  chip({BuildContext ctx,Widget child,EdgeInsetsGeometry padding, Color colors}){
    final scaler = config.ScreenScale(ctx).scaler;
    return Container(
      padding: padding==null?scaler.getPaddingLTRB(2,0.5,2,0.5):padding,
      decoration: BoxDecoration(
        color: colors==null?Theme.of(ctx).primaryColor.withOpacity(0.9):colors,
        boxShadow: [BoxShadow(color: Theme.of(ctx).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: child,
    );
  }
  imageUser({BuildContext context,String img, isUpdate=false}){
    print("image user $img");
    final scaler = config.ScreenScale(context).scaler;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(img)
        ),
        // baseImage(img, height: scaler.getHeight(3), width: scaler.getWidth(6),shape: BoxShape.circle),
        if(isUpdate)Icon(Icons.camera_alt,size: 10,)
      ],
    );
  }
  icons({BuildContext ctx,IconData icon,Color color}){
    final scaler = config.ScreenScale(ctx).scaler;
    return Icon(icon,size: scaler.getTextSize(StringConfig.iconSize),color: color==null?Theme.of(ctx).hintColor:color);
  }
  Widget field({BuildContext context,String title,TextInputType textInputType = TextInputType.text,TextInputAction textInputAction=TextInputAction.done, TextEditingController textEditingController, FocusNode focusNode,bool readOnly=false,int maxLines=1,Function(String) submited,Function() onTap,Function(String e) onChange}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            readOnly: readOnly,
            maxLines: maxLines,
            style:config.MyFont.style(context: context,style: Theme.of(context).textTheme.bodyText2,fontWeight: FontWeight.normal,fontSize: 10),
            focusNode: focusNode,
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: title,
              hintStyle: config.MyFont.style(context: context,style: Theme.of(context).textTheme.bodyText2,fontSize: 10,fontWeight: FontWeight.normal,color: Theme.of(context).textTheme.headline1.color.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color.withOpacity(0.2))),
              focusedBorder:UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color)),
            ),
            keyboardType: textInputType,
            textInputAction: textInputAction,
            onTap: ()=>onTap(),
            onSubmitted: (e)=>submited(e),
            onChanged: (e)=>onChange(e),
            inputFormatters: <TextInputFormatter>[
              if(textInputType == TextInputType.number) LengthLimitingTextInputFormatter(13),
              if(textInputType == TextInputType.number) FilteringTextInputFormatter.digitsOnly
            ],
          )
        ],
      ),
    );
  }


}