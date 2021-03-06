import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/database_config.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/database_helper.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/member/detail_member_model.dart';
import 'package:miski_shop/pages/component/address/address_component.dart';
import 'package:miski_shop/pages/component/help_support/help_support_component.dart';
import 'package:miski_shop/pages/widget/drawer_widget.dart';
import 'package:miski_shop/pages/widget/profile/form_profile_widget.dart';
import 'package:miski_shop/pages/widget/upload_image_widget.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:miski_shop/provider/user_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';

import '../main_component.dart';

class ProfileComponent extends StatefulWidget {
  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  // dynamic dataUser;
  String foto="";
  DatabaseConfig db = DatabaseConfig();
  dynamic  resUserFuture;
  Future loadData()async{
    // final img= await UserHelper().getDataUser(StringConfig.foto);
    // final name= await UserHelper().getDataUser(StringConfig.nama);
    // final email= await UserHelper().getDataUser(StringConfig.email);
    // final gender= await UserHelper().getDataUser(StringConfig.jenis_kelamin);
    // final birthDate = await UserHelper().getDataUser(StringConfig.tgl_ultah);
    // DateTime tempDate = new DateFormat("yyyy-MM-dd").parse(birthDate);
    // foto = img;
    // dataUser = {
    //   StringConfig.nama:name,
    //   StringConfig.email:email,
    //   StringConfig.jenis_kelamin:gender,
    //   StringConfig.tgl_ultah:"$tempDate".substring(0,10),
    // };
    // this.setState(() {});
  }
  updateImage(data)async{
    WidgetHelper().loadingDialog(context);
    final id= await UserHelper().getDataUser(StringConfig.id_user);
    final res=await HandleHttp().putProvider("member/$id", data,context: context);
    if(res!=null){
      final getDetail=await HandleHttp().getProvider("member/$id", detailMemberModelFromJson,context: context);
      if(getDetail!=null){
        DetailMemberModel result=DetailMemberModel.fromJson(getDetail.toJson());
        dynamic updateState = resUserFuture;
        updateState.update(StringConfig.foto, (value) => result.result.foto);
        Provider.of<UserProvider>(context, listen: false).setData(updateState);
        await db.update(UserQuery.TABLE_NAME, {StringConfig.foto:result.result.foto});
        if(this.mounted){
          this.setState(() {
            foto=result.result.foto;
          });
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          WidgetHelper().showFloatingFlushbar(context, "success", "data berhasil diubah");
        }
      }
    }
  }
  Future update(Map<dynamic,dynamic> data)async{
    final id= await UserHelper().getDataUser(StringConfig.id_user);
    final idLocal= await UserHelper().getDataUser(StringConfig.id);
    Navigator.of(context).pop();
    WidgetHelper().loadingDialog(context);
    data[StringConfig.jenis_kelamin] = data[StringConfig.jenis_kelamin]=="Wanita"?"0":"1";
    Provider.of<UserProvider>(context, listen: false).setData(data);
    dynamic storeData = {
      StringConfig.nama:data[StringConfig.nama],
      StringConfig.email:data[StringConfig.email],
      StringConfig.tgl_ultah:data[StringConfig.tgl_ultah],
      StringConfig.jenis_kelamin:data[StringConfig.jenis_kelamin]=="Wanita"?"0":"1",
    };
    print(storeData);
    storeData.addAll({"id":idLocal.toString()});
    await db.update(UserQuery.TABLE_NAME, storeData);
    storeData.remove("id");
    final res=await HandleHttp().putProvider("member/$id", storeData,context: context);
    if(res!=null){
      loadData();
      Navigator.of(context).pop();
      WidgetHelper().showFloatingFlushbar(context, "success", "data berhasil diubah");
    }
  }
  @override
  void initState() {
    super.initState();
    loadData();
  }
  @override
  Widget build(BuildContext context) {
    final resUserFuture = Provider.of<UserProvider>(context).dataUser;
    List<Widget> historyWidget = [];
    List historArray =FunctionHelper.arrOptDate;
    for(int i=0;i<historArray.length;i++){
      historyWidget.add(
        WidgetHelper().myRipple(
          radius: 0,
          callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.historyOrder}",arguments: i);
          },
          child:  ListTile(
            dense: true,
            title:config.MyFont.subtitle(context: context,text:historArray[i]),
          )
        ),
      );
    }
    final scaler=config.ScreenScale(context).scaler;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListTile(
            leading:  WidgetHelper().myRipple(
                callback: (){
                  WidgetHelper().myModal(context, UploadImageWidget(callback: (e){
                    updateImage({StringConfig.foto:e});
                  },title: "Ubah foto",));
                },
                child: WidgetHelper().imageUser(context: context,img: resUserFuture[StringConfig.foto],isUpdate: true)
            ),
            title: config.MyFont.title(context: context,text:resUserFuture[StringConfig.nama]),
            subtitle: config.MyFont.subtitle(context: context,text:resUserFuture[StringConfig.tlp],fontSize: 9),
            trailing: WidgetHelper().myRipple(
                callback: (){
                  WidgetHelper().myModal(
                      context,
                      Container(
                        height: scaler.getHeight(70),
                        child: Center(
                          child: WidgetHelper.qr(context: context,data: resUserFuture[StringConfig.id_user]),
                        ),
                      )
                  );
                },
                child: Icon(AntDesign.qrcode)
            ),
          ),
          Container(
            margin: scaler.getMargin(0,2),
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
                    padding: scaler.getPadding(1,1),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 4);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(UiIcons.heart),
                        config.MyFont.subtitle(context: context,text:'Wishlist',fontSize: 9 ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    padding: scaler.getPadding(1,1),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/${StringConfig.brand}', arguments: 0);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(UiIcons.favorites),
                        config.MyFont.subtitle(context: context,text:'Brand',fontSize: 9 ),

                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    padding: scaler.getPadding(1,1),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 3);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(UiIcons.chat_1),
                        config.MyFont.subtitle(context: context,text:'Pesan',fontSize: 9 ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: scaler.getMargin(1,2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              children: [
                WidgetHelper().titleQ(context, "Riwayat belanja",icon: UiIcons.shopping_cart,padding: scaler.getPaddingLTRB(2,1,2,0),callback:(){} ),
                Column(children: historyWidget),
              ],
            ),
          ),
          Container(
            margin: scaler.getMargin(1,2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              primary: false,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WidgetHelper().titleQ(context, "Data diri",icon: UiIcons.user_1,padding: scaler.getPaddingLTRB(2,1,2,0),callback:(){} ),
                    Padding(
                        padding: scaler.getPaddingLTRB(0,1,2,0),
                        child:FormProfileWidget(
                          user: resUserFuture,
                          onChanged: (){this.setState(() {});},
                          onSubmited: (data){
                            update(data);
                          },
                        )
                    )
                  ],
                ),

                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Nama lengkap'),
                  trailing: config.MyFont.subtitle(context: context,text:resUserFuture[StringConfig.nama]),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Email'),
                  trailing: config.MyFont.subtitle(context: context,text:resUserFuture[StringConfig.email]),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Jenis kelamain'),
                  trailing: config.MyFont.subtitle(context: context,text:resUserFuture[StringConfig.jenis_kelamin]=="0"?"Wanita":"Pria"),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'tanggal lahir'),
                  trailing: config.MyFont.subtitle(context: context,text:resUserFuture[StringConfig.tgl_ultah]),
                ),
              ],
            ),
          ),
          Container(
            margin: scaler.getMargin(1,2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
              ],
            ),
            child: ListView(
              padding: scaler.getPaddingLTRB(2, 1,2,1),
              shrinkWrap: true,
              primary: false,
              children: <Widget>[
                WidgetHelper().titleQ(context, "Lainnya",icon: UiIcons.settings_1,callback:(){} ),
                WidgetHelper().myRipple(
                    callback: (){},
                    child: ListTile(
                      contentPadding: EdgeInsets.all(0),
                      onTap: () {
                        WidgetHelper().myPush(context,AddressComponent());
                      },
                      dense: true,
                      title:config.MyFont.subtitle(context: context,text:'Alamat'),

                    )
                ),
                WidgetHelper().myRipple(
                  callback: (){},
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    onTap: () {
                      WidgetHelper().myPush(context,HelpSupportComponent());
                    },
                    dense: true,
                    title:config.MyFont.subtitle(context: context,text:'Pusat bantuan'),

                  )
                ),
                WidgetHelper().myRipple(
                  callback: (){},
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    onTap: () {
                      FunctionHelper().logout(context);
                    },
                    dense: true,
                    title:config.MyFont.subtitle(context: context,text:'Keluar'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
