import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/skeleton_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/resi_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/model/history/detail_history_transaction_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/resi_screen.dart';
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
              WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2));
            },(){
              WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2));
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
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context, "Detail Riwayat Pembelian", (){Navigator.pop(context);},<Widget>[
      ],brightness: Brightness.light),
      body: isTimeout?TimeoutWidget(callback: ()async{
        setState(() {
          isTimeout=false;
          isLoading=true;
        });
        await loadData();
      },):(isLoading?_loading(context):buildContent(context)),
      bottomNavigationBar:isLoading?Text(''):Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, -2)),],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: Cro,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                  onPressed: () {checkResi();},
                  padding: EdgeInsets.symmetric(vertical: 14),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child:WidgetHelper().textQ("Lacak Resi",12, Theme.of(context).primaryColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),
            SizedBox(width: 10),
            detailHistoryTransactionModel.result.resi!='-'?Expanded(
              child: FlatButton(
                  onPressed: () {},
                  padding: EdgeInsets.symmetric(vertical: 14),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child:WidgetHelper().textQ("Selesai",12, Theme.of(context).primaryColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ):Expanded(
              child: FlatButton(
                  onPressed: () {
                    WidgetHelper().myPush(context,FormReviewWidget(detailHistoryTransactionModel: detailHistoryTransactionModel));
                  },
                  padding: EdgeInsets.symmetric(vertical: 14),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child:WidgetHelper().textQ("Beri Ulasan",12, Theme.of(context).primaryColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context){
    return  SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding:EdgeInsets.only(top: 20.0, bottom: 0.0, left: 15.0, right: 15.0),
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
                          WidgetHelper().textQ("Status",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().myStatus(context,detailHistoryTransactionModel.result.status),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Tanggal Pembelian",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${DateFormat.yMMMMEEEEd('id').format(detailHistoryTransactionModel.result.createdAt)} ${DateFormat.Hms().format(detailHistoryTransactionModel.result.createdAt)}",10.0,SiteConfig().secondColor,FontWeight.normal),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("No.Invoice",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${detailHistoryTransactionModel.result.kdTrx}",10.0,SiteConfig().secondColor,FontWeight.normal),
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
                      WidgetHelper().textQ("Daftar Produk",14.0,SiteConfig().darkMode,FontWeight.bold),
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
                      WidgetHelper().textQ("Detail Pengiriman",14.0,SiteConfig().darkMode,FontWeight.bold),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Nama Toko",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${detailHistoryTransactionModel.result.tenant}",10.0,SiteConfig().secondColor,FontWeight.normal),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Kurir Pengiriman",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${detailHistoryTransactionModel.result.kurir}",10.0,SiteConfig().secondColor,FontWeight.normal),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("No.Resi",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${detailHistoryTransactionModel.result.resi=="-"?"Belum ada No.Resi":detailHistoryTransactionModel.result.resi}",10.0,SiteConfig().secondColor,FontWeight.normal),
                        ],
                      ),
                      detailHistoryTransactionModel.result.resi=="-"?Container():GestureDetector(
                        onTap: () {
                          Clipboard.setData(new ClipboardData(text: detailHistoryTransactionModel.result.resi));
                        },
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            WidgetHelper().textQ("",12.0,SiteConfig().secondColor,FontWeight.bold),
                            WidgetHelper().textQ("Salin No.Resi",12.0,SiteConfig().secondColor,FontWeight.bold),
                          ],
                        ),
                      ) ,

                      Divider(),
                      WidgetHelper().textQ("Alamat Pengiriman",12.0,SiteConfig().darkMode,FontWeight.bold),
                      SizedBox(height: 5.0,),
                      WidgetHelper().textQ("jalan kebon manggu rt 02/04 kelurahan padasuka kecamatan cimahi tengah kota cimahi",10.0,SiteConfig().darkMode,FontWeight.normal),
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
                      WidgetHelper().textQ("Informasi Pembayaran",14.0,SiteConfig().darkMode,FontWeight.bold),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Metode Pembayaran",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("Transfer",10.0,SiteConfig().secondColor,FontWeight.normal),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Total Harga",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(detailHistoryTransactionModel.result.subtotal))}",12.0,Colors.green,FontWeight.bold),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidgetHelper().textQ("Total Ongkos Kirim",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(detailHistoryTransactionModel.result.ongkir))}",12.0,Colors.green,FontWeight.bold),
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
                          WidgetHelper().textQ("Total Pembayaran",12.0,SiteConfig().darkMode,FontWeight.normal),
                          WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(detailHistoryTransactionModel.result.grandtotal))}",12.0,Colors.green,FontWeight.bold),
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
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(left: 0,right:0,top:10,bottom:0),
      width:  width / 1,
      // color: Colors.white,
      child: new StaggeredGridView.countBuilder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        itemCount: detailHistoryTransactionModel.result.barang.length,
        itemBuilder: (BuildContext context, int index) {
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
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
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
