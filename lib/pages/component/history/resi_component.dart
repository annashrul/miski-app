import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/checkout/resi_model.dart';

// ignore: must_be_immutable
class ResiComponent extends StatefulWidget {
  ResiModel resiModel;
  ResiComponent({this.resiModel});
  @override
  _ResiComponentState createState() => _ResiComponentState();
}

class _ResiComponentState extends State<ResiComponent> {
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
      key: scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context, "Lacak Resi ${widget.resiModel.result.resi}", (){Navigator.pop(context);},<Widget>[]),
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

              padding:EdgeInsets.only(top: 20.0, bottom: 0.0, left: 15.0, right: 15.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      config.MyFont.subtitle(context: context,text:"No.Resi",color: Theme.of(context).textTheme.caption.color),
                      config.MyFont.subtitle(context: context,text:widget.resiModel.result.resi),


                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      config.MyFont.subtitle(context: context,text:"Tanggal pengiriman",color: Theme.of(context).textTheme.caption.color),
                      config.MyFont.subtitle(context: context,text:"${DateFormat.yMMMMd().format(widget.resiModel.result.ongkir.details.waybillDate)} ${widget.resiModel.result.ongkir.details.waybillTime}"),

                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      config.MyFont.subtitle(context: context,text:"Service code",color: Theme.of(context).textTheme.caption.color),
                      config.MyFont.subtitle(context: context,text:widget.resiModel.result.ongkir.summary.courierName),

                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      config.MyFont.subtitle(context: context,text:"Pembeli",color: Theme.of(context).textTheme.caption.color),
                      config.MyFont.subtitle(context: context,text:widget.resiModel.result.ongkir.deliveryStatus.podReceiver),


                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      config.MyFont.subtitle(context: context,text:"Status",color: Theme.of(context).textTheme.caption.color),
                      config.MyFont.subtitle(context: context,text:widget.resiModel.result.ongkir.deliveryStatus.status),


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
    final scaler=config.ScreenScale(context).scaler;
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
                    padding:scaler.getPadding(1,0),
                    child: new Row(
                      children: <Widget>[
                        new Padding(
                          padding:
                          new EdgeInsets.symmetric(horizontal: 20.0 - 12.0 / 2),
                          child: new Container(
                            height: 12.0,
                            width: 12.0,
                            decoration: new BoxDecoration(shape: BoxShape.circle, color:config.Colors.mainColors),
                          ),
                        ),
                        new Expanded(
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              config.MyFont.subtitle(context: context,text:DateFormat.yMMMMd().format(val.manifestDate.toLocal()),color: Theme.of(context).textTheme.caption.color),
                              config.MyFont.subtitle(context: context,text:val.manifestDescription.toLowerCase(),),
                            ],
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child:config.MyFont.subtitle(context: context,text:val.manifestTime,color: Theme.of(context).textTheme.caption.color),

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
      top: 200.0,
      bottom: 0.0,
      left: 20,
      child: new Container(
        width: 1.0,
        color:config.Colors.mainColors,
      ),
    );
  }
}
