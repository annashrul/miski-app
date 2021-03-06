import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/model/promo/global_promo_model.dart';
import 'package:miski_shop/model/slider/ListSliderModel.dart';
import 'package:miski_shop/model/tenant/listGroupProductModel.dart';
import 'package:miski_shop/model/tenant/list_product_tenant_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class FunctionHome{
  Future loadProduct({BuildContext context,String where})async{
    ListProductTenantModel listProductTenantModel;
    final tenant = await FunctionHelper().getTenant();
    String url = "barang?id_tenant=${tenant[StringConfig.idTenant]}";
    if(where!="") url+="$where";
    print(url);
    final res = await HandleHttp().getProvider(url, listProductTenantModelFromJson,context: context);
    if(res!=null){
      if(res is ListProductTenantModel){
        ListProductTenantModel result = ListProductTenantModel.fromJson(res.toJson());
        listProductTenantModel=result;
      }
    }
    return listProductTenantModel;
  }
  Future loadGroup({BuildContext context})async{
    List resFilter=[];
    final res = await HandleHttp().getProvider("kelompok?page=1",listGroupProductModelFromJson,context: context);
    if(res is ListGroupProductModel){
      ListGroupProductModel result=ListGroupProductModel.fromJson(res.toJson());
      print("ADD SELECTED KELOMPOK ${result.result.toJson()}");
      
      result.result.data.forEach((element) {
        resFilter.add({"id":element.id,"image":element.image,"title":element.title,"selected":false});
      });
      return resFilter;
    }
  }
  Future loadSlider({BuildContext context})async{
    final res = await HandleHttp().getProvider("slider?page=1",listSliderModelFromJson,context: context);
    if(res is ListSliderModel){
      ListSliderModel result=ListSliderModel.fromJson(res.toJson());
      return result;
    }
  }
  Future loadPromo({BuildContext context})async{
    final tenant = await FunctionHelper().getTenant();
    final res = await HandleHttp().getProvider("promo?page=1&id_tenant=${tenant[StringConfig.idTenant]}",globalPromoModelFromJson,context: context);
    if(res is GlobalPromoModel){
      GlobalPromoModel result=GlobalPromoModel.fromJson(res.toJson());
      return result;
    }
  }
}