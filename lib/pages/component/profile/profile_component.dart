import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';

class ProfileComponent extends StatefulWidget {
  @override
  _ProfileComponentState createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchBarWidget(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    width: 55,
                    height: 55,
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
                      Navigator.of(context).pushNamed('/Tabs', arguments: 4);
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
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/Tabs', arguments: 3);
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
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  leading: Icon(UiIcons.inbox),
                  title:config.MyFont.title(context: context,text:'My orders' ),
                  trailing: ButtonTheme(
                    padding: EdgeInsets.all(0),
                    minWidth: 50.0,
                    height: 25.0,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Orders');
                      },
                      child:config.MyFont.title(context: context,text:"View all"),

                    ),
                  ),
                ),
               WidgetHelper().myRipple(
                 callback: (){},
                 child:  ListTile(
                   dense: true,
                   title:config.MyFont.subtitle(context: context,text:'Unpaid',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                   trailing: Chip(
                     padding: EdgeInsets.symmetric(horizontal: 10),
                     backgroundColor: Colors.transparent,
                     shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor)),
                     label: config.MyFont.subtitle(context: context,text:"1",fontSize: 8,color:Theme.of(context).focusColor),
                   ),
                 )
               ),
                WidgetHelper().myRipple(
                    callback: (){},
                    child:  ListTile(
                      dense: true,
                      title:config.MyFont.subtitle(context: context,text:'To be shipped',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                      trailing: Chip(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor)),
                        label: config.MyFont.subtitle(context: context,text:"1",fontSize: 8,color:Theme.of(context).focusColor),
                      ),
                    )
                ),
                WidgetHelper().myRipple(
                    callback: (){},
                    child:  ListTile(
                      dense: true,
                      title:config.MyFont.subtitle(context: context,text:'shipped',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                      trailing: Chip(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor)),
                        label: config.MyFont.subtitle(context: context,text:"1",fontSize: 8,color:Theme.of(context).focusColor),
                      ),
                    )
                ),
                WidgetHelper().myRipple(
                    callback: (){},
                    child:  ListTile(
                      dense: true,
                      title:config.MyFont.subtitle(context: context,text:'Success',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                    )
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  title: config.MyFont.title(context: context,text:'Profile settings'),
                  trailing: ButtonTheme(
                    padding: EdgeInsets.all(0),
                    minWidth: 50.0,
                    height: 25.0,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Orders');
                      },
                      child:config.MyFont.title(context: context,text:"Edit"),
                    ),
                  ),
                  // trailing: ButtonTheme(
                  //   padding: EdgeInsets.all(0),
                  //   minWidth: 50.0,
                  //   height: 25.0,
                  //   child: ProfileSettingsDialog(
                  //     user: this._user,
                  //     onChanged: () {
                  //       setState(() {});
                  //     },
                  //   ),
                  // ),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Fullname',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
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
                  title: config.MyFont.subtitle(context: context,text:'Gender',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:'My orders',fontSize: 9,color:Theme.of(context).focusColor),
                ),
                ListTile(
                  onTap: () {},
                  dense: true,
                  title: config.MyFont.subtitle(context: context,text:'Birth date',fontSize: 9,color: Theme.of(context).textTheme.caption.color),
                  trailing: config.MyFont.subtitle(context: context,text:'My orders',fontSize: 9,color:Theme.of(context).focusColor),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  title: config.MyFont.title(context: context,text:'Account settings'),
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
