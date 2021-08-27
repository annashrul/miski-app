
import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/general_model.dart';
import 'package:miski_shop/model/ticket/list_ticket_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class ChatProvider with ChangeNotifier{
  ListTicketModel listTicketModel;
  bool isLoading=true,isLoadMore=false,isSuccess=true;
  int perPage=StringConfig.perpage;
  ScrollController controller;
  Future read(BuildContext context)async{
    if(listTicketModel==null) isLoading=true;
    var res = await HandleHttp().getProvider( "chat?page=1&perpage=$perPage", listTicketModelFromJson,context: context);
    listTicketModel = ListTicketModel.fromJson(res.toJson());
    isLoading=false;
    isLoadMore=false;
    notifyListeners();
  }
  Future create(BuildContext context,dataStore)async{
    final data={
      "title":dataStore["title"],
      "deskripsi":dataStore["deskripsi"],
      "lampiran":dataStore["lampiran"],
      "layanan":"Barang",
      "prioritas":"0",
      "status":"0",
      "id_tenant":dataStore["id_tenant"]
    };
    final res = await HandleHttp().postProvider("chat", data,context: context);
    if(res!=null){
      Navigator.pop(context);
      read(context);
      isSuccess=true;
      notifyListeners();
    }
    else{
      isSuccess=false;
      notifyListeners();
    }
  }
  Future delete(BuildContext context,index) async {
    await HandleHttp().deleteProvider("chat/${listTicketModel.result.data[index].id}", generalFromJson,context: context);
    read(context);
    notifyListeners();
  }
  reload(BuildContext context){
    isLoading=true;
    notifyListeners();
    read(context);
  }
  void scrollListener({BuildContext context}) {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perPage<int.parse(listTicketModel.result.total)){
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