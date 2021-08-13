import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/help_support/help_support_component.dart';

class DrawerWidget extends StatefulWidget {
  final dynamic user;
  DrawerWidget({this.user});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 1);
            },
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.1),
              ),
              accountName: config.MyFont.title(context:context,text: widget.user[StringConfig.nama] ),
              accountEmail: config.MyFont.subtitle(context:context,text:widget.user[StringConfig.email],color: Theme.of(context).textTheme.caption.color,fontSize: 9 ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: NetworkImage(widget.user[StringConfig.foto]),
              ),
            ),
          ),
          WidgetHelper().titleQ(context, "Beranda",fontWeight: FontWeight.normal,icon: UiIcons.home,padding: scaler.getPadding(1,2),callback:()=>Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 2)),
          WidgetHelper().titleQ(context, "Notifikasi",fontWeight: FontWeight.normal,icon: UiIcons.bell,padding: scaler.getPadding(1,2),callback:()=>Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 0)),
          WidgetHelper().titleQ(context, "Riwayat belanja",fontWeight: FontWeight.normal,icon: UiIcons.line_chart,padding: scaler.getPadding(1,2),callback:()=>Navigator.of(context).pushNamed('/${StringConfig.historyOrder}', arguments: 5)),
          WidgetHelper().titleQ(context, "Wishlist",fontWeight: FontWeight.normal,icon: UiIcons.heart,padding: scaler.getPadding(1,2),callback:()=>Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 4)),

          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text: "Produk",fontSize: 8),

            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),
          WidgetHelper().titleQ(context, "Kategori",fontWeight: FontWeight.normal,icon: UiIcons.folder_1,padding: scaler.getPadding(1,2),callback:()=>Navigator.of(context).pushNamed('/${StringConfig.category}')),
          WidgetHelper().titleQ(context, "Brand",fontWeight: FontWeight.normal,icon: UiIcons.folder_1,padding: scaler.getPadding(1,2),callback:()=>Navigator.of(context).pushNamed('/${StringConfig.brand}')),

          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text: "Lainnya",fontSize: 8),
            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),

          WidgetHelper().titleQ(context, "Pusan bantuan",fontWeight: FontWeight.normal,icon: UiIcons.information,padding: scaler.getPadding(1,2),callback:()=>WidgetHelper().myPush(context, HelpSupportComponent())),
          WidgetHelper().titleQ(context, "Pengaturan",fontWeight: FontWeight.normal,icon: UiIcons.settings_2,padding: scaler.getPadding(1,2),callback:()=>Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 1)),
          WidgetHelper().titleQ(context, "Keluar",fontWeight: FontWeight.normal,icon: UiIcons.power_button,padding: scaler.getPadding(1,2),callback:()async{
            await FunctionHelper().logout(context);
          }),
          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text:"Versi ${StringConfig.version}",fontSize: 8),
            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

