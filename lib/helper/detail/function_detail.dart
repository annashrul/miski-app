import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/database_config.dart';
import 'package:miski_shop/helper/database_helper.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/cart/detail_cart_model.dart';
import 'package:miski_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:miski_shop/model/tenant/list_product_tenant_model.dart';
import 'package:miski_shop/provider/base_provider.dart';
import 'package:miski_shop/provider/handle_http.dart';

class FunctionDetail{
  Future loadDetail({BuildContext context,String idProduct})async{
    int hargaFinish=0;
    String hargaMaster="";
    final res = await HandleHttp().getProvider("barang/$idProduct", detailProductTenantModelFromJson,context: context);
    if(res!=null){
      DetailProductTenantModel result=DetailProductTenantModel.fromJson(res.toJson());
      if(int.parse(result.result.disc1)>0){
        result.result.harga = FunctionHelper().doubleDiskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']).toString();
        hargaFinish = FunctionHelper().doubleDiskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']);
        hargaMaster = FunctionHelper().doubleDiskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']).toString();
      }

      hargaMaster = result.result.harga;
      hargaFinish = int.parse(result.result.harga);
      dynamic data = result.result.toJson();


      data["id_varian"] ="";
      data["id_sub_varian"] ="";
      data["harga_finish"] =hargaFinish;
      data["harga_master"] =hargaMaster;
      data["harga_varian"]  =0;
      data["harga_sub_varian"] =0;
      final dataCart = await getCountCart(data);
      data["qty"] = dataCart["qty"];
      data["total_cart"] = dataCart["totalCart"];
      data["product_by_group"] = await loadProductByGroup(data["kelompok"]);
      data["varian"] = data["varian"];
      data["harga_bertingkat"] = data["harga_bertingkat"];
      // data["is_varian"] = false;
      return {
        "data":data
      };
    }
  }
  Future getCountCart(dynamic data) async{
    final res = await BaseProvider().getCart(data["id_tenant"]);
    final subtotal = await getSubTotal(data: data);
    return {
      "totalCart":res.result.length,
      "qty":subtotal["qty"],
    };
  }

  Future addToCart({BuildContext context,dynamic data})async{
    if(int.parse(data["stock"])<1){
      WidgetHelper().showFloatingFlushbar(context,"failed","maaf stock barang kosong");
      return null;
    }
    else{
      WidgetHelper().loadingDialog(context,title: 'pengecekan harga bertingkat');
      final res = await FunctionHelper().checkingPriceComplex(
        data["id_tenant"],
        data["id"],
        data["kode"],
        data["id_varian"],
        data["id_sub_varian"],
        data["qty"].toString(),
        data["harga"],
        data["disc1"],
        data["disc2"],
        data["harga_bertingkat"].length>0?true:false,
        data["harga_master"],
        data["harga_varian"],
        data["harga_sub_varian"],
      );
      Navigator.pop(context);
      int hrg = 0;
      print(res);
      res.forEach((element) {hrg = int.parse(element['harga']);});
      final subtotal = await getSubTotal(data: data);
      final resCart = await BaseProvider().getCart(data["id_tenant"]);
      return {
        "harga":hrg.toString(),
        "hargaFinish":hrg,
        "totalCart":resCart.result.length,
        "subtotal":subtotal["total"],
        "qty":subtotal["qty"]
      };
    }
  }
  Future getSubTotal({dynamic data})async{
    int qty = await getQty(data: data);
    return {
      "qty":qty,
      "total":qty>1?qty*(data["harga_finish"]+data["harga_varian"]+data["harga_sub_varian"]):data["harga_finish"]+data["harga_varian"]+data["harga_sub_varian"]
    };
  }
  Future getQty({dynamic data})async{
    var res = await HandleHttp().getProvider('cart/detail/${data["id_tenant"]}/${data["id"]}', detailCartModelFromJson);
    if(res is DetailCartModel){
      DetailCartModel result = DetailCartModel.fromJson(res.toJson());
      return int.parse(result.result.qty);
    }
    return 0;

  }
  Future loadProductByGroup(namaKelompok)async{
    final res = await HandleHttp().getProvider("barang?page=1&kelompok=$namaKelompok", listProductTenantModelFromJson);
    if(res is ListProductTenantModel){
      ListProductTenantModel result=res;
      return result;
    }
  }


  Future handleFavorite({BuildContext context,Map<String, Object> data,String method="store"})async{
    final DatabaseConfig _helper = new DatabaseConfig();
    final getWhere = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME, data["id_tenant"],'id_product',data["id"]);
    if(method=="store"){
     var parseData={
       "id_product": data["id"],
       "id_tenant": data["id_tenant"].toString(),
       "kode": data["kode"].toString(),
       "title": data["title"].toString(),
       "tenant": data["tenant"].toString(),
       "id_kelompok": data["id_kelompok"].toString(),
       "kelompok":data["kelompok"].toString(),
       "id_brand":data["id_brand"].toString(),
       "brand": data["brand"].toString(),
       "deskripsi": data["deskripsi"].toString(),
       "harga":data["harga"].toString(),
       "harga_coret": data["harga_coret"].toString(),
       "berat": "0",
       "pre_order": "0",
       "free_return":"0",
       "gambar":data["gambar"].toString(),
       "disc1": data["disc1"].toString(),
       "disc2": data["disc2"].toString(),
       "stock": data["stock"].toString(),
       "stock_sales": data["stock_sales"].toString(),
       "rating": data["rating"].toString(),
       "is_favorite":"true",
       "is_click":"false"
     };
     if(getWhere.length==0){
       await _helper.insert(ProductQuery.TABLE_NAME, parseData);
       WidgetHelper().showFloatingFlushbar(context,"success","barang berhasil ditambahkan kedalam favorite anda");
       return true;
     }
     else{
       await _helper.delete(ProductQuery.TABLE_NAME, "id_product",parseData["id_product"]);
       WidgetHelper().showFloatingFlushbar(context,"success","barang berhasil dihapus dari favorite anda");
       return false;
     }
   }
   else{
     bool isFav=false;
     getWhere.forEach((element) {
       if(element['is_favorite'] == "true"){
         isFav=true;
       }
       else{
         isFav=false;
       }
     });
     return isFav;
   }
  }


}