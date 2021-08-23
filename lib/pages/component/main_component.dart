import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/component/chat/chat_component.dart';
import 'package:miski_shop/pages/component/favorite/favorite_component.dart';
import 'package:miski_shop/pages/component/home/home_component.dart';
import 'package:miski_shop/pages/component/notification/notification_component.dart';
import 'package:miski_shop/pages/component/profile/profile_component.dart';
import 'package:miski_shop/pages/widget/drawer_widget.dart';
import 'package:miski_shop/provider/cart_provider.dart';
import 'package:miski_shop/provider/tenant_provider.dart';
import 'package:miski_shop/provider/user_provider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MainComponent extends StatefulWidget {
  int currentTab = StringConfig.defaultTab;
  int selectedTab = StringConfig.defaultTab;
  String currentTitle = 'Home';
  Widget currentPage = HomeComponent();
  MainComponent({
    Key key,
    this.currentTab,
    this.currentPage
  }) : super(key: key);
  @override
  _MainComponentState createState() => _MainComponentState();
}

class _MainComponentState extends State<MainComponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    _selectTab(widget.currentTab);
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.getCartData(context);
    final user = Provider.of<UserProvider>(context, listen: false);
    user.getUserData(context);
    final tenant = Provider.of<TenantProvider>(context, listen: false);
    tenant.read();
  }

  @override
  void didUpdateWidget(MainComponent oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget");
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
    final cart = Provider.of<CartProvider>(context);
    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: DrawerWidget(),
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
              WidgetHelper().iconAppBarBadges(
                context: context,
                icon:UiIcons.shopping_cart,
                isActive:cart.isActiveCart,
                callback: (){
                  if(cart.isActiveCart){
                    Navigator.of(context).pushNamed("/${StringConfig.cart}").whenComplete(() => cart.isActiveCart);
                  }
                  else{
                    WidgetHelper().showFloatingFlushbar(context,"failed", "maaf keranjang kamu kosong");

                  }
                }
              ),
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
