import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';

// ignore: must_be_immutable
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
      radius: 0,
      callback: (){},
      child: Wrap(
        direction: Axis.horizontal,
        runSpacing: 10,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: WidgetHelper().baseImage(widget.foto,shape: BoxShape.circle,height: scaler.getHeight(4),width: scaler.getWidth(10)),
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
                                  WidgetHelper().icons(ctx:context,icon: UiIcons.calendar,color: Theme.of(context).focusColor),
                                  SizedBox(width: scaler.getWidth(1)),
                                  config.MyFont.subtitle(context: context,text:widget.time,fontSize: 8,color: Theme.of(context).textTheme.caption.color),
                                ],
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        WidgetHelper().myRating(context: context,rating: widget.rate)

                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          config.MyFont.subtitle(context: context,text:"${widget.caption}",fontSize: 9),
        ],
      )
    );
  }
}



