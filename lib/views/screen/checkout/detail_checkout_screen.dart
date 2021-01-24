import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSite();
  }



  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();
    return WillPopScope(
      child: Scaffold(
            backgroundColor: site?SiteConfig().darkMode:Colors.white,
            key: key,
            appBar: WidgetHelper().appBarWithButton(context, "INVOICE ${widget.invoice_no}",(){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => WrapperScreen(currentTab: 2,mode: site)), (Route<dynamic> route) => false);
            },<Widget>[],brightness: site?Brightness.dark:Brightness.light),
            resizeToAvoidBottomInset: false,
            body: Scrollbar(
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 30),
                    Image.asset(
                      'img/checkmark.gif',
                      height: MediaQuery.of(context).size.height / 7,
                      fit: BoxFit.fitHeight,
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 8.0),
                      child: WidgetHelper().textQ("Silahkan transfer tepat sebesar :", 12, site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color:SiteConfig().accentColor,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          padding: const EdgeInsets.symmetric(horizontal:10.0,vertical:10.0),
                          child:Center(
                            child: WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse(widget.total_transfer))} .-", 18, Colors.white, FontWeight.bold),
                          ),
                        )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 8.0),
                      child: WidgetHelper().textQ("Pembayaran dapat dilakukan ke rekening berikut : ", 12, site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          onTap: (){
                            Clipboard.setData(new ClipboardData(text: "${widget.bank_acc}"));
                            WidgetHelper().showFloatingFlushbar(context,"success"," no rekening berhasil disalin");
                          },
                          contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                          leading: Container(
                            width: 90.0,
                            height: 50.0,
                            padding: EdgeInsets.all(10),
                            child: CircleAvatar(
                                minRadius: 150,
                                maxRadius: 150,
                                child:Image.network(SiteConfig().noImage,fit: BoxFit.fill)
                            ),
                          ),
                          title:WidgetHelper().textQ("${widget.bank_atas_nama}", 12, Colors.black, FontWeight.bold),
                          subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                WidgetHelper().textQ("${widget.bank_acc}", 12, Colors.black.withOpacity(0.7), FontWeight.bold),
                                SizedBox(width: 5),
                                Icon(Icons.content_copy, color: Colors.black, size: 15,),
                              ]
                          ),
                        ),
                      ),
                    ),
                    !site?Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                        child: Container(
                            decoration: BoxDecoration(
                                color:SiteConfig().accentColor,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                            child:Center(
                              child: WidgetHelper().textQ('VERIFIKASI PENERIMAAN TRANSFER ANDA AKAN DIPROSES SELAMA 5-10 MENIT', 14, Colors.white, FontWeight.bold),
                            )
                        )
                    ):Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                      child: WidgetHelper().textQ('VERIFIKASI PENERIMAAN TRANSFER ANDA AKAN DIPROSES SELAMA 5-10 MENIT', 14, Colors.white, FontWeight.bold,textAlign: TextAlign.center),
                    ),
                    !site?Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 8.0),
                        child: Container(
                          color: const Color(0xffF4F7FA),
                          padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 8.0),
                          child: RichText(
                            text: TextSpan(
                                text: 'Anda dapat melakukan transfer menggunakan ATM, Mobile Banking atau SMS Banking dengan memasukan kode bank',
                                style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle,color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: ' ${widget.bank_name} (${widget.bank_code})',style: TextStyle(color:SiteConfig().mainColor, fontSize: 12,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle)),
                                  TextSpan(text: ' di depan No.Rekening atas nama',style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle)),
                                  TextSpan(text: ' ${widget.bank_atas_nama}',style: TextStyle(color:SiteConfig().mainColor, fontSize: 12,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle)),
                                ]
                            ),
                          ),
                        )
                    ):Padding(
                      padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                      child: RichText(
                        text: TextSpan(
                            text: 'Anda dapat melakukan transfer menggunakan ATM, Mobile Banking atau SMS Banking dengan memasukan kode bank',
                            style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle,color:Colors.white),
                            children: <TextSpan>[
                              TextSpan(text: ' ${widget.bank_name} (${widget.bank_code})',style: TextStyle(color:SiteConfig().mainColor, fontSize: 12,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle)),
                              TextSpan(text: ' di depan No.Rekening atas nama',style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle)),
                              TextSpan(text: ' ${widget.bank_atas_nama}',style: TextStyle(color:SiteConfig().mainColor, fontSize: 12,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle)),
                            ]
                        ),
                      ),
                    ),
                    !site?Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 8.0),
                        child: Container(
                            color: const Color(0xffF4F7FA),
                            padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 8.0),
                            child:WidgetHelper().textQ("mohon transfer tepat hingga 3 digit terakhir agar tidak menghambat proses verifikasi", 12, Colors.black, FontWeight.normal)
                        )
                    ):Container(
                        padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                        child:WidgetHelper().textQ("mohon transfer tepat hingga 3 digit terakhir agar tidak menghambat proses verifikasi", 12, Colors.white, FontWeight.normal)
                    ),
                    !site?Padding(
                        padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                        child: Container(
                          color: const Color(0xffF4F7FA),
                          padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                          child: RichText(
                            text: TextSpan(
                                text: 'Pastikan anda transfer sebelum tanggal',
                                style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle,color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: ' $hari-$bulan-$tahun 23:00 WIB',style: TextStyle(color:SiteConfig().mainColor, fontSize: 12,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle)),
                                  TextSpan(text: ' atau transaksi anda otomatis dibatalkan oleh sistem. jika sudah melakukan transfer segera upload bukti transfer disini atau di halaman detail riwayat pembelian',style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle)),
                                ]
                            ),
                          ),
                        )
                    ):Container(
                        padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 10.0),
                        child:RichText(
                          text: TextSpan(
                              text: 'Pastikan anda transfer sebelum tanggal',
                              style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle,color: Colors.white),
                              children: <TextSpan>[
                                TextSpan(text: ' $hari-$bulan-$tahun 23:00 WIB',style: TextStyle(color:SiteConfig().mainColor, fontSize: 12,fontWeight: FontWeight.bold,fontFamily:SiteConfig().fontStyle)),
                                TextSpan(text: ' atau transaksi anda otomatis dibatalkan oleh sistem. jika sudah melakukan transfer segera upload bukti transfer disini atau di halaman detail riwayat pembelian',style: TextStyle(fontSize: 12,fontFamily:SiteConfig().fontStyle)),
                              ]
                          ),
                        )
                    ),
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
    return InkWell(
      onTap: (){
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
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Container(
          width:double.infinity,
          height: kBottomNavigationBarHeight,
          decoration: BoxDecoration(
              color: SiteConfig().mainColor,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
              ]),
          child: Center(
            child: WidgetHelper().textQ("Saya sudah transfer",14,Colors.white, FontWeight.bold),
          ),
        ),
      ),
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
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,mode: site));
          },(){
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,mode: site));
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
          WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,mode: site));
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
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSite();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: site?SiteConfig().darkMode:Colors.transparent,
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
            SizedBox(height: 20.0),
            WidgetHelper().textQ("Ambil gambar dari ?",12,site?Colors.white:Colors.black,FontWeight.bold),
            SizedBox(height: 10.0),
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
              child: _image == null ?Image.network("http://lequytong.com/Content/Images/no-image-02.png"): new Image.file(_image,width: MediaQuery.of(context).size.width/1,height: MediaQuery.of(context).size.height/2,filterQuality: FilterQuality.high,),
            ),
            SizedBox(height: 10.0),
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
