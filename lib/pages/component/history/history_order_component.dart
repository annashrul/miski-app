import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/history/history_transaction_model.dart';
import 'package:netindo_shop/pages/widget/drawer_widget.dart';
import 'package:netindo_shop/pages/widget/history/history_order_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

// ignore: must_be_immutable
class HistoryOrderComponent extends StatefulWidget {
  int currentTab;
  HistoryOrderComponent({this.currentTab});
  @override
  _HistoryOrderComponentState createState() => _HistoryOrderComponentState();
}

class _HistoryOrderComponentState extends State<HistoryOrderComponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  HistoryTransactionModel historyTransactionModel;
  bool isLoading=true,isError=false;
  Future loadHistory()async{
    String par = "transaction/report?page=1&perpage=10";
    var res = await HandleHttp().getProvider(par, historyTransactionModelFromJson);
    if(res!=null){
      HistoryTransactionModel result = HistoryTransactionModel.fromJson(res.toJson());
      if(res!=StringConfig.errNoData||result.result.data.length<1) setState(() {
        isError=true;
      });


      historyTransactionModel = result;
      isLoading=false;
      if(this.mounted){setState(() {});}
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadHistory();
  }
  String layout="list";
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    List<Widget> historyTab = [];
    List<Widget> historyView = [];
    List historyArray=[];
    historyArray.add("semua");
    historyArray.addAll(FunctionHelper.arrOptDate);
    print(layout);
    for(int i=0;i<historyArray.length;i++){
      historyView.add(HistoryOrderWidget(status:i,layout:layout));
      historyTab.add(
        Tab(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),border: Border.all(color: Theme.of(context).accentColor, width: 1)),
            child: Align(
              alignment: Alignment.center,
              child: Text(historyArray[i],style: config.MyFont.textStyle.copyWith(fontSize: 14)),
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
          drawer: DrawerWidget(),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: new IconButton(
              icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              WidgetHelper().iconAppbar(color:this.layout == 'list' ? Theme.of(context).accentColor : Theme.of(context).focusColor,context: context,icon:Icons.format_list_bulleted,callback: ()=>this.setState(() {
                layout="list";
              })),
              WidgetHelper().iconAppbar(color:this.layout == 'grid' ? Theme.of(context).accentColor : Theme.of(context).focusColor,context: context,icon:Icons.apps,callback: ()=>this.setState(() {
                layout="grid";
              })),
            ],
            title: config.MyFont.title(context: context,text:"Riwayat belanja"),
            bottom: TabBar(
              labelPadding: scaler.getPadding(0,0.5),
              unselectedLabelColor: Theme.of(context).accentColor,
              labelColor: Theme.of(context).primaryColor,
              isScrollable: true,
              physics: NeverScrollableScrollPhysics(),
              indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).accentColor),
              tabs: historyTab
            ),
          ),
          body: TabBarView(children:historyView),
        ));
  }
}
