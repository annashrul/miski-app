import 'package:flutter/cupertino.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/model/slider/ListSliderModel.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class FunctionHome{
  Future loadProduct({BuildContext context,String idKelompok})async{
    ListProductTenantModel listProductTenantModel;
    final tenant = await FunctionHelper().getTenant();
    String url = "barang?page=1&id_tenant=${tenant[StringConfig.idTenant]}";
    if(idKelompok!="") url+="&kelompok=$idKelompok";
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
      result.result.data.forEach((element) {
        resFilter.add({"id":element.id,"image":"assets/img/logo-0${3}.svg","title":element.title,"selected":false});
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
}