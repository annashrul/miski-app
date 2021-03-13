import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';


class EmptyTenant extends StatefulWidget {
  @override
  _EmptyTenantState createState() => _EmptyTenantState();
}

class _EmptyTenantState extends State<EmptyTenant> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.center,
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: config.AppConfig(context).appHeight(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                      Theme.of(context).focusColor,
                      Theme.of(context).focusColor.withOpacity(0.1),
                    ])),
                child: Icon(
                  AntDesign.inbox,
                  color: Theme.of(context).primaryColor,
                  size: 70,
                ),
              ),
              Positioned(
                right: -30,
                bottom: -50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                top: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          Opacity(
            opacity: 0.4,
            child: WidgetHelper().textQ(SiteConfig().noData, 16, Colors.grey, FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

class EmptyDataWidget extends StatefulWidget {
  IconData iconData;
  String title;
  Function callback;
  bool isFunction;
  String txtFunction;
  EmptyDataWidget({this.iconData,this.title,this.callback,this.isFunction,this.txtFunction});
  @override
  _EmptyDataWidgetState createState() => _EmptyDataWidgetState();
}

class _EmptyDataWidgetState extends State<EmptyDataWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.center,
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: config.AppConfig(context).appHeight(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                      Theme.of(context).focusColor,
                      Theme.of(context).focusColor.withOpacity(0.1),
                    ])),
                child: Icon(
                  widget.iconData,
                  color: Colors.white,
                  size: 70,
                ),
              ),
              Positioned(
                right: -30,
                bottom: -50,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                top: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          Opacity(
            opacity: 0.4,
            child:WidgetHelper().textQ(widget.title,14,Colors.grey,FontWeight.normal,textAlign: TextAlign.center),
          ),
          widget.isFunction?SizedBox(height: 50):Container(),
          widget.isFunction?FlatButton(
            onPressed:widget.callback,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            color: Theme.of(context).focusColor.withOpacity(0.15),
            shape: StadiumBorder(),
            child: RichText(
                maxLines: 2,
                overflow: TextOverflow.clip,
                softWrap: true,
                text: TextSpan(
                  text:widget.txtFunction,
                  style: Theme.of(context).textTheme.title,
                )
            ),
            // child: Text(
            //   'Start Exploring',
            //   style: Theme.of(context).textTheme.title,
            // ),
          ):Container(),
        ],
      ),
    );
  }

}

