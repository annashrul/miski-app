import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/resi_model.dart';

class ResiScreen extends StatefulWidget {
  ResiModel resiModel;
  ResiScreen({this.resiModel});
  @override
  _ResiScreenState createState() => _ResiScreenState();
}

class _ResiScreenState extends State<ResiScreen> {
  final GlobalKey<AnimatedListState> _listKey = new GlobalKey<AnimatedListState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      key: scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context, "Lacak Resi ${widget.resiModel.result.resi}", (){Navigator.pop(context);},<Widget>[],brightness:Brightness.light),
      body: Stack(
        children: <Widget>[
          _buildTimeline(),
          buildContent(context),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context){
    return Container(
      child: Padding(
        padding: new EdgeInsets.only(top: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color:Colors.white),
              padding:EdgeInsets.only(top: 20.0, bottom: 0.0, left: 15.0, right: 15.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("No.Resi",12.0,SiteConfig().secondColor,FontWeight.bold),
                      WidgetHelper().textQ(widget.resiModel.result.resi,12.0,Colors.grey,FontWeight.bold),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("Tanggal Pengiriman",12.0,SiteConfig().secondColor,FontWeight.bold),
                      WidgetHelper().textQ("${DateFormat.yMMMMd().format(widget.resiModel.result.ongkir.details.waybillDate)} ${widget.resiModel.result.ongkir.details.waybillTime}",12.0,Colors.grey,FontWeight.bold),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("Service Code",12.0,SiteConfig().secondColor,FontWeight.bold),
                      WidgetHelper().textQ(widget.resiModel.result.ongkir.summary.courierName,12.0,Colors.grey,FontWeight.bold),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("Pembeli",12.0,SiteConfig().secondColor,FontWeight.bold),
                      WidgetHelper().textQ(widget.resiModel.result.ongkir.deliveryStatus.podReceiver,12.0,Colors.grey,FontWeight.bold),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidgetHelper().textQ("Status",12.0,SiteConfig().secondColor,FontWeight.bold),
                      WidgetHelper().textQ(widget.resiModel.result.ongkir.deliveryStatus.status,12.0,Colors.grey,FontWeight.bold),
                    ],
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),

            _buildTasksList(context)
          ],
        ),
      ),
    );
  }



  Widget _buildTasksList(BuildContext context) {
    return new Expanded(
      child: Scrollbar(
          child: new AnimatedList(
            initialItemCount: widget.resiModel.result.ongkir.manifest.length,
            key: _listKey,
            itemBuilder: (context, index, animation) {
              var val = widget.resiModel.result.ongkir.manifest[index];
              return new FadeTransition(
                opacity: animation,
                child: new SizeTransition(
                  sizeFactor: animation,
                  child: new Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: new Row(
                      children: <Widget>[
                        new Padding(
                          padding:
                          new EdgeInsets.symmetric(horizontal: 32.0 - 12.0 / 2),
                          child: new Container(
                            height: 12.0,
                            width: 12.0,
                            decoration: new BoxDecoration(shape: BoxShape.circle, color:SiteConfig().mainColor),
                          ),
                        ),
                        new Expanded(
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              WidgetHelper().textQ(DateFormat.yMMMMd().format(val.manifestDate.toLocal()), 12,Colors.grey,FontWeight.bold),
                              WidgetHelper().textQ(val.manifestDescription.toLowerCase(), 12,SiteConfig().secondColor,FontWeight.bold),
                            ],
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child:WidgetHelper().textQ(val.manifestTime, 12,SiteConfig().secondColor,FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
      ),
    );
  }


  Widget _buildTimeline() {
    return new Positioned(
      top: 0.0,
      bottom: 0.0,
      left: 32.0,
      child: new Container(
        width: 1.0,
        color:SiteConfig().mainColor,
      ),
    );
  }
}


