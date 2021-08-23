

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/model/promo/detail_global_promo_model.dart';
import 'package:miski_shop/model/promo/global_promo_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class PromoProvider with ChangeNotifier{
  GlobalPromoModel globalPromoModel ;
  DetailGlobalPromoModel  detailGlobalPromoModel;
  bool isLoading=true,isLoadingDetail=true;
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
    print("promo ${globalPromoModel.result}");

    isLoading=false;
    notifyListeners();
  }
  Future readDetail(BuildContext context,id)async{
    isLoadingDetail=detailGlobalPromoModel==null;
    final res=await HandleHttp().getProvider("promo/$id",detailGlobalPromoModelFromJson,context: context);
    detailGlobalPromoModel = DetailGlobalPromoModel.fromJson(res.toJson());
    isLoadingDetail=false;
    notifyListeners();
  }


}