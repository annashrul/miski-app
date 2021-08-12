
class UserQuery {
  static const String TABLE_NAME = "user";
  static const String CREATE_TABLE = " CREATE TABLE IF NOT EXISTS $TABLE_NAME ( id INTEGER PRIMARY KEY AUTOINCREMENT, id_user TEXT , token TEXT, nama TEXT, email TEXT, status TEXT, alamat TEXT,jenis_kelamin TEXT,  tgl_ultah TEXT, tlp TEXT, foto TEXT, biografi TEXT, last_login TEXT, is_login TEXT, onboarding TEXT, exit_app TEXT, onesignal_id TEXT ) ";
  static const String SELECT = "select * from $TABLE_NAME";
}



class ProductQuery {
  static const String TABLE_NAME = "product";
  static const String CREATE_TABLE = " CREATE TABLE IF NOT EXISTS $TABLE_NAME ( id INTEGER PRIMARY KEY AUTOINCREMENT, id_product TEXT,id_tenant TEXT, kode TEXT, title TEXT,tenant TEXT,id_kelompok TEXT,kelompok TEXT,id_brand TEXT,brand TEXT,deskripsi TEXT,harga TEXT,harga_coret TEXT,berat TEXT,pre_order TEXT,free_return TEXT,gambar TEXT,disc1 TEXT,disc2 TEXT,stock TEXT,stock_sales TEXT,rating TEXT, is_favorite TEXT, is_click TEXT) ";
  static const String SELECT = "select * from $TABLE_NAME";
}

