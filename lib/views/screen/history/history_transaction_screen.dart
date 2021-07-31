import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/history/history_transaction_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/detail_checkout_screen.dart';
import 'package:netindo_shop/views/screen/history/detail_history_transaction_screen.dart';
import 'package:netindo_shop/views/widget/choose_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:netindo_shop/views/widget/review/form_review_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';

class HistoryTransactionScreen extends StatefulWidget {
  final int status;
  HistoryTransactionScreen({this.status});
  @override
  _HistoryTransactionScreenState createState() => _HistoryTransactionScreenState();
}

class _HistoryTransactionScreenState extends State<HistoryTransactionScreen> with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  int perpage=10;
  int total=0;
  ScrollController controller;

  bool isLoadmore=false;
  bool isTimeout=false;
  int filterStatus=5;
  HistoryTransactionModel historyTransactionModel;
  bool isLoading=false;
  Future loadHistory()async{
    String par = "transaction/report?page=1&perpage=$perpage";
    if(filterStatus!=5){
      par+="&status=$filterStatus";
    }
    var res = await BaseProvider().getProvider(par, historyTransactionModelFromJson);
    if(res is HistoryTransactionModel){
      setState(() {
        historyTransactionModel = HistoryTransactionModel.fromJson(res.toJson());
        total=res.result.total;
      });
      setState(() {
        isLoading=false;
        isLoadmore=false;
      });
    }
    else{
      setState(() {
        isTimeout=true;
        isLoading=false;
        isLoadmore=false;
      });
    }

  }
  void _scrollListener() {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perpage<total){
          setState((){
            perpage = perpage+5;
            isLoadmore=true;
          });
          loadHistory();
        }
      }
    }
  }
  Future<void> _handleRefresh() {
    setState(() {
      isLoading=true;
    });
    loadHistory();
  }





  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterStatus=widget.status;
    isLoading=true;
    controller = new ScrollController()..addListener(_scrollListener);
    loadHistory();

  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context,"History pembelian",(){}, <Widget>[],param: "default"),
      body: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);

    return RefreshWidget(
      widget: Container(
        padding:scaler.getPadding(0,0),
        child: isTimeout?TimeoutWidget(callback: (){
          setState(() {
            isTimeout=false;
            isLoading=true;
          });
          loadHistory();
        }):Column(
          children: [
            Expanded(
                flex: 1,
                child: ListView.builder(
                  padding: scaler.getPadding(0,2),
                  scrollDirection: Axis.horizontal,
                  itemCount: FunctionHelper.arrOptDate.length,
                  itemBuilder: (context,index){
                    double _marginRight = 2;
                    (index == 5) ? _marginRight = 0 : _marginRight = 2;
                    return ChooseWidget(
                      res: {"right":_marginRight,"isActive":filterStatus==index,"title":FunctionHelper.arrOptDate[index]},
                      callback: (){
                        isLoading=true;
                        filterStatus = index;
                        loadHistory();
                        setState(() {});
                      },
                    );
                  },
                )
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              flex: 19,
              child: isLoading?LoadingHistory(tot: 10):historyTransactionModel.result.data.length>0?Column(
                children: [
                  Expanded(
                      flex:16,
                      child: ListView.separated(
                        padding: scaler.getPadding(1,2),
                      key: PageStorageKey<String>('HistoryPembelianScreen'),
                      primary: false,
                      physics: ScrollPhysics(),
                      controller: controller,
                      itemCount: historyTransactionModel.result.data.length,
                      itemBuilder: (context,index){
                        print(historyTransactionModel.result.data[index]);
                        final val=historyTransactionModel.result.data[index];
                        final valDet = historyTransactionModel.result.data[index].detail;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[200],
                                spreadRadius: 0,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: scaler.getPaddingLTRB(1, 1,1,0.5),
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
                                          WidgetHelper().textQ("${val.tenant.toUpperCase()}",scaler.getTextSize(9),LightColor.black,FontWeight.bold),
                                          SizedBox(height: 2.0),
                                          WidgetHelper().textQ("${val.kdTrx}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                                        ],
                                      ),
                                    ),
                                    WidgetHelper().myStatus(context,val.status)
                                  ],
                                ),
                                Divider(),
                                if(valDet.length>0)Row(
                                  children: [
                                    WidgetHelper().baseImage(valDet[0]?.gambar,height: scaler.getHeight(3),width: scaler.getWidth(10),fit: BoxFit.fill),
                                    SizedBox(width: scaler.getWidth(1)),
                                    Column(
                                      children: [
                                        Container(
                                          width: scaler.getWidth(60),
                                          child: WidgetHelper().textQ(valDet[0].barang,scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                                        ),
                                        WidgetHelper().textQ("${valDet.length} * ${FunctionHelper().formatter.format(int.parse(valDet[0].hargaJual))}",scaler.getTextSize(9),LightColor.orange,FontWeight.normal),
                                      ],
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                    ),
                                  ],
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
                                              WidgetHelper().textQ("Total Belanja",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                                              WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(val.grandtotal))} .-",scaler.getTextSize(9),LightColor.orange,FontWeight.normal),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    WidgetHelper().myRipple(
                                      isRadius: true,
                                      radius: 100,
                                      callback: (){
                                        WidgetHelper().myModal(context, Container(
                                          padding: EdgeInsets.only(top:10.0,left:0,right:0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight:Radius.circular(10.0) ),
                                          ),
                                          // color: Colors.white,
                                          child: Padding(
                                            padding: scaler.getPadding(0.5, 2),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                SizedBox(height:10.0),
                                                Center(
                                                  child: Container(
                                                    padding: EdgeInsets.only(top:10.0),
                                                    width: 50,
                                                    height: 10.0,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:  BorderRadius.circular(10.0),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height:10.0),
                                                WidgetHelper().myRipple(
                                                    callback: (){
                                                      WidgetHelper().myPush(context,DetailHistoryTransactoinScreen(noInvoice:base64.encode(utf8.encode(val.kdTrx))));
                                                    },
                                                    child:  Padding(
                                                      padding: scaler.getPadding(0.5, 0),
                                                      child: Row(
                                                        children: [
                                                          Icon(Ionicons.ios_arrow_dropright_circle,color: LightColor.lightblack),
                                                          SizedBox(width: scaler.getWidth(3)),
                                                          WidgetHelper().textQ("Detail history pembelian", scaler.getTextSize(10),LightColor.lightblack, FontWeight.bold)
                                                        ],
                                                      ),
                                                    )
                                                ),
                                                if(val.status==0) WidgetHelper().myRipple(
                                                    callback: (){
                                                      WidgetHelper().myPush(context,DetailCheckoutScreen(
                                                        param:"bisa",
                                                        invoice_no:"${val.kdTrx}",
                                                        grandtotal:"${val.grandtotal}",
                                                        kode_unik:"${val.kodeUnik}",
                                                        total_transfer:"${int.parse(val.jumlahTf)}",
                                                        bank_logo:"${val.bankLogo}",
                                                        bank_name:"${val.bankTujuan}",
                                                        bank_atas_nama:"${val.atasNama}",
                                                        bank_acc:"${val.rekeningTujuan}",
                                                        bank_code:"${val.bankCode}",
                                                      ));
                                                    },
                                                    child:  Padding(
                                                      padding: scaler.getPadding(0.5, 0),
                                                      child: Row(
                                                        children: [
                                                          Icon(Ionicons.md_cloud_upload,color: LightColor.lightblack),
                                                          SizedBox(width: scaler.getWidth(3)),
                                                          WidgetHelper().textQ("Upload bukti transfer", scaler.getTextSize(10),LightColor.lightblack, FontWeight.bold)
                                                        ],
                                                      ),
                                                    )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        padding: scaler.getPadding(0.5, 1),
                                        child: Icon(Ionicons.ios_more,color: LightColor.lightblack),
                                      ),
                                    )

                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    separatorBuilder: (context,index){
                        return SizedBox(height: 10.0);
                    },
                  )
                  ),
                  isLoadmore?Expanded(flex:4,child: LoadingHistory(tot: 1)):Container()
                ],
              ):EmptyTenant(),
            )
          ],
        ),
      ),
      callback: (){_handleRefresh();},
    );
  }


}



