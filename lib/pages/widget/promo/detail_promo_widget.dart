import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/detail_address_model.dart';
import 'package:netindo_shop/model/promo/detail_global_promo_model.dart';
import 'package:netindo_shop/pages/widget/product/porduct_list_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';

import '../drawer_widget.dart';

class DetailPromoWidget extends StatefulWidget {
  final String id;
  DetailPromoWidget({this.id});
  @override
  _DetailPromoWidgetState createState() => _DetailPromoWidgetState();
}

class _DetailPromoWidgetState extends State<DetailPromoWidget>  with SingleTickerProviderStateMixin{
  DetailGlobalPromoModel detailGlobalPromoModel;
  bool isLoading=true;
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _tabIndex = 0;
  Future loadData()async{
    final res=await HandleHttp().getProvider("promo/${widget.id}",detailGlobalPromoModelFromJson,context: context);
    if(res!=null){
      detailGlobalPromoModel=DetailGlobalPromoModel.fromJson(res.toJson());
      isLoading=false;
      if(this.mounted){
        this.setState(() {});
      }
    }
  }
  @override
  void initState() {
    _tabController = TabController(length: 2, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
    loadData();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    // return Scaffold(
    //   appBar: WidgetHelper().appBarWithButton(context, "Detail promo", (){},<Widget>[],param: "default"),
    //   body:
    // );



    return isLoading?WidgetHelper().loadingWidget(context):Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(),
      bottomNavigationBar:  detailGlobalPromoModel.result.isVoucher==1?Padding(
      padding: EdgeInsets.all(10),
      child:  Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // child:
            // child: WidgetHelper().textQ(detailGlobalPromoModel.result.kode,14,Colors.white,FontWeight.bold),
            decoration: BoxDecoration(
                color:Colors.grey,
                borderRadius: BorderRadius.circular(10.0)
            ),
            padding: EdgeInsets.all(10.0),
            // child: config.MyFont.title(context: context,text:detailGlobalPromoModel.result.kode),
            child: config.MyFont.title(context: context,text:"0909090909"),
          ),
          SizedBox(width: 10.0),
          InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: (){
              Clipboard.setData(new ClipboardData(text: "0000"));
              WidgetHelper().showFloatingFlushbar(context,"success","Kode promo berhasil disalin");
            },
            child: Container(
              decoration: BoxDecoration(
                color:SiteConfig().secondColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(10.0),
              child:  config.MyFont.title(context: context,text:"Salin kode"),
            ),
          )
        ],
      ),
    ):Text(""),
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          snap: true,
          floating: true,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(UiIcons.return_icon, color: Theme.of(context).primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),

          expandedHeight: 250,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: Center(
                    child: Hero(
                      tag: "${detailGlobalPromoModel.result.title}${detailGlobalPromoModel.result.id}",
                      child: WidgetHelper().baseImage(
                        StringConfig.noImage,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -60,
                  bottom: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(300),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  top: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(150),
                    ),
                  ),
                )
              ],
            ),
          ),

        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Offstage(
              offstage: 0 != _tabIndex,
              child: Padding(
                padding: scaler.getPadding(1,2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    config.MyFont.title(context: context,text: detailGlobalPromoModel.result.title,fontSize: 11),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WidgetHelper().titleQ(context, detailGlobalPromoModel.result.title,icon: UiIcons.alarm_clock,fontSize: 9,fontWeight: FontWeight.normal),
                        config.MyFont.subtitle(context: context,text: DateFormat("yyyy-MM-dd hh:mm:ss").format(detailGlobalPromoModel.result.periodeEnd),fontWeight: FontWeight.normal),
                      ],
                    ),
                    Divider(),
                    config.MyFont.subtitle(context: context,text: detailGlobalPromoModel.result.deskripsi,fontWeight: FontWeight.normal,maxLines: 1000),
                  ],
                ),
              ),
            ),
            Offstage(
              offstage: 1 != _tabIndex,
              child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      detailGlobalPromoModel.result.detail.length<1?EmptyTenant():ListView.separated(
                        padding: scaler.getPadding(1,2),
                        addRepaintBoundaries: true,
                        primary: false,
                        shrinkWrap: true,
                        itemCount:detailGlobalPromoModel.result.detail.length ,
                        itemBuilder: (context, index) {
                          final res = detailGlobalPromoModel.result.detail[index];
                          return WidgetHelper().titleQ(context, "barang promo",
                            image: res.gambar,
                            subtitle: "diskon ${res.disc1.toString()} + ${res.disc2.toString()}",
                            fontSize: 9,
                            fontWeight: FontWeight.normal
                          );
                        },
                        separatorBuilder: (context,index){return Divider();},
                      )
                    ],
                  )
              ),
            ),
          ]),
        )
      ]),
    );
  }
}
