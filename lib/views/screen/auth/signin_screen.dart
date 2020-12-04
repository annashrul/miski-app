import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/screen_util_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/auth/login_model.dart';
import 'package:netindo_shop/model/config/config_auth.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/auth/secure_code_screen.dart';
import 'package:netindo_shop/views/screen/auth/signup_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/country_widget.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
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
      print("DATA USER $data");
      final countTbl = await _helper.queryRowCount(UserQuery.TABLE_NAME);
      if(countTbl>0){
        await _helper.deleteAll(UserQuery.TABLE_NAME);
      }
      await _helper.insert(UserQuery.TABLE_NAME,data);
      WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,));
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
    if(res == 'TimeoutException' || res == 'SocketException'){
      setState(() {Navigator.pop(context);});
      WidgetHelper().notifDialog(context, 'Oopss','Terjadi kesalahan server',(){Navigator.pop(context);},(){Navigator.pop(context);});
    }
    else{
      if(res is General){
        General result = res;
        setState(() {Navigator.pop(context);});
        WidgetHelper().showFloatingFlushbar(context, 'failed',result.msg);
      }
      else{
        var result =LoginModel.fromJson(res);
        if(result.status=='success'){
          setState(() {Navigator.pop(context);});
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
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,));
          }
        }
        else{
          setState(() {Navigator.pop(context);});
          WidgetHelper().showFloatingFlushbar(context, 'failed',result.msg);
        }
      }
    }
  }
  Future validasi(String type) async{
    final regEmail=FunctionHelper().isEmail(_emailController.text);
    if(type=='otp'){
      if(_nohpController.text==''){
        WidgetHelper().showFloatingFlushbar(context, 'failed','no handphone tidak boleh kosong');
        // WidgetHelper().notifNoAction(_scaffoldKey, context, 'no handphone tidak boleh kosong');
        await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
        _nohpFocus.requestFocus();
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
    print("RESULT CONFIG $result");
    setState(() {
      type = result;
      isLoading=false;
    });

  }
  Future countTable() async{
    await _helper.queryRowCount(UserQuery.TABLE_NAME);
  }

  @override
  void initState()  {
    _helper.openDB();
    getConfig();
    countTable();
    isLoading=true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
    ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).accentColor,
      body: isLoading?WidgetHelper().loadingWidget(context):SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  margin: EdgeInsets.symmetric(vertical: 65, horizontal: 50),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  margin: EdgeInsets.symmetric(vertical: 85, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.2), offset: Offset(0, 10), blurRadius: 20)
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      SizedBox(height: 20),
                      type=='otp'?Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetHelper().textQ("No Handphone",12,Colors.black.withOpacity(0.6),FontWeight.bold),
                          SizedBox(height: 10.0),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: TextFormField(
                              style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
                              decoration: InputDecoration(
                                disabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                                enabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                                focusedBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                              ),
                              controller: _nohpController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ):
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetHelper().textQ("Alamat Email",12,Colors.black.withOpacity(0.6),FontWeight.bold),
                          SizedBox(height: 10.0),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: TextFormField(
                              style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
                              decoration: InputDecoration(
                                disabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                                enabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                                focusedBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                              ),
                              controller: _emailController,
                              focusNode: _emailFocus,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (term){
                                WidgetHelper().fieldFocusChange(context, _emailFocus, _passwordFocus);
                              },
                            ),
                          ),
                          SizedBox(height: 10.0),
                          WidgetHelper().textQ("Kata Sandi",12,Colors.black.withOpacity(0.6),FontWeight.bold),
                          SizedBox(height: 10.0),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: TextFormField(
                              style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(top:15),
                                disabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                                enabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                                focusedBorder:UnderlineInputBorder(borderSide: BorderSide.none),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                  color: Theme.of(context).accentColor.withOpacity(0.4),
                                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: !_showPassword,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                      type!='otp'?Text(''):SizedBox(height: 10),
                      type!='otp'?Text(''):Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetHelper().textQ("Kirim otp via ${_switchValue?'whatsapp':'sms'}", 12, Colors.black.withOpacity(0.6),FontWeight.bold),
                          SizedBox(
                              width: 70,
                              height: 10,
                              child: Switch(
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
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal:125),
                          onPressed: () {
                            validasi(type);
                          },
                          child: WidgetHelper().textQ("Login",18,Colors.white,FontWeight.bold),
                          color: Theme.of(context).accentColor,
                          shape: StadiumBorder(),
                        ),
                      ),
                      Center(
                        child: FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
                          child:  WidgetHelper().textQ("Atau",12,SiteConfig().accentColor,FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal:125),
                          onPressed: () {
                            WidgetHelper().myPushAndLoad(context,  SignupScreen(), (){getConfig();});
                            // WidgetHelper().myPush(context, SignupScreen());
                          },
                          child: WidgetHelper().textQ("Daftar",18,Colors.white,FontWeight.bold),
                          color: Theme.of(context).primaryColorDark,
                          shape: StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

