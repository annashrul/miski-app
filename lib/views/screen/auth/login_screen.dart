import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/screen_util_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/auth/login_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/auth/register_screen.dart';
import 'package:netindo_shop/views/screen/auth/secure_code_screen.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:netindo_shop/views/screen/auth/signup_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;

import '../wrapper_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // static final FacebookLogin facebookSignIn = new FacebookLogin();
  String name = '', image;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _showPassword = false;
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _nohpController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nohpFocus = FocusNode();
  final DatabaseConfig _helper = new DatabaseConfig();
  String type='';
  bool _switchValue=true;

  _callBack(BuildContext context,bool isTrue,Map<String, Object> data)async{
    if(isTrue){
      WidgetHelper().loadingDialog(context);
      print("DATA USER $data");
      final countTbl = await _helper.queryRowCount(UserQuery.TABLE_NAME);
      if(countTbl>0){
        await _helper.deleteAll(UserQuery.TABLE_NAME);
      }
      await _helper.insert(UserQuery.TABLE_NAME,data);
      Navigator.pop(context);
      WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
    }
  }
  bool isLoadingReOtp=false;
  Future login(String type) async{
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

    // var res = await AuthProvider().login(email,pass,onesignalUserId,nohp,type,_switchValue?'whatsapp':'sms');
    final data={
      'email': '$email',
      'password': '$pass',
      'deviceid': onesignalUserId,
      'nohp': nohp,
      'type': type,
      'type_otp': _switchValue?'whatsapp':'sms',
    };
    var res = await BaseProvider().postProvider('auth', data);
    setState(() {Navigator.pop(context);});
    if(res == 'TimeoutException' || res == 'SocketException'){
      WidgetHelper().notifDialog(context, 'Oopss','Terjadi kesalahan server',(){Navigator.pop(context);},(){Navigator.pop(context);});
    }
    else{
      if(res is General){
        General result = res;
        WidgetHelper().showFloatingFlushbar(context, 'failed',result.msg);
      }
      else{
        var result =LoginModel.fromJson(res);
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
            print("IEU LOGIN $dataUser");
            WidgetHelper().myPush(context, SecureCodeScreen(
              callback:(context,isTrue){_callBack(context, true,dataUser);},
              code:result.result.otp,
              param: 'otp',
              desc: _switchValue?'WhatsApp':'SMS',
              data: {
                "nomor":"${result.result.tlp}",
                "type":"${_switchValue?'whatsapp':'sms'}",
                "nama":"${result.result.nama}"
              },
            ));
          }
          else{
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
          }
        }
        else{
          WidgetHelper().showFloatingFlushbar(context, 'failed',result.msg);
        }
      }
    }
  }
  Future validasi(String type) async{
    final regEmail=FunctionHelper().isEmail(_emailController.text);
    if(type=='otp'){
      if(_nohpController.text==''){
        _nohpFocus.requestFocus();

        WidgetHelper().showFloatingFlushbar(context, 'failed','no handphone tidak boleh kosong');
        // WidgetHelper().notifNoAction(_scaffoldKey, context, 'no handphone tidak boleh kosong');
        await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
      }else{
        login(type);
      }
    }
    else{
      if(_emailController.text==''){
        WidgetHelper().showFloatingFlushbar(context, 'failed','email tidak boleh kosong');

        // WidgetHelper().notifNoAction(_scaffoldKey, context, 'email tidak boleh kosong');
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
        login(type);
      }
    }

  }
  bool isLoading=false;
  Future getConfig() async{
    var result= await FunctionHelper().getConfig();
    setState(() {
      type = result["type"];
      isLoading=false;
    });
  }
  Future countTable() async{
    await _helper.queryRowCount(UserQuery.TABLE_NAME);
  }
  // Future handleFb()async{
  //   final FacebookLoginResult result =
  //   await facebookSignIn.logIn(['email']);
  //
  //   switch (result.status) {
  //     case FacebookLoginStatus.loggedIn:
  //       final FacebookAccessToken accessToken = result.accessToken;
  //       final graphResponse = await http.get(
  //           'https://graph.facebook.com/v2.12/me?fields=gender,name,first_name,last_name,email,picture&access_token=${accessToken.token}'
  //       );
  //       final profile = jsonDecode(graphResponse.body);
  //       print(profile);
  //       setState(() {
  //         name = profile['first_name'];
  //         image = profile['picture']['data']['url'];
  //       });
  //
  //       print('''
  //       name  $name
  //       image $image
  //        Logged in!
  //        Token: ${accessToken.token}
  //        User id: ${accessToken.userId}
  //        Expires: ${accessToken.expires}
  //        Permissions: ${accessToken.permissions}
  //        Declined permissions: ${accessToken.declinedPermissions}
  //        ''');
  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       print('Login cancelled by the user.');
  //       break;
  //     case FacebookLoginStatus.error:
  //       print('Something went wrong with the login process.\n'
  //           'Here\'s the error Facebook gave us: ${result.errorMessage}');
  //       break;
  //   }
  // }
  // GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  //
  // Future handleGoogle()async{
  //   try{
  //     await _googleSignIn.signIn();
  //     print(_googleSignIn.currentUser.displayName);
  //     print(_googleSignIn.currentUser.email);
  //     print(_googleSignIn.currentUser.photoUrl);
  //     // _googleSignIn.isSignedIn().then((value){
  //     //   print(value);
  //     // });
  //     // _googleSignIn.onCurrentUserChanged.listen((event) {
  //     //   print(event);
  //     // },onDone: (){
  //     //   print('done');
  //     // },onError: (){
  //     //   print('error');
  //     // });
  //     // print(_googleSignIn.);
  //     // setState(() {
  //     //   _isLoggedIn = false;
  //     // });
  //     // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home(
  //     //   title: 'Login With Google',
  //     //   name: _googleSignIn.currentUser.displayName,
  //     //   photo: _googleSignIn.currentUser.photoUrl,
  //     //   email: _googleSignIn.currentUser.email,
  //     //   isLogin: 'google',
  //     // )));
  //   } catch (err){
  //     print(err);
  //   }
  // }
  @override
  void initState()  {
    _helper.openDB();
    getConfig();
    countTable();
    isLoading=true;
    super.initState();
  }


  Widget _entryField(String title,TextInputType textInputType,TextInputAction textInputAction, TextEditingController textEditingController, FocusNode focusNode, {bool isPassword = false}) {
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
            textInputAction: textInputAction
          )
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
      child: WidgetHelper().myPress((){WidgetHelper().myPush(context,RegisterScreen());},Container(
        decoration: BoxDecoration(
          color: SiteConfig().mainDarkColor,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(5),
              topRight: Radius.circular(5)),
        ),
        alignment: Alignment.center,
        child:  WidgetHelper().textQ("Register",14,Colors.white,FontWeight.bold,letterSpacing: 10),
      )),
    );
  }

  Widget _submitButton() {
    return WidgetHelper().myPress((){
      // handleGoogle();
      // handleFb();
      validasi(type);
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
      child: WidgetHelper().textQ("Login",14,Colors.white,FontWeight.bold,letterSpacing: 10),
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
  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WidgetHelper().textQ("Forgot Password ??",12,Colors.black.withOpacity(0.6),FontWeight.normal),
            SizedBox(
              width: 10,
            ),
            WidgetHelper().textQ("Click here .. ",12,Colors.black.withOpacity(0.6),FontWeight.normal),
          ],
        ),
      ),
    );
  }
  Widget _emailPasswordWidget() {
    return type=='otp'?Column(
      children: <Widget>[
        _entryField("No Handphone",TextInputType.number,TextInputAction.done,_nohpController,_nohpFocus),
      ],
    ):
    Column(
      children: <Widget>[
        _entryField("Email",TextInputType.emailAddress,TextInputAction.done,_emailController,_emailFocus),
        _entryField("Password",TextInputType.text,TextInputAction.done,_passwordController,_passwordFocus, isPassword: true),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
    ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false);
    final height = MediaQuery.of(context).size.height;
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Scaffold(
      backgroundColor: Colors.white,
        body: Container(

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
                      SizedBox(height: height * .2),
                      // _title(),
                      SizedBox(height: 70),
                      _emailPasswordWidget(),
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
                      SizedBox(height: height * .055),
                      _createAccountLabel(),
                    ],
                  ),
                ),
              ),

              // Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        )
    );
  }
}
