import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/cart/cart_model.dart';
import 'package:miski_shop/model/cart/detail_cart_model.dart';
import 'package:miski_shop/model/general_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class CartProvider with ChangeNotifier {
  CartModel cart;
  DetailCartModel detailCart;
  CartModel get dataCart => cart;
  int subtotal =  0,qtyPerProduct=0;
  bool loading = false,isError=false,isActiveCart=false;
  getCartData(BuildContext context,{loading=true}) async {
    isError=false;
    loading = loading;
    final tenant = await FunctionHelper().getTenant();
    final url ="cart/${tenant[StringConfig.idTenant]}";
    final res = await HandleHttp().getProvider(url, cartModelFromJson,context: context);
    loading = false;
    if(res==StringConfig.errNoData){
      isError=true;
      isActiveCart=false;
      notifyListeners();
    }else{
      cart = CartModel.fromJson(res.toJson());
      isActiveCart =true;
      isError=false;
      notifyListeners();
    }
  }

  deleteCartData(BuildContext context,param,id)async{
    final tenant = await FunctionHelper().getTenant();
    WidgetHelper().notifDialog(context, 'Perhatian', 'Anda yakin akan menghapus data ini ?', ()=>Navigator.pop(context), ()async{
      Navigator.pop(context);
      WidgetHelper().loadingDialog(context);
      var url=param=='all'?'cart/${tenant[StringConfig.idTenant]}?all=true':'cart/$id';
      await HandleHttp().deleteProvider(url, generalFromJson,context: context);
      getCartData(context,loading: false);
      Navigator.pop(context);
      notifyListeners();
    });
  }

  storeCart(BuildContext context,data)async{
    WidgetHelper().loadingDialog(context,title: 'pengecekan harga bertingkat');
    await FunctionHelper().checkingPriceComplex(
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
    getCartData(context,loading: false);
    qtyPerProduct = data["qty"];
    notifyListeners();
  }

  getSubtotal()async{
    int st = 0;
    for(var i=0;i<cart.result.length;i++){
      st = st+int.parse(cart.result[i].hargaJual)*int.parse(cart.result[i].qty);
    }
    subtotal = st;
    print("SUBTOTAL $subtotal");
    notifyListeners();
  }


  getDetail(BuildContext context,idProduct)async{
    final tenant = await FunctionHelper().getTenant();
    print("RESPONSE DETAIL CART 'cart/detail/${tenant[StringConfig.idTenant]}/$idProduct'");
    final res = await HandleHttp().getProvider('cart/detail/${tenant[StringConfig.idTenant]}/$idProduct', detailCartModelFromJson);
    print("RESPONSE DETAIL CART $res");
    if(res==null){
      qtyPerProduct = 0;
      notifyListeners();

    }else{
      detailCart = DetailCartModel.fromJson(res.toJson());
      qtyPerProduct = int.parse(detailCart.result.qty);
      notifyListeners();
    }
  }

}
