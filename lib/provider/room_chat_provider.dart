

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/model/ticket/detail_ticket_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class RoomChatProvider with ChangeNotifier{
  List data = [];
  bool isLoading = true;
  ScrollController scrollController = new ScrollController();
  Future read({BuildContext context,String idChat})async{
    final res=await HandleHttp().getProvider("chat/$idChat", detailTicketModelFromJson,context: context);
    if(res!=null){
      DetailTicketModel result=res;
      dynamic dataToJson = result.result.toJson();
      print("dataToJson $dataToJson");
      data = dataToJson["detail"];
      WidgetsBinding.instance.addPostFrameCallback((_){
        if (scrollController.hasClients) {
          scrollController.jumpTo(
            scrollController.position.maxScrollExtent,
          );
        }
      });
      isLoading=false;
      notifyListeners();
    }
  }


  Future store({BuildContext context,dynamic datas})async{
    final fakeData = {
      "id":datas["id_master"],
      "id_master":datas["id_master"],
      "id_member":datas["id_member"],
      "member":"",
      "id_user":"",
      "users":"",
      "msg":datas["msg"],
      "created_at":"",
      "updated_at":"",
    };
    data.insert(data.length, fakeData);
    scrollController.animateTo(
      scrollController.position.maxScrollExtent*2,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
    print("############################ $datas");
    final res = await HandleHttp().postProvider("chat/reply", datas,context: context);
    print("############################ $res");

    notifyListeners();

  }


}