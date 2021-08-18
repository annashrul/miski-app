import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/model/cart/cart_model.dart';
import 'package:miski_shop/provider/base_provider.dart';
import 'package:miski_shop/provider/handle_http.dart';
Future<CartModel> loadCart(BuildContext context) async {
  final tenant = await FunctionHelper().getTenant();
  final url ="cart/${tenant[StringConfig.idTenant]}";
  final res = await HandleHttp().getProvider(url, cartModelFromJson,context: context);
  CartModel result=CartModel.fromJson(res.toJson());
  print("################ RESULT CART = ${result.result.length}");
  return result;
}
class CartProvider with ChangeNotifier {
  CartModel cart;
  CartModel get dataCart => cart;
  bool loading = false;
  getCartData(BuildContext context) async {
    loading = true;
    cart = await loadCart(context);
    loading = false;
    notifyListeners();
  }
}
//
// class CartProvider extends ChangeNotifier { // create a common file for data
//   CartModel cartModel;
//   dynamic  get dataCart => cartModel;
//   void setData(input) {
//     cartModel = input;
//     print("SET DATA $cartModel");
//     notifyListeners();
//   }
// }