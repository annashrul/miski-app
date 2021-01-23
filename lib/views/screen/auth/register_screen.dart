import 'package:flutter/material.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/screen_util_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/auth/otp_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/auth/login_screen.dart';
import 'package:netindo_shop/views/screen/auth/secure_code_screen.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
          WidgetHelper().myPushRemove(context,LoginScreen());
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
      final data= {
        'nomor': _noHpController.text,
        'type': type!='otp'?'email':_switchValue?'whatsapp':'sms',
        'nama': _nameController.text,
      };
      var res = await BaseProvider().postProvider('auth/otp', data);
      if(res == 'TimeoutException' || res == 'SocketException'){
        WidgetHelper().showFloatingFlushbar(context,'failed', 'Terjadi kesalahan server');
      }
      else{
        if(res is General){
          General result=res;
          WidgetHelper().showFloatingFlushbar(context,'failed', result.msg);
        }
        else{
          var result =OtpModel.fromJson(res);
          if(result.status=='success'){
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
  Future getConfig() async{
    var result= await FunctionHelper().getConfig();
    if(result==SiteConfig().errSocket||result==SiteConfig().errTimeout){
      setState(() {
        isError = true;
        isLoading=false;
      });
    }
    else{
      print("RESULT CONFIG $result");
      setState(() {
        type = result;
        isLoading=false;
      });
    }


  }

  @override
  void initState()  {
    isLoading=true;
    getConfig();
    super.initState();
  }

  Widget _entryField(String title,TextInputType textInputType,TextInputAction textInputAction, TextEditingController textEditingController, FocusNode focusNode, {bool isPassword = false,Function(String) function}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WidgetHelper().textQ(title,12,Colors.black.withOpacity(0.6),FontWeight.bold),
          SizedBox(
            height: 10,
          ),
          TextField(
              style: TextStyle(letterSpacing:3,fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color:Colors.black.withOpacity(0.6)),
              focusNode: focusNode,
              controller: textEditingController,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true
              ),
              keyboardType: textInputType,
              textInputAction: textInputAction,
            onSubmitted:function,
          )
        ],
      ),
    );
  }
  Widget _submitButton() {
    return WidgetHelper().myPress((){
      save();
      // validasi(type);
    },Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [SiteConfig().mainColor,SiteConfig().mainDarkColor]
          )
      ),
      child: WidgetHelper().textQ("Register",14,Colors.white,FontWeight.bold,letterSpacing: 10),
    ));
  }
  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.grey[200],
                thickness: 1,
              ),
            ),
          ),
          WidgetHelper().textQ("OR",14,Colors.grey,FontWeight.bold,letterSpacing: 10),
          // Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.grey[200],
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
  Widget _facebookButton(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: WidgetHelper().myPress((){WidgetHelper().myPushRemove(context,LoginScreen());},Container(
        decoration: BoxDecoration(
          color: SiteConfig().mainDarkColor,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(5),
              topRight: Radius.circular(5)),
        ),
        alignment: Alignment.center,
        child:  WidgetHelper().textQ("Login",14,Colors.white,FontWeight.bold,letterSpacing: 10),
      )),
    );
  }
  Widget _emailPasswordWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        _entryField("Nama Lengkap",TextInputType.name,TextInputAction.next,_nameController,_nameFocus,function:  (term){
          WidgetHelper().fieldFocusChange(context, _nameFocus, _noHpFocus);
        }),
        _entryField("No Handphone",TextInputType.number,TextInputAction.next,_noHpController,_noHpFocus,function:  (term){
          WidgetHelper().fieldFocusChange(context, _noHpFocus, _emailFocus);
        }),
        _entryField("Email",TextInputType.emailAddress,TextInputAction.next,_emailController,_emailFocus,function:  (term){
          WidgetHelper().fieldFocusChange(context, _emailFocus, _passwordFocus);
        }),
        _entryField("Kata Sandi",TextInputType.visiblePassword,TextInputAction.next,_passwordController,_passwordFocus,isPassword: true,function:  (term){
          WidgetHelper().fieldFocusChange(context, _passwordFocus, _confPasswordFocus);
        }),
        _entryField("Ulangi Kata Sandi",TextInputType.visiblePassword,TextInputAction.done,_confPasswordController,_confPasswordFocus,isPassword: true),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidgetHelper().textQ("Jenis Kelamin",12,Colors.black.withOpacity(0.6),FontWeight.bold),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(15.0),
                color: Colors.grey[200],
                child: DropdownButton<String>(
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
                      child: Row(
                        children: [
                          WidgetHelper().textQ(value,12,Colors.grey,FontWeight.bold)
                        ],
                      ),
                    );
                  }).toList(),

                ),
              )
            ],
          ),
        )
        // _entryField("Password", isPassword: true),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
    ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Scrollbar(child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // SizedBox(height: height * .2),
                      // _title(),
                      SizedBox(height: 40),
                      _emailPasswordWidget(context),
                      SizedBox(height: 20),
                      type!='otp'?Text(''):WidgetHelper().myPress((){
                        setState(() {
                          _switchValue=!_switchValue;
                        });
                      },Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetHelper().textQ("Kirim otp via ${_switchValue?'whatsapp':'sms'}", 12, Colors.black.withOpacity(0.6),FontWeight.bold),
                          SizedBox(
                              width: 70,
                              height: 10,
                              child: Switch(
                                activeTrackColor: SiteConfig().mainDarkColor,
                                inactiveTrackColor:SiteConfig().mainDarkColor,
                                inactiveThumbColor:SiteConfig().mainDarkColor,
                                activeColor: SiteConfig().mainDarkColor,
                                value: _switchValue,
                                onChanged: (value) {
                                  setState(() {
                                    _switchValue = value;
                                  });
                                },
                              )
                          ),
                          // SizedBox(height:typeOtp==false?5.0:0.0),
                        ],
                      )),
                      SizedBox(height: 20),
                      _submitButton(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.centerRight,
                      ),
                      _divider(),
                      _facebookButton(context),
                      // SizedBox(height: height * .055),
                      // _createAccountLabel(),
                    ],
                  ),
                ),
              ),
              // Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        ))
    );
  }
}
