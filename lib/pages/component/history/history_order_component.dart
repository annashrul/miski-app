import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/pages/widget/history/history_order_widget.dart';

// ignore: must_be_immutable
class HistoryOrderComponent extends StatefulWidget {
  int currentTab;
  HistoryOrderComponent({this.currentTab});
  @override
  _HistoryOrderComponentState createState() => _HistoryOrderComponentState();
}

class _HistoryOrderComponentState extends State<HistoryOrderComponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int status=5;
  @override
  void initState() {
    super.initState();
    status=widget.currentTab;
  }
  String layout="list";
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    List<Widget> historyTab = [];
    List<Widget> historyView = [];
    List historyArray=FunctionHelper.arrOptDate;

    for(int i=0;i<historyArray.length;i++){
      status=i;
      historyView.add(HistoryOrderWidget(status:status,layout:layout));
      historyTab.add(
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),border: Border.all(color: Theme.of(context).accentColor, width: 1)),
            child: Align(
              alignment: Alignment.center,
              child: Text(historyArray[i]),
            ),
          ),
        ),
      );
    }
    return DefaultTabController(
        initialIndex: widget.currentTab ?? 0,
        length: historyArray.length,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: new IconButton(
              icon: new Icon(UiIcons.return_icon, color: Theme.of(context).hintColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: config.MyFont.title(context: context,text:"Riwayat belanja"),
            bottom: TabBar(
              labelStyle: config.MyFont.textStyle,
              labelPadding: scaler.getPadding(0,0.5),
              unselectedLabelColor: Theme.of(context).accentColor,
              labelColor: Theme.of(context).primaryColor,
              isScrollable: true,
              indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).accentColor),
              tabs: historyTab,
              onTap: (e){
                this.setState(() {
                  status=e;
                });
              },
            ),
          ),
          body: TabBarView(children:historyView),
        ));
  }
}
