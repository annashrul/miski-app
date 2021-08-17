import 'package:flutter/cupertino.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/address/function_address.dart';
import 'package:netindo_shop/helper/bank/function_bank.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/kurir_model.dart';
import 'package:netindo_shop/model/address/list_address_model.dart';
import 'package:netindo_shop/model/bank/bank_model.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/checkout/check_ongkir_model.dart';
import 'package:netindo_shop/model/checkout/checkout_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';


class FunctionCheckout{
  final user = UserHelper();

  Future storeCheckout({BuildContext context,dynamic data})async{
    Navigator.of(context).pop(); /*close dialog*/
    WidgetHelper().loadingDialog(context);
    final res = await HandleHttp().postProvider("transaction", data,context: context);
    if(res!=null){
      Navigator.of(context).pop(); /*close loading*/
      // var resposneCheckout = CheckoutModel.fromJson(res);
      // Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.successCheckout}", (route) => false,arguments: resposneCheckout.result.toJson());
    }
  }

  Future loadData({BuildContext context,String type="all",int ongkos=0})async{
    final tenant = await FunctionHelper().getTenant();
    final res = await HandleHttp().getProvider('cart/${tenant[StringConfig.idTenant]}', cartModelFromJson,context: context);
    Map<String,Object> resData = {};
    if(res is CartModel){
      final idUser = await user.getDataUser(StringConfig.id_user);
      List productDetail = [];
      CartModel product=CartModel.fromJson(res.toJson());
      for(var i=0;i<product.result.length;i++){
        int disc1Nominal = FunctionHelper().percentToRp(int.parse(product.result[i].disc1), int.parse(product.result[i].hargaMaster));
        int disc2Nominal = FunctionHelper().percentToRp(int.parse(product.result[i].disc2), int.parse(product.result[i].hargaMaster));
        final resProduct=product.result[i];
        productDetail.add({
          "id":resProduct.idBarang,
          "title":resProduct.barang,
          "gambar":resProduct.gambar,
          "kode_barang":resProduct.kodeBarang,
          "id_varian":resProduct.idVarian,
          "id_subvarian":resProduct.idSubvarian,
          "qty":resProduct.qty,
          "harga_jual":"${int.parse(resProduct.hargaMaster)+int.parse(resProduct.varianHarga)+int.parse(resProduct.subvarianHarga)}",
          "disc":disc1Nominal+disc2Nominal,
          "subtotal":(int.parse(resProduct.hargaJual)*int.parse(resProduct.qty)).toString(),
          "tax":"0"
        });
      }
      int subTotal = await loadSubTotal(cartModel: product);
      if(type=="all"){
        ListAddressModel  address = await FunctionAddress().loadData(context: context,isChecking: true);
        if(address.result.data.length>0){
          KurirModel kurir = await loadKurir(context: context);
          final ongkir = await loadOngkir(context: context,kodeKecamatan: address.result.data[0].kdKec,kurir: kurir.result[0].kurir);
          int grandTotal = await loadGrandTotal(cartModel: product,cost: ongkir["cost"]);
          resData = {
            "idTenant":tenant[StringConfig.idTenant],
            "idUser":idUser,
            "product":product,
            "productDetail":productDetail,
            "grandTotal":grandTotal,
            "subTotal":subTotal,
            "address":address.result.toJson(),
            "shipping":{
              "kurir":kurir.toJson(),
              "layanan":ongkir
            }

          };
        }else{
          return StringConfig.errNoData;
        }
      }
      else{
        int grandTotal = await loadGrandTotal(cartModel: product,cost: ongkos);
        resData={
          "grandTotal":grandTotal,
          "subTotal":subTotal,
          "productDetail":productDetail,

        };
      }
    }

    return resData;
  }
  Future loadGrandTotal({CartModel cartModel,int cost})async{
    int gt = 0;
    for(var i=0;i<cartModel.result.length;i++){
      gt = gt+int.parse(cartModel.result[i].hargaJual)*int.parse(cartModel.result[i].qty);
    }
    return gt+cost;
  }
  Future loadSubTotal({CartModel cartModel})async{
    int st = 0;
    for(var i=0;i<cartModel.result.length;i++){
      st = st+int.parse(cartModel.result[i].hargaJual)*int.parse(cartModel.result[i].qty);
    }
    return st;
  }
  Future loadKurir({BuildContext context})async{
    final res=await HandleHttp().getProvider("kurir", kurirModelFromJson,context: context);
    if(res is KurirModel){
      KurirModel result=KurirModel.fromJson(res.toJson());
      return result;
    }
  }
  Future loadOngkir({BuildContext context,String kodeKecamatan, String kurir})async{
    final res = await HandleHttp().postProvider('kurir/cek/ongkir',{
      "ke":kodeKecamatan,
      "berat":"100",
      "kurir":"$kurir"
    });
    var resLayanan = CheckOngkirModel.fromJson(res);
    return {
      "ongkir":resLayanan.result.toJson(),
      "layanan":"${resLayanan.result.ongkir[0].service} | ${FunctionHelper().formatter.format(resLayanan.result.ongkir[0].cost)} | ${resLayanan.result.ongkir[0].estimasi}",
      "service":resLayanan.result.ongkir[0].service,
      "cost":resLayanan.result.ongkir[0].cost
    };

  }
}


class ManageStateCheckout extends ChangeNotifier {
  int indexBank = 0 ;
  int indexAddress = 0 ;
  int indexKurir = 0 ;
  int get bank{
    return indexBank ;
  }
  void setBank(index) {
    indexBank = index;
    notifyListeners();
  }
}