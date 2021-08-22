import 'package:flutter/cupertino.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/model/address/list_address_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class FunctionAddress{
  Future loadData({BuildContext context,bool isChecking=false})async{
    final idUser = await UserHelper().getDataUser("id_user");
    final res = await HandleHttp().getProvider("member_alamat?page=1&id_member=$idUser", listAddressModelFromJson,context: context);
    if(res is ListAddressModel){
      ListAddressModel result=ListAddressModel.fromJson(res.toJson());
      return result;
    }
  }



}