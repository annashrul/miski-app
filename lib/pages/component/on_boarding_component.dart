import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';

class OnBoardingComponent extends StatefulWidget {
  @override
  _OnBoardingComponentState createState() => _OnBoardingComponentState();
}

class _OnBoardingComponentState extends State<OnBoardingComponent> {
  int _current = 0;
  List resOnboarding=[];
  Future loadOnboarding()async{
    print("LOAD ONBOARDING");
    resOnboarding.add({"image": 'img/onboarding0.png', "description": 'Don\'t cry because it\'s over, smile because it happened.'});
    resOnboarding.add({"image": 'img/onboarding1.png', "description": 'Be yourself, everyone else is already taken.'});
    resOnboarding.add({"image": 'img/onboarding2.png', "description": 'So many books, so little time.'});
    resOnboarding.add({"image": 'img/onboarding3.png', "description": 'A room without books is like a body without a soul.'});
    setState(() {});
  }


  @override
  void initState() {
    loadOnboarding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler  = config.ScreenScale(context).scaler;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.96),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding:scaler.getPadding(4, 4),
              child: FlatButton(
                onPressed: () { Navigator.of(context).pushNamed('/${StringConfig.signIn}');},
                child: config.MyFont.title(context: context,text: 'Skip',color: Theme.of(context).primaryColor),
                color: Theme.of(context).accentColor,
                shape: StadiumBorder(),
              ),
            ),
            CarouselSlider(
              options: CarouselOptions(
                height: scaler.getHeight(50),
                viewportFraction: 1.0,
                onPageChanged: (index,reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: resOnboarding.map((e){
                return Builder(
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: scaler.getPadding(2, 2),
                          child: Image.asset(
                            e['image'],
                            width: scaler.getWidth(100),
                          ),
                        ),
                        Container(
                          width:scaler.getWidth(75),
                          padding: scaler.getPaddingLTRB(0, 0, 2, 0),
                          child: config.MyFont.title(context: context,text: e['description']),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
            Container(
              width:scaler.getWidth(75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: resOnboarding.map((e){
                  return Container(
                    width: scaler.getWidth(4),
                    height: scaler.getHeight(0.2),
                    margin: scaler.getMargin(1,0.4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: _current == resOnboarding.indexOf(e)
                            ? Theme.of(context).hintColor.withOpacity(0.8)
                            : Theme.of(context).hintColor.withOpacity(0.2)),
                  );
                }).toList(),
              ),
            ),
            Container(
              width:scaler.getWidth(75),
              padding: scaler.getPadding(5,0),
              child: FlatButton(
                padding: scaler.getPadding(1,6),
                onPressed: () {
                  Navigator.of(context).pushNamed('/${StringConfig.signUp}');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    config.MyFont.title(context: context,text: 'Sign up',color: Theme.of(context).primaryColor),
                    Icon(
                      AntDesign.arrowright,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
