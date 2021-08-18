import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' show Client;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/model/cart/cart_model.dart';
import 'package:miski_shop/model/cart/harga_bertingkat_model.dart';
import 'package:miski_shop/model/general_model.dart';

class BaseProvider{
  Client client = Client();
  final userRepository = UserHelper();





  Future<CartModel> getCart(var idTenant,{BuildContext context}) async {
    final token= await userRepository.getDataUser('token');
    final url ="${StringConfig.baseUrl}cart/$idTenant";
    print("CART URL=$url");
    final response = await client.get(url, headers: {'Authorization':token,'username': StringConfig.username, 'password': StringConfig.password,'myconnection':StringConfig.connection},).timeout(Duration(seconds: StringConfig.timeout));
    if (response.statusCode == 200) {
      return cartModelFromJson(response.body);
    } else {
      throw Exception('Failed to load cart');
    }
  }
  Future postCart(var idTenant,var kodeBarang,var idVarian,var idSubVarian,var qty,var hargaJual,var disc1,var disc2) async {
    try {
      final token= await userRepository.getDataUser('token');
      final request = await client.post(
          "${StringConfig.baseUrl}cart",
          headers: {'Authorization':token,'username': StringConfig.username, 'password': StringConfig.password,'myconnection':StringConfig.connection},
          body: {
            'id_tenant': idTenant,
            'kode_barang': kodeBarang,
            'id_varian': idVarian,
            'id_subvarian': idSubVarian,
            'qty': qty,
            'harga_jual': hargaJual,
            'disc1': disc1,
            'disc2': disc2,
          }
      ).timeout(Duration(seconds: StringConfig.timeout));
      var res = General.fromJson(json.decode(request.body));
      if(res is General){
        General result = res;
        if(result.status=='success'){
          return 'success';
        }
        else{
          return 'failed';
        }
      }
    } on TimeoutException catch (_) {
      return 'error';
    } on SocketException catch (_) {
      return 'error';
    }

  }
  Future hargaBertingkat(var id) async {
    final url ="${StringConfig.baseUrl}cart/bertingkat/$id";
    final token= await userRepository.getDataUser('token');
    print("TOKEN $token");
    print("URL HARGA BERTINGKAT $url");
    final response = await client.get(
      url, headers: {'Authorization':token,'username':StringConfig.username,'password':StringConfig.password,'myconnection':StringConfig.connection},
    ).timeout(Duration(seconds: StringConfig.timeout));
    try{
      print("RESPONSE ${response.body}");
      if(response.statusCode == 200){
        return hargaBertingkatModelFromJson(response.body);
      }
      else{
        return 'gagal';
      }
    }on TimeoutException catch (_) {
      print('TimeoutException');
      return 'error';
    } on SocketException catch (_) {
      print('SocketException');
      return 'error';
    }

  }
  Future countCart(idTenant)async{
    var res = await getCart(idTenant);
    return res.result.length;
  }
}

