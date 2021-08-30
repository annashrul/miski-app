import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/user_helper.dart';

Future loadData( ) async {
  final foto= await UserHelper().getDataUser(StringConfig.foto);
  final name= await UserHelper().getDataUser(StringConfig.nama);
  final email= await UserHelper().getDataUser(StringConfig.email);
  final gender= await UserHelper().getDataUser(StringConfig.jenis_kelamin);
  final telp = await UserHelper().getDataUser(StringConfig.tlp);
  final birthDate = await UserHelper().getDataUser(StringConfig.tgl_ultah);
  final idUser = await UserHelper().getDataUser(StringConfig.id_user);
  DateTime tempDate = new DateFormat("yyyy-MM-dd").parse(birthDate);
  final data={
    StringConfig.id_user:idUser,
    StringConfig.nama:name,
    StringConfig.tlp:telp,
    StringConfig.foto:foto,
    StringConfig.email:email,
    StringConfig.jenis_kelamin:gender,
    StringConfig.tgl_ultah:"$tempDate".substring(0,10),
  };
  return data;
}

class UserProvider extends ChangeNotifier { // create a common file for data
  dynamic data;
  dynamic get dataUser => data;
  bool loading = false;
  getUserData(BuildContext context) async {
    loading = true;
    data = await loadData();
    loading = false;
    notifyListeners();
  }
  void setData(input) {
    data = input;
    print("SET DATA $data");
    notifyListeners();
  }
}