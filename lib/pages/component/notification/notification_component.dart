import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/notification/list_notification_model.dart';
import 'package:miski_shop/provider/handle_http.dart';
import '../../widget/empty_widget.dart';
import '../../widget/loading_widget.dart';

class NotificationComponent extends StatefulWidget {
  @override
  _NotificationComponentState createState() => _NotificationComponentState();
}

class _NotificationComponentState extends State<NotificationComponent> {
  bool isLoading=true,isLoadmore=false;
  int perpage=StringConfig.perpage,total=0;
  ListNotificationModel listNotificationModel;
  ScrollController controller;

  Future loadData()async{
    final res=await HandleHttp().getProvider("site/notification?page=1&perpage=$perpage", listNotificationModelFromJson,context: context);
    if(res!=null){
      ListNotificationModel result=ListNotificationModel.fromJson(res.toJson());
      listNotificationModel =result;
      total=result.result.total;
      isLoading=false;
      isLoadmore=false;
      if(this.mounted){
        this.setState(() {});
      }
    }
  }
  
  Future update(id)async{
    final res= await HandleHttp().putProvider("site/notification/read/$id", {
      "status":"1"
    });
    if(res!=null){
      loadData();
    }
  }
  void _scrollListener() {
    if (!isLoading) {
      print(total);

      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perpage<total){
          setState((){
            perpage+=perpage;
            isLoadmore=true;
          });
          loadData();
        }else{
          setState((){
            isLoadmore=false;
          });
        }
      }
    }
  }
  @override
  void initState() {
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);

    loadData();
  }
  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,

        child: Column(
          children: <Widget>[
            isLoading?Padding(padding: scaler.getPadding(0,2),child: LoadingCart(total:7)):listNotificationModel.result.data.length<1?EmptyDataWidget(
              iconData: UiIcons.bell,
              title: StringConfig.noData,
              isFunction: false,
            ):ListView.separated(
              padding: scaler.getPadding(1, 2),
              shrinkWrap: true,
              primary: false,
              itemCount: listNotificationModel.result.data.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 7);
              },
              itemBuilder: (context, index) {
                return buildItem(context: context,index: index);
              },
            ),
            isLoadmore?Padding(padding: scaler.getPadding(0,2),child: LoadingCart(total:1)):SizedBox()
          ],
        ),
      ),
    );
  }
  Widget buildItem({BuildContext context,int index}) {
    final scaler=config.ScreenScale(context).scaler;
    final res=listNotificationModel.result.data[index];
    return WidgetHelper().myRipple(
      callback: (){
        update(res.id);
      },
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
