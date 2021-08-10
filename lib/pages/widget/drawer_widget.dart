import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/help_support/help_support_component.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String image="",name="",email="";

  Future loadDataUser()async{
    final resImage=await UserHelper().getDataUser(StringConfig.foto);
    final resName=await UserHelper().getDataUser(StringConfig.nama);
    final resEmail=await UserHelper().getDataUser(StringConfig.email);
    if(this.mounted){
      this.setState(() {
        image=resImage;
        name=resName;
        email=resEmail;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDataUser();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 1);
            },
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.1),
              ),
              accountName: config.MyFont.title(context:context,text: name ),
              accountEmail: config.MyFont.subtitle(context:context,text:email,color: Theme.of(context).textTheme.caption.color,fontSize: 9 ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: NetworkImage(image),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 2);
            },
            leading: Icon(
              UiIcons.home,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Beranda",color: Theme.of(context).textTheme.caption.color),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 0);
            },
            leading: Icon(
              UiIcons.bell,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Notifikasi",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 0);
            },
            leading: Icon(
              UiIcons.inbox,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Riwayat belanja",color: Theme.of(context).textTheme.caption.color),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 4);
            },
            leading: Icon(
              UiIcons.heart,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Wishlist",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text: "Produk",fontSize: 8),

            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.category}');

            },
            leading: Icon(
              UiIcons.folder_1,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Kategori",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.brand}');
            },
            leading: Icon(
              UiIcons.folder_1,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Brand",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text: "Lainnya",fontSize: 8),
            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),
          ListTile(
            onTap: () {
              WidgetHelper().myPush(context, HelpSupportComponent());
            },
            leading: Icon(
              UiIcons.information,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Pusat bantuan",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 1);
            },
            leading: Icon(
              UiIcons.settings_1,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Settings",color: Theme.of(context).textTheme.caption.color),

          ),

          ListTile(
            onTap: () {
              WidgetHelper().notifDialog(context,"Perhatian !!","Anda yakin akan keluar dari aplikasi ??", (){Navigator.pop(context);}, ()async{
                DatabaseConfig db = DatabaseConfig();
                final id = await UserHelper().getDataUser('id');
                await db.update(UserQuery.TABLE_NAME, {'id':"${id.toString()}","is_login":"0"});
                Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.signIn}", (route) => false);
              });
            },
            leading: Icon(
              UiIcons.upload,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Keluar",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text:"Versi ${StringConfig.version}",fontSize: 8),

            // title: Text(
            //   "Version 0.0.1",
            //   style: Theme.of(context).textTheme.body1,
            // ),
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

