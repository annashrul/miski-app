import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/skeleton_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/resi_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/model/history/detail_history_transaction_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/detail_checkout_screen.dart';
import 'package:netindo_shop/views/screen/checkout/resi_screen.dart';
import 'package:netindo_shop/views/screen/product/product_detail_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/product/second_product_widget.dart';
import 'package:netindo_shop/views/widget/review/form_review_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';

class DetailHistoryTransactoinScreen extends StatefulWidget {
  final String noInvoice;
  DetailHistoryTransactoinScreen({this.noInvoice});
  @override
  _DetailHistoryTransactoinScreenState createState() => _DetailHistoryTransactoinScreenState();
}

class _DetailHistoryTransactoinScreenState extends State<DetailHistoryTransactoinScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DetailHistoryTransactionModel detailHistoryTransactionModel;
  final GlobalKey<AnimatedListState> _listKey = new GlobalKey<AnimatedListState>();

  bool isLoading=false;
  bool isTimeout=false;
  int retry=0;
  ResiModel resiModel;
  Future loadData()async{
    var res = await BaseProvider().getProvider("transaction/report/${widget.noInvoice}", detailHistoryTransactionModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isLoading=false;
        isTimeout=true;
      });
    }
    else{
      setState(() {
        detailHistoryTransactionModel = DetailHistoryTransactionModel.fromJson(res.toJson());
        isLoading=false;
        isTimeout=false;
      });
    }
  }
  Future checkResi() async{
    if(detailHistoryTransactionModel.result.resi!='-'){
      WidgetHelper().showFloatingFlushbar(context,"failed","No.Resi belum tersedia");
    }
    else{
      WidgetHelper().loadingDialog(context);
      var res = await BaseProvider().postProvider("kurir/cek/resi",{
        // "resi":detailHistoryTransactionModel.result.resi,
        "resi":'Jd0098226293',
        "kurir":'jnt'
      });
      if(res == '${SiteConfig().errTimeout}'|| res=='${SiteConfig().errSocket}'){
        Navigator.pop(context);
        WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Mohon maaf server kami sedang dalam masalah", (){Navigator.of(context).pop();},(){Navigator.of(context).pop();});
      }
      else{
        if(res is General){
          General result = res;
          Navigator.pop(context);
          if(retry>=3){
            WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Silahkan lakukan pembuatan tiket komplain di halaman tiket", (){
              WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
            },(){
              WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
            },titleBtn1: "kembali",titleBtn2: "home");
          }
          else{
            WidgetHelper().notifDialog(context,"Terjadi Kesalahan","${result.msg}", (){
              Navigator.pop(context);
            },(){
              Navigator.pop(context);
              checkingAgain();
            },titleBtn1: "kembali",titleBtn2: "Coba lagi");
          }
        }
        else{
          Navigator.pop(context);
          setState(() {
            resiModel = ResiModel.fromJson(res);
          });
          WidgetHelper().myPush(context,ResiScreen(resiModel: resiModel));
        }
      }
    }

  }
  Future checkingAgain()async{
    await checkResi();
    setState(() {
      retry+=1;
    });
  }
  String appID = "";
  String output = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    loadData();
    initializeDateFormatting('id');

  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context, "Detail Riwayat Pembelian", (){Navigator.pop(context);},<Widget>[
        if(!isLoading&&detailHistoryTransactionModel.result.status==0)Container(
          margin:scaler.getMarginLTRB(0, 0, 0,0),
          padding: scaler.getPadding(0.2, 0),
          child: WidgetHelper().myRipple(
            isRadius: true,
              radius: 100,
              callback: (){
                WidgetHelper().myPush(context,DetailCheckoutScreen(
                  param:"bisa",
                  invoice_no:"${detailHistoryTransactionModel.result.kdTrx}",
                  grandtotal:"${detailHistoryTransactionModel.result.grandtotal}",
                  kode_unik:"${detailHistoryTransactionModel.result.kodeUnik}",
                  total_transfer:"${int.parse(detailHistoryTransactionModel.result.jumlahTf)}",
                  bank_logo:"${detailHistoryTransactionModel.result.logo}",
                  bank_name:"${detailHistoryTransactionModel.result.bankTujuan}",
                  bank_atas_nama:"${detailHistoryTransactionModel.result.atasNama}",
                  bank_acc:"${detailHistoryTransactionModel.result.rekeningTujuan}",
                  bank_code:"${detailHistoryTransactionModel.result.bankCode}",
                ));              },
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  padding: scaler.getPadding(0.5, 2),
                  alignment: Alignment.center,
                  child: Icon(Ionicons.md_cloud_upload,color: LightColor.lightblack,)
              ),
          ),
        )
      ]),
      body: isTimeout?TimeoutWidget(callback: ()async{
        setState(() {
          isTimeout=false;
          isLoading=true;
        });
        await loadData();
      },):(isLoading?_loading(context):buildContent(context)),
      bottomNavigationBar:isLoading?Text(''):Container(
        padding:scaler.getPadding(0,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if(detailHistoryTransactionModel.result.status!=0)Expanded(
              child: FlatButton(
                  onPressed: () {
                    WidgetHelper().myPush(context,FormReviewWidget(detailHistoryTransactionModel: detailHistoryTransactionModel));
                  },
                  padding:scaler.getPadding(1,0),
                  color: LightColor.mainDarkColor,
                  // shape: StadiumBorder(),
                  child:WidgetHelper().textQ("Beri Ulasan",scaler.getTextSize(10), Theme.of(context).primaryColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),
            if(detailHistoryTransactionModel.result.resi!='-') Expanded(
              child: FlatButton(
                  onPressed: () {checkResi();},
                  padding:scaler.getPadding(1,0),
                  color: SiteConfig().secondColor,
                  child:WidgetHelper().textQ("Lacak Resi",scaler.getTextSize(10), Theme.of(context).primaryColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),
            if(detailHistoryTransactionModel.result.resi!='-')Expanded(
              child: FlatButton(
                  onPressed: () {},
                  padding:scaler.getPadding(1,0),
                  color: LightColor.mainDarkColor,
                  // shape: StadiumBorder(),
                  child:WidgetHelper().textQ("Selesai",scaler.getTextSize(10), Theme.of(context).primaryColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return  SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding:scaler.getPadding(1,2),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Status",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().myStatus(context,detailHistoryTransactionModel.result.status),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Tgl pembelian",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().textQ("${DateFormat.yMMMMEEEEd('id').format(detailHistoryTransactionModel.result.createdAt)} ${DateFormat.Hms().format(detailHistoryTransactionModel.result.createdAt)}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("No.Invoice",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().textQ("${detailHistoryTransactionModel.result.kdTrx}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Divider(color: Colors.grey[200]),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("Daftar Produk",scaler.getTextSize(10),SiteConfig().darkMode,FontWeight.bold),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    buildItem(context),
                  ],
                ),
                Container(
                  child: Divider(color: Colors.grey[200]),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("Detail Pengiriman",scaler.getTextSize(10),LightColor.black,FontWeight.bold),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Nama Toko",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().textQ("${detailHistoryTransactionModel.result.tenant}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Kurir Pengiriman",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              WidgetHelper().baseImage(detailHistoryTransactionModel.result.logoKurir,height: scaler.getHeight(1)),
                              SizedBox(width: scaler.getWidth(1)),
                              WidgetHelper().textQ("${detailHistoryTransactionModel.result.kurir}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){
                          if(detailHistoryTransactionModel.result.resi!="-"){
                            Clipboard.setData(new ClipboardData(text: detailHistoryTransactionModel.result.resi));
                            WidgetHelper().showFloatingFlushbar(context,"success"," no resi berhasil disalin");
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            WidgetHelper().textQ("No.Resi",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                            Row(
                              children: [
                                WidgetHelper().textQ("${detailHistoryTransactionModel.result.resi=="-"?"Belum ada No.Resi":detailHistoryTransactionModel.result.resi}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                                if(detailHistoryTransactionModel.result.resi!="-")Icon(Ionicons.ios_copy, color:LightColor.lightblack,size: scaler.getTextSize(9),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      WidgetHelper().textQ("jalan kebon manggu rt 02/04 kelurahan padasuka kecamatan cimahi tengah kota cimahi",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                    ],
                  ),
                ),
                Container(
                  child: Divider(color: Colors.white),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("Informasi Pembayaran",scaler.getTextSize(10),LightColor.black,FontWeight.bold),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Metode Pembayaran",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().textQ("Transfer",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Total Harga",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(detailHistoryTransactionModel.result.subtotal))} .-",scaler.getTextSize(9),LightColor.orange,FontWeight.normal),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Total Ongkos Kirim",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(detailHistoryTransactionModel.result.ongkir))} .-",scaler.getTextSize(9),LightColor.orange,FontWeight.normal),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:EdgeInsets.only(top: 0.0, bottom: 10.0),
                  child: Divider(),
                ),
                Container(
                  padding:EdgeInsets.only(top: 0.0, bottom: 10.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Total Pembayaran",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                          WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(detailHistoryTransactionModel.result.grandtotal))} .-",scaler.getTextSize(9),LightColor.orange,FontWeight.normal),
                        ],
                      ),
                    ],
                  ),
                ),
                // Container(color:Colors.white,height: 20.0,child: Container()),

              ],
            )
          ],
        ),
      ),
    );

  }

  Widget buildItem(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(left: 0,right:0,top:10,bottom:0),
      width:  width / 1,
      // color: Colors.white,
      child: new StaggeredGridView.countBuilder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 1,
        itemCount: detailHistoryTransactionModel.result.barang.length,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int index) {
          var val=detailHistoryTransactionModel.result.barang[index];
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
            child: WidgetHelper().myRipple(
              callback: (){
                WidgetHelper().myPush(context,ProductDetailPage(id:val));
              },
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: WidgetHelper().baseImage(val.gambar,height: scaler.getHeight(10),width: scaler.getWidth(10),fit: BoxFit.fill),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    WidgetHelper().textQ(val.barang, scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(val.hargaJual))} * ${val.qty}",  scaler.getTextSize(9),LightColor.orange,FontWeight.normal),
                        WidgetHelper().textQ("=",  scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                        WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(val.subtotal))}",  scaler.getTextSize(9),LightColor.orange,FontWeight.normal)
                      ],
                    ),
                  ],
                ),
              )
            ),
          );
          return FirstProductWidget(
            id: detailHistoryTransactionModel.result.barang[index].id,
            gambar: detailHistoryTransactionModel.result.barang[index].gambar,
            title: detailHistoryTransactionModel.result.barang[index].barang,
            harga: detailHistoryTransactionModel.result.barang[index].hargaJual,
            hargaCoret: "0",
            rating: "0",
            stock: SiteConfig().noDataCode.toString(),
            stockSales: "0",
            disc1: "${detailHistoryTransactionModel.result.barang[index].varian==null?"-":detailHistoryTransactionModel.result.barang[index].varian}",
            disc2: "${detailHistoryTransactionModel.result.barang[index].subvarian==null?"-":detailHistoryTransactionModel.result.barang[index].subvarian}",
            countCart: (){},
          );
        },
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
      ),
    );
  }


  Widget _loading(BuildContext context){
    return  SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            // decoration: BoxDecoration(color: Colors.white),
            padding:EdgeInsets.only(top: 20.0, bottom: 0.0, left: 15.0, right: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,)
                  ],
                ),

                Divider(),
                SizedBox(height: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,)
                  ],
                ),
                SizedBox(height: 0.0),
                Divider(),
                SizedBox(height: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,)
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:EdgeInsets.only(top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
            // color: Colors.white,
            child: Divider(color: Colors.white),
          ),
          Container(
            // color: Colors.white,
            padding:EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,),
                SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0,)
              ],
            ),
          ),
          Container(
            width:  MediaQuery.of(context).size.width/1,
            color: Colors.transparent,
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: 2,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Row(
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.only(left:10.0,right:5.0),
                                    width: 70.0,
                                    height: 70.0,
                                    child: SkeletonFrame(width: 70.0,height: 70.0,)
                                )
                              ],

                            ),
                          ),
                          new Expanded(
                              child: new Container(
                                margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                                child: new Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(0.0),
                                      child: SkeletonFrame(width: MediaQuery.of(context).size.width/2,height: 10.0),
                                    ),
                                    SizedBox(height: 5.0),
                                    SkeletonFrame(width: MediaQuery.of(context).size.width/1.5,height: 10.0),
                                    SizedBox(height: 5.0),
                                    SkeletonFrame(width: MediaQuery.of(context).size.width/1.5,height: 10.0),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              )),
                        ],
                      ),
                      Container(
                        padding:EdgeInsets.only(top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
                        // color: Colors.white,
                        child: Divider(color: Colors.white),
                      ),
//                  SizedBox(height: 10.0,child: Container(color: Colors.transparent)),
                    ],
                  );
                }),
          ),
          Container(
            // color: Colors.white,
            padding:EdgeInsets.only(top: 0.0, bottom: 10.0, left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SkeletonFrame(width: MediaQuery.of(context).size.width/1.3,height: 10.0),
              ],
            ),
          ),
          Container(
            // decoration: BoxDecoration(color: Colors.white),
            padding:EdgeInsets.only(top: 20.0, bottom: 20.0, left: 15.0, right: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                  ],
                ),

                Divider(color: Colors.white),
                SkeletonFrame(width: MediaQuery.of(context).size.width/1,height: 10.0),
                SizedBox(height: 5.0,),
                SkeletonFrame(width: MediaQuery.of(context).size.width/1,height: 10.0),
              ],
            ),
          ),

          Container(
            // color: Colors.white,
            padding:EdgeInsets.only(top: 0.0, bottom: 10.0, left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SkeletonFrame(width: MediaQuery.of(context).size.width/1.7,height: 10.0),
              ],
            ),
          ),
          Container(
            // decoration: BoxDecoration(color: Colors.white),
            padding:EdgeInsets.only(top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                  ],
                ),
                Divider(),
                SizedBox(height: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                  ],
                ),
              ],
            ),
          ),
          Container(
            // color: Colors.white,
            padding:EdgeInsets.only(top: 0.0, bottom: 10.0, left: 15.0, right: 15.0),
            child: Divider(color: Colors.white),
          ),
          Container(
            // decoration: BoxDecoration(color: Colors.white),
            padding:EdgeInsets.only(top: 0.0, bottom: 0.0, left: 15.0, right: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10.0),
                  ],
                ),
              ],
            ),
          ),
          // Container(color:Colors.white,height: 20.0,child: Container())
        ],
      ),
    );
  }
}
