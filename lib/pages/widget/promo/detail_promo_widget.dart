import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/promo/detail_global_promo_model.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:miski_shop/provider/promo_provider.dart';
import 'package:provider/provider.dart';
import '../empty_widget.dart';


class DetailPromoWidget extends StatefulWidget {
  final dynamic data;
  DetailPromoWidget({this.data});
  @override
  _DetailPromoWidgetState createState() => _DetailPromoWidgetState();
}

class _DetailPromoWidgetState extends State<DetailPromoWidget>  with SingleTickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    final promo = Provider.of<PromoProvider>(context, listen: false);
    promo.readDetail(context, widget.data["id"]);
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    final promo = Provider.of<PromoProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar:  !promo.isLoadingDetail&&promo.detailGlobalPromoModel.result.isVoucher==1?Padding(
        padding: EdgeInsets.all(10),
        child:  Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            decoration: BoxDecoration(
                color:Colors.grey,
                borderRadius: BorderRadius.circular(10.0)
            ),
            padding: EdgeInsets.all(10.0),
            child: config.MyFont.title(context: context,text:promo.detailGlobalPromoModel.result.kode),
          ),
          SizedBox(width: 10.0),
          InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: (){
              Clipboard.setData(new ClipboardData(text: promo.detailGlobalPromoModel.result.kode));
              WidgetHelper().showFloatingFlushbar(context,"success","Kode promo berhasil disalin");
            },
            child: Container(
              decoration: BoxDecoration(
                color:Theme.of(context).accentColor,
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
                      tag: widget.data["hero"]+widget.data["id"],
                      child: WidgetHelper().baseImage(
                        widget.data["image"],
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
            Padding(
              padding: scaler.getPadding(1,2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  promo.isLoadingDetail?WidgetHelper().baseLoading(context, WidgetHelper().shimmer(context: context,height: 1,width: 80)):config.MyFont.title(context: context,text:  promo.detailGlobalPromoModel.result.title,fontSize: 11),
                  SizedBox(height: scaler.getHeight(1)),
                  promo.isLoadingDetail?WidgetHelper().baseLoading(context, WidgetHelper().shimmer(context: context,height: 1,width: 50)):WidgetHelper().titleQ(context, "Berlaku sampai ${DateFormat("yyyy-MM-dd hh:mm:ss").format( promo.detailGlobalPromoModel.result.periodeEnd)}",icon: UiIcons.alarm_clock,fontSize: 9,fontWeight: FontWeight.normal),
                  Divider(),
                  promo.isLoadingDetail?WidgetHelper().baseLoading(context, ListView.builder(
                      padding: scaler.getPadding(0, 0),
                      cacheExtent: 1.0,
                      itemCount: 15,
                      shrinkWrap: true,
                      primary: true,
                      itemBuilder: (context,i){
                        return Container(
                            width: MediaQuery.of(context).size.width/2,
                            child: WidgetHelper().shimmer(context: context,width: MediaQuery.of(context).size.width/1)
                        );
                      }
                  )):config.MyFont.subtitle(context: context,text:  promo.detailGlobalPromoModel.result.deskripsi,fontWeight: FontWeight.normal,maxLines: 1000),
                ],
              ),
            ),
          ]),
        )
      ]),
    );
  }
}
