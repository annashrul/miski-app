import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';

class ProfileComponent extends StatefulWidget {
  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
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
                      config.MyFont.title(context: context,text:"Annashrul yusuf"),
                      config.MyFont.subtitle(context: context,text:"Annashrulyusuf@gmail.com",fontSize: 9,color:Theme.of(context).textTheme.caption.color ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                SizedBox(
                    width: scaler.getWidth(10),
                    height: scaler.getHeight(4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(300),
                      onTap: () {
                        Navigator.of(context).pushNamed('/Tabs', arguments: 1);
                      },
                      child: CircleAvatar(
                        backgroundImage: AssetImage(StringConfig.userImage),
                      ),
                    )),
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
                        config.MyFont.subtitle(context: context,text:'Wish List',fontSize: 9 ),
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
                        config.MyFont.subtitle(context: context,text:'Brands',fontSize: 9 ),

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
                        config.MyFont.subtitle(context: context,text:'Messages',fontSize: 9 ),
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
                ListTile(
                  leading: Icon(UiIcons.inbox),
                  title:config.MyFont.title(context: context,text:'Riwayat belanja' ),
                  trailing: WidgetHelper().myRipple(
                    radius: 0,
                    callback: () {
                      Navigator.of(context).pushNamed('/${StringConfig.historyOrder}',arguments: 0);
                    },
                    child:config.MyFont.title(context: context,text:"semua",fontSize: 9,color: config.Colors.mainColors),
                  )
                ),
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
                ListTile(
                  leading: Icon(UiIcons.user_1),
                  title: config.MyFont.title(context: context,text:'Data diri'),
                  trailing: WidgetHelper().myRipple(
                    radius: 0,
                    callback: () {
                      Navigator.of(context).pushNamed('/${StringConfig.historyOrder}',arguments: 0);
                    },
                    child:config.MyFont.title(context: context,text:"edit",fontSize: 9,color: config.Colors.mainColors),
                  )
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Nama lengkap',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:'Annashrul yusuf',fontSize: 9,color: Theme.of(context).focusColor),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Email',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:'My orders',fontSize: 9,color:Theme.of(context).focusColor),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Jenis kelamain',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:'My orders',fontSize: 9,color:Theme.of(context).focusColor),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'tanggal lahir',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:'My orders',fontSize: 9,color:Theme.of(context).focusColor),
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
              children: <Widget>[
                ListTile(
                  leading: Icon(UiIcons.settings_1),
                  title: config.MyFont.title(context: context,text:'Lainnya'),
                ),
                WidgetHelper().myRipple(
                  callback: (){},
                  child: ListTile(
                    onTap: () {},
                    dense: true,
                    title: Row(
                      children: <Widget>[
                        Icon(
                          UiIcons.placeholder,
                          size: 22,
                          color: Theme.of(context).focusColor,
                        ),
                        SizedBox(width: 10),
                        config.MyFont.subtitle(context: context,text:'Shipping address',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                      ],
                    ),
                  ),
                ),

                WidgetHelper().myRipple(
                  callback: (){},
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Help');
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
                        config.MyFont.subtitle(context: context,text:'Help & support',fontSize: 9,color: Theme.of(context).textTheme.caption.color),

                      ],
                    ),

                  )
                ),
                WidgetHelper().myRipple(
                  callback: (){},
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed('/Help');
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
                        config.MyFont.subtitle(context: context,text:'Log out',fontSize: 9,color: Theme.of(context).textTheme.caption.color),

                      ],
                    ),

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
