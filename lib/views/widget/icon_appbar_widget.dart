import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class IconAppBarWidget extends StatelessWidget {
  final bool isIcon;
  final IconData icon;
  final String title;
  final Function callback;
  IconAppBarWidget({
    this.isIcon=true,
    this.icon,
    this.title='',
    this.callback,
    Key key
  });

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Container(
      margin:scaler.getMarginLTRB(0, 0, 0,0),
      child: WidgetHelper().myRipple(
          isRadius: true,
          radius: 100,
          callback: this.callback,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  padding: scaler.getPadding(0.5, 1.5),
                  alignment: Alignment.center,
                  child: this.isIcon?Icon(this.icon,color: LightColor.lightblack):WidgetHelper().textQ(this.title,scaler.getTextSize(9),LightColor.mainColor,FontWeight.bold)
              ),
            ],
          )
      ),
    );
  }
}
