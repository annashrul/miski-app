// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:netindo_shop/config/site_config.dart';
// import 'package:netindo_shop/helper/function_helper.dart';
// import 'package:netindo_shop/helper/screen_util_helper.dart';
// import 'package:netindo_shop/helper/widget_helper.dart';
// import 'package:netindo_shop/model/auth/otp_model.dart';
// import 'package:netindo_shop/model/general_model.dart';
// import 'package:netindo_shop/provider/base_provider.dart';
// import 'package:netindo_shop/views/screen/auth/login_screen.dart';
// import 'package:netindo_shop/views/screen/auth/secure_code_screen.dart';
// import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
// import 'package:netindo_shop/views/widget/timeout_widget.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
//
// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//   bool _showPassword = false,_showConfPassword=false;
//   var _noHpController = TextEditingController();
//   var _nameController = TextEditingController();
//   var _emailController = TextEditingController();
//   var _passwordController = TextEditingController();
//   var _confPasswordController = TextEditingController();
//   final FocusNode _noHpFocus = FocusNode();
//   final FocusNode _nameFocus = FocusNode();
//   final FocusNode _emailFocus = FocusNode();
//   final FocusNode _passwordFocus = FocusNode();
//   final FocusNode _confPasswordFocus = FocusNode();
//
//   String isErrorName='',isErrorPhone='',isErrorEmail='',isErrorPassword='',isErrorConfPassword='';
//   String type='',jenisKelamin='pria';
//   bool _switchValue=true;
//
//   Future create() async{
//     print("############################## ANYING ############################");
//
//     var status = await OneSignal.shared.getPermissionSubscriptionState();
//     String onesignalUserId = status.subscriptionStatus.userId;
//     final data={
//       'nama'          : _nameController.text,
//       'alamat'        : '-',
//       'tlp'           : _noHpController.text,
//       'email'         : _emailController.text,
//       'password'      : _passwordController.text,
//       'jenis_kelamin' : jenisKelamin=='pria'?'0':'1',
//       'platform'      : 'Email',
//       'deviceid'      : onesignalUserId,
//       'type'          : type,
//       'type_otp'      : _switchValue?'whatsapp':'sms',
//     };
//     var res = await BaseProvider().postProvider("auth/register", data);
//     setState(() {
//       Navigator.pop(context);
//     });
//
//     if(res == 'TimeoutException' || res == 'SocketException'){
//       WidgetHelper().notifDialog(context,'Oops','Terjadi kesalahan server',(){
//         Navigator.pop(context);
//       },(){Navigator.pop(context);});
//     }
//     else if(res=='Email telah terdaftar'){
//       WidgetHelper().showFloatingFlushbar(context, 'failed','Email telah terdaftar');
//     }
//     else{
//       print("############################## ${res is General} ############################");
//       if(res is General){
//         General result = res;
//         WidgetHelper().showFloatingFlushbar(context, 'failed','${result.msg} telah terdaftar');
//         print("############################## ${result.status} ############################");
//
//       }
//       else{
//         WidgetHelper().notifDialog(context,'Berhasil','Pendaftaran berhasil dilakukan',(){
//           Navigator.pop(context);
//         },(){
//           Navigator.pop(context);
//           WidgetHelper().myPush(context,SigninScreen());
//         });
//       }
//     }
//   }
//
//   Future save() async{
//     String nama=_nameController.text;
//     String nohp=_noHpController.text;
//     String email=_emailController.text;
//     String password=_passwordController.text;
//     String confPassword=_confPasswordController.text;
//     final regEmail = FunctionHelper().isEmail(_emailController.text);
//     if(nama==''){
//       WidgetHelper().showFloatingFlushbar(context,'failed', 'nama tidak boleh kosong');
//       await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
//       _nameFocus.requestFocus();
//     }
//     else if(nohp==''){
//       WidgetHelper().showFloatingFlushbar(context,'failed', 'no handphone tidak boleh kosong');
//       await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
//       _noHpFocus.requestFocus();
//     }
//     else if(email==''){
//       WidgetHelper().showFloatingFlushbar(context,'failed', 'email tidak boleh kosong');
//       await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
//       _emailFocus.requestFocus();
//     }
//     else if(regEmail==false){
//       WidgetHelper().showFloatingFlushbar(context,'failed', 'format email tidak sesuai');
//       await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
//       _emailFocus.requestFocus();
//     }
//     else if(password==''){
//       WidgetHelper().showFloatingFlushbar(context,'failed', 'kata sandi tidak boleh kosong');
//       await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
//       _passwordFocus.requestFocus();
//     }
//     else if(confPassword==''){
//       WidgetHelper().showFloatingFlushbar(context,'failed', 'konfirmasi kata sandi tidak boleh kosong');
//       await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
//       _confPasswordFocus.requestFocus();
//     }
//     else if(confPassword!=password){
//       WidgetHelper().showFloatingFlushbar(context,'failed', 'kata sandi tidak cocok');
//       await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
//       _confPasswordFocus.requestFocus();
//     }
//     else{
//       final data= {
//         'nomor': _noHpController.text,
//         'type': type!='otp'?'email':_switchValue?'whatsapp':'sms',
//         'nama': _nameController.text,
//       };
//       var res = await BaseProvider().postProvider('auth/otp', data);
//       if(res == 'TimeoutException' || res == 'SocketException'){
//         WidgetHelper().showFloatingFlushbar(context,'failed', 'Terjadi kesalahan server');
//       }
//       else{
//         if(res is General){
//           General result=res;
//           WidgetHelper().showFloatingFlushbar(context,'failed', result.msg);
//         }
//         else{
//           var result =OtpModel.fromJson(res);
//           if(result.status=='success'){
//             if(type=='otp'){
//               WidgetHelper().myPush(context, SecureCodeScreen(callback:_callBack,code:result.result.otp,param: 'otp',desc: _switchValue?'WhatsApp':'SMS'));
//             }
//             else{
//               WidgetHelper().loadingDialog(context);
//               create();
//             }
//           }
//         }
//       }
//
//
//     }
//   }
//   _callBack(BuildContext context,bool isTrue)async{
//     if(isTrue){
//       WidgetHelper().loadingDialog(context);
//       create();
//     }
//   }
//   bool isLoading=false;
//   bool isError=false;
//   Future getConfig() async{
//     var result= await FunctionHelper().getConfig();
//     if(result==SiteConfig().errSocket||result==SiteConfig().errTimeout){
//       setState(() {
//         isError = true;
//         isLoading=false;
//       });
//     }
//     else{
//       print("RESULT CONFIG $result");
//       setState(() {
//         type = result;
//         isLoading=false;
//       });
//     }
//
//
//   }
//
//   @override
//   void initState()  {
//     isLoading=true;
//     getConfig();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtilHelper.instance = ScreenUtilHelper.getInstance()..init(context);
//     ScreenUtilHelper.instance = ScreenUtilHelper(allowFontScaling: false);
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Theme.of(context).accentColor,
//       body: isLoading?WidgetHelper().loadingWidget(context): isError?TimeoutWidget(callback: (){
//         setState(() {
//           isLoading=true;
//           isError=false;
//         });
//         getConfig();
//       }):SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             Stack(
//               children: <Widget>[
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//                   margin: EdgeInsets.symmetric(vertical: 65, horizontal: 50),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Theme.of(context).primaryColor.withOpacity(0.6),
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
//                   margin: EdgeInsets.symmetric(vertical: 85, horizontal: 20),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Theme.of(context).primaryColor,
//                     boxShadow: [
//                       BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.2), offset: Offset(0, 10), blurRadius: 20)
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       SizedBox(height: 25),
//                       Center(child: WidgetHelper().textQ('Daftar Akun',18,SiteConfig().mainColor,FontWeight.bold)),
//                       SizedBox(height: 20.0),
//                       WidgetHelper().textQ("Nama Lengkap",12,Colors.black.withOpacity(0.6),FontWeight.bold),
//                       SizedBox(height: 10.0),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(20)
//                         ),
//                         child: TextFormField(
//                           style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
//                           decoration: InputDecoration(
//                             enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none,),
//                             focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none,),
//                           ),
//                           controller: _nameController,
//                           focusNode: _nameFocus,
//                           keyboardType: TextInputType.name,
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (term){
//                             WidgetHelper().fieldFocusChange(context, _nameFocus, _noHpFocus);
//                           },
//                           inputFormatters: <TextInputFormatter>[
//                             WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z]+|\s"))
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 10.0),
//                       WidgetHelper().textQ("No. Handphone",12,Colors.black.withOpacity(0.6),FontWeight.bold),
//                       SizedBox(height: 10.0),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(20)
//                         ),
//                         child: TextFormField(
//                           style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
//                           decoration: InputDecoration(
//                             disabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             enabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             focusedBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                           ),
//                           controller: _noHpController,
//                           focusNode: _noHpFocus,
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (term){
//                             WidgetHelper().fieldFocusChange(context, _nameFocus, _emailFocus);
//                           },
//                           inputFormatters: <TextInputFormatter>[
//                             WhitelistingTextInputFormatter.digitsOnly
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 10.0),
//                       WidgetHelper().textQ("Alamat Email",12,Colors.black.withOpacity(0.6),FontWeight.bold),
//                       SizedBox(height: 10.0),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(20)
//                         ),
//                         child: TextFormField(
//                           style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
//                           decoration: InputDecoration(
//                             disabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             enabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             focusedBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                           ),
//                           controller: _emailController,
//                           focusNode: _emailFocus,
//                           keyboardType: TextInputType.emailAddress,
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (term){
//                             WidgetHelper().fieldFocusChange(context, _emailFocus, _passwordFocus);
//                           },
//                         ),
//                       ),
//                       SizedBox(height: 10.0),
//                       WidgetHelper().textQ("Kata Sandi",12,Colors.black.withOpacity(0.6),FontWeight.bold),
//                       SizedBox(height: 10.0),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(20)
//                         ),
//                         child: TextFormField(
//                           style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
//                           decoration: InputDecoration(
//                             contentPadding: EdgeInsets.only(top:15),
//                             disabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             enabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             focusedBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             suffixIcon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _showPassword = !_showPassword;
//                                 });
//                               },
//                               color: Theme.of(context).accentColor.withOpacity(0.4),
//                               icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
//                             ),
//                           ),
//                           controller: _passwordController,
//                           focusNode: _passwordFocus,
//                           obscureText: !_showPassword,
//                           keyboardType: TextInputType.emailAddress,
//                           textInputAction: TextInputAction.next,
//                           onFieldSubmitted: (term){
//                             WidgetHelper().fieldFocusChange(context, _passwordFocus, _confPasswordFocus);
//                           },
//                         ),
//                       ),
//                       SizedBox(height: 10.0),
//                       WidgetHelper().textQ("Konfirmasi Kata Sandi",12,Colors.black.withOpacity(0.6),FontWeight.bold),
//                       SizedBox(height: 10.0),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//                         decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(20)
//                         ),
//                         child: TextFormField(
//                           style: TextStyle(fontSize:ScreenUtilHelper.getInstance().setSp(30),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,color: Colors.grey),
//                           decoration: InputDecoration(
//                             contentPadding: EdgeInsets.only(top:15),
//                             disabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             enabledBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             focusedBorder:UnderlineInputBorder(borderSide: BorderSide.none),
//                             suffixIcon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _showConfPassword = !_showConfPassword;
//                                 });
//                               },
//                               color: Theme.of(context).accentColor.withOpacity(0.4),
//                               icon: Icon(_showConfPassword ? Icons.visibility_off : Icons.visibility),
//                             ),
//                           ),
//                           controller: _confPasswordController,
//                           focusNode: _confPasswordFocus,
//                           obscureText: !_showConfPassword,
//                           keyboardType: TextInputType.text,
//                           textInputAction: TextInputAction.done,
//
//                         ),
//                       ),
//                       SizedBox(height: 10.0),
//                       WidgetHelper().textQ("Jenis Kelamin", 12, Colors.black.withOpacity(0.6),FontWeight.bold),
//                       SizedBox(height: 10.0),
//                       Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                           decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(20)
//                           ),
//                           child: DropdownButton<String>(
//                             isDense: true,
//                             isExpanded: true,
//                             value: jenisKelamin,
//                             icon: Icon(Icons.arrow_drop_down),
//                             iconSize: 20,
//                             underline: SizedBox(),
//                             onChanged: (value) {
//                               setState(() {
//                                 jenisKelamin = value;
//                               });
//                             },
//                             items: <String>['pria', 'wanita'].map<DropdownMenuItem<String>>((String value) {
//                               return new DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Row(
//                                   children: [
//                                     WidgetHelper().textQ(value,12,Colors.grey,FontWeight.bold)
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//
//                           )
//                       ),
//                       type!='otp'?Text(''):SizedBox(height: 10),
//                       type!='otp'?Text(''):Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           WidgetHelper().textQ("Kirim otp via ${_switchValue?'whatsapp':'sms'}", 12, Colors.black.withOpacity(0.6),FontWeight.bold),
//                           SizedBox(
//                               width: 70,
//                               height: 10,
//                               child: Switch(
//                                 activeColor: SiteConfig().mainDarkColor,
//                                 value: _switchValue,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _switchValue = value;
//                                   });
//                                 },
//                               )
//                           ),
//                           // SizedBox(height:typeOtp==false?5.0:0.0),
//                         ],
//                       ),
//                       SizedBox(height: 40),
//                       Align(
//                         alignment: Alignment.center,
//                         child: Column(
//                           children: [
//                             FlatButton(
//                               padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
//                               onPressed: () {
//                                 save();
//                               },
//                               child:WidgetHelper().textQ("Register",18,Colors.white,FontWeight.bold),
//                               color: Theme.of(context).accentColor,
//                               shape: StadiumBorder(),
//                             ),
//                             SizedBox(height: 20),
//                             FlatButton(
//                               onPressed: () {
//                                 WidgetHelper().myPush(context, LoginScreen());
//                               },
//                               child:WidgetHelper().textQ("Sudah punya akun ? Login",14,SiteConfig().mainColor,FontWeight.bold),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
//
// }
