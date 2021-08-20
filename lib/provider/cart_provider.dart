import 'package:flutter/cupertino.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/cart/cart_model.dart';
import 'package:miski_shop/model/general_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class CartProvider with ChangeNotifier {
  CartModel cart;
  CartModel get dataCart => cart;
  int subtotal =  0;
  bool loading = false;bool isError=false;
  getCartData(BuildContext context,{loading=true}) async {
    isError=false;
    loading = loading;
    print("LOADING $loading");
    final tenant = await FunctionHelper().getTenant();
    final url ="cart/${tenant[StringConfig.idTenant]}";
    final res = await HandleHttp().getProvider(url, cartModelFromJson,context: context);
    loading = false;
    if(res==StringConfig.errNoData){
      isError=true;
      notifyListeners();
    }else{
      cart = CartModel.fromJson(res.toJson());
      notifyListeners();
    }
    print("LOADING $loading");

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

  storeCart(BuildContext context,int index)async{
    final res=cart.result[index];
    WidgetHelper().loadingDialog(context,title: 'pengecekan harga bertingkat');
    await FunctionHelper().checkingPriceComplex(
        res.idTenant,
        res.idBarang,
        res.kodeBarang,
        res.idVarian,
        res.idSubvarian,
        res.qty,
        res.hargaJual,
        res.disc1,
        res.disc2,
        res.bertingkat,
        res.hargaMaster,
        res.varianHarga,
        res.subvarianHarga
    );
    Navigator.pop(context);
    getCartData(context,loading: false);
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

}
