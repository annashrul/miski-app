import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/database_config.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/database_helper.dart';
import 'package:miski_shop/helper/function_helper.dart';

class FavoriteProvider with ChangeNotifier{
  final DatabaseConfig _helper = new DatabaseConfig();
  List resFavoriteProduct;
  ScrollController controller;
  bool isLoading=false,isLoadMore=false;
  int perPage=StringConfig.perpage;
  String any="",layout = 'grid';

  Future read()async{
    isLoading = resFavoriteProduct==null;
    final tenant=await FunctionHelper().getTenant();
    String where = "is_favorite=? and id_tenant=?";
    if(any!="")where+=" and title LIKE '%$any%' or deskripsi LIKE '%$any%'";
    var resLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE $where LIMIT $perPage",["true",tenant[StringConfig.idTenant]]);
    resFavoriteProduct = resLocal;
    isLoading=false;
    isLoadMore=false;
    notifyListeners();
  }
  Future delete(res)async{
    await _helper.delete(ProductQuery.TABLE_NAME, "id", res["id"]);
    await read();
  }
  void scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if(perPage<=resFavoriteProduct.length){
        perPage+=StringConfig.perpage;
        isLoadMore=true;
        read();
        notifyListeners();
      }
    }

  }
  void setAny(res){
    any=res;
    notifyListeners();
  }
  void setLayout(res){
    layout=res;
    notifyListeners();
  }

}