import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/auth/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _current = 0;
  List resOnboarding=[];
  final DatabaseConfig _helper = new DatabaseConfig();

  Future loadOnboarding()async{
    resOnboarding.add({"image": 'img/onboarding0.png', "description": 'Don\'t cry because it\'s over, smile because it happened.'});
    resOnboarding.add({"image": 'img/onboarding1.png', "description": 'Be yourself, everyone else is already taken.'});
    resOnboarding.add({"image": 'img/onboarding2.png', "description": 'So many books, so little time.'});
    resOnboarding.add({"image": 'img/onboarding3.png', "description": 'A room without books is like a body without a soul.'});
    setState(() {});
  }


  @override
  void initState() {
    _helper.openDB();
    loadOnboarding();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.96),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 50),
              child: FlatButton(
                onPressed: () {},
                // child: Text('Skip', style: Theme.of(context).textTheme.button,),
                child:RichText(text: TextSpan(style:TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,fontSize: 14), children: [TextSpan(text:'Skip')])),
                color: Theme.of(context).accentColor,
                shape: StadiumBorder(),
              ),
            ),
            CarouselSlider(
              options: CarouselOptions(
                height: 500.0,
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
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            e['image'],
                            width: 500,
                          ),
                        ),
                        Container(
                          width: config.AppConfig(context).appWidth(75),
                          padding: const EdgeInsets.only(right: 20),
                          child:RichText(text: TextSpan(style:TextStyle(color:config.Colors().secondColor(1),fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,fontSize: 14), children: [TextSpan(text:e['description'])])),

                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
            Container(
              width: config.AppConfig(context).appWidth(75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: resOnboarding.map((e){
                  return Container(
                    width: 25.0,
                    height: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
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
              width: config.AppConfig(context).appWidth(75),
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: FlatButton(
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                onPressed: () {
                  WidgetHelper().myPush(context, SignupScreen());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RichText(text: TextSpan(style:TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle,fontSize: 14), children: [TextSpan(text:'Sign up')])),
                    Icon(
                      Icons.arrow_forward,
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
