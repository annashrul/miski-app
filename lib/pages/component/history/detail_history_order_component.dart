import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/skeleton_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/resi_model.dart';
import 'package:netindo_shop/model/history/detail_history_transaction_model.dart';
import 'package:netindo_shop/model/history/order/detail_history_order_model.dart';
import 'package:netindo_shop/pages/widget/history/history_modal_option_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class DetailHistoryOrderComponent extends StatefulWidget {
  final String data;
  DetailHistoryOrderComponent({this.data});
  @override
  _DetailHistoryOrderComponentState createState() => _DetailHistoryOrderComponentState();
}

class _DetailHistoryOrderComponentState extends State<DetailHistoryOrderComponent> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  DetailHistoryOrderModel detailHistoryOrderModel;
  bool isLoading=false;
  ResiModel resiModel;
  Future loadData()async{
    var res = await HandleHttp().getProvider("transaction/report/${widget.data}", detailHistoryOrderModelFromJson,context: context);
    if(res!=null){
      detailHistoryOrderModel = DetailHistoryOrderModel.fromJson(res.toJson());
      isLoading=false;
      setState(() {});
    }
  }
  Future checkResi() async{
    WidgetHelper().loadingDialog(context);
    var res = await HandleHttp().postProvider("kurir/cek/resi",{
      "resi":'Jd0098226293',
      "kurir":'jnt'
    });
    if(res!=null){
      Navigator.pop(context);
      setState(() { resiModel = ResiModel.fromJson(res);});
      Navigator.of(context).pushNamed("/${StringConfig.resi}");
    }
  }
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
      key: scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context, "Detail Pembelian", (){Navigator.pop(context);},<Widget>[
        WidgetHelper().iconAppbar(context: context,icon: Ionicons.ios_more,callback: (){
          final val=detailHistoryOrderModel.result;
          WidgetHelper().myModal(context, HistoryModalOptionWIdget(
            val: val,
            barang: val.toJson()["barang"],
          ));
        })
      ]),
      body: isLoading?_loading(context):buildContent(context),

    );
  }
  Widget buildContent(BuildContext context){
    final scaler=config.ScreenScale(context).scaler;
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
                          config.MyFont.subtitle(context: context,text:"Status"),
                          WidgetHelper().myStatus(context,detailHistoryOrderModel.result.status),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 0.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          config.MyFont.subtitle(context: context,text:"Tgl pembelian"),
                          config.MyFont.subtitle(context: context,text:"${DateFormat.yMMMMEEEEd('id').format(detailHistoryOrderModel.result.createdAt)} ${DateFormat.Hms().format(detailHistoryOrderModel.result.createdAt)}"),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          config.MyFont.subtitle(context: context,text:"No.Invoice"),
                          config.MyFont.subtitle(context: context,text:"${detailHistoryOrderModel.result.kdTrx}"),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                WidgetHelper().titleQ(context, "Daftar belanjaan",
                  padding: EdgeInsets.all(0),
                  icon: UiIcons.shopping_cart
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    buildItem(context),
                  ],
                ),
                WidgetHelper().titleQ(context, "Detail pengiriman",
                    icon:Ionicons.md_bus
                ),
                SizedBox(height: 5.0),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          config.MyFont.subtitle(context: context,text:"Nama toko"),
                          config.MyFont.subtitle(context: context,text:"${detailHistoryOrderModel.result.tenant}"),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          config.MyFont.subtitle(context: context,text:"Kurir Pengiriman"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.network(detailHistoryOrderModel.result.logoKurir,fit: BoxFit.contain,height: scaler.getHeight(2),),
                              // WidgetHelper().baseImage(detailHistoryOrderModel.result.logoKurir,height: scaler.getHeight(2),width: scaler.getWidth(5)),
                              SizedBox(width: scaler.getWidth(1)),
                              config.MyFont.subtitle(context: context,text:"${detailHistoryOrderModel.result.kurir}"),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      GestureDetector(
                        onTap: (){
                          if(detailHistoryOrderModel.result.resi!="-"){
                            Clipboard.setData(new ClipboardData(text: detailHistoryOrderModel.result.resi));
                            WidgetHelper().showFloatingFlushbar(context,"success"," no resi berhasil disalin");
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            config.MyFont.subtitle(context: context,text:"No.Resi"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                config.MyFont.subtitle(context: context,text:"${detailHistoryOrderModel.result.resi=="-"?"-":detailHistoryOrderModel.result.resi}"),
                                if(detailHistoryOrderModel.result.resi!="-")Icon(Ionicons.ios_copy, color:LightColor.lightblack,size: scaler.getTextSize(9),),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      config.MyFont.subtitle(context: context,text:"jalan kebon manggu rt 02/04 kelurahan padasuka kecamatan cimahi tengah kota cimahi"),
                    ],
                  ),
                ),
                Divider(),
                WidgetHelper().titleQ(context, "Informasi pembayaran",
                    icon:Ionicons.ios_information_circle_outline
                ),
                SizedBox(height: 5.0),
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          config.MyFont.subtitle(context: context,text:"Metode Pembayaran"),
                          config.MyFont.subtitle(context: context,text:"${detailHistoryOrderModel.result.metodePembayaran}"),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          config.MyFont.subtitle(context: context,text:"Total harga"),
                          config.MyFont.subtitle(context: context,text:"Rp ${config.MyFont.toMoney("${detailHistoryOrderModel.result.subtotal}")} .-",color: config.Colors.moneyColors),
                        ],
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          config.MyFont.subtitle(context: context,text:"Total ongkos kirim"),
                          config.MyFont.subtitle(context: context,text:"Rp ${config.MyFont.toMoney("${detailHistoryOrderModel.result.ongkir}")} .-",color: config.Colors.moneyColors),

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
                          config.MyFont.subtitle(context: context,text:"Total pembayaran"),
                          config.MyFont.subtitle(context: context,text:"Rp ${config.MyFont.toMoney("${detailHistoryOrderModel.result.grandtotal}")} .-",color: config.Colors.moneyColors),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

  }

  Widget buildItem(BuildContext context){
    final scaler=config.ScreenScale(context).scaler;
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(left: 0,right:0,top:10,bottom:0),
      width:  width / 1,
      child: new StaggeredGridView.countBuilder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 1,
        itemCount: detailHistoryOrderModel.result.barang.length,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int index) {
          var val=detailHistoryOrderModel.result.barang[index];
          return WidgetHelper().titleQ(
            context,
            val.barang,
            image: val.gambar,
            subtitle: "${val.qty} barang",
            fontSize: 9,
            fontWeight: FontWeight.normal,
            callback: (){
              Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
                "heroTag":val.gambar,
                "id":val.idBarang,
                "image":val.gambar,
              });
            }
          );
        },
        staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
      ),
    );
  }

  Widget _loading(BuildContext context){
    return WidgetHelper().baseLoading(context,  SingleChildScrollView(
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
    ));
  }
}
