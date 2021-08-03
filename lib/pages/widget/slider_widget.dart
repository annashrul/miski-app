import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/helper/widget_helper.dart';

class SliderWidget extends StatefulWidget {
  final List data;
  SliderWidget({this.data});
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> with SingleTickerProviderStateMixin {
  int _current = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            viewportFraction: 1.0,
            height: scaler.getHeight(20),
            onPageChanged: (index,reason) {
              setState(() {
                _current=index;
              });
            },
          ),
          items: widget.data.map((slide){
            return Container(
              margin: scaler.getMarginLTRB(2,1,2,0),
              height: scaler.getHeight(20),
              child: WidgetHelper().myRipple(
                callback: (){
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(slide.image), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.2), offset: Offset(0, 4), blurRadius: 9)
                    ],
                  ),
                )
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 25,
          right: 41,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: widget.data.map((slide) {
              return Container(
                width: 20.0,
                height: 3.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: _current ==  widget.data.indexOf(slide)
                        ? Theme.of(context).hintColor
                        : Theme.of(context).hintColor.withOpacity(0.3)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
