import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/model/address/kecamatan_model.dart';
import 'package:netindo_shop/model/address/kota_model.dart';
import 'package:netindo_shop/model/address/provinsi_model.dart';
import 'package:netindo_shop/model/cart/harga_bertingkat_model.dart';
import 'package:netindo_shop/model/config/config_auth.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_brand_product_model.dart';
import 'package:netindo_shop/model/tenant/list_category_product_model.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FunctionHelper{
  final DatabaseConfig _helper = new DatabaseConfig();
  final userRepository = UserHelper();
  final formatter = new NumberFormat("#,###");
  static var arrOptDate=[
    "Belum dibayar",
    "Menunggu konfirmasi",
    "Barang sedang dikemas",
    "Dikirim",
    "Selesai",
    "Semua status",
  ];
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
    return File(pickedFile.path);
  }
  bool isEmail(String em) {
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }
  String removeLastCharacter(String str) {
    String result = null;
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

  double_diskon(total, diskon) {
    var hitung_diskon = double.parse(total);
    for (var i=0; i<diskon.length; i++) {
      if((double.parse(diskon[i])) > 0){
        hitung_diskon = hitung_diskon - (hitung_diskon * ((double.parse(diskon[i])) / 100));
      }
    }
    // var exp = hitung_diskon.toString().split('.');
    return int.parse(exp(hitung_diskon.toString()));
  }

  exp(String txt){
    return txt.split('.')[0];
  }

  Future getConfig() async{
    var res = await BaseProvider().getProvider('auth/config', configAuthModelFromJson);
    if(res is ConfigAuthModel){
      ConfigAuthModel result = res;
      // print("CONFIG $re")
      return result.result.type;
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
                  harga = (FunctionHelper().double_diskon(result.result[i].harga, ['${disc1.toString()}','${disc2.toString()}'])).toString();
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
                  harga = (FunctionHelper().double_diskon(
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

  Future<List> baseProduct(where)async{
    List newArr = [];
    String url = 'barang?page=1';
    if(where!=''){
      url+= "&$where";
    }
    var res = await BaseProvider().getProvider(url, listProductTenantModelFromJson);
    await setSession("perPage", "${res.result.perPage.toString()}");
    await setSession("lastPage", "${res.result.lastPage.toString()}");
    if(res is ListProductTenantModel){
      newArr.add({
        "data": ListProductTenantModel.fromJson(res.toJson()),
        "total": res.result.total
      });
    }
    else{
      newArr = [];
    }
    return newArr;
  }



  Future insertProduct(idTenant)async{
    print("INSERT");
    final countTableProduct = await _helper.queryRowCount(ProductQuery.TABLE_NAME);
    ListProductTenantModel productTenantModel;
    // final perPage = await FunctionHelper().getSession("perPage");
    // final lastPage = await FunctionHelper().getSession("lastPage");
    // int perpage = int.parse(perPage)*int.parse(lastPage);
    var resProduct = await FunctionHelper().baseProduct('perpage=100000000&tenant=$idTenant');
    if(resProduct.length>0){
      productTenantModel = resProduct[0]['data'];
      productTenantModel.result.data.forEach((element)async {
        final data = {
          "id_product": element.id.toString(),
          "id_tenant": element.idTenant.toString(),
          "kode": element.kode.toString(),
          "title": element.title.toString(),
          "tenant": element.tenant.toString(),
          "id_kelompok": element.idKelompok.toString(),
          "kelompok": element.kelompok.toString(),
          "id_brand":element.idBrand.toString(),
          "brand": element.brand.toString(),
          "deskripsi": element.deskripsi.toString(),
          "harga": element.harga.toString(),
          "harga_coret": element.hargaCoret.toString(),
          "berat": element.berat.toString(),
          "pre_order": element.preOrder.toString(),
          "free_return": element.freeReturn.toString(),
          "gambar": element.gambar.toString(),
          "disc1": element.disc1.toString(),
          "disc2": element.disc2.toString(),
          "stock": element.stock.toString(),
          "stock_sales": element.stockSales,
          "rating": element.rating.toString(),
        };
        var insert = await _helper.insert(ProductQuery.TABLE_NAME, data);
        if(insert){
          print("BERHASIL INSERT ${element.title}");
        }
        else{
          print("GAGAL INSERT ${element.title}");
        }
      });
    }

  }

  Future baseCategory()async{
    var resCategory = await BaseProvider().getProvider("kategori?page=1&perpage=10000000", listCategoryProductModelFromJson);
    if(resCategory is ListCategoryProductModel){
      ListCategoryProductModel result = resCategory;
      return result.result.data;
    }
  }
  Future baseGroup()async{
    var resGroup = await BaseProvider().getProvider("kelompok?page=1&perpage=10000000", listGroupProductModelFromJson);
    if(resGroup is ListGroupProductModel){
      ListGroupProductModel result = resGroup;
      return result.result.data;
    }
  }
  Future baseBrand()async{
    var resBrand = await BaseProvider().getProvider("brand?page=1&perpage=10000000", listBrandProductModelFromJson);
    if(resBrand is ListBrandProductModel){
      ListBrandProductModel result = resBrand;
      return result.result.data;
    }
  }

  Future insertCategory()async{
    final countTableCategory = await _helper.queryRowCount(CategoryQuery.TABLE_NAME);
    if(countTableCategory<1){
      var resCategory = await FunctionHelper().baseCategory();
      resCategory.forEach((element)async {
        print("INSERT CATEGORY ${element.title.toString()}");
        await _helper.insert(CategoryQuery.TABLE_NAME, {
          "id_category":element.id.toString(),
          "title":element.title.toString(),
          "image":element.image.toString(),
          "status":element.status.toString(),
        });
      });
    }

  }
  Future insertBrand()async{
    final countTableBrand = await _helper.queryRowCount(BrandQuery.TABLE_NAME);
    if(countTableBrand<1){
      await _helper.insert(BrandQuery.TABLE_NAME, {
        "id_brand":"",
        "title":"All",
        "image":"",
        "status":"",
      });
      var resBrand = await FunctionHelper().baseBrand();
      resBrand.forEach((element)async {
        print("INSERT BRAND ${element.title.toString()}");
        await _helper.insert(BrandQuery.TABLE_NAME, {
          "id_brand":element.id.toString(),
          "title":element.title.toString(),
          "image":element.image.toString(),
          "status":element.status.toString(),
        });
      });
    }

  }
  Future insertGroup()async{
    final countTableGroup = await _helper.queryRowCount(GroupQuery.TABLE_NAME);
    if(countTableGroup<1){

      var resGroup = await FunctionHelper().baseGroup();
      resGroup.forEach((element)async {
        print("INSERT GROUP ${element.title.toString()}");
        await _helper.insert(GroupQuery.TABLE_NAME, {
          "id_groups":element.id.toString(),
          "id_category":element.idKategori.toString(),
          "category":element.kategori.toString(),
          "title":element.title.toString(),
          "image":element.image.toString(),
          "status":element.status.toString(),
        });
      });
    }
  }

  Future getFilterLocal(param)async{
    if(param!=''){
      // await _helper.deleteAllProductByTenant(ProductQuery.TABLE_NAME,param);
      await _helper.deleteAll(CategoryQuery.TABLE_NAME);
      await _helper.deleteAll(GroupQuery.TABLE_NAME);
      await _helper.deleteAll(BrandQuery.TABLE_NAME);
    }
    await insertCategory();
    await insertGroup();
    await insertBrand();
  }

  Future setSession(key,val)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key,val);
  }
  Future getSession(key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  Future<void> handleRefresh(Function callback)async {
    final Completer<void> completer = Completer<void>();
    await Future.delayed(Duration(seconds: 1));
    completer.complete();
    return completer.future.then<void>((_) {
      callback();
    });
  }

  Future<bool> getSite()async{
    bool isMode=false;
    await _helper.getData(SiteQuery.TABLE_NAME).then((value){
      value.forEach((element) {
        if(element['mode']=='light'){
          isMode= false;
        }
        else{
          isMode = true;
        }
      });

    });
    return isMode;
  }

  Future storeSite(value)async{
    if(value==true){
      await _helper.deleteAll(SiteQuery.TABLE_NAME);
      await _helper.insert(SiteQuery.TABLE_NAME, {"onBoarding":"0","exitApp":"0","mode":"dark"});
      await getSite();
    }
    else{
      await _helper.deleteAll(SiteQuery.TABLE_NAME);
      await _helper.insert(SiteQuery.TABLE_NAME, {"onBoarding":"0","exitApp":"0","mode":"light"});
      await getSite();
    }
  }

  whereDynamic(List colWhere,List valWhere){
    if(colWhere.length>0){
      var buffer = StringBuffer();
      String separator = "";
      String separator1 = 'LIKE ';
      for (var i=0;i<colWhere.length;i++) {
        buffer..write(separator)..write("${colWhere[i]} ");
        buffer..write(separator1)..write("'%${valWhere[i]}%'");
        separator= " and ";
      }
      var loc = buffer.toString();
      return loc;
    }

  }



}