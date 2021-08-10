import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/screen_util_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/auth/otp_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/pages/component/auth/signin_component.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/screen/auth/secure_code_screen.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SignUpComponent extends StatefulWidget {
  @override
  _SignUpComponentState createState() => _SignUpComponentState();
}

class _SignUpComponentState extends State<SignUpComponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _showPassword = false,_showConfPassword=false;
  var _noHpController = TextEditingController();
  var _nameController = TextEditingController();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _confPasswordController = TextEditingController();
  final FocusNode _noHpFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confPasswordFocus = FocusNode();

  String isErrorName='',isErrorPhone='',isErrorEmail='',isErrorPassword='',isErrorConfPassword='';
  String type='',jenisKelamin='pria';
  bool _switchValue=true;
  Future create() async{
    print("############################## ANYING ############################");
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    String onesignalUserId = status.subscriptionStatus.userId;
    final data={
      'nama'          : _nameController.text,
      'alamat'        : '-',
      'tlp'           : _noHpController.text,
      'email'         : _emailController.text,
      'password'      : _passwordController.text,
      'jenis_kelamin' : jenisKelamin=='pria'?'0':'1',
      'platform'      : 'Email',
      'deviceid'      : onesignalUserId,
      'type'          : type,
      'type_otp'      : _switchValue?'whatsapp':'sms',
    };
    var res = await BaseProvider().postProvider("auth/register", data);
    setState(() {
      Navigator.pop(context);
    });

    if(res == 'TimeoutException' || res == 'SocketException'){
      WidgetHelper().notifDialog(context,'Oops','Terjadi kesalahan server',(){
        Navigator.pop(context);
      },(){Navigator.pop(context);});
    }
    else if(res=='Email telah terdaftar'){
      WidgetHelper().showFloatingFlushbar(context, 'failed','Email telah terdaftar');
    }
    else{
      print("############################## ${res is General} ############################");
      if(res is General){
        General result = res;
        WidgetHelper().showFloatingFlushbar(context, 'failed','${result.msg} telah terdaftar');
        print("############################## ${result.status} ############################");

      }
      else{
        WidgetHelper().notifDialog(context,'Berhasil','Pendaftaran berhasil dilakukan',(){
          Navigator.pop(context);
        },(){
          Navigator.pop(context);
          WidgetHelper().myPushRemove(context,SignInComponent());
        });
      }
    }
  }
  Future save() async{
    String nama=_nameController.text;
    String nohp=_noHpController.text;
    String email=_emailController.text;
    String password=_passwordController.text;
    String confPassword=_confPasswordController.text;
    final regEmail = FunctionHelper().isEmail(_emailController.text);
    if(nama==''){
      WidgetHelper().showFloatingFlushbar(context,'failed', 'nama tidak boleh kosong');
      await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      _nameFocus.requestFocus();
    }
    else if(nohp==''){
      WidgetHelper().showFloatingFlushbar(context,'failed', 'no handphone tidak boleh kosong');
      await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      _noHpFocus.requestFocus();
    }
    else if(email==''){
      WidgetHelper().showFloatingFlushbar(context,'failed', 'email tidak boleh kosong');
      await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      _emailFocus.requestFocus();
    }
    else if(regEmail==false){
      WidgetHelper().showFloatingFlushbar(context,'failed', 'format email tidak sesuai');
      await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      _emailFocus.requestFocus();
    }
    else if(password==''){
      WidgetHelper().showFloatingFlushbar(context,'failed', 'kata sandi tidak boleh kosong');
      await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      _passwordFocus.requestFocus();
    }
    else if(confPassword==''){
      WidgetHelper().showFloatingFlushbar(context,'failed', 'konfirmasi kata sandi tidak boleh kosong');
      await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      _confPasswordFocus.requestFocus();
    }
    else if(confPassword!=password){
      WidgetHelper().showFloatingFlushbar(context,'failed', 'kata sandi tidak cocok');
      await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      _confPasswordFocus.requestFocus();
    }
    else{
      WidgetHelper().loadingDialog(context);
      final data= {
        'nomor': _noHpController.text,
        'type': type!='otp'?'email':_switchValue?'whatsapp':'sms',
        'nama': _nameController.text,
      };
      var res = await HandleHttp().postProvider('auth/otp', data,context: context);

      if(res!=null){
        var result =OtpModel.fromJson(res);
        Navigator.of(context).pop();
        if(type=='otp'){
          WidgetHelper().myPush(context, SecureCodeScreen(callback:_callBack,code:result.result.otp,param: 'otp',desc: _switchValue?'WhatsApp':'SMS'));
        }
        else{
          WidgetHelper().loadingDialog(context);
          create();
        }
      }
    }
  }
  _callBack(BuildContext context,bool isTrue)async{
    if(isTrue){
      WidgetHelper().loadingDialog(context);
      create();
    }
  }
  bool isLoading=false;
  bool isError=false;


  @override
  void initState()  {
    isLoading=true;
    super.initState();
    FunctionHelper().getSession(StringConfig.loginType).then((value){
      setState(() {
        type = value;
      });
    });
  }

  Widget _submitButton(BuildContext context,{label="Daftar"}) {
    return WidgetHelper().myRipple(
        callback:(){
          save();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color:config.Colors.mainColors
          ),
          child:config.MyFont.title(context: context,text:label,color: config.Colors.secondDarkColors),
          // child: WidgetHelper().textQ("Login",14,Colors.white,FontWeight.bold,letterSpacing: 10),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
    ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false);
    final height = MediaQuery.of(context).size.height;
    final scaler=config.ScreenScale(context).scaler;
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
                top: -height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: BezierContainer()),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListView(
                padding:scaler.getPaddingLTRB(2, 15, 2,2),
                children: [
                  _entryField(context,"Nama Lengkap",TextInputType.name,TextInputAction.next,_nameController,_nameFocus,onSubmitted: (term){WidgetHelper().fieldFocusChange(context, _nameFocus, _noHpFocus);}),
                  _entryField(context,"No Handphone",TextInputType.number,TextInputAction.next,_noHpController,_noHpFocus,onSubmitted: (term){WidgetHelper().fieldFocusChange(context, _noHpFocus, _emailFocus);}),
                  _entryField(context,"Email",TextInputType.emailAddress,TextInputAction.next,_emailController,_emailFocus,onSubmitted: (term){WidgetHelper().fieldFocusChange(context, _emailFocus, _passwordFocus);}),
                  _entryField(context,"Kata Sandi",TextInputType.visiblePassword,TextInputAction.next,_passwordController,_passwordFocus,isPassword: true,onSubmitted: (term){WidgetHelper().fieldFocusChange(context, _passwordFocus, _confPasswordFocus);}),
                  _entryField(context,"Ulangi Kata Sandi",TextInputType.visiblePassword,TextInputAction.done,_confPasswordController,_confPasswordFocus,isPassword: true),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        config.MyFont.title(context: context,text:"Jenis kelamin",fontWeight: FontWeight.normal,color: Theme.of(context).textTheme.headline1.color),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding:scaler.getPaddingLTRB(0, 0, 0, 1),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Theme.of(context).textTheme.headline1.color.withOpacity(0.2)))
                          ),
                          child: DropdownButton<String>(
                            style: config.MyFont.style(
                              context: context,
                              style:  Theme.of(context).textTheme.headline1,
                              color: Theme.of(context).textTheme.headline1.color,
                              fontWeight: FontWeight.normal
                            ),
                            isDense: true,
                            isExpanded: true,
                            value: jenisKelamin,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 20,
                            underline: SizedBox(),
                            onChanged: (value) {
                              setState(() {
                                jenisKelamin = value;
                              });
                            },
                            items: <String>['pria', 'wanita'].map<DropdownMenuItem<String>>((String value) {
                              return new DropdownMenuItem<String>(
                                value: value,
                                child:config.MyFont.title(context: context,text:value,fontWeight: FontWeight.normal,color: Theme.of(context).textTheme.headline1.color),
                              );
                            }).toList(),

                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: WidgetHelper().myRipple(
                        callback: (){
                          _switchValue=!_switchValue;
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            config.MyFont.title(context: context,text: "Kirim otp via ${_switchValue?'whatsapp':'sms'}"),
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
                                  value: _switchValue,
                                  onChanged: (value) =>setState(()=>_switchValue=value),
                                )
                            ),
                            // SizedBox(height:typeOtp==false?5.0:0.0),
                          ],
                        )
                    ),
                  ),
                  SizedBox(height: 20),
                  _submitButton(context,label:"Daftar"),
                ],
              ),
            ),
          ],
        ),
      bottomNavigationBar: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          config.MyFont.title(context: context,text: "sudah punya akun ?"),
          FlatButton(
              onPressed: (){
                WidgetHelper().myPush(context, SignInComponent());
              },
              child:config.MyFont.title(context: context,text: "masuk disini",color: config.Colors.mainColors)
          )
        ],
      ),
    );
  }


  Widget _entryField(BuildContext context,String title,TextInputType textInputType,TextInputAction textInputAction, TextEditingController textEditingController, FocusNode focusNode, {bool isPassword = false,Function(String e) onSubmitted}) {
    return TextField(
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
      onSubmitted: (e)=>onSubmitted(e),

    );
  }

}
