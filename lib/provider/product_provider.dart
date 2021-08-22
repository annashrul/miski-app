

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/model/tenant/list_product_tenant_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class ProductProvider with ChangeNotifier{
  ListProductTenantModel listProductTenantModel;
  bool isLoading=true,isLoadMore=false;
  int perPage=StringConfig.perpage;
  String where="",kelompok="",q="";
  ScrollController controller;

  setKelompok(input){
    isLoading=true;
    print("listProductTenantModel ${listProductTenantModel.result.data.length}");
    kelompok=input;
    notifyListeners();
  }
  setQ(input){
    q=input;
    notifyListeners();
  }
  reload(BuildContext context){
    isLoading=true;
    notifyListeners();
    read(context: context);
  }
  void scrollListener({BuildContext context}) {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        loadMore(context);
      }
    }
  }
  Future loadMore(BuildContext context)async{
    if(perPage<listProductTenantModel.result.total){
      addListener(()=>isLoadMore=true);
      perPage+=StringConfig.perpage;
      await read(context: context);
      isLoadMore=false;
      notifyListeners();
      print("true");
    }else{
      addListener(()=>isLoadMore=false);
      notifyListeners();
      print("false");
    }
  }

  Future read({BuildContext context})async{
    if(listProductTenantModel==null) isLoading=true;
    final tenant = await FunctionHelper().getTenant();
    String url = "barang?id_tenant=${tenant[StringConfig.idTenant]}&page=1&perpage=$perPage";
    if(q!="") url+="&q=$q";
    if(kelompok!="") url+="&kelompok=$kelompok";
    print("======================== RESPONSE PRODUCT $url");

    final res = await HandleHttp().getProvider(url, listProductTenantModelFromJson,context: context);
    listProductTenantModel = ListProductTenantModel.fromJson(res.toJson());
    isLoading=false;

    notifyListeners();
  }


}