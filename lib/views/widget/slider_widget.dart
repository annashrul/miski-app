import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  int _current = 0;
  List resSlider=[];
  Future loadSlider()async{
    resSlider.add({"image": 'assets/img/slide1.jpg'});
    resSlider.add({"image": 'assets/img/slide2.jpg'});
    resSlider.add({"image": 'img/slider2.jpg'});
    setState(() {});
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadSlider();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: true,
            height: 250,
            enlargeCenterPage: false,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: resSlider.map((slide) => Container(
            width: double.infinity,
            height: 250,
            child: Container(
              width: double.infinity,
              child: Image.asset(
                slide['image'],
                fit: BoxFit.fill,
                width:
                MediaQuery.of(context).size.width,
              ),
            ),
          )).toList(),
        ),
        Positioned(
          bottom: 25,
          right: 41,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: resSlider.map((slide) {
              return Container(
                width: 20.0,
                height: 3.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: _current == resSlider.indexOf(slide)
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
