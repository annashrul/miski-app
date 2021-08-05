import 'package:flutter/cupertino.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/address/function_address.dart';
import 'package:netindo_shop/helper/bank/function_bank.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/model/address/kurir_model.dart';
import 'package:netindo_shop/model/address/list_address_model.dart';
import 'package:netindo_shop/model/bank/bank_model.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/checkout/check_ongkir_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class FunctionCheckout{
  final user = UserHelper();
  Future loadData({BuildContext context,String type="all",int ongkos=0})async{
    final tenant = await FunctionHelper().getTenant();
    final res = await HandleHttp().getProvider('cart/${tenant["id"]}', cartModelFromJson,context: context);
    Map<String,Object> resData = {};
    if(res is CartModel){
      final idUser = await user.getDataUser(StringConfig.id_user);
      List productDetail = [];
      CartModel product=CartModel.fromJson(res.toJson());
      for(var i=0;i<product.result.length;i++){
        int disc1Nominal = FunctionHelper().percentToRp(int.parse(product.result[i].disc1), int.parse(product.result[i].hargaMaster));
        int disc2Nominal = FunctionHelper().percentToRp(int.parse(product.result[i].disc2), int.parse(product.result[i].hargaMaster));
        final resProduct=product.result[i];
        print("nama ${resProduct.barang}");
        productDetail.add({
          "id":resProduct.idBarang,
          "title":resProduct.barang,
          "gambar":resProduct.gambar,
          "kodeBarang":resProduct.kodeBarang,
          "idVarian":resProduct.idVarian,
          "idSubvarian":resProduct.idSubvarian,
          "qty":resProduct.qty,
          "harga":"${int.parse(resProduct.hargaMaster)+int.parse(resProduct.varianHarga)+int.parse(resProduct.subvarianHarga)}",
          "disc":disc1Nominal+disc2Nominal,
          "subtotal":(int.parse(resProduct.hargaJual)*int.parse(resProduct.qty)).toString(),
          "tax":"0"
        });
      }
      int subTotal = await loadSubTotal(cartModel: product);
      if(type=="all"){
        BankModel bank = await FunctionBank().loadData(context: context);
        KurirModel kurir = await loadKurir(context: context);
        ListAddressModel  address = await FunctionAddress().loadData(context: context,isChecking: true);
        final ongkir = await loadOngkir(context: context,kodeKecamatan: address.result.data[0].kdKec,kurir: kurir.result[0].kurir);
        int grandTotal = await loadGrandTotal(cartModel: product,cost: ongkir["cost"]);
        resData = {
          "idUser":idUser,
          "product":product,
          "productDetail":productDetail,
          "grandTotal":grandTotal,
          "subTotal":subTotal,
          "bank":bank.result,
          "address":address.result.toJson(),
          "shipping":{
            "kurir":kurir.toJson(),
            "layanan":ongkir
          }

        };
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