import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/provider/notification_provider.dart';
import 'package:provider/provider.dart';
import '../../widget/empty_widget.dart';
import '../../widget/loading_widget.dart';

class NotificationComponent extends StatefulWidget {
  @override
  _NotificationComponentState createState() => _NotificationComponentState();
}

class _NotificationComponentState extends State<NotificationComponent> {



  @override
  void initState() {
    super.initState();
    final notif = Provider.of<NotificationProvider>(context, listen: false);
    notif.read(context);
    notif.controller = new ScrollController()..addListener(notif.scrollListener);
  }
  @override
  void dispose() {
    super.dispose();
    final notif = Provider.of<NotificationProvider>(context, listen: false);
    notif.controller.removeListener(notif.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    final notif = Provider.of<NotificationProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        controller: notif.controller,
        child: Column(
          children: <Widget>[
            notif.isLoading?Padding(padding: scaler.getPadding(0,2),child: LoadingCart(total:7)):notif.listNotificationModel.result.data.length<1?EmptyDataWidget(
              iconData: UiIcons.bell,
              title: StringConfig.noData,
              isFunction: false,
            ):ListView.separated(
              padding: scaler.getPadding(1, 2),
              shrinkWrap: true,
              primary: false,
              itemCount: notif.listNotificationModel.result.data.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 7);
              },
              itemBuilder: (context, index) {
                return buildItem(context: context,index: index);
              },
            ),
            notif.isLoadMore?Padding(padding: scaler.getPadding(0,2),child: LoadingCart(total:1)):SizedBox()
          ],
        ),
      ),
    );
  }
  Widget buildItem({BuildContext context,int index}) {
    final notif = Provider.of<NotificationProvider>(context);
    final scaler=config.ScreenScale(context).scaler;
    final res=notif.listNotificationModel.result.data[index];
    return WidgetHelper().myRipple(
      callback: ()=>notif.update(context, res.id),
      child: Container(
        color: res.status==1 ? Colors.transparent : Theme.of(context).focusColor.withOpacity(0.15),
        padding: scaler.getPadding(1,2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  config.MyFont.title(context: context,text:res.title,fontSize: 9,fontWeight: res.status==1 ? FontWeight.w300:FontWeight.w600,maxLines: 2),
                  config.MyFont.subtitle(context: context,text:res.msg,fontSize: 8,color:  Theme.of(context).textTheme.caption.color),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: config.MyFont.subtitle(context: context,text:DateFormat("yyyy-MM-dd hh:mm:ss").format(res.createdAt),fontSize: 8,color:  Theme.of(context).textTheme.caption.color),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
