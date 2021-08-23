

import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';

class TenantProvider with ChangeNotifier{
  String idTenant="",namaTenant="",emailTenant="",telpTenant="",alamatTenant="",logoTenant="";
  Future read()async{
    final tenant = await FunctionHelper().getTenant();
    idTenant=tenant[StringConfig.idTenant];
    namaTenant=tenant[StringConfig.namaTenant];
    emailTenant=tenant[StringConfig.emailTenant];
    telpTenant=tenant[StringConfig.telpTenant];
    alamatTenant=tenant[StringConfig.alamatTenant];
    logoTenant=tenant[StringConfig.logoTenant];
    notifyListeners();
  }
}