import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/home/home_component.dart';

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
  @override
  initState() {
    _selectTab(widget.currentTab);
    super.initState();
  }

  @override
  void didUpdateWidget(MainComponent oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    print("tab active $tabItem");
    setState(() {
      widget.currentTab = tabItem;
      widget.selectedTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentTitle = 'Notifications';
          widget.currentPage = HomeComponent();
          break;
        case 1:
          widget.currentTitle = 'Profile';
          widget.currentPage = HomeComponent();
          break;
        case 2:
          widget.currentTitle = 'Home';
          widget.currentPage = HomeComponent();
          break;
        case 3:
          widget.currentTitle = 'Messages';
          widget.currentPage = HomeComponent();
          break;
        case 4:
          widget.currentTitle = 'Favorites';
          widget.currentPage = HomeComponent();
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
          WidgetHelper().iconAppBarBadges(context: context,icon:FlutterIcons.cart_outline_mco),
        ],
      ),
      body: widget.currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: scaler.getTextSize(12),
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(size:  scaler.getTextSize(12)),
        selectedItemColor: Theme.of(context).accentColor,
        unselectedItemColor: Theme.of(context).hintColor.withOpacity(1),
        currentIndex: widget.currentTab,
        onTap: (int i) {
          this._selectTab(i);
          print(i);
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
                child: new Icon(FlutterIcons.home_outline_mco, color:Theme.of(context).hintColor.withOpacity(1)),
              )),
          BottomNavigationBarItem(
            icon: new Icon(FlutterIcons.chat_outline_mco),
            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: new Icon(FlutterIcons.heart_outline_mco),
            title: new Container(height: 0.0),
          ),
        ],
      ),
    );
  }
}
