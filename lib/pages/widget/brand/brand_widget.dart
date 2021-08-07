import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class BrandWidget extends StatefulWidget {
  @override
  _BrandWidgetState createState() => _BrandWidgetState();
}

class _BrandWidgetState extends State<BrandWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return StaggeredGridView.countBuilder(
      primary: false,
      shrinkWrap: true,
      padding: scaler.getPaddingLTRB(0, 1, 0, 0),
      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
      itemCount: 7,
      itemBuilder: (BuildContext context, int index) {
        List<Color> col = [Colors.greenAccent,Colors.greenAccent.withOpacity(double.parse("0.$index"))];
        String image=StringConfig.localAssets+"logo-0${index+3}.svg";
        print(image);
        return WidgetHelper().myRipple(
          callback: () {
            Navigator.of(context).pushNamed("/${StringConfig.productByBrand}",arguments: {
              "color":Colors.greenAccent,
              "hero":"brand$index",
              "image":image
            });
          },
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(0),
                alignment: AlignmentDirectional.topCenter,
                padding: scaler.getPadding(2,2),
                width: double.infinity,
                height: scaler.getHeight(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
                    ],
                    gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors:col)),
                child: Hero(
                  tag: "brand$index",
                  child: SvgPicture.asset(
                    image,
                    color: Theme.of(context).primaryColor,
                    width: scaler.getWidth(16),
                  ),
                ),
              ),
              Positioned(
                right: -50,
                bottom: -100,
                child: Container(
                  width: scaler.getWidth(44),
                  height: scaler.getHeight(22),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                top: -60,
                child: Container(
                  width: scaler.getWidth(22),
                  height: scaler.getHeight(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Container(
                margin:scaler.getMarginLTRB(0, 7, 0, 1),
                padding: scaler.getPadding(0.5,1.5),
                width: scaler.getWidth(30),
                height: scaler.getHeight(6),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    config.MyFont.title(context: context,text:"Zogaa FlameSweater",color: Theme.of(context).textTheme.bodyText2.color,maxLines: 1,fontSize: 9),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: config.MyFont.subtitle(context: context,text:"$index Product",color: Theme.of(context).textTheme.bodyText1.color,fontSize: 9),
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                        config.MyFont.subtitle(context: context,text:"5",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8),

                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 15.0,
    );
  }
}
