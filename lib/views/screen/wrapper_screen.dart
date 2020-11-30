import 'package:flutter/material.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/history/history_transaction_screen.dart';
import 'package:netindo_shop/views/screen/product/favorite_screen.dart';
import 'package:netindo_shop/views/screen/profile/profile_screen.dart';
import 'package:netindo_shop/views/screen/ticket/ticket_screen.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';

import 'home/public_home_screen.dart';

class WrapperScreen extends StatefulWidget {
  int currentTab = 2;
  int selectedTab = 2;
  String currentTitle = 'Home';
  Widget currentPage = PublicHomeScreen();
  int otherParam=5;
  WrapperScreen({
    Key key,
    this.currentTab,
    this.otherParam
  }) : super(key: key);
  @override
  _WrapperScreenState createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String foto='',nama='';
  final userHelper = UserHelper();
  String check='';String id='';

  Future loadData() async{
    final name = await userHelper.getDataUser('nama');
    final poto = await userHelper.getDataUser('foto');
    setState(() {
      nama = name;
      foto = poto;
    });
  }
  bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }
  @override
  initState() {
    _selectTab(widget.currentTab);
    super.initState();
    loadData();
    getSite();
  }

  @override
  void didUpdateWidget(WrapperScreen oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
    loadData();
    getSite();
  }

  void _selectTab(int tabItem) {
    getSite();
    setState(() {
      widget.currentTab = tabItem;
      widget.selectedTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentTitle = 'History';
          widget.currentPage = HistoryTransactionScreen(status:widget.otherParam==null?5:widget.otherParam);
          break;
        case 1:
          widget.currentTitle = 'Account';
          widget.currentPage = ProfileScreen();
          break;
        case 2:
          widget.currentTitle = 'Home';
          widget.currentPage = PublicHomeScreen();
          break;
        case 3:
          widget.currentTitle = 'Messages';
          widget.currentPage = TicketScreen(mode: site);
          break;
        case 4:
          widget.currentTitle = 'Favorites';
          widget.currentPage = FavoriteScreen(mode: site);
          break;
      }
    });
  }
  static const _kFontFam = 'EcommerceAppUI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: site?SiteConfig().darkMode:Colors.white,
      key: _scaffoldKey,
      appBar: WidgetHelper().myAppBarNoButton(context,"Hai, $nama",<Widget>[
        // new CartWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(right: 20.0,top:10),
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Icon(
                  UiIcons.bell,
                  color:site?Colors.white:Theme.of(context).hintColor,
                  size: 28,
                ),
              ),
              Container(
                child: Text(
                  "1",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption.merge(
                    TextStyle(color: Theme.of(context).primaryColor, fontSize: 9),
                  ),
                ),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.all(Radius.circular(10))),
                constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
              ),
            ],
          ),
        )
      ],brightness: site?Brightness.dark:Brightness.light),
      body: widget.currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).accentColor,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 22,
        elevation: 0,
        backgroundColor: site?SiteConfig().darkMode:Colors.transparent,
        selectedIconTheme: IconThemeData(size: 25),
        unselectedItemColor: site?Colors.white:Theme.of(context).hintColor.withOpacity(1),
        currentIndex: widget.selectedTab,
        onTap: (int i) {
          this._selectTab(i);
        },
        // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: Icon(UiIcons.bar_chart),
            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: Icon(UiIcons.user_1),
            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
              title: new Container(height: 5.0),
              icon: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                    BoxShadow(
                        color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                  ],
                ),
                child: new Icon(const IconData(0xe800, fontFamily: _kFontFam), color: Theme.of(context).primaryColor),
              )),
          BottomNavigationBarItem(
            icon: new Icon(const IconData(0xe81c, fontFamily: _kFontFam)),
            title: new Container(height: 0.0),
          ),
          BottomNavigationBarItem(
            icon: new Icon( const IconData(0xe801, fontFamily: _kFontFam)),
            title: new Container(height: 0.0),
          ),
        ],
      ),
    );
  }
}
