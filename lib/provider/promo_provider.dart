

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/model/promo/global_promo_model.dart';
import 'package:miski_shop/model/slider/ListSliderModel.dart';
import 'package:miski_shop/provider/handle_http.dart';

class PromoProvider with ChangeNotifier{
  GlobalPromoModel globalPromoModel;
  bool isLoading=true;
  reload(BuildContext context){
    isLoading=true;
    notifyListeners();
    read(context);
  }
  Future read(BuildContext context)async{
    final tenant=await FunctionHelper().getTenant();
    if(globalPromoModel==null) isLoading=true;
    final res = await HandleHttp().getProvider("promo?page=1&id_tenant=${tenant[StringConfig.idTenant]}",globalPromoModelFromJson,context: context);
    globalPromoModel = GlobalPromoModel.fromJson(res.toJson());
    print("======================== RESPONSE GLOBAL PROMO ${globalPromoModel.result.toJson()}");
    isLoading=false;
    notifyListeners();
  }
}