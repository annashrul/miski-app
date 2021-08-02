
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';

class UserHelper{
  final DatabaseConfig _helper = new DatabaseConfig();
  Future getDataUser(param) async{
    final countTable = await _helper.queryRowCount(UserQuery.TABLE_NAME);
    if(countTable>0){
      final users = await _helper.getData(UserQuery.TABLE_NAME);
      return users[0][param];
      if(param==StringConfig.id){return users[0][StringConfig.id];}
      if(param==StringConfig.id_user){return users[0][StringConfig.id_user];}
      if(param==StringConfig.nama){return users[0][StringConfig.nama];}
      if(param==StringConfig.token){return users[0][StringConfig.token];}
      if(param==StringConfig.email){return users[0][StringConfig.email];}
      if(param==StringConfig.jenis_kelamin){return users[0][StringConfig.jenis_kelamin];}
      if(param==StringConfig.status){return users[0][StringConfig.status];}
      if(param==StringConfig.alamat){return users[0][StringConfig.alamat];}
      if(param==StringConfig.tgl_ultah){return users[0][StringConfig.tgl_ultah];}
      if(param==StringConfig.tlp){return users[0][StringConfig.tlp];}
      if(param==StringConfig.foto){return users[0][StringConfig.foto].replaceAll(' ','');}
      if(param==StringConfig.biografi){return users[0][StringConfig.biografi];}
      if(param==StringConfig.last_login){return users[0][StringConfig.last_login];}
      if(param==StringConfig.is_login){return users[0][StringConfig.is_login];}
      if(param==StringConfig.onboarding){return users[0][StringConfig.onboarding];}
      if(param==StringConfig.exit_app){return users[0][StringConfig.exit_app];}
      if(param==StringConfig.onesignal_id){return users[0][StringConfig.onesignal_id];}
    }



  }
}