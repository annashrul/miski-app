import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/review/review_model.dart';

class ReviewWidget extends StatefulWidget {
  ReviewWidget({
    this.id,
    this.idMember,
    this.kdBrg,
    this.nama,
    this.caption,
    this.rate,
    this.foto,
    this.time,
    this.createdAt,
    this.updatedAt,
  });
  String id;
  String idMember;
  String kdBrg;
  String nama;
  String caption;
  String rate;
  String foto;
  String time;
  String createdAt;
  String updatedAt;
  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return WidgetHelper().myRipple(
      callback: (){},
      child: Wrap(
        direction: Axis.horizontal,
        runSpacing: 10,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: scaler.getHeight(5),
                width: scaler.getWidth(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  image: DecorationImage(image: AssetImage(StringConfig.localAssets+"user0.jpg"), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: scaler.getWidth(1.5)),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              config.MyFont.title(context: context,text:widget.nama,fontSize: 9),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    UiIcons.calendar,
                                    color: Theme.of(context).focusColor,
                                    size: scaler.getTextSize(12),
                                  ),
                                  SizedBox(width: scaler.getWidth(1)),
                                  config.MyFont.title(context: context,text:widget.time,fontSize: 8,color: Theme.of(context).textTheme.caption.color),
                                ],
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Chip(
                          padding: EdgeInsets.all(0),
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              config.MyFont.title(context: context,text:"${widget.rate}",fontSize: 9,color: Theme.of(context).primaryColor),
                              Icon(
                                Icons.star_border,
                                color: Theme.of(context).primaryColor,
                                size: scaler.getTextSize(10),
                              ),
                            ],
                          ),
                          backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                          shape: StadiumBorder(),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          config.MyFont.title(context: context,text:"${widget.caption}",fontSize: 9),
        ],
      )
    );
  }
}



