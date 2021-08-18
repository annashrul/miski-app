import 'package:flutter/cupertino.dart';
import 'package:miski_shop/model/bank/bank_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class FunctionBank{
  Future loadData({BuildContext context})async{
    final res = await HandleHttp().getProvider("bank",bankModelFromJson,context: context);
    if(res is BankModel){
      BankModel result=BankModel.fromJson(res.toJson());
      return result;
    }
  }
}