import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/main.dart';
import 'package:netindo_shop/views/screen/history/history_transaction_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/profile/profile_dialog_form_widget.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/views/widget/refresh_widget.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  String foto='',name='',email='',gender='';
  DateTime birthDate;
  final userRepository = UserHelper();
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
    });
  }
  bool site=false;
  bool isLoading=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    print("SITE $res");
    setState(() {
      site = res;
      isLoading=false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSite();
    loadData();
    initializeDateFormatting('id');
    isLoading=true;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading?Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WidgetHelper().loadingWidget(context,color: site?Colors.white:Colors.white)
        ],
      ),
    ): RefreshWidget(
      widget: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 7),
        child:Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      onPressed: () {
                        // Navigator.of(context).pushNamed('/Tabs', arguments: 4);
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(UiIcons.heart,color: Colors.grey),
                          WidgetHelper().textQ("Favorite",12,SiteConfig().secondColor,FontWeight.bold)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      onPressed: () {
                        // Navigator.of(context).pushNamed('/Tabs', arguments: 0);
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(UiIcons.favorites,color: Colors.grey),
                          WidgetHelper().textQ("Favorite",12,SiteConfig().secondColor,FontWeight.bold)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      onPressed: () {
                        // Navigator.of(context).pushNamed('/Tabs', arguments: 3);
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(UiIcons.chat_1,color: Colors.grey),
                          WidgetHelper().textQ("Favorite",12,SiteConfig().secondColor,FontWeight.bold)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: site?SiteConfig().darkMode:Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: site?Colors.transparent:Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                ],
              ),
              child: ListView(
                padding: EdgeInsets.all(0.0),
                shrinkWrap: true,
                primary: false,
                children: <Widget>[
                  ListTile(
                    leading: Icon(UiIcons.user_1,color: site?Colors.white:Colors.grey),
                    title: WidgetHelper().textQ("Pengaturan Akun",12,site?Colors.white:SiteConfig().secondColor,FontWeight.bold),
                    trailing: InkWell(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                title: Row(
                                  children: <Widget>[
                                    Icon(UiIcons.user_1),
                                    SizedBox(width: 10),
                                    Text(
                                      'Profile Settings',
                                      style: Theme.of(context).textTheme.body2,
                                    )
                                  ],
                                ),
                                children: <Widget>[
                                  Form(
                                    key: _profileSettingsFormKey,
                                    child: Column(
                                      children: <Widget>[
                                        new TextFormField(
                                          style: TextStyle(color: Theme.of(context).hintColor),
                                          keyboardType: TextInputType.text,
                                          decoration: getInputDecoration(hintText: 'John Doe', labelText: 'Full Name'),
                                          initialValue: name,
                                          validator: (input) => input.trim().length < 3 ? 'Not a valid full name' : null,
                                          onSaved: (input) => name = input,
                                        ),
                                        new TextFormField(
                                          style: TextStyle(color: Theme.of(context).hintColor),
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: getInputDecoration(hintText: 'johndo@gmail.com', labelText: 'Email Address'),
                                          initialValue: email,
                                          validator: (input) => !input.contains('@') ? 'Not a valid email' : null,
                                          onSaved: (input) => email = input,
                                        ),
                                        FormField<String>(
                                          builder: (FormFieldState<String> state) {
                                            return DropdownButtonFormField<String>(
                                              decoration: getInputDecoration(hintText: 'Pria', labelText: 'Jenis Kelamin'),
                                              hint: Text("Select Device"),
                                              value: gender,
                                              onChanged: (input) {
                                                setState(() {
                                                  gender = input;
                                                });
                                              },
                                              onSaved: (input) => gender = input,
                                              items: [
                                                new DropdownMenuItem(value: 'Wanita', child: Text('Wanita')),
                                                new DropdownMenuItem(value: 'Pria', child: Text('Pria')),
                                              ],
                                            );
                                          },
                                        ),
                                        FormField<String>(
                                          builder: (FormFieldState<String> state) {
                                            return DateTimeField(
                                              decoration: getInputDecoration(hintText: '1996-12-31', labelText: 'Birth Date'),
                                              format: new DateFormat('yyyy-MM-dd'),
                                              initialValue: birthDate,
                                              onShowPicker: (context, currentValue) {
                                                return showDatePicker(
                                                    context: context,
                                                    firstDate: DateTime(1900),
                                                    initialDate: currentValue ?? DateTime.now(),
                                                    lastDate: DateTime(2100));
                                              },
                                              onSaved: (input) => setState(() {
                                                // birthDate = input.toString();
                                                // widget.onChanged();
                                              }),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: <Widget>[
                                      MaterialButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      MaterialButton(
                                        onPressed: _submit,
                                        child: Text(
                                          'Save',
                                          style: TextStyle(color: Theme.of(context).accentColor),
                                        ),
                                      ),
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.end,
                                  ),
                                  SizedBox(height: 10),
                                ],
                              );
                            });
                      },
                      child: WidgetHelper().textQ("Ubah",10,site?Colors.white:SiteConfig().secondColor,FontWeight.bold),
                    ),
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                  ),

                  ListTile(
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                    onTap: () {},
                    dense: true,
                    title: WidgetHelper().textQ("Nama",10, site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                    trailing: WidgetHelper().textQ(name,10,Theme.of(context).focusColor,FontWeight.normal),
                  ),
                  ListTile(
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                    onTap: () {},
                    dense: true,
                    title: WidgetHelper().textQ("Email",10, site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                    trailing: WidgetHelper().textQ(email,10,Theme.of(context).focusColor,FontWeight.normal),
                  ),
                  ListTile(
                    contentPadding: site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                    onTap: () {},
                    dense: true,
                    title: WidgetHelper().textQ("Jenis Kelamin",10, site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                    trailing: WidgetHelper().textQ(gender,10,Theme.of(context).focusColor,FontWeight.normal),
                  ),
                  ListTile(
                    contentPadding: site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                    onTap: () {},
                    dense: true,
                    title: WidgetHelper().textQ("Tanggal Lahir",10, site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                    trailing: WidgetHelper().textQ("$birthDate",10,Theme.of(context).focusColor,FontWeight.normal),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: site?SiteConfig().darkMode:Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: site?Colors.transparent:Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                primary: false,
                children: <Widget>[
                  ListTile(
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                    leading: Icon(UiIcons.bar_chart,color: site?Colors.white:Colors.grey),
                    title: WidgetHelper().textQ("Riwayat Pembelian",12,site?Colors.white:SiteConfig().secondColor,FontWeight.bold),
                    trailing: ButtonTheme(
                      padding: EdgeInsets.all(0),
                      minWidth: 50.0,
                      height: 25.0,
                      child: FlatButton(
                        onPressed: () {
                          WidgetHelper().myPush(context,WrapperScreen(currentTab: 0,otherParam: 5));
                        },
                        child: WidgetHelper().textQ("Semua Status",10,site?Colors.white:SiteConfig().secondColor,FontWeight.normal),
                      ),
                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(site?0.0:0.0),
                    onPressed: (){
                      WidgetHelper().myPush(context,WrapperScreen(currentTab: 0,otherParam: 0));
                    },
                    child: ListTile(
                      contentPadding: site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                      dense: true,
                      title: WidgetHelper().textQ("${FunctionHelper.arrOptDate[0]}",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                      trailing: Icon(Icons.looks_one,color: site?Colors.white:Theme.of(context).focusColor),
                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),

                    onPressed: (){
                      WidgetHelper().myPush(context,WrapperScreen(currentTab: 0,otherParam: 1));
                    },
                    child: ListTile(
                      contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                      dense: true,
                      title: WidgetHelper().textQ("${FunctionHelper.arrOptDate[1]}",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                      trailing: Icon(Icons.looks_two,color: site?Colors.white:Theme.of(context).focusColor),

                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),

                    onPressed: (){
                      WidgetHelper().myPush(context,WrapperScreen(currentTab: 0,otherParam: 2));

                    },
                    child: ListTile(
                      contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                      dense: true,
                      title: WidgetHelper().textQ("${FunctionHelper.arrOptDate[2]}",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                      trailing: Icon(Icons.looks_3,color: site?Colors.white:Theme.of(context).focusColor),
                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),

                    onPressed: (){
                      WidgetHelper().myPush(context,WrapperScreen(currentTab: 0,otherParam: 3));

                    },
                    child: ListTile(
                      contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                      dense: true,
                      title: WidgetHelper().textQ("${FunctionHelper.arrOptDate[3]}",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                      trailing: Icon(Icons.looks_4,color: site?Colors.white:Theme.of(context).focusColor),

                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),

                    onPressed: (){
                      WidgetHelper().myPush(context,WrapperScreen(currentTab: 0,otherParam: 4));
                    },
                    child: ListTile(
                      contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                      dense: true,
                      title: WidgetHelper().textQ("${FunctionHelper.arrOptDate[4]}",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal),
                      trailing: Icon(Icons.looks_5,color: site?Colors.white:Theme.of(context).focusColor),

                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: site?SiteConfig().darkMode:Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: site?Colors.transparent:Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                ],
              ),
              child: ListView(
                padding: EdgeInsets.all(0.0),

                shrinkWrap: true,
                primary: false,
                children: <Widget>[
                  ListTile(
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                    leading: Icon(UiIcons.settings_1,color: site?Colors.white:Colors.grey),
                    title: WidgetHelper().textQ("Pengaturan Umum",12,site?Colors.white:SiteConfig().secondColor,FontWeight.bold),
                  ),
                  ListTile(
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),
                    onTap: () {},
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Icon(
                          site?UiIcons.cloud_computing:UiIcons.cloud_computing_1,
                          size: 22,
                          color: Theme.of(context).focusColor,
                        ),
                        SizedBox(width: 10),
                        WidgetHelper().textQ("Warna Tema ${site?'Gelap':'Cerah'}",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal)

                      ],
                    ),
                    trailing: SizedBox(
                        width: 70,
                        height: 10,
                        child: Switch(
                          activeColor: site?Colors.white:SiteConfig().mainDarkColor,
                          value: site,
                          onChanged: (value) async{

                            WidgetHelper().myPush(context,MyApp());
                            await FunctionHelper().storeSite(value);
                            setState(() {
                              site = value;
                            });
                          },
                        )
                    ),
                  ),
                  ListTile(
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),

                    onTap: () {},
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Icon(
                          UiIcons.map,
                          size: 22,
                          color: Theme.of(context).focusColor,
                        ),
                        SizedBox(width: 10),
                        WidgetHelper().textQ("Alamat",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal)
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding:  site?EdgeInsets.all(0.0):EdgeInsets.only(left:20,right:20),

                    onTap: () {
                    },
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Icon(
                          UiIcons.information,
                          size: 22,
                          color: Theme.of(context).focusColor,
                        ),
                        SizedBox(width: 10),
                        WidgetHelper().textQ("Kebijakan & Privasi",10,site?Colors.grey[200]:SiteConfig().secondColor,FontWeight.normal)

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      callback: (){
        FunctionHelper().handleRefresh((){
          setState(() {
            isLoading=true;
          });
          getSite();
        });
      },
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
