


import 'package:flutter/cupertino.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';

class AuthProvider with ChangeNotifier{
  Future<bool> checkTokenExp({BuildContext context})async{
    final token = await UserHelper().getDataUser(StringConfig.token);
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    bool  isTokenExpired = JwtDecoder.isExpired(token);
    notifyListeners();
    return isTokenExpired;
    // if(isTokenExpired){
    //   WidgetHelper().notifOneBtnDialog(context,StringConfig.titleErrToken,StringConfig.descErrToken,()async{
    //     await FunctionHelper().logout(context);
    //   });
    // }
    print("####################### PAYLOAD TOKEN $isTokenExpired ########################################");

    // return isTokenExpired;
  }
}