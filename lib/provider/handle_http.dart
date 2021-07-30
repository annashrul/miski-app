import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client;
import 'package:netindo_shop/config/site_config.dart';
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
      if(context==null){
        return SiteConfig().errTimeout;
      }
      else{
        print("###################################### GET TimeoutException $url ");
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){
          callback();
        });
      }
    } on SocketException catch (_) {
      if(context==null){
        return SiteConfig().errTimeout;
      }
      else{
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){
          print("###################################### GET SocketException $url ");
          callback();
        });
      }
    } on Error catch (e) {
      return WidgetHelper().notifOneBtnDialog(context,"Terjadi Kesalahan Syntax","Mohon segera hubungi admin kami",()async{
        Navigator.pop(context);
        await FunctionHelper().logout(context);
      });
      // print('General Error: $e');
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
        print(jsonResponse['msg']);
        if(jsonResponse['msg']=='PIN Tidak Sesuai.'||jsonResponse['msg']=='PIN anda tidak sesuai.'|| jsonResponse['msg']=='PIN tidak valid'){
          return WidgetHelper().notifOneBtnDialog(context,"Terjadi Kesalahan",jsonResponse['msg'],()=>Navigator.pop(context));
        }
        else{
          print("error bukan pin");
          return WidgetHelper().notifOneBtnDialog(context,"Terjadi Kesalahan",jsonResponse['msg'],(){callback();});
        }
      }
      else if(request.statusCode==404){
        return WidgetHelper().notifOneBtnDialog(context,"Informasi !","url not found",(){Navigator.pop(context);});
      }
    } on TimeoutException catch (_) {
      print("=================== TimeoutException $url = $TimeoutException ============================");
      if(context!=null){
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){Navigator.pop(context);});
      }else{
        return SiteConfig().errTimeout;
      }

    } on SocketException catch (_) {
      print("=================== SocketException $url = $SocketException ============================");
      if(context!=null){
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){Navigator.pop(context);});
      }else{
        return SiteConfig().errSocket;
      }
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
        return WidgetHelper().notifOneBtnDialog(context,"Terjadi Kesalahan",jsonResponse['msg'],(){Navigator.pop(context);});
      }
      else if(request.statusCode==413){
        Navigator.pop(context);
        // final jsonResponse = json.decode(request.body);
        print("jsonResponse");
        return WidgetHelper().notifOneBtnDialog(context,"Terjadi Kesalahan","File terlalu besar",(){Navigator.pop(context);});
      }
    } on TimeoutException catch (_) {
      print("=================== TimeoutException $url = $TimeoutException ============================");
      if(context!=null){
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){Navigator.pop(context);});
      }else{
        return SiteConfig().errTimeout;
      }

    } on SocketException catch (_) {
      print("=================== SocketException $url = $SocketException ============================");
      if(context!=null){
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){Navigator.pop(context);});
      }else{
        return SiteConfig().errSocket;
      }
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
      else{
        if(context!=null){
          return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){Navigator.pop(context);});
        }else{
          return General.fromJson(jsonDecode(request.body));
        }
      }
    } on TimeoutException catch (_) {
      if(context!=null){
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){Navigator.pop(context);});
      }else{
        return SiteConfig().errTimeout;
      }
    } on SocketException catch (_) {
      if(context!=null){
        return WidgetHelper().notifOneBtnDialog(context,SiteConfig().titleErrTimeout,SiteConfig().descErrTimeout,(){Navigator.pop(context);});
      }else{
        return SiteConfig().errSocket;
      }

    }

  }

}
