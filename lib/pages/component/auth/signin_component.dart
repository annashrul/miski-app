import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/auth/login_model.dart';
import 'package:netindo_shop/pages/component/auth/signup_component.dart';
import 'package:netindo_shop/pages/widget/secure_code_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import "package:netindo_shop/config/app_config.dart" as config;
import 'package:onesignal_flutter/onesignal_flutter.dart';
class SignInComponent extends StatefulWidget {
  @override
  _SignInComponentState createState() => _SignInComponentState();
}

class _SignInComponentState extends State<SignInComponent> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _nohpController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nohpFocus = FocusNode();
  final DatabaseConfig _helper = new DatabaseConfig();
  bool isOtp=true;
  String type = "",name = '', image;
  _callBack(BuildContext context,bool isTrue,Map<String, Object> data)async{
    if(isTrue){
      final countTbl = await _helper.queryRowCount(UserQuery.TABLE_NAME);
      if(countTbl>0){
        await _helper.deleteAll(UserQuery.TABLE_NAME);
      }
      await _helper.insert(UserQuery.TABLE_NAME,data);
      Navigator.pushNamedAndRemoveUntil(context,"/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
    }
  }

  Future login(BuildContext context,String type) async{
    WidgetHelper().loadingDialog(context);
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    String onesignalUserId = status.subscriptionStatus.userId;
    String email,pass,nohp;
    if(_emailController.text!=''&&_passwordController.text!=''){
      setState(() {
        email = _emailController.text;
        pass = _passwordController.text;
        nohp = '0';
      });
    }
    else{
      setState(() {
        email = '-';
        pass = '-';
        nohp = _nohpController.text;
      });
    }
    final data={
      'email': '$email',
      'password': '$pass',
      'deviceid': onesignalUserId,
      'nohp': nohp,
      'type': type,
      'type_otp': isOtp?'whatsapp':'sms',
    };
    // final res = await HandleHttp().postProvider("auth", {
    //   "nomor":"$nohp",
    //   "type":"$type",
    //   "isForgot":false,
    //   "isLogin":true
    // });
    // if(res!=null){
    //
    // }
    var res = await HandleHttp().postProvider('auth', data,context: context);
    if(res!=null){
      var result = LoginModel.fromJson(res);
      if(result.status=='success'){
        final dataUser={
          "id_user":result.result.id.toString(),
          "token":result.result.token.toString(),
          "nama":result.result.nama.toString(),
          "email":result.result.email.toString(),
          "status":result.result.status.toString(),
          "alamat":result.result.alamat.toString(),
          "jenis_kelamin":result.result.jenisKelamin.toString(),
          "tgl_ultah":result.result.tglUltah.toString(),
          "tlp":result.result.tlp.toString(),
          "foto":result.result.foto.toString().replaceAll(' ',''),
          "biografi":result.result.biografi.toString(),
          "last_login":result.result.lastLogin.toString(),
          "is_login":"1",
          "onboarding":"1",
          "exit_app":"0",
          "onesignal_id":onesignalUserId,
        };
        if(type=='otp'){
          WidgetHelper().myPush(context, SecureCodeWidget(
            callback:(context,isTrue){_callBack(context, true,dataUser);},
            code:result.result.otp,
            param: 'otp',
            desc: isOtp?'WhatsApp':'SMS',
            data: {
              "nomor":"${result.result.tlp}",
              "type":"${isOtp?'whatsapp':'sms'}",
              "nama":"${result.result.nama}"
            },
          ));
        }
        else{
          Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
        }
      }
      else{
        WidgetHelper().showFloatingFlushbar(context, 'failed',result.msg);
      }
    }
  }
  Future validasi(BuildContext context,String types) async{


    if(types=='otp'){
      if(_nohpController.text==''){
        _nohpFocus.requestFocus();
        WidgetHelper().showFloatingFlushbar(context, 'failed','no handphone tidak boleh kosong');
        await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      }else{
        login(context,types);
      }
    }
    else{
      final regEmail=FunctionHelper().isEmail(_emailController.text);
      if(_emailController.text==''){
        WidgetHelper().showFloatingFlushbar(context, 'failed','email tidak boleh kosong');
        await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
        _emailFocus.requestFocus();
      }
      else if(regEmail==false){
        WidgetHelper().showFloatingFlushbar(context, 'failed','format email tidak sesuai');

        // WidgetHelper().notifNoAction(_scaffoldKey, context, 'format email tidak sesuai');
        await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
        _emailFocus.requestFocus();
      }
      else if(_passwordController.text==''){
        WidgetHelper().showFloatingFlushbar(context, 'failed','password tidak boleh kosong');

        // WidgetHelper().notifNoAction(_scaffoldKey, context, 'password tidak boleh kosong');
        await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
        _passwordFocus.requestFocus();
      }
      else{
        login(context,types);
      }
    }

  }



  @override
  void initState()  {
    _helper.openDB();
    FunctionHelper().getSession(StringConfig.loginType).then((value){
      setState(() {
        type = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _emailPasswordWidget(context),
                      SizedBox(height: scaler.getHeight(1)),
                      Container(
                        child: WidgetHelper().myRipple(
                          callback: (){
                            isOtp=!isOtp;
                            setState(() {});
                          },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                config.MyFont.title(context: context,text: "Kirim otp via ${isOtp?'whatsapp':'sms'}"),
                                Container(
                                    padding: scaler.getPaddingLTRB(0, 0, 0, 0),
                                    margin: scaler.getMarginLTRB(0, 0, 0, 0),
                                    width: scaler.getWidth(15),
                                    height: scaler.getHeight(2),
                                    child: Switch(
                                      activeTrackColor: config.Colors.mainColors,
                                      inactiveTrackColor:config.Colors.accentDarkColors,
                                      inactiveThumbColor:config.Colors.mainColors,
                                      activeColor: config.Colors.mainDarkColors,
                                      value: isOtp,
                                      onChanged: (value) =>setState(()=>isOtp=value),
                                    )
                                ),
                                // SizedBox(height:typeOtp==false?5.0:0.0),
                              ],
                            )
                        ),
                      ),
                      SizedBox(height: scaler.getHeight(2)),
                      _submitButton(context),
                      if(type!="otp")SizedBox(height: scaler.getHeight(2)),
                      if(type!="otp")Container(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            config.MyFont.title(context: context,text: "Lupa password ?",color: Theme.of(context).textTheme.headline1.color),
                            FlatButton(
                                onPressed: (){},
                                child:config.MyFont.title(context: context,text: "klik disini",color: config.Colors.mainColors)
                            )
                          ],
                        ),
                      ),
                      // _createAccountLabel(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          config.MyFont.title(context: context,text: "belum punya akun ?"),
          FlatButton(
              onPressed: (){
                WidgetHelper().myPush(context, SignUpComponent());
              },
              child:config.MyFont.title(context: context,text: "daftar disini",color: config.Colors.mainColors)
          )
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Widget _submitButton(BuildContext context) {
    return WidgetHelper().myRipple(
      callback:(){
        validasi(context,type);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color:config.Colors.mainColors
        ),
        child:config.MyFont.title(context: context,text: "Masuk",color: config.Colors.secondDarkColors),
        // child: WidgetHelper().textQ("Login",14,Colors.white,FontWeight.bold,letterSpacing: 10),
      )
    );
  }


  Widget _emailPasswordWidget(BuildContext context) {
    return type=='otp'?Column(
      children: <Widget>[
        _entryField(context,"No Handphone",TextInputType.number,TextInputAction.done,_nohpController,_nohpFocus),
      ],
    ):
    Column(
      children: <Widget>[
        _entryField(context,"Email",TextInputType.emailAddress,TextInputAction.done,_emailController,_emailFocus),
        _entryField(context,"Password",TextInputType.text,TextInputAction.done,_passwordController,_passwordFocus, isPassword: true),
      ],
    );
  }
  Widget _entryField(BuildContext context,String title,TextInputType textInputType,TextInputAction textInputAction, TextEditingController textEditingController, FocusNode focusNode, {bool isPassword = false}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
              style: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color),
              focusNode: focusNode,
              controller: textEditingController,
              obscureText: isPassword,
              decoration: InputDecoration(
                hintText: title,
                hintStyle: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color.withOpacity(0.2))),
                focusedBorder:UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color)),
              ),
              keyboardType: textInputType,
              textInputAction: textInputAction,
              inputFormatters: <TextInputFormatter>[
                if(textInputType == TextInputType.number) LengthLimitingTextInputFormatter(13),
                if(textInputType == TextInputType.number) WhitelistingTextInputFormatter.digitsOnly
              ],
              onSubmitted: (e){
                validasi(context,type);
              },

          )
        ],
      ),
    );
  }
}
