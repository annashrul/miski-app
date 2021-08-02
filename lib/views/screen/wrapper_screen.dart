import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/home/home_screen.dart';
import 'package:netindo_shop/views/screen/profile/profile_screen.dart';
import 'package:netindo_shop/views/screen/ticket/ticket_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/public_home_screen.dart';

class WrapperScreen extends StatefulWidget {
  int currentTab = StringConfig.defaultTab;
  int selectedTab = StringConfig.defaultTab;
  String currentTitle = 'Home';
  WrapperScreen({
    Key key,
    this.currentTab,
  }) : super(key: key);
  @override
  _WrapperScreenState createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  Widget currentPage;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String foto='',nama='';
  final userHelper = UserHelper();
  String check='';String id='';
  String namaTenant='',idTenant='';
  bool isTenant=true;
  Future loadData() async{
    var cek = await FunctionHelper().checkTenant();
    print("tenant");
    SharedPreferences sess = await SharedPreferences.getInstance();
    bool isBoolTenant=sess.getBool("isTenant");
    String idt=sess.getString("idTenant");
    String namat=sess.getString("namaTenant");
    if(!isBoolTenant){
      print("CEK STATUS TENANT ${sess.getBool("isTenant")}");
      print("CEK ID TENANT ${sess.getString("idTenant")}");
      currentPage = HomeScreen(id:idt,nama:namat);
    }
    else{
      print("CEK STATUS TENANT true");
      print("CEK ID TENANT kosong");
      currentPage = PublicHomeScreen();
    }
    final name = await userHelper.getDataUser('nama');
    final poto = await userHelper.getDataUser('foto');
    setState(() {
      idTenant=idt;
      namaTenant=namat;
      isTenant=isBoolTenant;
      nama = name;
      foto = poto;
    });
  }


  @override
  initState() {
    super.initState();
    loadData();
  }
  @override
  void didUpdateWidget(WrapperScreen oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
    loadData();
  }
  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      widget.selectedTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentTitle = 'Account';
          currentPage = ProfileScreen();
          break;
        case 1:
          widget.currentTitle = 'Home';
          currentPage = isTenant?PublicHomeScreen():HomeScreen(id: idTenant,nama:namaTenant);
          break;
        case 2:
          widget.currentTitle = 'Messages';
          currentPage = TicketScreen();
          break;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: widget.currentTitle=='Home'?null:WidgetHelper().myAppBarNoButton(context,"Hai, $nama",<Widget>[
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(right: 20.0,top:10),
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Icon(
                  Ionicons.ios_notifications,
                  color:Theme.of(context).hintColor,
                  size: 28,
                ),
              ),
              Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.all(Radius.circular(10))),
                constraints: BoxConstraints(minWidth: 10, maxWidth: 10, minHeight: 10, maxHeight: 10),
              ),
            ],
          ),
        )
      ]),
      body:currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).accentColor,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 22,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(size: 25),
        unselectedItemColor: Theme.of(context).hintColor.withOpacity(1),
        currentIndex: widget.selectedTab,
        onTap: (int i) {
          this._selectTab(i);
        },
        // this will be set when a new tab is tapped
        items: [
          // BottomNavigationBarItem(
          //   icon: Icon(AntDesign.barchart),
          //   title: new Container(height: 0.0),
          // ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.profile),
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
                child: new Icon(AntDesign.home, color: Colors.white),
              )),
          BottomNavigationBarItem(
            icon: new Icon(AntDesign.message1),
            title: new Container(height: 0.0),
          ),
          // BottomNavigationBarItem(
          //   icon: new Icon(AntDesign.hearto),
          //   title: new Container(height: 0.0),
          // ),
        ],
      ),
    );
  }
}


