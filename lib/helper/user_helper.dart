
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';

class UserHelper{
  final DatabaseConfig _helper = new DatabaseConfig();
  Future getDataUser(param) async{
    final countTable = await _helper.queryRowCount(UserQuery.TABLE_NAME);
    if(countTable>0){
      final users = await _helper.getData(UserQuery.TABLE_NAME);

      print("GET DATA USER $users");
      if(param=='id'){return users[0]['id'];}
      if(param=='id_user'){return users[0]['id_user'];}
      if(param=='nama'){return users[0]['nama'];}
      if(param=='token'){return users[0]['token'];}
      if(param=='email'){return users[0]['email'];}
      if(param=='jenis_kelamin'){return users[0]['jenis_kelamin'];}
      if(param=='status'){return users[0]['status'];}
      if(param=='alamat'){return users[0]['alamat'];}
      if(param=='tgl_ultah'){return users[0]['tgl_ultah'];}
      if(param=='tlp'){return users[0]['tlp'];}
      if(param=='foto'){return users[0]['foto'].replaceAll(' ','');}
      if(param=='biografi'){return users[0]['biografi'];}
      if(param=='last_login'){return users[0]['last_login'];}
      if(param=='is_login'){print("return is login");return users[0]['is_login'];}
      if(param=='onboarding'){return users[0]['onboarding'];}
      if(param=='exit_app'){return users[0]['exit_app'];}
      if(param=='onesignal_id'){return users[0]['onesignal_id'];}
    }



  }
}