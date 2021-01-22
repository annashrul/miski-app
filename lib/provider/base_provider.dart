import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' show Client;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/cart/harga_bertingkat_model.dart';
import 'package:netindo_shop/model/general_model.dart';

class BaseProvider{
  Client client = Client();
  final userRepository = UserHelper();
  Future getProvider(url,param)async{
    try{
      final token= await userRepository.getDataUser('token');
      Map<String, String> head={'Authorization':token,'username': SiteConfig().username, 'password': SiteConfig().password,'myconnection':SiteConfig().connection};
      final response = await client.get("${SiteConfig().baseUrl}$url", headers:head).timeout(Duration(seconds: SiteConfig().timeout));
      if (response.statusCode == 200) {
        // print("GET PROVIDER RESPONSE $url ${response.body}");
        return param(response.body);
      }
    }on TimeoutException catch (_) {
      print('TimeoutException');
      return 'TimeoutException';
    } on SocketException catch (_) {
      print('SocketException');
      return 'SocketException';
    }
  }
  Future postProvider(url,Map<String, Object> data) async {
    print("${SiteConfig().baseUrl}$url");
    print(data);
    try {
      final token= await userRepository.getDataUser('token');
      final request = await client.post(
          "${SiteConfig().baseUrl}$url",
          headers: {
            'Authorization':token,
            'username': SiteConfig().username,
            'password': SiteConfig().password,
            'myconnection':SiteConfig().connection,
            "HttpHeaders.contentTypeHeader": "application/json"
          },
          body:data
      ).timeout(Duration(seconds: SiteConfig().timeout));
      print(request.body);
      if(request.statusCode==200){
        return jsonDecode(request.body);
      }
      else if(request.statusCode==400){
        return General.fromJson(jsonDecode(request.body));
      }
    } on TimeoutException catch (_) {
      return 'TimeoutException';
    } on SocketException catch (_) {
      return 'SocketException';
    }
  }
  Future putProvider(url,Map<String, Object> data) async {
    try {
      final token= await userRepository.getDataUser('token');
      final request = await client.put(
          "${SiteConfig().baseUrl}$url",
          headers: {'Authorization':token,'username': SiteConfig().username, 'password': SiteConfig().password,'myconnection':SiteConfig().connection},
          body:data
      ).timeout(Duration(seconds: SiteConfig().timeout));
      print(request.body);
      if(request.statusCode==200){
        return jsonDecode(request.body);
      }
      else if(request.statusCode==400){
        return General.fromJson(jsonDecode(request.body));
      }
    } on TimeoutException catch (_) {
      return 'TimeoutException';
    } on SocketException catch (_) {
      return 'SocketException';
    }
  }

  Future deleteProvider(url,param) async {
    try {
      final token= await userRepository.getDataUser('token');
      String baseUrl = "${SiteConfig().baseUrl}$url";
      final request = await client.delete(
        baseUrl,
        headers: {'Authorization':token,'username': SiteConfig().username, 'password': SiteConfig().password,'myconnection':SiteConfig().connection},
      ).timeout(Duration(seconds: SiteConfig().timeout));
      if(request.statusCode==200){
        return param(request.body);
      }
      else{
        return General.fromJson(jsonDecode(request.body));
      }
    } on TimeoutException catch (_) {
      return 'TimeoutException';
    } on SocketException catch (_) {
      return 'SocketException';
    }

  }

  Future<CartModel> getCart(var idTenant) async {
    final token= await userRepository.getDataUser('token');
    final url ="${SiteConfig().baseUrl}cart/$idTenant";
    final response = await client.get(url, headers: {'Authorization':token,'username': SiteConfig().username, 'password': SiteConfig().password,'myconnection':SiteConfig().connection},).timeout(Duration(seconds: SiteConfig().timeout));
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
          "${SiteConfig().baseUrl}cart",
          headers: {'Authorization':token,'username': SiteConfig().username, 'password': SiteConfig().password,'myconnection':SiteConfig().connection},
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
      ).timeout(Duration(seconds: SiteConfig().timeout));
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
    final url ="${SiteConfig().baseUrl}cart/bertingkat/$id";
    final token= await userRepository.getDataUser('token');
    print("TOKEN $token");
    print("URL HARGA BERTINGKAT $url");
    final response = await client.get(
      url, headers: {'Authorization':token,'username':SiteConfig().username,'password':SiteConfig().password,'myconnection':SiteConfig().connection},
    ).timeout(Duration(seconds: SiteConfig().timeout));
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