import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/main.dart';
import 'package:netindo_shop/views/screen/address/address_screen.dart';
import 'package:netindo_shop/views/screen/auth/login_screen.dart';
import 'package:netindo_shop/views/screen/auth/signin_screen.dart';
import 'package:netindo_shop/views/screen/history/history_transaction_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/profile/profile_dialog_form_widget.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  String foto='',name='',email='',gender='';
  DateTime birthDate;
  final userRepository = UserHelper();
  DatabaseConfig db = DatabaseConfig();
  Future loadData() async{
    final var_foto = await userRepository.getDataUser('foto');
    final var_nama = await userRepository.getDataUser('nama');
    final var_email = await userRepository.getDataUser('email');
    final var_gender = await userRepository.getDataUser('jenis_kelamin');
    final var_birthDate = await userRepository.getDataUser('tgl_ultah');
    setState(() {
      foto = var_foto;
      name = var_nama;
      email = var_email;
      gender = var_gender;
      birthDate = DateTime.parse(var_birthDate);
      isLoading=false;
    });
  }
  bool isLoading=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    initializeDateFormatting('id');
    isLoading=true;
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return isLoading?Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WidgetHelper().loadingWidget(context,color: Colors.black)
        ],
      ),
    ): RefreshWidget(
      widget: SingleChildScrollView(
        padding:scaler.getPadding(1,3),
        child:Column(
          children: <Widget>[
            wrapperHeader(context,[
              wrapperTitle(context,(){},AntDesign.user,'Pengaturan Akun'),
              wrapperContent(context,'Alamat',icon:  Icons.arrow_right,i: 0,callback: (){WidgetHelper().myPush(context,AddressScreen());}),
              wrapperContent(context,'Bank',icon:  Icons.arrow_right,i: 1),
              wrapperContent(context,'Data Diri',icon:  Icons.arrow_right,i: 0),
            ]),
            SizedBox(height:scaler.getHeight(1)),
            wrapperHeader(context,[
              wrapperTitle(context,(){},AntDesign.barchart,'Riwayat Pembelian'),
              Column(
                children: FunctionHelper.arrOptDate.asMap().map((i,k) =>  MapEntry(
                    i,
                    wrapperContent(context, k, icon: Icons.arrow_right, callback: (){WidgetHelper().myPush(context,WrapperScreen(currentTab: 0,otherParam: i));}, i: i)
                )).values.toList(),
              )
            ]),
            SizedBox(height:scaler.getHeight(1)),
            wrapperHeader(context,[
              wrapperTitle(context,(){},AntDesign.setting,'Pengaturan Umum'),
              // wrapperContent(context,'Alamat',i: 0,icon: Icons.arrow_right,callback: (){WidgetHelper().myPush(context,AddressScreen());}),
              wrapperContent(context,'Kebijakan & Privasi',i: 1,icon: Icons.arrow_right),
              wrapperContent(context,'Keluar',i: 0,icon: Icons.arrow_right,callback: ()async{
                WidgetHelper().notifDialog(context,"Perhatian !!","Anda yakin akan keluar dari aplikas ??", (){Navigator.pop(context);}, ()async{
                  final id = await UserHelper().getDataUser('id');
                  await db.update(UserQuery.TABLE_NAME, {'id':"${id.toString()}","is_login":"0"});
                  // await db.deleteAll(UserQuery.TABLE_NAME);
                  WidgetHelper().myPushRemove(context,LoginScreen());
                });
              }),
            ]),

          ],
        ),
      ),
      callback: (){
        FunctionHelper().handleRefresh((){
          setState(() {
            isLoading=true;
          });
        });
      },
    );
  }

  Widget wrapperHeader(BuildContext context,List<Widget> children){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color:Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
        ],
      ),
      child: ListView(
        padding:EdgeInsets.all(0.0),
        shrinkWrap: true,
        primary: false,
        children: children,
      ),
    );
  }

  Widget wrapperContent(BuildContext context,String title,{Function callback, IconData icon,String desc,int i=0}){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return FlatButton(
      color: i%2==0?Color(0xFFEEEEEE):Colors.transparent,
      padding:scaler.getPadding(0,2),
      onPressed:callback!=null?callback:(){},
      child: Row(
        
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          WidgetHelper().textQ(title,10,SiteConfig().darkMode,FontWeight.bold),
          if(icon!=null)Icon(icon,color:Theme.of(context).focusColor),
          if(desc!=null)WidgetHelper().textQ(desc,10,Theme.of(context).focusColor,FontWeight.normal),
        ],
      ),

    );
  }
  Widget wrapperTitle(BuildContext context,Function callback, IconData icon,String title){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return FlatButton(
      padding:scaler.getPadding(0,2),
      onPressed:callback!=null?callback:(){},
      child: Row(
        children: [
          Icon(icon,color:SiteConfig().mainColor),
          SizedBox(width: 10),
          WidgetHelper().textQ(title,scaler.getTextSize(10),SiteConfig().mainColor,FontWeight.bold),
        ],
      ),

    );
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.body1.merge(
        TextStyle(color: Theme.of(context).focusColor),
      ),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      hasFloatingPlaceholder: true,
      labelStyle: Theme.of(context).textTheme.body1.merge(
        TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  void _submit() {
    if (_profileSettingsFormKey.currentState.validate()) {
      _profileSettingsFormKey.currentState.save();
      Navigator.pop(context);
    }
  }
}
