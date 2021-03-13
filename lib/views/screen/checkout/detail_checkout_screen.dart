import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/site_config.dart';
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

    final key = new GlobalKey<ScaffoldState>();
    return WillPopScope(
      child: Scaffold(
            backgroundColor: Colors.white,
            key: key,
            appBar: WidgetHelper().appBarWithButton(context, "${widget.invoice_no}",(){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => WrapperScreen(currentTab: 2)), (Route<dynamic> route) => false);
            },<Widget>[],brightness: Brightness.light),
            resizeToAvoidBottomInset: false,
            body: Scrollbar(
                child: ListView(
                  children: <Widget>[
                    // SizedBox(height: 30),
                    Image.asset(
                      'img/checkmark.gif',
                      height: MediaQuery.of(context).size.height / 7,
                      fit: BoxFit.fitHeight,
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                      padding:scaler.getPadding(0,2),
                      child: WidgetHelper().textQ("Silahkan transfer tepat sebesar :", scaler.getTextSize(10),SiteConfig().darkMode, FontWeight.normal),
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Container(
                      margin: scaler.getMargin(0, 0),
                      color:Theme.of(context).focusColor.withOpacity(0.1),
                      padding:scaler.getPadding(1,2),
                      child:Center(
                        child: WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(widget.total_transfer))} .-", scaler.getTextSize(12),SiteConfig().moneyColor, FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                      padding:scaler.getPadding(0,2),
                      child: WidgetHelper().textQ("Pembayaran dapat dilakukan ke rekening berikut : ", scaler.getTextSize(10), SiteConfig().darkMode, FontWeight.normal),
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
                          title:WidgetHelper().textQ("${widget.bank_atas_nama}", scaler.getTextSize(10),SiteConfig().darkMode, FontWeight.normal),
                          subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                WidgetHelper().textQ("${widget.bank_acc}", scaler.getTextSize(10),SiteConfig().darkMode, FontWeight.normal),
                                SizedBox(width: 5),
                                Icon(Icons.content_copy, color:SiteConfig().darkMode, size: 15,),
                              ]
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    Padding(
                      padding:scaler.getPadding(0,2),
                        child:Center(
                          child: WidgetHelper().textQ('VERIFIKASI PENERIMAAN TRANSFER ANDA AKAN DIPROSES SELAMA 5-10 MENIT', scaler.getTextSize(10), SiteConfig().mainColor, FontWeight.normal,letterSpacing: 2,maxLines: 3),
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
                                style: TextStyle(fontSize: scaler.getTextSize(10),fontFamily:SiteConfig().fontStyle,color:SiteConfig().darkMode,fontWeight: FontWeight.normal),
                                children: <TextSpan>[
                                  TextSpan(text: ' ${widget.bank_name} (${widget.bank_code})',style: TextStyle(color:SiteConfig().mainColor, fontSize:  scaler.getTextSize(10),fontWeight: FontWeight.normal,fontFamily:SiteConfig().fontStyle)),
                                  TextSpan(text: ' di depan No.Rekening atas nama',style: TextStyle(fontSize:  scaler.getTextSize(10),fontFamily:SiteConfig().fontStyle)),
                                  TextSpan(text: ' ${widget.bank_atas_nama}',style: TextStyle(color:SiteConfig().mainColor, fontSize: 12,fontWeight: FontWeight.normal,fontFamily:SiteConfig().fontStyle)),
                                ]
                            ),
                          ),
                        )
                    ),
                    SizedBox(height: scaler.getHeight(1)),

                    Container(
                        padding:scaler.getPadding(0,2),
                        child:WidgetHelper().textQ("mohon transfer tepat hingga 3 digit terakhir agar tidak menghambat proses verifikasi", scaler.getTextSize(10),SiteConfig().darkMode, FontWeight.normal)
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
                                style: TextStyle(fontWeight:FontWeight.normal,fontSize: scaler.getTextSize(10),fontFamily:SiteConfig().fontStyle,color:SiteConfig().darkMode),
                                children: <TextSpan>[
                                  TextSpan(text: ' $hari-$bulan-$tahun 23:00 WIB',style: TextStyle(color:SiteConfig().mainColor, fontSize:  scaler.getTextSize(10),fontWeight: FontWeight.normal,fontFamily:SiteConfig().fontStyle)),
                                  TextSpan(text: ' atau transaksi anda otomatis dibatalkan oleh sistem. jika sudah melakukan transfer segera upload bukti transfer disini atau di halaman detail riwayat pembelian',style: TextStyle(fontWeight:FontWeight.normal,fontSize:  scaler.getTextSize(10),fontFamily:SiteConfig().fontStyle)),
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
      onWillPop:widget.param=='bisa'?null: () async{
          WidgetHelper().showFloatingFlushbar(context,"failed","gunakan tombol kembali yang ada pada aplikasi ini.");
          return false;
      },
    );
  }
  String url = '',image='';
  Widget _bottomNavBarBeli(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      height: scaler.getHeight(4),
      padding: scaler.getPadding(0,2),
      child: WidgetHelper().buttonQ(context,(){
        WidgetHelper().myModal(context, UploadImage(
          callback: (String img)async{
            setState(() {
              url = base64.encode(utf8.encode(widget.invoice_no));
              image = img;
            });
            upload(url,image);
          },
        ));
      }, "saya sudah transfer"),
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
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2));
          },(){
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2));
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
          WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2));
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
            WidgetHelper().buttonQ(context, (){
              if(_image!=null){
                String fileName;
                String base64Image;
                fileName = _image.path.split("/").last;
                var type = fileName.split('.');
                base64Image = 'data:image/' + type[1] + ';base64,' + base64Encode(_image.readAsBytesSync());
                widget.callback(base64Image);
              }
            },'Simpan')
          ],
        )
    );
  }
}
