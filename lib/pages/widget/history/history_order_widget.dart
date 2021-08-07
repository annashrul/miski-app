import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/model/history/history_transaction_model.dart';
import 'package:netindo_shop/pages/widget/history/history_grid_item_widget.dart';
import 'package:netindo_shop/pages/widget/history/histroy_list_item_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

// ignore: must_be_immutable
class HistoryOrderWidget extends StatefulWidget {
  int status;
  String layout;
  HistoryOrderWidget({this.status,this.layout});
  @override
  _HistoryOrderWidgetState createState() => _HistoryOrderWidgetState();
}

class _HistoryOrderWidgetState extends State<HistoryOrderWidget> {
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


  String layout = 'list';
  @override
  Widget build(BuildContext context) {

    final scaler = config.ScreenScale(context).scaler;
    return SingleChildScrollView(
      padding:scaler.getPadding(0,0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
         Offstage(
            offstage: widget.layout != 'list',
            child:  isLoading?Padding(child: LoadingHistory(tot: 10),padding: scaler.getPadding(1,2)):historyTransactionModel.result.data.length<1?EmptyTenant():ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: historyTransactionModel.result.data.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return HistoryListItemWidget(
                  data:historyTransactionModel,
                  i: index,
                );
              },
            ),
          ),
          Offstage(
            offstage: widget.layout != 'grid',
            child: isLoading?LoadingProductTenant(tot: 10): historyTransactionModel.result.data.length<1?EmptyTenant():Container(
              padding:scaler.getPadding(1,2),
              child: new StaggeredGridView.countBuilder(
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 4,
                itemCount:historyTransactionModel.result.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return HistoryGridItemWidget(
                    data: historyTransactionModel,
                    i: index,
                  );
                },
                staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
