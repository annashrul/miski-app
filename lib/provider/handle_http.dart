import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';

class HandleHttp{
  Client client = Client();
  final userRepository = UserHelper();



  Future getProvider(url,dynamic param,{BuildContext context,Function callback})async{
    try{
      final token= await userRepository.getDataUser(StringConfig.token);
      Map<String, String> head={
        'Authorization':"$token",
        'username': "${StringConfig.username}",
        'password': "${StringConfig.password}",
        'myconnection':"${StringConfig.connection}",
      };
      final response = await client.get("${StringConfig.baseUrl}$url", headers:head).timeout(Duration(seconds: StringConfig.timeout));
      // print("=================== SUCCESS $url ${response.body}  ==========================");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("JSON RESPONSE $url =  $jsonResponse");
        if(jsonResponse['result'].length>0){
          return param==null?jsonResponse:param(response.body);
        }else{
          print("=================== GET DATA $url = NODATA ============================");
          return StringConfig.errNoData;
        }
      }
      else if(response.statusCode == 400){
          final jsonResponse = json.decode(response.body);
        if(jsonResponse['msg']=='Invalid Token.'){
          return WidgetHelper().notifOneBtnDialog(context,StringConfig.titleErrToken,StringConfig.descErrToken,()async{
            Navigator.pop(context);
            await FunctionHelper().logout(context);
          });
        }
        if(context!=null){
          return WidgetHelper().notifOneBtnDialog(context,"Informasi",jsonResponse['msg'],()async{
            Navigator.pop(context);
          });
        }
      }
      else if(response.statusCode==404){
        Navigator.pop(context);
        return WidgetHelper().showFloatingFlushbar(context, "failed", "terjadi kesalahan url");
      }
    }on TimeoutException catch (_) {
      print("###################################### GET TimeoutException $url ");
      return Navigator.pushNamed(context, "error");
    } on SocketException catch (_) {
      print("###################################### GET SocketException $url ");
      return Navigator.pushNamed(context, "error");
    }
    on Error catch (e) {
      print("###################################### GET Error $url $e ");
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }
    catch(_){
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }
  }
  Future postProvider(url,var data,{BuildContext context,Function callback}) async {
    print(data);
    try {
      final token= await userRepository.getDataUser(StringConfig.token);
      final request = await client.post(
          "${StringConfig.baseUrl}$url",
          headers: {
            'Authorization':token,
            'username': StringConfig.username,
            'password': StringConfig.password,
            'myconnection':StringConfig.connection,
            "HttpHeaders.contentTypeHeader": "application/json"
          },
          body:data
      ).timeout(Duration(seconds: StringConfig.timeout));
      if(request.statusCode==200){
        print("=================== POST DATA 200 $url = ${json.decode(request.body)} ============================");
        return json.decode(request.body);
      }
      else if(request.statusCode==400){
        final jsonResponse = json.decode(request.body);
        Navigator.pop(context);
        return WidgetHelper().showFloatingFlushbar(context, "failed", jsonResponse['msg']);
      }
      else if(request.statusCode==404){
        print("=================== request.statusCode==404  $url = $TimeoutException ============================");
        Navigator.pop(context);
        return WidgetHelper().showFloatingFlushbar(context, "failed", "terjadi kesalahan url");
      }
    } on TimeoutException catch (_) {
      print("=================== TimeoutException $url = $TimeoutException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.descErrTimeout);
    } on SocketException catch (_) {
      print("=================== SocketException $url = $SocketException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.msgConnection);
    }
    on Error catch (e) {
      print("###################################### GET Error $url $e ");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }
  }
  Future putProvider(url,Map<String, Object> data,{BuildContext context}) async {
    try {
      final token= await userRepository.getDataUser('token');
      Map<String, String> head={
        'Authorization':token,
        'username': StringConfig.username,
        'password': StringConfig.password,
        'myconnection':StringConfig.connection,
        "HttpHeaders.contentTypeHeader": "application/json"
      };
      final request = await client.put("${StringConfig.baseUrl}$url", headers:head, body:data).timeout(Duration(seconds: StringConfig.timeout));
      print("=================== PUT DATA $url = ${request.statusCode} ============================");
      if(request.statusCode==200){
        return {"statusCode":request.statusCode,"data":jsonDecode(request.body)};
      }
      else if(request.statusCode==400){
        final jsonResponse = json.decode(request.body);
        Navigator.pop(context);
        return WidgetHelper().showFloatingFlushbar(context, "failed", jsonResponse['msg']);
      }
      else if(request.statusCode==404){
        print("=================== request.statusCode==404  $url = $TimeoutException ============================");
        Navigator.pop(context);
        return WidgetHelper().showFloatingFlushbar(context, "failed", "terjadi kesalahan url");
      }
      else if(request.statusCode==413){
        Navigator.pop(context);
        print("jsonResponse");
        return WidgetHelper().showFloatingFlushbar(context, "failed", "File terlalu besar");
      }
    } on TimeoutException catch (_) {
      print("=================== TimeoutException $url = $TimeoutException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.descErrTimeout);
    } on SocketException catch (_) {
      print("=================== SocketException $url = $SocketException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.msgConnection);
    } on Error catch (e) {
      print("###################################### GET Error $url $e ");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }
  }
  Future deleteProvider(url,param,{BuildContext context}) async {
    try {
      final token= await userRepository.getDataUser('token');
      Map<String, String> head={
        'Authorization':token,
        'username': StringConfig.username,
        'password': StringConfig.password,
        'myconnection':StringConfig.connection,
        // "HttpHeaders.contentTypeHeader": "application/json"
      };
      String baseUrl = "${StringConfig.baseUrl}$url";
      final request = await client.delete(
        baseUrl,
        headers: head,
      ).timeout(Duration(seconds: StringConfig.timeout));
      if(request.statusCode==200){
        Navigator.pop(context);
        WidgetHelper().showFloatingFlushbar(context, "success","data berhasil dihapus");
        return param(request.body);
      }
      else if(request.statusCode==400){
        final jsonResponse = json.decode(request.body);
        Navigator.pop(context);
        return WidgetHelper().showFloatingFlushbar(context, "failed", jsonResponse['msg']);
      }
      else if(request.statusCode==404){
        print("=================== request.statusCode==404  $url = $TimeoutException ============================");
        Navigator.pop(context);
        return WidgetHelper().showFloatingFlushbar(context, "failed", "terjadi kesalahan url");
      }
    } on TimeoutException catch (_) {
      print("=================== TimeoutException $url = $TimeoutException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.descErrTimeout);
    } on SocketException catch (_) {
      print("=================== SocketException $url = $SocketException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.msgConnection);
    } on Error catch (e) {
      print("###################################### GET Error $url $e ");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }

  }

}
