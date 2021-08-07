import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';

class DrawerWidget extends StatelessWidget {
  // User _user = new User.init().getCurrentUser();
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
              accountName: config.MyFont.title(context:context,text: "annashrul" ),
              accountEmail: config.MyFont.subtitle(context:context,text: "annashrul@gmail.com",color: Theme.of(context).textTheme.caption.color,fontSize: 9 ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: AssetImage(StringConfig.userImage),
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
            title: config.MyFont.subtitle(context:context,text: "Home",color: Theme.of(context).textTheme.caption.color),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 0);
            },
            leading: Icon(
              UiIcons.bell,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Notification",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 0);
            },
            leading: Icon(
              UiIcons.inbox,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "My orders",color: Theme.of(context).textTheme.caption.color),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.main}', arguments: 4);
            },
            leading: Icon(
              UiIcons.heart,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Wish list",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text: "Product",fontSize: 8),

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
            title: config.MyFont.subtitle(context:context,text: "Categories",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/${StringConfig.brand}');
            },
            leading: Icon(
              UiIcons.folder_1,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Brands",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text: "Application Preferences",fontSize: 8),
            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/Help');
            },
            leading: Icon(
              UiIcons.information,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Help & support",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/Tabs', arguments: 1);
            },
            leading: Icon(
              UiIcons.settings_1,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Settings",color: Theme.of(context).textTheme.caption.color),

          ),

          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/Login');
            },
            leading: Icon(
              UiIcons.upload,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: config.MyFont.subtitle(context:context,text: "Log out",color: Theme.of(context).textTheme.caption.color),

          ),
          ListTile(
            dense: true,
            title: config.MyFont.title(context:context,text:"Version ${StringConfig.version}",fontSize: 8),

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
