

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/model/promo/global_promo_model.dart';
import 'package:miski_shop/model/slider/ListSliderModel.dart';
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
    print("======================== RESPONSE GROUP ${listGroupProductModel.result.toJson()}");
    isLoading=false;
    notifyListeners();
  }
}