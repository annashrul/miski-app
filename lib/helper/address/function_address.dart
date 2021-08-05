import 'package:flutter/cupertino.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/list_address_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class FunctionAddress{
  Future loadData({BuildContext context,bool isChecking=false})async{
    final idUser = await UserHelper().getDataUser("id_user");
    final res = await HandleHttp().getProvider("member_alamat?page=1&id_member=$idUser", listAddressModelFromJson,context: context);
    if(res is ListAddressModel){
      ListAddressModel result=ListAddressModel.fromJson(res.toJson());
      if(isChecking){
        if(result.result.data.length<1){
          return WidgetHelper().notifOneBtnDialog(context, "Perhatian", "Silahkan isi alamat lengkap anda terlebih dahulu", (){
            Navigator.pop(context);
            // WidgetHelper().myPushAndLoad(context, AddressScreen(),(){
            //   getAlamat();
            // });
          });
        }
      }
      return result;
    }
  }
}