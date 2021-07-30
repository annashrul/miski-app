

import 'dart:ui';

class SiteConfig{
  // final String baseUrl        = 'http://192.168.100.10:3000/';
  final String siteName        = 'Happy Fresh';
  final String baseUrl        = 'http://ptnetindo.com:6698/';
  // final String baseUrl        = 'http://192.168.40.254:6690/';
  final bool showCode         = true;
  final String versionCode    = '0.0.1';
  final String username       = 'netindo';
  final String connection     = 'nshop';
  final String localAssets    = 'assets/img/';
  final String password       = "\$2b\$08\$hLMU6rEvNILCMaQbthARK.iCmDRO7jNbUB8CcvyRStqsHD4UQxjDO";
  final String oneSignalId    = "b1057dd8-ea51-41d2-be3b-a6778ffbf5e4";
  final String noImage        = 'https://upload.wikimedia.org/wikipedia/commons/0/0a/No-image-available.png';
  final String noData         = 'Data Tidak Tersedia';
  final String serverDown     = 'img/server_down.png';
  final int timeout           = 60;
  final int noDataCode        = -100000000;
  final String fontStyle      = 'Roboto-Light';
  final String errTimeout     = 'TimeoutException';
  final String errSocket      = 'SocketException';
  final String errExpToken    = 'TokenExpiredError';
  final String errNoData      = 'No Data.';
  final String msgConnection  = 'Terjadi Kesalahan Jaringan';
  final String titleErrToken  = 'Sesi anda sudah berakhir';
  final String descErrToken   = 'Silahkan login ulang untuk melanjutkan proses ini';
  final String titleMsgSuccessTrx = 'Transaksi Berhasil !';
  final String descMsgSuccessTrx  = 'Terimakasih Telah Melakukan Transaksi disini';
  final String titleErrTimeout    = 'Terjadi Kesalahan !';
  final String descErrTimeout = 'silahkan cobalagi untuk melanjutkan proses ini';
  final Color mainColor       = Color(0xFF009DB5);
  final Color mainDarkColor   = Color(0xFF22B7CE);
  final Color secondColor     = Color(0xFF04526B);
  final Color secondDarkColor = Color(0xFFE7F6F8);
  final Color accentColor     = Color(0xFFADC4C8);
  final Color accentDarkColor = Color(0xFFADC4C8);
  final Color darkMode = Color(0xFF2C2C2C);
  final Color moneyColor = Color(0xFFff5722);
  // final Color transparentColor = Color(0xFFff5722);
  // Theme.of(context).focusColor.withOpacity(0.1),
}