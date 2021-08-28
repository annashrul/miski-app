import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:miski_shop/model/tenant/list_product_tenant_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class ProductProvider with ChangeNotifier{
  ListProductTenantModel listProductTenantModel;
  ListProductTenantModel listProductTenantModelByGroup;
  DetailProductTenantModel detailProductTenantModel;
  bool isLoading=true,isLoadingDetail=true,isLoadMore=false;
  int perPage=StringConfig.perpage;
  String where="",idGroup="",q="",byGroup="";
  ScrollController controller;
  int endPrice=0;
  String masterPrice="";
  dynamic dataDetail;
  setDataDetail(index){
    dataDetail = listProductTenantModel.result.data[index].toJson();
    dataDetail.addAll({ "harga_finish":0,"harga_master":"0"});
    dataDetail["harga"]=dataDetail["harga"];
    if(int.parse(dataDetail["disc1"])>0){
      dataDetail["harga"]=FunctionHelper().doubleDiskon(dataDetail["harga"], ['${dataDetail["disc1"].toString()}','${dataDetail["disc2"].toString()}']).toString();
      dataDetail["harga_finish"]=FunctionHelper().doubleDiskon(dataDetail["harga"], ['${dataDetail["disc1"].toString()}','${dataDetail["disc2"].toString()}']);
      dataDetail["harga_master"]=FunctionHelper().doubleDiskon(dataDetail["harga"], ['${dataDetail["disc1"].toString()}','${dataDetail["disc2"].toString()}']).toString();
    }

    notifyListeners();
  }

  Future read({BuildContext context})async{
    if(listProductTenantModel==null) isLoading=true;
    final tenant = await FunctionHelper().getTenant();
    String url = "barang?id_tenant=${tenant[StringConfig.idTenant]}&page=1&perpage=$perPage";
    if(q!="") url+="&q=$q";
    if(idGroup!="") url+="&kelompok=$idGroup";
    final res = await HandleHttp().getProvider(url, listProductTenantModelFromJson,context: context);
    listProductTenantModel = ListProductTenantModel.fromJson(res.toJson());
    isLoading=false;
    notifyListeners();
  }

  Future readDetail(BuildContext context,idProduct)async{
    isLoadingDetail=detailProductTenantModel==null||listProductTenantModelByGroup==null;
    final tenant = await FunctionHelper().getTenant();
    final res = await HandleHttp().getProvider("barang/$idProduct", detailProductTenantModelFromJson,context: context);
    detailProductTenantModel = DetailProductTenantModel.fromJson(res.toJson());
    dynamic price = detailProductTenantModel.result.harga;
    dynamic disc1 = detailProductTenantModel.result.disc1;
    dynamic disc2 = detailProductTenantModel.result.disc2;
    endPrice = int.parse(price);
    masterPrice = price.toString();
    if(int.parse(detailProductTenantModel.result.disc1)>0){
      price = FunctionHelper().doubleDiskon(price, ['${disc1.toString()}','${disc2.toString()}']).toString();
      endPrice = FunctionHelper().doubleDiskon(price, ['${disc1.toString()}','${disc2.toString()}']);
      masterPrice = FunctionHelper().doubleDiskon(price, ['${disc1.toString()}','${disc2.toString()}']).toString();
    }
    String url = "barang?id_tenant=${tenant[StringConfig.idTenant]}&page=1&kelompok=${detailProductTenantModel.result.kelompok}";
    final resProductByGroup = await HandleHttp().getProvider(url, listProductTenantModelFromJson,context: context);
    listProductTenantModelByGroup = ListProductTenantModel.fromJson(resProductByGroup.toJson());
    isLoadingDetail=false;
    notifyListeners();
  }

  setGroup(input){
    isLoading=listProductTenantModel==null;
    idGroup=input;
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
  Future loadMore(BuildContext context)async{
    if(perPage<listProductTenantModel.result.total){
      addListener(()=>isLoadMore=true);
      perPage+=StringConfig.perpage;
      await read(context: context);
      isLoadMore=false;
      notifyListeners();
    }else{
      addListener(()=>isLoadMore=false);
      notifyListeners();
    }
  }
  void scrollListener({BuildContext context}) {
    print("scroll");
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        loadMore(context);
      }
    }
  }
  void toTop(){
    controller.animateTo(
      0.0,
      curve: Curves.ease,
      duration: const Duration(milliseconds: 5000),
    );
    notifyListeners();
  }

}