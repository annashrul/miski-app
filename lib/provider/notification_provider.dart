

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/notification/list_notification_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class NotificationProvider with ChangeNotifier{
  ListNotificationModel listNotificationModel;
  ScrollController controller;
  bool isLoading=true,isLoadMore=false;
  int perPage=StringConfig.perpage;

  Future read(BuildContext context)async{
    if(listNotificationModel==null) isLoading=true;
    final res=await HandleHttp().getProvider("site/notification?page=1&perpage=$perPage", listNotificationModelFromJson,context: context);
    listNotificationModel = ListNotificationModel.fromJson(res.toJson());
    isLoading=false;
    isLoadMore=false;
    notifyListeners();
  }

  Future update(BuildContext context,id)async{
    WidgetHelper().loadingDialog(context);
    await HandleHttp().putProvider("site/notification/read/$id", {"status":"1"});
    Navigator.of(context).pop();
    read(context);
    notifyListeners();
  }


  void scrollListener({BuildContext context}) {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perPage<listNotificationModel.result.total){
          isLoadMore=true;
          perPage+=StringConfig.perpage;
          read(context);
          notifyListeners();
        }else{
          isLoadMore=false;
          notifyListeners();
        }
      }
    }
  }

}