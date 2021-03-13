import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
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

    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 10,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: scaler.getHeight(5),
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
                            WidgetHelper().textQ(widget.nama, scaler.getTextSize(9), SiteConfig().mainColor, FontWeight.bold),
                            Row(
                              children: <Widget>[
                                Icon(AntDesign.calendar, color:SiteConfig().accentColor,size:  scaler.getTextSize(9),),
                                SizedBox(width: 10),
                                WidgetHelper().textQ("${widget.tgl}",  scaler.getTextSize(8),SiteConfig().accentColor, FontWeight.normal),
                              ],
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                      RatingBar.builder(
                        unratedColor: Colors.grey,
                        itemSize: 15.0,
                        initialRating: double.parse(widget.rate),
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemPadding: EdgeInsets.only(right: 4.0),
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent,
                              );
                            case 2:
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                              );
                            case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                            default:
                              return Container();
                          }
                        },
                        onRatingUpdate:null,
                      )

                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        WidgetHelper().textQ("${widget.desc}", 10,SiteConfig().accentColor, FontWeight.normal),
      ],
    );
  }
}
