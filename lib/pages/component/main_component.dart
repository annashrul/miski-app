import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/home/function_home.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/slider/ListSliderModel.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/pages/component/chat/chat_component.dart';
import 'package:netindo_shop/pages/component/favorite/favorite_component.dart';
import 'package:netindo_shop/pages/component/home/home_component.dart';
import 'package:netindo_shop/pages/component/notification/notification_component.dart';
import 'package:netindo_shop/pages/component/profile/profile_component.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';

// ignore: must_be_immutable
class MainComponent extends StatefulWidget {
  int currentTab = StringConfig.defaultTab;
  int selectedTab = StringConfig.defaultTab;
  String currentTitle = 'Home';
  Widget currentPage;
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
  String id="";
  ListProductTenantModel listProductTenantModel;
  ListSliderModel listSliderModel;
  List resKelompok=[];
  bool isLoadingProduct=true,isLoadingGroup=true,isLoadingSlider=true;
  callHome(product,kelompok,slider){
    widget.currentPage = HomeComponent(
        callback: (id){
          if(id=="norefresh"){
            loadCart();
            return;
          }
          loadDataHome(id);
          setState(() {});
        },
        product: product,
        kelompok:kelompok,
        slider:slider
    );
  }
  Future loadDataHome(kelompok)async{
    if(kelompok!=""){
      final resProduct = await FunctionHome().loadProduct(context: context,idKelompok: kelompok);
      callHome(resProduct, resKelompok,listSliderModel);
      if(this.mounted){
        this.setState(() {listProductTenantModel=resProduct;});
      }
      return;
    }
    final resProduct = await FunctionHome().loadProduct(context: context,idKelompok: kelompok);
    final resGroup = await FunctionHome().loadGroup(context: context);
    final resSlider = await FunctionHome().loadSlider(context: context);
    if(this.mounted){
      callHome(resProduct, resGroup,resSlider);
      this.setState(() {
        listProductTenantModel=resProduct;
        listSliderModel=resSlider;
        resKelompok=resGroup;
        isLoadingProduct=false;
        isLoadingGroup=false;
        isLoadingSlider=false;
      });
    }
  }

  @override
  initState() {
    _selectTab(widget.currentTab);
    super.initState();
    loadDataHome('');
  }

  @override
  void didUpdateWidget(MainComponent oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);

  }

  Future loadCart()async{
    String idTenant = await FunctionHelper().getSession(StringConfig.idTenant);
    final res = await BaseProvider().countCart(idTenant);
    print("LOAD CART = $res");
    if(this.mounted) setState(() {
      totalCart = res;
      idTenant=id;
    });
  }

  void _selectTab(int tabItem) {
    loadCart();
    setState(() {
      widget.currentTab = tabItem;
      widget.selectedTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentTitle = 'Notifications';
          widget.currentPage = NotificationComponent();
          break;
        case 1:
          widget.currentTitle = 'Profile';
          widget.currentPage = ProfileComponent();
          break;
        case 2:
          widget.currentTitle = 'Home';
          callHome(listProductTenantModel,resKelompok,listSliderModel);
          break;
        case 3:
          widget.currentTitle = 'Messages';
          widget.currentPage = ChatComponent();
          break;
        case 4:
          widget.currentTitle = 'Favorites';
          widget.currentPage = FavoriteComponent();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(FlutterIcons.ios_menu_ion, color: Theme.of(context).hintColor),
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: config.MyFont.title(context: context,text: widget.currentTitle),
        actions: [
          WidgetHelper().iconAppBarBadges(context: context,icon:FlutterIcons.cart_outline_mco,isActive: totalCart>0,callback: (){
            Navigator.of(context).pushNamed("/${StringConfig.cart}").whenComplete((){
              loadCart();
            });
          }),
        ],
      ),
      body: isLoadingSlider||isLoadingGroup||isLoadingProduct?WidgetHelper().loadingWidget(context):widget.currentPage,
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
            icon: Icon(FlutterIcons.bell_circle_outline_mco),
            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIcons.account_circle_outline_mco),
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
                child: new Icon(FlutterIcons.home_outline_mco, color:config.Colors.secondDarkColors),
              )),
          BottomNavigationBarItem(
            icon: new Icon(FlutterIcons.message_circle_fea),
            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: new Icon(FlutterIcons.heart_circle_outline_mco),
            title: new Container(height: 0.0),
          ),
        ],
      ),
    );
  }
}
