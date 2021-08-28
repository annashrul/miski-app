

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/model/tenant/listGroupProductModel.dart';
import 'package:miski_shop/provider/handle_http.dart';

class GroupProvider with ChangeNotifier{
  ListGroupProductModel listGroupProductModel;
  bool isLoading=true;
  reload(BuildContext context){
    isLoading=true;
    notifyListeners();
    read(context);
  }
  Future read(BuildContext context)async{
    if(listGroupProductModel==null) isLoading=true;
    final res = await HandleHttp().getProvider("kelompok?page=1&perpage=50",listGroupProductModelFromJson,context: context);
    listGroupProductModel = ListGroupProductModel.fromJson(res.toJson());
    isLoading=false;
    notifyListeners();
  }
}