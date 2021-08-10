import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/history/history_transaction_model.dart';
import 'package:netindo_shop/model/history/order/history_order_model.dart';
import 'package:netindo_shop/pages/widget/history/history_modal_option_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/review/form_review_widget.dart';

// ignore: must_be_immutable
class HistoryOrderWidget extends StatefulWidget {
  int status;
  String layout;
  HistoryOrderWidget({this.status,this.layout});
  @override
  _HistoryOrderWidgetState createState() => _HistoryOrderWidgetState();
}

class _HistoryOrderWidgetState extends State<HistoryOrderWidget> {
  HistoryOrderModel historyOrderModel;
  bool isLoading=true,isError=false,isLoadmore=false;
  int filterStatus=5;
  ScrollController controller;
  int perpage=StringConfig.perpage,total=0;

  void _scrollListener() {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        print("bus");
        if(perpage<total){
          setState((){
            perpage+=perpage;
            isLoadmore=true;
          });
          loadHistory();
        }else{
          setState((){
            isLoadmore=false;
          });
        }
      }
    }
  }

  Future loadHistory()async{
    String par = "transaction/report?page=1&perpage=$perpage";
    if(widget.status!=5){
      par+="&status=${widget.status}";
    }
    print(filterStatus);
    var res = await HandleHttp().getProvider(par, historyOrderModelFromJson,context: context);

    if(res!=null){
      HistoryOrderModel result = HistoryOrderModel.fromJson(res.toJson());
      if(res!=StringConfig.errNoData||result.result.data.length<1) {
        if(this.mounted){
          setState(() {

            isError=true;
          });
        }
      }

      historyOrderModel = result;
      total=result.result.total;
      isLoadmore=false;
      isLoading=false;
      if(this.mounted){setState(() {});}
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadHistory();
    initializeDateFormatting('id');
    controller = new ScrollController()..addListener(_scrollListener);
    setState(() {
      filterStatus=widget.status;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.removeListener(_scrollListener);
  }

  String layout = 'list';


  @override
  Widget build(BuildContext context) {
    return buildItem(context);

  }


  Widget buildItem(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return isLoading?LoadingHistory(tot: 10):historyOrderModel.result.data.length>0?Column(
      children: [
        Expanded(
          flex: 19,
          child: ListView.separated(
            padding: scaler.getPadding(1,2),
            key: PageStorageKey<String>('HistoryPembelianScreen'),
            primary: false,
            controller: controller,
            itemCount: historyOrderModel.result.data.length,
            itemBuilder: (context,index){
              final val=historyOrderModel.result.data[index];
              final valDet = historyOrderModel.result.data[index].detail;
              return WidgetHelper().chip(
                  ctx: context,
                  child: Container(
                    padding: scaler.getPaddingLTRB(1, 0,1,0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  config.MyFont.title(context: context,text:val.tenant,fontSize: 9,fontWeight: FontWeight.normal),
                                  SizedBox(height: 2.0),
                                  config.MyFont.subtitle(context: context,text:"${DateFormat.yMMMMEEEEd('id').format(val.createdAt)} ${DateFormat.Hms().format(val.createdAt)}",fontSize:8,fontWeight: FontWeight.normal,color: Theme.of(context).textTheme.caption.color),
                                ],
                              ),
                            ),
                            WidgetHelper().myStatus(context,val.status)
                          ],
                        ),
                        Divider(),
                        if(valDet.length>0)WidgetHelper().titleQ(
                            context,
                            valDet[0].barang,
                            image: valDet[0]?.gambar,
                            subtitle: "${valDet.length} barang",
                            fontSize: 9,
                            fontWeight: FontWeight.normal,
                            callback: (){
                              Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
                                "heroTag":"producthistory${valDet[0].idBarang}$index",
                                "id":valDet[0].idBarang,
                                "image":valDet[0].gambar,
                              });
                            }
                        ),
                        if(valDet.length>0)SizedBox(height: scaler.getHeight(0.5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: scaler.getPadding(0, 0),
                              child: Column(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      config.MyFont.title(context: context,text:"Total belanja",fontSize: 9,fontWeight: FontWeight.normal),
                                      config.MyFont.title(context: context,text:"Rp ${config.MyFont.toMoney("${val.grandtotal}")} .-",fontSize:8,fontWeight: FontWeight.normal,color: config.Colors.moneyColors),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            WidgetHelper().myRipple(
                              isRadius: true,
                              radius: 100,
                              callback: (){
                                WidgetHelper().myModal(context, HistoryModalOptionWIdget(
                                  val: val,
                                  barang: valDet,
                                ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                padding: scaler.getPadding(0.5, 1),
                                child: WidgetHelper().icons(ctx: context,icon: Ionicons.ios_more),
                              ),
                            )

                          ],
                        ),
                      ],
                    ),
                  )
              );
            },
            separatorBuilder: (context,index){
              return SizedBox(height: 10.0);
            },
          ),
        ),
        isLoadmore?Expanded(flex:4,child: Container(
          padding: scaler.getPadding(0, 2),
          child: LoadingHistory(tot: 1),
        )):SizedBox()
      ],
    ):EmptyTenant();
  }
}
