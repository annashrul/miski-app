import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/address/address_component.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
import 'package:netindo_shop/pages/widget/user/image_user_widget.dart';

class ProfileComponent extends StatefulWidget {
  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  dynamic dataUser;
  Future loadData()async{
    final name= await UserHelper().getDataUser(StringConfig.nama);
    final email= await UserHelper().getDataUser(StringConfig.email);
    final gender= await UserHelper().getDataUser(StringConfig.jenis_kelamin);
    final birthDate = await UserHelper().getDataUser(StringConfig.tgl_ultah);
    DateTime tempDate = new DateFormat("yyyy-MM-dd").parse(birthDate);

    dataUser = {
      StringConfig.nama:name,
      StringConfig.email:email,
      StringConfig.jenis_kelamin:gender,
      StringConfig.tgl_ultah:"$tempDate".substring(0,10),
    };
    this.setState(() {});
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();

  }

  @override
  Widget build(BuildContext context) {
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
            title:config.MyFont.subtitle(context: context,text:historArray[i],fontSize: 9,color: Theme.of(context).textTheme.caption.color),
          )
        ),
      );
    }
    final scaler=config.ScreenScale(context).scaler;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: <Widget>[
          Padding(
            padding: scaler.getPadding(0,2),
            child: SearchBarWidget(),
          ),
          Padding(
            padding: scaler.getPadding(1,2),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      config.MyFont.title(context: context,text:dataUser==null?"":dataUser[StringConfig.nama]),
                      config.MyFont.subtitle(context: context,text:dataUser==null?"":dataUser[StringConfig.email],fontSize: 9,color:Theme.of(context).textTheme.caption.color ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                ImageUserWidget()
                // SizedBox(
                //     width: scaler.getWidth(10),
                //     height: scaler.getHeight(4),
                //     child: InkWell(
                //       borderRadius: BorderRadius.circular(300),
                //       onTap: () {
                //       },
                //       child: CircleAvatar(
                //         backgroundImage: AssetImage(StringConfig.userImage),
                //       ),
                //     )),
              ],
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
                      Navigator.of(context).pushNamed('/Tabs', arguments: 0);
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
                  children: [
                    WidgetHelper().titleQ(context, "Data diri",icon: UiIcons.user_1,padding: scaler.getPaddingLTRB(2,1,2,0),callback:(){} ),
                    Padding(
                      padding: scaler.getPaddingLTRB(0,0,2,0),
                      child: config.MyFont.subtitle(context: context,text:"Ubah",fontSize: 9,color: config.Colors.mainColors),
                    )
                  ],
                ),

                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Nama lengkap',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:dataUser==null?"":dataUser[StringConfig.nama],fontSize: 9,color: Theme.of(context).focusColor),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Email',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:dataUser==null?"":dataUser[StringConfig.email],fontSize: 9,color:Theme.of(context).focusColor),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Jenis kelamain',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:dataUser==null?"":dataUser[StringConfig.jenis_kelamin],fontSize: 9,color:Theme.of(context).focusColor),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'tanggal lahir',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:dataUser==null?"":dataUser[StringConfig.tgl_ultah],fontSize: 9,color:Theme.of(context).focusColor),
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
                        // Navigator.of(context).pushNamed('/${StringConfig.address}',arguments: {"callback":null,"indexArr":0});
                      },
                      dense: true,
                      title:config.MyFont.subtitle(context: context,text:'Pusat bantuan',fontSize: 9,color: Theme.of(context).textTheme.caption.color),

                    )
                ),
                WidgetHelper().myRipple(
                  callback: (){},
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    onTap: () {
                      Navigator.of(context).pushNamed('/Help');
                    },
                    dense: true,
                    title:config.MyFont.subtitle(context: context,text:'Pusat bantuan',fontSize: 9,color: Theme.of(context).textTheme.caption.color),

                  )
                ),
                WidgetHelper().myRipple(
                  callback: (){},
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    onTap: () {
                      WidgetHelper().notifDialog(context,"Perhatian !!","Anda yakin akan keluar dari aplikasi ??", (){Navigator.pop(context);}, ()async{
                        DatabaseConfig db = DatabaseConfig();
                        final id = await UserHelper().getDataUser('id');
                        await db.update(UserQuery.TABLE_NAME, {'id':"${id.toString()}","is_login":"0"});
                        Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.signIn}", (route) => false);
                      });
                    },
                    dense: true,
                    title:config.MyFont.subtitle(context: context,text:'Keluar',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
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
