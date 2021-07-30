import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class ReviewWidget extends StatefulWidget {
  final String foto;
  final String nama;
  final String tgl;
  final String rate;
  final String desc;
  ReviewWidget({
    this.foto,this.nama,this.tgl,this.rate,this.desc
  });
  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return WidgetHelper().myRipple(
        callback: (){},
        child: Container(
          padding: scaler.getPadding(0,0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200],
                spreadRadius: 20,
                blurRadius: 15,
              ),
            ],
          ),
          child: Wrap(
            direction: Axis.horizontal,
            runSpacing: 10,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: scaler.getHeight(4),
                    width:  scaler.getWidth(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      image: DecorationImage(
                        image: NetworkImage(SiteConfig().noImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
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
                                  WidgetHelper().textQ(widget.nama, scaler.getTextSize(9), LightColor.lightblack, FontWeight.bold),
                                  Row(
                                    children: <Widget>[
                                      Icon(Ionicons.md_time, color:LightColor.lightblack,size:  scaler.getTextSize(9),),
                                      SizedBox(width: 5),
                                      WidgetHelper().textQ("${widget.tgl}",  scaler.getTextSize(9),LightColor.lightblack, FontWeight.normal),
                                    ],
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                            WidgetHelper().rating(widget.rate)
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              WidgetHelper().textQ("${widget.desc}", scaler.getTextSize(9),LightColor.lightblack, FontWeight.normal),
            ],
          ),
        )
    );

  }
}
