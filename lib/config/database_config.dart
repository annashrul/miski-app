

import 'package:miski_shop/helper/database_helper.dart';
import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

class DatabaseConfig {
  static DatabaseConfig _dbHelper = DatabaseConfig._singleton();
  factory DatabaseConfig() {
    return _dbHelper;
  }

  DatabaseConfig._singleton();
  final tables = [
    UserQuery.CREATE_TABLE,
    ProductQuery.CREATE_TABLE,

  ];

  Future<Database> openDB() async {
    final dbPath = await sqlite.getDatabasesPath();
    return sqlite.openDatabase(path.join(dbPath, 'miski_shop.db'),
        onCreate: (db, version) {
          tables.forEach((table) async {
            await db.execute(table).then((value) {
              print("berashil $table");
            }).catchError((err) {
              print("errornya ${err.toString()}");
            });
          });
        }, version: 1);
  }

  Future<bool> insert(String table, Map<String, Object> data) async {
    try{
      final db = await openDB();
      await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    }
    catch(_){
      return false;
    }
  }

  Future<List> getDataLimit(String tableName, String limit) async {
    final db = await openDB();
    var result = await db.rawQuery('SELECT * FROM $tableName ORDER BY RANDOM() LIMIT $limit');
    return result.toList();
  }

  Future<List> getData(String tableName,{String orderBy=''}) async {
    final db = await openDB();
    var result = await db.rawQuery('SELECT * FROM $tableName');

    if(orderBy!=''){
      result = await db.rawQuery('SELECT * FROM $tableName ORDER BY $orderBy DESC');
    }
    return result.toList();
  }
  Future<List> getDataWhere(String tableName,String idTenant,String idProduct) async {
    final db = await openDB();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE id_tenant=? and id_product=?',[idProduct,idTenant]);
    return result.toList();
  }
  Future<List> getDataByTenant(String tableName,String idTenant) async {
    final db = await openDB();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE id_tenant=?',[idTenant]);
    return result.toList();
  }
  Future<List> getDataByTenantLimit(String tableName,String idTenant, String limit) async {
    final db = await openDB();
    var result=  await db.rawQuery('SELECT * FROM $tableName WHERE id_tenant=? and kelompok LIKE "%Celana Dalam%"  LIMIT $limit',[idTenant]);
    return result.toList();
  }
  Future<List<Map<String, dynamic>>> getRow(String sql, [List<dynamic> arguments])async{
    final db = await openDB();
    var result = await db.rawQuery(sql,arguments);
    return result.toList();
  }

  Future<List> readData(String table,String idTenant, {List colWhere,List valWhere,limit='',String param='LIKE'}) async {
    final db = await openDB();
    var result=await db.rawQuery("SELECT * FROM $table WHERE id_tenant=?",[idTenant]);
    var buffer = StringBuffer();
    String separator = ""; // Avoid leading comma.
    String sp = 'LIKE ';
    if(param=='LIKE&BEETWEN&LIMIT')
    if(colWhere!=null){
        if(colWhere.length>0&&limit!=''){
          for (var i=0;i<colWhere.length;i++) {
            buffer..write(separator)..write("${colWhere[i]} ");
            buffer..write(sp)..write("'%${valWhere[i]}%'");
            separator= " and ";
          }
          var loc = buffer.toString();
          print(loc);
          result = await db.rawQuery('SELECT * FROM $table WHERE id_tenant=? and $loc',[idTenant]);
          // print('SELECT * FROM $table WHERE id_tenant=? and $loc LIMIT $limit');
        }
        if(colWhere.length>0){
          for (var i=0;i<colWhere.length;i++) {
            buffer..write(separator)..write("${colWhere[i]} ");
            buffer..write(sp)..write("'%${valWhere[i]}%'");
            separator= " and ";
          }
          var loc = buffer.toString();
          result = await db.rawQuery('SELECT * FROM $table WHERE id_tenant=? and $loc',[idTenant]);
        }
    }

    if(param=='BETWEEN'){
      print('SELECT * FROM $table WHERE id_tenant=? and harga BETWEEN CAST(${colWhere[0]} as INTEGER) and CAST(${colWhere[1]} as INTEGER)');
      result = await db.rawQuery('SELECT * FROM $table WHERE id_tenant=? and harga BETWEEN CAST(${colWhere[0]} as INTEGER) and CAST(${colWhere[1]} as INTEGER)',[idTenant]);
    }
    if(limit!=''){
      result = await db.rawQuery('SELECT * FROM $table WHERE id_tenant=? LIMIT $limit',[idTenant]);
    }
    return result.toList();
  }


  Future<int> queryRowCount(String tableName) async {
    Database db =  await openDB();
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
  }
  Future<int> queryRowCountWhere(String tableName,String column,String where) async {
    Database db =  await openDB();
    List<Map> list = await db.rawQuery('SELECT * FROM $tableName WHERE $column=?',[where]);
    int count = list.length;
    return count;
  }

  Future<bool> update(String table, Map<String, Object> data) async {
    print("DATA $data");
    try{
      print("sukses");
      final db = await openDB();
      String id = data['id'];
      await  db.update(table, data,where: 'id = ?', whereArgs: [id],conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    }
    catch(_){
      print("sukses $_");
      return false;
    }
  }

  deleteAll(table) async{
    openDB().then((db) {
      db.execute("DELETE FROM $table");
    }).catchError((err) {
      print("error $err");
    });
  }

  Future<bool> deleteProductByTenant(table,String idTenant) async{
    try{
      final db = await openDB();
      await db.rawDelete('DELETE FROM $table WHERE id_tenant=? and is_favorite="false" and is_click="false"', [idTenant]);
      return true;
    }
    catch(_){
      return false;
    }
  }

  Future<bool> deleteProductOtherByTenant(table,String idTenant,String isFavorite, String isClick) async{
    try{
      final db = await openDB();
      await db.rawDelete('DELETE FROM $table WHERE id_tenant=? and is_favorite=? and is_click=?', [idTenant,isFavorite,isClick]);
      return true;
    }
    catch(_){
      return false;
    }
  }

  Future<bool> deleteAllProductByTenant(table,String idTenant) async{
    try{
      final db = await openDB();
      await db.rawDelete('DELETE FROM $table WHERE id_tenant=?', [idTenant]);
      return true;
    }
    catch(_){
      return false;
    }
  }
  Future<bool> delete(table,column,value) async{
    try{
      final db = await openDB();
      await db.rawDelete('DELETE FROM $table WHERE $column=?', [value]);
      return true;
    }
    catch(_){
      return false;
    }
  }

  Future<bool> updateProductByTenant(table,String qty,String idTenant,String idProduct) async{
    try{
      final db = await openDB();
      await db.rawUpdate("UPDATE $table SET qty_product = ? WHERE id_tenant = ? and id_product=?",[qty,idTenant,idProduct]);
      return true;
    }
    catch(_){
      return false;
    }
  }



  Future<bool> updateData(table,String column,String value,String idTenant,String idProduct) async{
    try{
      final db = await openDB();
      await db.rawUpdate("UPDATE $table SET $column = ? WHERE id_tenant = ? and id_product=?",[value,idTenant,idProduct]);
      return true;
    }
    catch(_){
      return false;
    }
  }

  Future<List> getWhereFavorite(String tableName,String idTenant,String idProduct,String idUser) async {
    final db = await openDB();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE id_tenant=? and id_product=? and id_user=?',[idTenant,idProduct,idUser]);
    return result.toList();
  }
  Future<List> getDataByUser(String tableName,String idUser) async {
    final db = await openDB();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE id_user=?',[idUser]);
    return result.toList();
  }
  Future<List> getWhereByTenant(String tableName,String idTenant,String column,String value) async {
    final db = await openDB();
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE $column=? and id_tenant=?',[value,idTenant]);
    return result.toList();
  }
  Future<List> getWhere(String tableName,String column,String value,String limit,{orderBy=''}) async {
    final db = await openDB();
    var result;
    if(orderBy!=''){
      orderBy='ORDER BY $orderBy DESC';
    }
    if(column!=""){
      result = await db.rawQuery("SELECT * FROM $tableName WHERE $column=? $orderBy",[value]);
    }
    if(column!=""&&limit!=""){
      result = await db.rawQuery("SELECT * FROM $tableName WHERE $column=? LIMIT $limit",[value]);
    }

    return result.toList();
  }

}