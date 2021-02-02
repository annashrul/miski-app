

import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';

class ProductProvider{
  final col='id_product,id_tenant,kode,title,tenant,id_kelompok,kelompok,id_brand,brand,deskripsi,harga,harga_coret,berat,pre_order,free_return,gambar,disc1,disc2,stock,stock_sales,rating';
  final userRepository = UserHelper();
  final DatabaseConfig _helper = new DatabaseConfig();
  Future getProduct(data)async{
    var list; String where='id_tenant=?'; List argWhere=[data['id_tenant']];
    if(data['id_brand']!=''){
      where+='and id_brand=?';
      argWhere.add(data['id_brand']);
    }
    var resProductLocal = await _helper.getRow("SELECT $col FROM ${ProductQuery.TABLE_NAME} WHERE $where LIMIT ${data['perpage']}",argWhere);
    var resTotalProductLocal = await _helper.getRow("SELECT $col FROM ${ProductQuery.TABLE_NAME} WHERE $where",argWhere);
    list = {'total':resTotalProductLocal.length,'data':resProductLocal};

    return list;
  }



}