import 'package:flutter/material.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/app_config.dart' as config;

class RoomChatWidget extends StatefulWidget {
  final Map<String,Object> data;
  final Animation animation;
  RoomChatWidget({this.data,this.animation});
  @override
  _RoomChatWidgetState createState() => _RoomChatWidgetState();
}

class _RoomChatWidgetState extends State<RoomChatWidget> {

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: widget.animation, curve: Curves.decelerate),
      child:widget.data["id_member"]!=null ? getSentMessageLayout(context) : getReceivedMessageLayout(context),
    );
  }
  Widget getSentMessageLayout(context) {
    final scaler=config.ScreenScale(context).scaler;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
        color: Theme.of(context).focusColor.withOpacity(0.2),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
        padding:scaler.getPadding(0.7,1),
        margin: scaler.getMargin(0.5,0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  config.MyFont.subtitle(context: context,text:"acuy",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8,fontWeight: FontWeight.bold),
                  new Container(
                    // child: new Text(widget.data["msg"]),
                    child: config.MyFont.subtitle(context: context,text:widget.data["msg"],fontSize: 8,color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ],
              ),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: new CircleAvatar(
                      backgroundImage: AssetImage(StringConfig.userImage),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getReceivedMessageLayout(context) {
    final scaler=config.ScreenScale(context).scaler;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
        padding:scaler.getPadding(0.7,1),
        margin: scaler.getMargin(0.5,0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: new CircleAvatar(
                      backgroundImage: AssetImage(StringConfig.userImage),
                    )),
              ],
            ),
            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  config.MyFont.subtitle(context: context,text:"acuy",color: Theme.of(context).primaryColor,fontSize: 8,fontWeight: FontWeight.bold),
                  new Container(
                    child:config.MyFont.subtitle(context: context,text:widget.data["msg"],color: Theme.of(context).primaryColor,fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}

