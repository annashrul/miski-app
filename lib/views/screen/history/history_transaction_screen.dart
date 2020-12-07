import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
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
  int perpage=5;
  int total=0;
  ScrollController controller;
  bool isLoadmore=false;
  bool isTimeout=false;
  List arrFilter = ["Dari Tanggal","Sampai Tanggal","Semua Status"];
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
    if(dateFrom!=""&&dateTo!=""){
      par+="&datefrom=$dateFrom&dateto=$dateTo";
    }
    print(par);
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
        itemTextStyle: TextStyle(color: site?Colors.white:SiteConfig().darkMode,fontWeight: FontWeight.bold,fontFamily: SiteConfig().fontStyle),
        backgroundColor: site?SiteConfig().darkMode:Colors.white,
        showTitle: true,
        confirm: Text('Selesai', style: TextStyle(color:site?Colors.white:SiteConfig().darkMode,fontFamily:SiteConfig().fontStyle,fontWeight:FontWeight.bold)),
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
              arrFilter[0] = dateFrom;
              isLoading=true;
            });
            loadHistory();
          }
          else {
            setState(() {
              dateTo = '${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}';
              arrFilter[1] = dateTo;
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
      arrFilter[2] = FunctionHelper.arrOptDate[widget.status];
      filterStatus = widget.status;
    });
  }
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
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
    getSite();

    filterStatus=widget.status;
    isLoading=true;
    controller = new ScrollController()..addListener(_scrollListener);
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.year}-${dateParse.month.toString().padLeft(2, '0')}-${dateParse.day.toString().padLeft(2, '0')}";
    dateFrom = formattedDate;
    dateTo = formattedDate;
    _dateTime = DateTime.parse(formattedDate);
    arrFilter[0]=dateFrom;
    arrFilter[1]=dateTo;
    loadHistory();
    changeStatus();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return buildContent(context);
  }

  Widget buildContent(BuildContext context){
    return RefreshWidget(
      widget: Container(
        padding: EdgeInsets.only(top:10,bottom:10,left:20,right:20),
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
                  itemCount: arrFilter.length,
                  itemBuilder: (context,index){
                    return  WidgetHelper().myPress(
                            (){
                          if(index==0||index==1){
                            index==0?_showDatePicker('1'):_showDatePicker('2');
                          }
                          else{
                            modalFilter(context,index);
                          }
                        },
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          decoration: BoxDecoration(
                            border: Border.all(width:3.0,color: site?Colors.white:Colors.grey[200]),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WidgetHelper().textQ("${arrFilter[index]}", 10,Colors.grey, FontWeight.bold),
                              Icon(Icons.keyboard_arrow_down,size: 17.0,color: Colors.grey,),
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
                  Expanded(flex:16,child: ListView.separated(
                      key: PageStorageKey<String>('HistoryPembelianScreen'),
                      primary: false,
                      physics: ScrollPhysics(),
                      controller: controller,
                      itemCount: historyTransactionModel.result.data.length,
                      itemBuilder: (context,index){
                        final val=historyTransactionModel.result.data[index];
                        final valDet = historyTransactionModel.result.data[index].detail;
                        return WidgetHelper().myPress(
                                (){
                              WidgetHelper().myPush(context,DetailHistoryTransactoinScreen(noInvoice:base64.encode(utf8.encode(val.kdTrx))));
                            },
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(width:3.0,color: site?Colors.white:Colors.grey[200]),
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
                                                  WidgetHelper().textQ("( ${val.kdTrx} )",10,SiteConfig().secondColor,FontWeight.bold),
                                                  SizedBox(height: 5.0),
                                                  WidgetHelper().textQ("${DateFormat.yMd().format(val.createdAt.toLocal())} ${DateFormat.Hm().format(val.createdAt.toLocal())}",10,SiteConfig().accentColor,FontWeight.bold),
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
                                  Padding(
                                    padding: EdgeInsets.only(left:10,right:10,top:0),
                                    child: Row(
                                      children: [
                                        Image.network("https://i.pinimg.com/originals/4e/be/50/4ebe50e2495b17a79c31e48a0e54883f.png",height: 50,width: 50),
                                        SizedBox(width: 10.0),
                                        Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width/1.5,
                                              child: WidgetHelper().textQ(valDet[0].barang,12,Colors.black,FontWeight.bold),
                                            ),
                                            WidgetHelper().textQ("${valDet.length} barang",10,Colors.grey,FontWeight.bold),
                                            WidgetHelper().textQ("Ukuran ${valDet[0].subvarian!=null?valDet[0].subvarian:"-"} Warna ${valDet[0].varian!=null?valDet[0].varian:"-"}",10,Colors.grey,FontWeight.bold),
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
                                                  WidgetHelper().textQ("Total Belanja",10,Colors.black,FontWeight.bold),
                                                  WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val.grandtotal))}",10,Colors.green,FontWeight.bold),
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
                                                  child: WidgetHelper().textQ(val.status==0?"Upload Bukti Transfer":"Beri Ulasan",10,Colors.white, FontWeight.bold),
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
                  )),
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


  Widget modalFilter(BuildContext context,int index){
    WidgetHelper().myModal(context, Container(
      decoration: BoxDecoration(
        color: site?SiteConfig().darkMode:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))
      ),
      height: MediaQuery.of(context).size.height/1.5,
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
          SizedBox(height: 20.0),
          Expanded(
            child:FilterStatus(
              site:site,
              val: filterStatus,
              callback: (idx,txt){
                setState(() {
                  arrFilter[2] = txt;
                  filterStatus = idx;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: WidgetHelper().buttonQ(context,(){
              Navigator.of(context).pop();
              setState(() {
                isLoading=true;
              });
              loadHistory();
            },"Terapkan"),
          )
        ],
      ),
    ));
  }
}


class FilterStatus extends StatefulWidget {
  FilterStatus({
    Key key,
    @required this.site,
    @required this.val,
    @required this.callback,
  }) : super(key: key);
  bool site;
  String title;
  final int val;
  final Function(int idx,String txt) callback;
  @override
  _FilterStatusState createState() => _FilterStatusState();
}

class _FilterStatusState extends State<FilterStatus> {
  int value=5;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    value=widget.val;
  }
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: ListView.separated(
          key: PageStorageKey<String>('FilterStatus'),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemBuilder: (context, index) {
            return ListTile(
              onTap: (){
                setState(() {
                  value = index;
                });
                widget.callback(index,FunctionHelper.arrOptDate[index]);
              },
              contentPadding: EdgeInsets.only(left:10,right:10,top:0,bottom:0),
              title: WidgetHelper().textQ("${FunctionHelper.arrOptDate[index]}", 14,widget.site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
              trailing: value==index?Icon(UiIcons.checked,color: widget.site?Colors.grey[200]:SiteConfig().darkMode):Text(
                  ''
              ),
            );
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WidgetHelper().textQ("${FunctionHelper.arrOptDate[index]}", 12,SiteConfig().secondColor, FontWeight.bold),
                new Radio(
                  value: index,
                  groupValue: value,
                  onChanged: (val){
                    widget.callback(val,FunctionHelper.arrOptDate[val]);
                    setState(() {
                      value = index;
                    });
                  },
                ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 1,
            );
          },
          itemCount:FunctionHelper.arrOptDate.length,
          primary: false,
          shrinkWrap: true,
        )
    );
  }
}