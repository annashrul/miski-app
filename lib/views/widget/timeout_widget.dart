import 'package:flutter/material.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';


class TimeoutWidget extends StatefulWidget {
  Function callback;
  TimeoutWidget({this.callback});
  @override
  _TimeoutWidgetState createState() => _TimeoutWidgetState();
}

class _TimeoutWidgetState extends State<TimeoutWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(SiteConfig().serverDown),
        Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
            onTap: widget.callback,
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    color: SiteConfig().mainColor,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
                    ]),
                child: Center(
                  child: WidgetHelper().textQ("Coba lagi",14,Colors.white, FontWeight.bold),
                )
            ),
          ),
        )
      ],
    );
  }
}
