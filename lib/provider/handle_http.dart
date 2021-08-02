import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/general_model.dart';

class HandleHttp{
  Client client = Client();
  final userRepository = UserHelper();



  Future getProvider(url,param,{BuildContext context,Function callback})async{
    try{
      final token= await userRepository.getDataUser('token');
      Map<String, String> head={
        'Authorization':token,
        'username': SiteConfig().username,
        'password': SiteConfig().password,
        'myconnection':SiteConfig().connection,
        "HttpHeaders.contentTypeHeader": "application/json"
      };
      final response = await client.get("${SiteConfig().baseUrl}$url", headers:head).timeout(Duration(seconds: SiteConfig().timeout));
      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        print("=================== SUCCESS $url = ${response.statusCode} ==========================");
        if(jsonResponse['result'].length>0){
          return param(response.body);
        }else{
          print("=================== GET DATA $url = NODATA ============================");
          return SiteConfig().errNoData;
        }
      }
      else if(response.statusCode == 400){
        print(jsonResponse['msg']);
        if(jsonResponse['msg']=='Invalid Token.'){
          if(context==null){
            return SiteConfig().errExpToken;
          }else{
            return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrToken,SiteConfig().descErrToken,()async{
              Navigator.pop(context);
              await FunctionHelper().logout(context);
            });
          }
        }
        return WidgetHelper().notifOneBtnDialog(context,"Informasi",jsonResponse['msg'],()async{
          Navigator.pop(context);
        });
      }
    }on TimeoutException catch (_) {
      print("###################################### GET TimeoutException $url ");
      return Navigator.pushNamed(context, "error");
    } on SocketException catch (_) {
      print("###################################### GET SocketException $url ");
      return Navigator.pushNamed(context, "error");
    } on Error catch (e) {
      print("###################################### GET Error $url ");
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }
  }
  Future postProvider(url,Map<String, Object> data,{BuildContext context,Function callback}) async {
    try {
      final token= await userRepository.getDataUser('token');
      Map<String, String> head={
        'Authorization':token,
        'username': SiteConfig().username,
        'password': SiteConfig().password,
        'myconnection':SiteConfig().connection,
        // "HttpHeaders.contentTypeHeader": "application/json"
      };
      final request = await client.post(
          "${SiteConfig().baseUrl}$url",
          headers: head,
          body:data
      ).timeout(Duration(seconds: SiteConfig().timeout));
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
    } on Error catch (e) {
      print("###################################### GET Error $url ");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }
  }
  Future putProvider(url,Map<String, Object> data,{BuildContext context}) async {
    try {
      final token= await userRepository.getDataUser('token');
      Map<String, String> head={
        'Authorization':token,
        'username': SiteConfig().username,
        'password': SiteConfig().password,
        'myconnection':SiteConfig().connection,
        "HttpHeaders.contentTypeHeader": "application/json"
      };
      final request = await client.put("${SiteConfig().baseUrl}$url", headers:head, body:data).timeout(Duration(seconds: SiteConfig().timeout));
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
    } on TimeoutException catch (_) {
      print("=================== TimeoutException $url = $TimeoutException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.descErrTimeout);
    } on SocketException catch (_) {
      print("=================== SocketException $url = $SocketException ============================");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.msgConnection);
    } on Error catch (e) {
      print("###################################### GET Error $url ");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }
  }
  Future deleteProvider(url,param,{BuildContext context}) async {
    try {
      final token= await userRepository.getDataUser('token');
      Map<String, String> head={
        'Authorization':token,
        'username': SiteConfig().username,
        'password': SiteConfig().password,
        'myconnection':SiteConfig().connection,
        // "HttpHeaders.contentTypeHeader": "application/json"
      };
      String baseUrl = "${SiteConfig().baseUrl}$url";
      final request = await client.delete(
        baseUrl,
        headers: head,
      ).timeout(Duration(seconds: SiteConfig().timeout));
      if(request.statusCode==200){
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
      print("###################################### GET Error $url ");
      Navigator.pop(context);
      return WidgetHelper().showFloatingFlushbar(context, "failed", StringConfig.errSyntax);
    }

  }

}
