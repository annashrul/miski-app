import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';

class DetailCheckoutScreen extends StatefulWidget {
  final String param;
  final String invoice_no;
  final String grandtotal;
  final String kode_unik;
  final String total_transfer;
  final String bank_logo;
  final String bank_name;
  final String bank_atas_nama;
  final String bank_acc;
  final String bank_code;

  DetailCheckoutScreen({
    this.param,
    this.invoice_no,
    this.grandtotal,
    this.kode_unik,
    this.total_transfer,
    this.bank_logo,
    this.bank_name,
    this.bank_atas_nama,
    this.bank_acc,
    this.bank_code,
  });
  @override
  _DetailCheckoutScreenState createState() => _DetailCheckoutScreenState();
}

class _DetailCheckoutScreenState extends State<DetailCheckoutScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String fileName;
  var hari  = DateFormat.d().format( DateTime.now().add(Duration(days: 3)));
  var bulan = DateFormat.M().format( DateTime.now());
  var tahun = DateFormat.y().format( DateTime.now());


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    print("widget.param ${widget.param}");
    final key = new GlobalKey<ScaffoldState>();
    return WillPopScope(
      child: Scaffold(
            backgroundColor: Colors.white,
            key: key,
            appBar: WidgetHelper().appBarWithButton(context, "${widget.invoice_no}",(){
              print("bus");
              if(widget.param!="bisa"){
                WidgetHelper().myPushRemove(context,  WrapperScreen(currentTab: StringConfig.defaultTab));
              }else{
                Navigator.pop(context);
              }
              // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => WrapperScreen(currentTab: StringConfig.defaultTab)), (Route<dynamic> route) => false);
            },<Widget>[],brightness: Brightness.light),
            resizeToAvoidBottomInset: false,
            body: Scrollbar(
                child: ListView(
                  children: <Widget>[
                    Image.asset(
                      'img/checkmark.gif',
                      height: MediaQuery.of(context).size.height / 7,
                      fit: BoxFit.fitHeight,
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                      padding:scaler.getPadding(0,2),
                      child: WidgetHelper().textQ("Silahkan transfer tepat sebesar :", scaler.getTextSize(9),LightColor.lightblack, FontWeight.normal),
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Container(
                      margin: scaler.getMargin(0, 0),
                      color:Theme.of(context).focusColor.withOpacity(0.1),
                      padding:scaler.getPadding(1,2),
                      child:Center(
                        child: WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(widget.total_transfer))} .-", scaler.getTextSize(12),LightColor.orange, FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                      padding:scaler.getPadding(0,2),
                      child: WidgetHelper().textQ("Pembayaran dapat dilakukan ke rekening berikut : ", scaler.getTextSize(9), LightColor.lightblack, FontWeight.normal),
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                      padding:scaler.getPadding(0,0),
                      child: Container(
                        color:Theme.of(context).focusColor.withOpacity(0.1),
                        child: ListTile(
                          onTap: (){
                            Clipboard.setData(new ClipboardData(text: "${widget.bank_acc}"));
                            WidgetHelper().showFloatingFlushbar(context,"success"," no rekening berhasil disalin");
                          },
                          contentPadding:scaler.getPadding(0,2),
                          leading: WidgetHelper().baseImage(widget.bank_logo),
                          title:WidgetHelper().textQ("${widget.bank_atas_nama}", scaler.getTextSize(9),LightColor.lightblack, FontWeight.bold),
                          subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                WidgetHelper().textQ("${widget.bank_acc}", scaler.getTextSize(9),LightColor.lightblack, FontWeight.normal),
                                SizedBox(width: scaler.getWidth(1)),
                                Icon(Ionicons.ios_copy, color:LightColor.lightblack,size: scaler.getTextSize(9),),
                              ]
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                      padding:scaler.getPadding(0,2),
                        child:Center(
                          child: WidgetHelper().textQ('VERIFIKASI PENERIMAAN TRANSFER ANDA AKAN DIPROSES SELAMA 5-10 MENIT', scaler.getTextSize(9), LightColor.lightblack, FontWeight.bold,maxLines: 3),
                        )
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                        padding:scaler.getPadding(0,0),
                        child: Container(
                          color:Theme.of(context).focusColor.withOpacity(0.1),
                          padding:scaler.getPadding(0.5,2),
                          child: RichText(
                            text: TextSpan(
                                text: 'Anda dapat melakukan transfer menggunakan ATM, Mobile Banking atau SMS Banking dengan memasukan kode bank',
                                style: GoogleFonts.robotoCondensed(fontSize: scaler.getTextSize(9),color: LightColor.lightblack),
                                children: <TextSpan>[
                                  TextSpan(text: ' ${widget.bank_name} (${widget.bank_code})',style: GoogleFonts.robotoCondensed(fontSize: scaler.getTextSize(9),color: LightColor.black,fontWeight: FontWeight.bold)),
                                  TextSpan(text: ' di depan No.Rekening atas nama',style: GoogleFonts.robotoCondensed(fontSize: scaler.getTextSize(9),color: LightColor.lightblack)),
                                  TextSpan(text: ' ${widget.bank_atas_nama}',style:GoogleFonts.robotoCondensed(fontSize: scaler.getTextSize(9),color: LightColor.black,fontWeight: FontWeight.bold)),
                                ]
                            ),
                          ),
                        )
                    ),
                    SizedBox(height: scaler.getHeight(1)),

                    Container(
                        padding:scaler.getPadding(0,2),
                        child:WidgetHelper().textQ("mohon transfer tepat hingga 3 digit terakhir agar tidak menghambat proses verifikasi".toUpperCase(),scaler.getTextSize(9), LightColor.lightblack, FontWeight.bold,maxLines: 3)
                    ),
                    SizedBox(height: scaler.getHeight(1)),

                    Padding(
                        padding:scaler.getPadding(0,0),
                        child: Container(
                          color:Theme.of(context).focusColor.withOpacity(0.1),
                          padding:scaler.getPadding(0.5,2),
                          child: RichText(
                            text: TextSpan(
                                text: 'Pastikan anda transfer sebelum tanggal',
                                style:  GoogleFonts.robotoCondensed(fontSize: scaler.getTextSize(9),color: LightColor.lightblack),
                                children: <TextSpan>[
                                  TextSpan(text: ' $hari-$bulan-$tahun 23:00 WIB',style: GoogleFonts.robotoCondensed(fontSize: scaler.getTextSize(9),color: LightColor.black,fontWeight: FontWeight.bold)),
                                  TextSpan(text: ' atau transaksi anda otomatis dibatalkan oleh sistem. jika sudah melakukan transfer segera upload bukti transfer disini atau di halaman detail riwayat pembelian',style: GoogleFonts.robotoCondensed(fontSize: scaler.getTextSize(9),color: LightColor.lightblack)),
                                ]
                            ),
                          ),
                        )
                    )
                  ],
                )
            ),
            bottomNavigationBar: _bottomNavBarBeli(context)
        ),
      onWillPop:widget.param=='bisa'? null: () async{
          WidgetHelper().showFloatingFlushbar(context,"failed","gunakan tombol kembali yang ada pada aplikasi ini.");
          return false;
      },
    );
  }
  String url = '',image='';
  Widget _bottomNavBarBeli(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return FlatButton(
        onPressed: () {
          WidgetHelper().myModal(context, UploadImage(
            callback: (String img)async{
              setState(() {
                url = base64.encode(utf8.encode(widget.invoice_no));
                image = img;
              });
              upload(url,image);
            },
          ));
        },
        padding:scaler.getPadding(1,0),
        color: SiteConfig().secondColor,
        // shape: StadiumBorder(),
        child:WidgetHelper().textQ("Saya sudah transfer",scaler.getTextSize(10), Theme.of(context).primaryColor, FontWeight.bold)
      // child:Text("abus")
    );

  }
  int retry=0;
  Future uploadAgain()async{
    print('upload deui');
    await upload(url,image);
    setState(() {
      retry+=1;
    });
    print("RETRY $retry");
  }

  Future upload(encoded,img)async{
    WidgetHelper().loadingDialog(context);
    var res = await BaseProvider().postProvider("transaction/bayar/$encoded", {"bukti":img});
    print("REPSONSE $res");
    if(res == '${SiteConfig().errTimeout}'|| res=='${SiteConfig().errSocket}'){
      Navigator.pop(context);
      WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Mohon maaf server kami sedang dalam masalah", (){},(){});
    }
    else{
      if(res is General){
        General result = res;
        Navigator.pop(context);
        if(retry>=3){
          WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Silahkan lakukan pembuatan tiket komplain di halaman tiket", (){
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
          },(){
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
          },titleBtn1: "kembali",titleBtn2: "home");
        }
        else{
          WidgetHelper().notifDialog(context,"Terjadi Kesalahan","${result.msg}", (){
            Navigator.pop(context);
          },(){
            Navigator.pop(context);
            uploadAgain();
          },titleBtn1: "kembali",titleBtn2: "Coba lagi");
        }

      }
      else{
        Navigator.pop(context);
        WidgetHelper().notifDialog(context,"Transaksi Berhasil","Terimakasih telah melakukan transaksi disini", (){
          WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: StringConfig.defaultTab));
        },(){
          Navigator.pop(context);
        },titleBtn2: "home",titleBtn1: "detail pembelian");
      }
    }
  }
}
class UploadImage extends StatefulWidget {
  final Function(String bukti) callback;
  UploadImage({this.callback});
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File _image;
  String dropdownValue = 'pilih';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      padding:scaler.getPadding(0,2),
      decoration: BoxDecoration(
        color:Colors.transparent,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), topLeft: Radius.circular(20.0))
      ),
      child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height:10.0),
            Center(
              child: Container(
                padding: EdgeInsets.only(top:10.0),
                width: 50,
                height: 10.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:  BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height:scaler.getHeight(1)),
            WidgetHelper().textQ("Ambil gambar dari ?",12,SiteConfig().darkMode,FontWeight.bold),
            SizedBox(height:scaler.getHeight(1)),
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: DropdownButton<String>(
                  isDense: true,
                  isExpanded: true,
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 20,
                  underline: SizedBox(),
                  onChanged: (newValue) async {
                    var img = await FunctionHelper().getImage(newValue);
                    print(img);
                    setState(() {
                      dropdownValue  = newValue;
                      _image = img;
                    });
                  },
                  items: <String>['pilih','kamera', 'galeri'].map<DropdownMenuItem<String>>((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          WidgetHelper().textQ(value,12,Colors.grey,FontWeight.bold)
                        ],
                      ),
                    );
                  }).toList(),
                )
            ),
            Divider(),
            Container(
              padding:EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                borderRadius:  BorderRadius.circular(10.0),
              ),
              child: _image == null ?Image.asset(SiteConfig().localAssets+'logo.jpeg',width: double.infinity,fit: BoxFit.contain): new Image.file(_image,width: MediaQuery.of(context).size.width/1,height: MediaQuery.of(context).size.height/2,filterQuality: FilterQuality.high,),
            ),
            SizedBox(height:scaler.getHeight(1)),
            Container(
              width: double.infinity,

              child: FlatButton(
                  onPressed: () {
                    if(_image!=null){
                      String fileName;
                      String base64Image;
                      fileName = _image.path.split("/").last;
                      var type = fileName.split('.');
                      base64Image = 'data:image/' + type[1] + ';base64,' + base64Encode(_image.readAsBytesSync());
                      widget.callback(base64Image);
                    }
                  },
                  padding:scaler.getPadding(1,0),
                  color: SiteConfig().secondColor,
                  child:WidgetHelper().textQ("Simpan",scaler.getTextSize(10), Theme.of(context).primaryColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),
            SizedBox(height:scaler.getHeight(1)),
          ],
        )
    );
  }
}
