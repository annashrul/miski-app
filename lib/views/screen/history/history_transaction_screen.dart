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
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
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
        padding:scaler.getPadding(0,2),
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
                  scrollDirection: Axis.horizontal,
                  itemCount: FunctionHelper.arrOptDate.length,
                  itemBuilder: (context,index){
                    print(FunctionHelper.arrOptDate.length-1);
                    double _marginRight = 2;
                    (index == 5) ? _marginRight = 0 : _marginRight = 2;
                    return  Container(
                      margin: scaler.getMarginLTRB(0, 0, _marginRight, 0),
                      child: WidgetHelper().myPress(
                              (){
                            setState(() {
                              isLoading=true;
                              filterStatus = index;
                            });
                            loadHistory();

                          },
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            decoration: BoxDecoration(
                              border: Border.all(width:filterStatus==index?2.0:1.0,color: filterStatus==index?LightColor.orange:Colors.grey[200]),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                WidgetHelper().textQ("${FunctionHelper.arrOptDate[index]}", scaler.getTextSize(9),Colors.grey, FontWeight.bold),
                                // Icon(Icons.keyboard_arrow_down,size: 17.0,color: Colors.grey,),
                              ],
                            ),
                          )
                      ),
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
                      key: PageStorageKey<String>('HistoryPembelianScreen'),
                      primary: false,
                      physics: ScrollPhysics(),
                      controller: controller,
                      itemCount: historyTransactionModel.result.data.length,
                      itemBuilder: (context,index){
                        print(historyTransactionModel.result.data[index]);
                        final val=historyTransactionModel.result.data[index];
                        final valDet = historyTransactionModel.result.data[index].detail;
                        return WidgetHelper().myPress(
                              (){
                              WidgetHelper().myPush(context,DetailHistoryTransactoinScreen(noInvoice:base64.encode(utf8.encode(val.kdTrx))));
                            },
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).focusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left:10,right:10,top:10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              WidgetHelper().textQ("${val.tenant.toUpperCase()}",scaler.getTextSize(9),LightColor.titleTextColor,FontWeight.bold),
                                              SizedBox(height: 2.0),
                                              WidgetHelper().textQ("${val.kdTrx}",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                            ],
                                          ),
                                        ),
                                        WidgetHelper().myStatus(context,val.status)
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10,right:10,top:5,bottom:5),
                                    child: Container(
                                      color: Colors.grey[200],
                                      height: 1.0,
                                      width: double.infinity,
                                    ),
                                  ),
                                  if(valDet.length>0)Padding(
                                    padding: EdgeInsets.only(left:10,right:10,top:0),
                                    child: Row(
                                      children: [
                                        Image.network(valDet[0]?.gambar,height: 50,width: 50,fit: BoxFit.fill,),
                                        SizedBox(width: 10.0),
                                        Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width/1.5,
                                              child: WidgetHelper().textQ(valDet[0].barang,scaler.getTextSize(9),Colors.black87,FontWeight.normal),
                                            ),
                                            WidgetHelper().textQ("${valDet.length} barang",scaler.getTextSize(8),Colors.grey,FontWeight.normal),
                                            WidgetHelper().textQ("Ukuran ${valDet[0].subvarian!=null?valDet[0].subvarian:"-"} Warna ${valDet[0].varian!=null?valDet[0].varian:"-"}",scaler.getTextSize(8),Colors.grey,FontWeight.normal),
                                          ],
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(left:10,right:10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Column(
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  WidgetHelper().textQ("Total Belanja",scaler.getTextSize(9),Colors.black87,FontWeight.normal),
                                                  WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val.grandtotal))}",scaler.getTextSize(9),Colors.green,FontWeight.normal),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          child:InkWell(
                                            onTap: (){
                                              if(val.status==0){
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
                                              }
                                              else{

                                              }
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                    color: SiteConfig().mainColor,
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
                                                    ]),
                                                child: Center(
                                                  child: WidgetHelper().textQ(val.status==0?"Upload Bukti Transfer":"Beri Ulasan",scaler.getTextSize(8),Colors.white, FontWeight.bold),
                                                )
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            )
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

