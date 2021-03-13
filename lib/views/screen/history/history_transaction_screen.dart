import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
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
  // List arrFilter = FunctionHelper.arrOptDate;
  int filterStatus=5;
  String dateFrom="";
  String dateTo="";
  DateTime _dateTime;
  DateTimePickerLocale _locale = DateTimePickerLocale.id;
  HistoryTransactionModel historyTransactionModel;
  bool isLoading=false;
  Future loadHistory()async{
    String par = "transaction/report?page=1&perpage=$perpage";
    if(filterStatus!=5){
      par+="&status=$filterStatus";
    }
    // if(dateFrom!=""&&dateTo!=""){
    //   par+="&datefrom=$dateFrom&dateto=$dateTo";
    // }
    // print(par);
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
  void _showDatePicker(var param) {
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      pickerTheme: DateTimePickerTheme(
        itemTextStyle: TextStyle(color: SiteConfig().darkMode,fontWeight: FontWeight.bold,fontFamily: SiteConfig().fontStyle),
        backgroundColor: Colors.white,
        showTitle: true,
        confirm: Text('Selesai', style: TextStyle(color:SiteConfig().darkMode,fontFamily:SiteConfig().fontStyle,fontWeight:FontWeight.bold)),
      ),
      minDateTime: DateTime.parse('2010-05-12'),
      maxDateTime: DateTime.parse('2100-01-01'),
      initialDateTime: _dateTime,
      dateFormat: 'yyyy-MM-dd',
      locale: _locale,
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
          if (param == '1') {
            setState(() {
              dateFrom = '${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}';
              // arrFilter[0] = dateFrom;
              isLoading=true;
            });
            loadHistory();
          }
          else {
            setState(() {
              dateTo = '${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}';
              // arrFilter[1] = dateTo;
              isLoading=true;
            });
            loadHistory();
          }

        });
      },
    );
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

  changeStatus(){
    setState(() {
      // arrFilter[2] = FunctionHelper.arrOptDate[widget.status];
      // filterStatus = widget.status;
    });
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
    // if(widget.)
    filterStatus=widget.status;
    isLoading=true;
    controller = new ScrollController()..addListener(_scrollListener);
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.year}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.day.toString().padLeft(2, '0')}";
    dateFrom = formattedDate;
    dateTo = formattedDate;
    _dateTime = DateTime.parse(formattedDate);
    // arrFilter[0]=dateFrom;
    // arrFilter[1]=dateTo;
    loadHistory();
    // changeStatus();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return buildContent(context);
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
                  scrollDirection: Axis.horizontal,
                  itemCount: FunctionHelper.arrOptDate.length,
                  itemBuilder: (context,index){
                    // print(arrFilter[index]);
                    return  WidgetHelper().myPress(
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
                            border: Border.all(width:1.0,color: filterStatus==index?SiteConfig().mainColor:Colors.grey[200]),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WidgetHelper().textQ("${FunctionHelper.arrOptDate[index]}", 10,Colors.grey, FontWeight.bold),
                              // Icon(Icons.keyboard_arrow_down,size: 17.0,color: Colors.grey,),
                            ],
                          ),
                        )
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
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(AntDesign.home,size: 10,color: Colors.black87),
                                                      SizedBox(width: 5.0),
                                                      WidgetHelper().textQ("${val.tenant.toUpperCase()}",scaler.getTextSize(8),Colors.black87,FontWeight.normal),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  WidgetHelper().textQ("${val.kdTrx}",scaler.getTextSize(8),Colors.black87,FontWeight.normal),

                                                  // WidgetHelper().textQ("${DateFormat.yMd().format(val.createdAt.toLocal())} ${DateFormat.Hm().format(val.createdAt.toLocal())}",10,SiteConfig().accentColor,FontWeight.normal),
                                                ],
                                              )
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

