
import 'package:miski_shop/config/database_config.dart';
import 'package:miski_shop/helper/database_helper.dart';

class UserHelper{
  final DatabaseConfig _helper = new DatabaseConfig();
  Future getDataUser(param) async{
    final countTable = await _helper.queryRowCount(UserQuery.TABLE_NAME);
    if(countTable>0){
      final users = await _helper.getData(UserQuery.TABLE_NAME);
      print(users[0]);
      return users[0][param];
    }
  }


}