import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/chat/chat_component.dart';
import 'package:netindo_shop/pages/component/favorite/favorite_component.dart';
import 'package:netindo_shop/pages/component/home/home_component.dart';
import 'package:netindo_shop/pages/component/notification/notification_component.dart';
import 'package:netindo_shop/pages/component/profile/profile_component.dart';
import 'package:netindo_shop/pages/widget/drawer_widget.dart';
import 'package:netindo_shop/provider/base_provider.dart';

// ignore: must_be_immutable
class MainComponent extends StatefulWidget {
  int currentTab = StringConfig.defaultTab;
  int selectedTab = StringConfig.defaultTab;
  String currentTitle = 'Home';
  Widget currentPage = HomeComponent();
  MainComponent({
    Key key,
    this.currentTab,
  }) : super(key: key);
  @override
  _MainComponentState createState() => _MainComponentState();
}

class _MainComponentState extends State<MainComponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int totalCart=0;
  dynamic dataUser;
  Future loadDataUser()async{
    final resImage=await UserHelper().getDataUser(StringConfig.foto);
    final resName=await UserHelper().getDataUser(StringConfig.nama);
    final resEmail=await UserHelper().getDataUser(StringConfig.email);
    final resPhone=await UserHelper().getDataUser(StringConfig.tlp);
    dataUser={
      StringConfig.foto:resImage,StringConfig.nama:resName,StringConfig.email:resEmail,StringConfig.tlp:resPhone
    };
    if(this.mounted){
      this.setState(() { });
    }
  }
  @override
  initState() {
    _selectTab(widget.currentTab);
    super.initState();
    loadDataUser();
  }

  @override
  void didUpdateWidget(MainComponent oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget");
  }

  Future loadCart()async{
    final tenant = await FunctionHelper().getTenant();
    final res = await BaseProvider().countCart(tenant[StringConfig.idTenant]);
    print("LOAD CART = $res");
    if(this.mounted) setState(() {
      totalCart = res;
    });
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      widget.selectedTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentTitle = 'Notifikasi';
          widget.currentPage = NotificationComponent();
          break;
        case 1:
          widget.currentTitle = 'Profil';
          widget.currentPage = ProfileComponent();
          break;
        case 2:
          loadCart();
          widget.currentTitle = 'Beranda';
          widget.currentPage = HomeComponent();
          break;
        case 3:
          widget.currentTitle = 'Pesan';
          widget.currentPage = ChatComponent();
          break;
        case 4:
          widget.currentTitle = 'Wishlist';
          widget.currentPage = FavoriteComponent();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: DrawerWidget(user: dataUser),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: new IconButton(
              icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
            ),

            backgroundColor: Colors.transparent,
            elevation: 0,
            title: config.MyFont.title(context: context,text: widget.currentTitle),
            actions: [
              WidgetHelper().iconAppBarBadges(context: context,icon:UiIcons.shopping_cart,isActive: totalCart>0,callback: (){
                if(totalCart>0){
                  Navigator.of(context).pushNamed("/${StringConfig.cart}").whenComplete((){
                    loadCart();
                  });
                }
              }),
            ],
          ),
          body:widget.currentPage,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            iconSize: scaler.getTextSize(14),
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedIconTheme: IconThemeData(size:  scaler.getTextSize(14)),
            selectedItemColor: Theme.of(context).accentColor,
            unselectedItemColor: Theme.of(context).hintColor.withOpacity(1),
            currentIndex: widget.currentTab,
            onTap: (int i) {
              this._selectTab(i);
            },
            // this will be set when a new tab is tapped
            items: [
              BottomNavigationBarItem(
                icon: Icon(UiIcons.bell),
                title: new Container(height: 0.0),
              ),
              BottomNavigationBarItem(
                icon: Icon(UiIcons.user_1),
                title: new Container(height: 0.0),
              ),
              BottomNavigationBarItem(
                  title: new Container(height: 5.0),
                  icon: Container(
                    width:  scaler.getWidth(9),
                    height: scaler.getHeight(3.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).accentColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                        BoxShadow(
                            color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                      ],
                    ),
                    child: new Icon(UiIcons.home, color:config.Colors.secondDarkColors),
                  )),
              BottomNavigationBarItem(
                icon: new Icon(UiIcons.chat),
                title: new Container(height: 0.0),
              ),
              BottomNavigationBarItem(
                icon: new Icon(UiIcons.heart),
                title: new Container(height: 0.0),
              ),
            ],
          ),
        ),
        onWillPop: _onWillPop
    );
  }
  Future<bool> _onWillPop() async {
    // return WidgetHelper().showFloatingFlushbar(context, "success", "desc");
    return (
    WidgetHelper().notifDialog(context,"Information", "tekan oke untuk keluar",()=>Navigator.of(context).pop(false), ()=>SystemNavigator.pop())
        // UserRepository().notifAlertQ(context, "info ", "Keluar", "Kamu yakin akan keluar dari aplikasi ?", "Ya", "Batal", ()=>SystemNavigator.pop(), ()=>Navigator.of(context).pop(false))
    ) ?? false;
  }

}
