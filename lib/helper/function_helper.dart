import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/harga_bertingkat_model.dart';
import 'package:netindo_shop/model/config/config_auth.dart';
import 'package:netindo_shop/model/tenant/list_tenant_model.dart';
import 'package:netindo_shop/pages/component/auth/signin_component.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FunctionHelper{
  final userRepository = UserHelper();
  final formatter = new NumberFormat("#,###");
  static var arrOptDate=[
    "Belum dibayar",
    "Menunggu konfirmasi",
    "Barang sedang dikemas",
    "Dikirim",
    "Selesai",
    "Semua"
  ];



  Future<Map<String,Object>> getTenant()async{
    SharedPreferences sess = await SharedPreferences.getInstance();
    List<String> tenant = sess.getStringList("tenant");
    Map<String,Object> setTenant = {
      StringConfig.idTenant:tenant[0],
      StringConfig.namaTenant:tenant[1],
      StringConfig.emailTenant:tenant[2],
      StringConfig.telpTenant:tenant[3],
      StringConfig.alamatTenant:tenant[4],
      StringConfig.logoTenant:tenant[5],
    };

    return setTenant;
  }
  Future checkTenant()async{
    ListTenantModel listTenantModel;
    final tenant = await HandleHttp().getProvider("tenant?page=1",listTenantModelFromJson);
    SharedPreferences sess = await SharedPreferences.getInstance();
    sess.setBool("isTenant", true);
    if(tenant is ListTenantModel){
      ListTenantModel dataTenant=ListTenantModel.fromJson(tenant.toJson());
      if(dataTenant.result.data.length==1){
        final val = dataTenant.result.data[0];
        listTenantModel = dataTenant;
        sess.setString("namaTenant", val.nama);
        sess.setString("idTenant", val.id);
        sess.setBool("isTenant", false);
        return listTenantModel;
      }
    }
  }

  getCurrentLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) async {
      String _currentAddress;
      print(position);
      try {
        List<Placemark> p = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);
        Placemark place = p[0];
        _currentAddress = "${place.thoroughfare}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
        print(_currentAddress);
        return place;
      } catch (e) {
        print(e);
      }
    }).catchError((e) {
      print(e);
    });


  }

  Future getImage(param) async {
    ImageSource imageSource;
    if(param == 'kamera'){
      imageSource = ImageSource.camera;
    }
    else{
      imageSource = ImageSource.gallery;
    }
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: imageSource);
    print(pickedFile.path);
    return File(pickedFile.path);
  }
  bool isEmail(String em) {
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }
  String removeLastCharacter(String str) {
    String result = "";
    if ((str != null) && (str.length > 0)) {
      result = str.substring(0, str.length - 2);
    }
    return result;
  }
  percentToRp(var disc,var price){
    double diskon =  (disc/100)*price;
    var exp = diskon.toString().split('.');
    return int.parse(exp[0]);
  }

  doubleDiskon(total, diskon) {
    var hitungDiskon = double.parse(total);
    for (var i=0; i<diskon.length; i++) {
      if((double.parse(diskon[i])) > 0){
        hitungDiskon = hitungDiskon - (hitungDiskon * ((double.parse(diskon[i])) / 100));
      }
    }
    // var exp = hitung_diskon.toString().split('.');
    return int.parse(exp(hitungDiskon.toString()));
  }

  exp(String txt){
    return txt.split('.')[0];
  }

  Future getConfig({BuildContext context}) async{
    var res = await HandleHttp().getProvider('auth/config', configAuthModelFromJson,context: context);
    if(res is ConfigAuthModel){
      ConfigAuthModel result = res;
      return result.result.toJson();
    }
  }
  Future<List> checkingPriceComplex(idTenant,idBarang,kode,idVarian,idSubVarian,qty,harga,disc1,disc2,isTrue,hargaMaster,hargaVarian,hargaSubVarian) async {
    await BaseProvider().postCart(
        idTenant,
        kode,
        idVarian==null?'-':idVarian,
        idSubVarian==null?'-':idSubVarian,
        qty.toString(),
        harga.toString(),
        disc1.toString(),
        disc2.toString()
    );
    List newArr = [];
    if(isTrue==true){
      var resBertingkatt = await BaseProvider().hargaBertingkat(idBarang);
      bool isSet = false;
      if(resBertingkatt is HargaBertingkatModel){
        HargaBertingkatModel result = resBertingkatt;
        if(result.status=='success'){
          if(result.result.length>0){
            for(var i=0; i<result.result.length;i++){
              if(int.parse(qty)>=result.result[i].dari&&int.parse(qty)<=result.result[i].sampai){
                harga = result.result[i].harga;
                if(int.parse(disc1)>0){
                  harga = (FunctionHelper().doubleDiskon(result.result[i].harga, ['${disc1.toString()}','${disc2.toString()}'])).toString();
                }
                await BaseProvider().postCart(idTenant, kode, idVarian==null?'-':idVarian, idSubVarian==null?'-':idSubVarian, qty.toString(), harga, disc1.toString(), disc2.toString());
                isSet=true;
                newArr.add({
                  "idTenant" : idTenant,
                  "kode" : kode,
                  "idVarian" : idVarian,
                  "idSubVarian" : idSubVarian,
                  "qty" : qty,
                  "harga" : harga,
                  "disc1" : disc1,
                  "disc2" : disc2,
                });
              }
              else{
                harga = hargaMaster;
                if(int.parse(disc1)>0){
                  harga = (FunctionHelper().doubleDiskon(
                      (int.parse(hargaMaster)+int.parse(hargaVarian)+int.parse(hargaSubVarian)).toString(), ['${disc1.toString()}','${disc2.toString()}'])
                  ).toString();
                }
                await BaseProvider().postCart(
                    idTenant,
                    kode,
                    idVarian==null?'-':idVarian,
                    idSubVarian==null?'-':idSubVarian,
                    qty.toString(),
                    harga,
                    disc1.toString(),
                    disc2.toString()
                );
                isSet=false;
                newArr.add({
                  "idTenant" : idTenant,
                  "kode" : kode,
                  "idVarian" : idVarian,
                  "idSubVarian" : idSubVarian,
                  "qty" : qty,
                  "harga" : harga,
                  "disc1" : disc1,
                  "disc2" : disc2,
                });
              }
              if(isSet==true){
                break;
              }
            }
          }
        }
      }
    }
    else{
      newArr.add({
        "idTenant" : idTenant,
        "kode" : kode,
        "idVarian" : idVarian,
        "idSubVarian" : idSubVarian,
        "qty" : qty,
        "harga" : harga,
        "disc1" : disc1,
        "disc2" : disc2,
      });
    }
    return newArr;
  }

  Future setSession(key,val)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key,val);
  }
  Future getSession(key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  Future rmSession(key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future rmPinPoint()async{
    await rmSession(StringConfig.longitude);
    await rmSession(StringConfig.latitude);
  }

  Future logout(BuildContext context)async{
    WidgetHelper().notifDialog(context,"Perhatian !!","Anda yakin akan keluar dari aplikasi ??", (){Navigator.pop(context);}, ()async{
      DatabaseConfig db = DatabaseConfig();
      final id = await UserHelper().getDataUser('id');
      await db.update(UserQuery.TABLE_NAME, {'id':"${id.toString()}",StringConfig.is_login:"0",StringConfig.onboarding:"1"});
      WidgetHelper().myPushRemove(context,SignInComponent());
    });

  }


}