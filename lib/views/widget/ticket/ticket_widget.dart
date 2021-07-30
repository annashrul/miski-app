import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class TicketWidget extends StatefulWidget {
  int status;
  String title;
  String tenant;
  DateTime createdAt;
  TicketWidget({this.status,this.title,this.tenant,this.createdAt});
  @override
  _TicketWidgetState createState() => _TicketWidgetState();
}

class _TicketWidgetState extends State<TicketWidget> {
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      color:Theme.of(context).focusColor.withOpacity(0.1),
      padding: scaler.getPadding(0.5,2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                width: scaler.getWidth(12),
                height: scaler.getHeight(5),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color:Theme.of(context).focusColor.withOpacity(0.15),
                      image: DecorationImage(
                          image: NetworkImage(SiteConfig().noImage)
                      )
                  ),
                ),
              ),
              Positioned(
                bottom: 3,
                right: 3,
                width: 12,
                height: 12,
                child: Container(
                  decoration: BoxDecoration(
                    // color: widget.message.user.userState == UserState.available ? Colors.green : widget.message.user.userState == UserState.away ? Colors.orange : Colors.red,
                    color: widget.status==0?Colors.green:Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          SizedBox(width: 15),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right:10.0),
                      child: WidgetHelper().textQ("${widget.tenant}", scaler.getTextSize(9), SiteConfig().mainColor, FontWeight.bold),
                    ),
                    Positioned(
                      child:Icon(AntDesign.home,color:SiteConfig().mainColor,size: 8),
                    )
                  ],
                ),
                WidgetHelper().textQ("${widget.title}", scaler.getTextSize(9),SiteConfig().darkMode,FontWeight.normal),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child:  WidgetHelper().textQ("${DateFormat().add_yMMMd().format(widget.createdAt)} ${DateFormat().add_jm().format(widget.createdAt)}", scaler.getTextSize(8),Colors.grey,FontWeight.normal),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
