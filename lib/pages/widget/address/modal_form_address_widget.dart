import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netindo_shop/model/address/detail_address_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/detail_address_model.dart';
import 'package:netindo_shop/model/address/kecamatan_model.dart';
import 'package:netindo_shop/model/address/kota_model.dart';
import 'package:netindo_shop/model/address/list_address_model.dart';
import 'package:netindo_shop/model/address/provinsi_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/screen/address/address_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// ignore: must_be_immutable
class ModalFormAddressWidget extends StatefulWidget {
  String id;
  Function(String param) callback;
  ModalFormAddressWidget({this.id,this.callback});
  @override
  _ModalFormAddressWidgetState createState() => _ModalFormAddressWidgetState();
}

class _ModalFormAddressWidgetState extends State<ModalFormAddressWidget> {
  var titleController = TextEditingController();
  final FocusNode titleFocus = FocusNode();
  var receiverController = TextEditingController();
  final FocusNode receiverFocus = FocusNode();
  var mainAddressController = TextEditingController();
  final FocusNode mainAddressFocus = FocusNode();
  var telpController = TextEditingController();
  final FocusNode telpFocus = FocusNode();
  var detailAddressController = TextEditingController();
  bool isLoading=false,isError=false,isErrorProv=false,isErrorCity=false,isErrorDistrcit=false;
  String prov='',provName='';int idxProv=0;
  String city='',cityName='';int idxCity=0;
  String district='',districtName='';int idxDistrict=0;
  String hintMainAddress = "nama jalan, rt,rw,keluarahan,kode pos";
  Future<bool> validate()async{
    if(titleController.text==''){
      titleFocus.requestFocus();
      return false;
    }
    else if(receiverController.text==''){
      receiverFocus.requestFocus();
      return false;
    }
    else if(telpController.text==''){
      telpFocus.requestFocus();
      return false;
    }
    else if(prov==''){
      setState(() {isErrorProv=true;});
      Timer(Duration(seconds:1), (){
        setState(() {isErrorProv=false;});
      });
      return false;
    }
    else if(city==''){
      setState(() {isErrorCity=true;});
      Timer(Duration(seconds:1), (){
        setState(() {isErrorCity=false;});
      });
      return false;
    }
    else if(district==''){
      setState(() {isErrorDistrcit=true;});
      Timer(Duration(seconds:1), (){
        setState(() {isErrorDistrcit=false;});
      });
      return false;
    }
    else if(mainAddressController.text==''){
      mainAddressFocus.requestFocus();
      return false;
    }
    else if(namaJalan==''||rt==''||rw==''||kodePos==''){
      WidgetHelper().showFloatingFlushbar(context,"failed","sesuaikan format pengisian detail alamat dengan contoh");
      mainAddressFocus.requestFocus();
      return false;
    }
    else{
      return true;
    }
  }
  Future insertAddress()async{
    var valid = await validate();
    if(valid==true){
      WidgetHelper().loadingDialog(context);
      final id_member = await UserHelper().getDataUser("id_user");
      final data={
        "id_member":"$id_member",
        "title":"${titleController.text}",
        "penerima":"${receiverController.text}",
        "main_address":"$namaJalan,$rt,$rw,$keluarahan,$districtName,$cityName,$provName,$kodePos".toUpperCase(),
        "kd_prov":"$prov",
        "kd_kota":"$city",
        "kd_kec":"$district",
        "no_hp":"${telpController.text}"
      };
      var res = await BaseProvider().postProvider("member_alamat",data);
      if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
        Navigator.pop(context);
        Navigator.pop(context);
        widget.callback('gagal');
      }
      else{
        Navigator.pop(context);
        Navigator.pop(context);
        widget.callback('berhasil');
      }
    }
  }
  Future updateAddress()async{
    var valid = await validate();
    if(valid==true){
      WidgetHelper().loadingDialog(context);
      final data={
        "title":"${titleController.text}",
        "penerima":"${receiverController.text}",
        "main_address":"$namaJalan,$rt,$rw,$keluarahan,$districtName,$cityName,$provName,$kodePos".toUpperCase(),
        "kd_prov":"$prov",
        "kd_kota":"$city",
        "kd_kec":"$district",
        "no_hp":"${telpController.text}"
      };
      var res = await BaseProvider().putProvider("member_alamat/${widget.id}", data);
      if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
        Navigator.pop(context);
        Navigator.pop(context);
        widget.callback('gagal');
      }
      else{
        Navigator.pop(context);
        Navigator.pop(context);
        widget.callback('berhasil');
      }
    }
  }
  DetailAddressModel detailAddressModel;
  Future getDetail()async{
    var res = await BaseProvider().getProvider("member_alamat/${widget.id}", detailAddressModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isLoading=false;
        isError=true;
      });
    }
    else{
      if(res is DetailAddressModel){

        DetailAddressModel result=res;
        String mainAdd=result.result.mainAddress;
        print(mainAdd);
        print(mainAdd.split(","));
        setState(() {
          detailAddressModel = DetailAddressModel.fromJson(result.toJson());
          isLoading=false;
          isError=false;
          titleController.text = result.result.title;
          receiverController.text = result.result.penerima;
          telpController.text=result.result.noHp;
          prov = result.result.kdProv;
          provName=result.result.provinsi;
          city=result.result.kdKota;
          cityName=result.result.kota;
          district=result.result.kdKec;
          districtName=result.result.kecamatan;
          mainAddressController.text = "${mainAdd.split(",")[0]},${mainAdd.split(",")[1]},${mainAdd.split(",")[2]},${mainAdd.split(",")[3]},${mainAdd.split(",")[7]}";
          namaJalan=mainAdd.split(",")[0];
          rt=mainAdd.split(",")[1];
          rw=mainAdd.split(",")[2];
          keluarahan=mainAdd.split(",")[3];
          kodePos=mainAdd.split(",")[7];
        });
      }
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.id!=''){
      isLoading=true;
      getDetail();
    }
  }
  String namaJalan="",rt='',rw='',keluarahan='',kodePos='';
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Container(
      height: MediaQuery.of(context).size.height/1.1,
      padding: EdgeInsets.only(top:10.0,left:0,right:0),
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight:Radius.circular(10.0) ),
      ),
      // color: Colors.white,
      child: Column(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.only(top:0.0),
              width: 50,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:  BorderRadius.circular(10.0),
              ),
            ),
          ),
          ListTile(
            dense:true,
            contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            leading: InkWell(
              onTap: ()=>Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Center(child: Icon(AntDesign.back, color:Theme.of(context).hintColor),),
              ),
            ),
            title: WidgetHelper().textQ("${widget.id==''?'Tambah':'Ubah'} Alamat".toUpperCase(),scaler.getTextSize(10), Theme.of(context).hintColor, FontWeight.bold),
            trailing: InkWell(
                onTap: ()async{
                  if(widget.id==''){
                    insertAddress();
                  }
                  else{
                    updateAddress();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [SiteConfig().secondColor,SiteConfig().secondColor]),
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: [BoxShadow(color: Color(0xFF6078ea).withOpacity(.3),offset: Offset(0.0, 8.0),blurRadius: 8.0)]
                  ),
                  child: WidgetHelper().textQ("Simpan",scaler.getTextSize(9),Colors.white,FontWeight.bold),
                )
            ),
          ),
          Divider(),
          SizedBox(height:10.0),
          isLoading?WidgetHelper().loadingWidget(context):Expanded(
            child: ListView(
              children: [
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetHelper().textQ("Simpan Alamat Sebagai (Contoh:Alamat rumah, Alamat kantor, Alamat pacar)",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                            ),
                          ),
                          padding: scaler.getPadding(1, 1),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            style: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10)),
                            controller: titleController,
                            focusNode: titleFocus,
                            autofocus: false,
                            decoration: InputDecoration.collapsed(
                              hintStyle: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10)),
                            ),
                            onFieldSubmitted: (_){
                              WidgetHelper().fieldFocusChange(context, titleFocus,receiverFocus);
                            },
                          ),
                        ),
                        SizedBox(height:scaler.getHeight(1)),
                        WidgetHelper().textQ("Penerima",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                            ),
                          ),
                          padding: scaler.getPadding(1, 1),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10)),
                            controller: receiverController,
                            focusNode: receiverFocus,
                            autofocus: false,
                            decoration: InputDecoration.collapsed(
                                hintStyle: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10))
                            ),
                            onFieldSubmitted: (_){
                              WidgetHelper().fieldFocusChange(context, receiverFocus,telpFocus);
                            },
                          ),
                        ),
                        SizedBox(height:scaler.getHeight(1)),
                        WidgetHelper().textQ("No.Telepon",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                            ),
                          ),
                          padding: scaler.getPadding(1, 1),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10)),
                            controller: telpController,
                            focusNode: telpFocus,
                            decoration: InputDecoration.collapsed(
                                hintStyle: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10))
                            ),
                            onFieldSubmitted: (_){
                              FocusScope.of(context).unfocus();
                              WidgetHelper().myModal(context,ModalProvinsi(
                                callback:(id,name,idx){
                                  setState(() {prov=id;provName=name;idxProv=idx;city='';});
                                  Navigator.pop(context);
                                },
                                id: prov,idx: idxProv,
                              ));
                            },
                          ),
                        ),
                        SizedBox(height:scaler.getHeight(1)),
                        WidgetHelper().textQ("Provinsi",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        tempAdd("${prov!=''?provName:'Pilih Provinsi'}",isErrorProv,(){
                          WidgetHelper().myModal(context,ModalProvinsi(
                            callback:(id,name,idx){
                              setState(() {prov=id;provName=name;idxProv=idx;city='';});
                              Navigator.pop(context);
                              WidgetHelper().myModal(context,ModalCity(
                                callback:(id,name,idx){
                                  setState(() {city=id;cityName=name;idxCity=idx;district='';});
                                  Navigator.pop(context);
                                },
                                id:city,idProv: prov,idx: idxCity,
                              ));
                            },
                            id: prov,idx: idxProv,
                          ));
                        }),
                        SizedBox(height:scaler.getHeight(1)),
                        WidgetHelper().textQ("Kota",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        tempAdd("${city!=''?cityName:'Pilih Kota'}",isErrorCity,(){
                          if(prov!=''){
                            WidgetHelper().myModal(context,ModalCity(
                              callback:(id,name,idx){
                                setState(() {city=id;cityName=name;idxCity=idx;district='';});
                                Navigator.pop(context);
                                WidgetHelper().myModal(context,ModalDisctrict(
                                  callback:(id,name,idx){
                                    setState(() {district=id;districtName=name;idxDistrict=idx;});
                                    Navigator.pop(context);
                                  },
                                  id:district,idCity: city,idx: idxDistrict,
                                ));
                              },
                              id:city,idProv: prov,idx: idxCity,
                            ));
                          }
                          else{
                            setState(() {isErrorProv=true;});
                            Timer(Duration(seconds:1), (){
                              setState(() {isErrorProv=false;});
                            });
                          }
                        }),
                        SizedBox(height:scaler.getHeight(1)),
                        WidgetHelper().textQ("Kecamatan",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        tempAdd("${district!=''?districtName:'Pilih Kecamatan'}",isErrorDistrcit,(){
                          if(prov!=''&&city!=''){
                            WidgetHelper().myModal(context,ModalDisctrict(
                              callback:(id,name,idx){
                                setState(() {district=id;districtName=name;idxDistrict=idx;});
                                Navigator.pop(context);
                                mainAddressFocus.requestFocus();
                              },
                              id:district,idCity: city,idx: idxDistrict,
                            ));
                          }
                          else{
                            if(prov==''){
                              setState(() {isErrorProv=true;});
                              Timer(Duration(seconds:1), (){
                                setState(() {isErrorProv=false;});
                              });
                            }else{
                              setState(() {isErrorCity=true;});
                              Timer(Duration(seconds:1), (){
                                setState(() {isErrorCity=false;});
                              });
                            }
                          }
                        }),
                        SizedBox(height:scaler.getHeight(1)),
                        WidgetHelper().textQ("Detail Alamat (format penulisan : nama jalan,rt,rw,kelurahan,kode pos)",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor.withOpacity(0.1),

                            // border: Border.all(color: Colors.grey[200]),
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)
                            ),
                          ),
                          padding: scaler.getPadding(1, 1),
                          child: TextField(
                            textInputAction: TextInputAction.done,
                            maxLines: 5,
                            style: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10)),
                            controller: mainAddressController,
                            focusNode: mainAddressFocus,
                            decoration: InputDecoration.collapsed(
                                hintStyle: GoogleFonts.robotoCondensed().copyWith(color:LightColor.black,fontSize: scaler.getTextSize(10))
                            ),
                            onChanged: (_){
                              if(_!=''){
                                if(mainAddressController.text.split(",").length>4){
                                  setState(() {
                                    namaJalan=mainAddressController.text.split(",")[0];
                                    rt=mainAddressController.text.split(",")[1];
                                    rw=mainAddressController.text.split(",")[2];
                                    keluarahan=mainAddressController.text.split(",")[3];
                                    kodePos=mainAddressController.text.split(",")[4];
                                  });
                                }
                              }
                              else{
                                setState(() {
                                  mainAddressController.text='';
                                  namaJalan="";
                                  rt="";
                                  rw="";
                                  kodePos="";
                                });
                              }

                            },
                          ),
                        ),
                        SizedBox(height:scaler.getHeight(1)),
                        WidgetHelper().textQ("Alamat ini digunakan untuk pengiriman",scaler.getTextSize(9),LightColor.grey, FontWeight.bold),
                        SizedBox(height:scaler.getHeight(0.5)),
                        Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).focusColor.withOpacity(0.1),

                              // border: Border.all(color: Colors.grey[200]),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                            ),
                            padding: scaler.getPadding(1, 1),
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("JALAN", scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$namaJalan", scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("RT", scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$rt", scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("RW",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$rw",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("KELURAHAN",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$keluarahan",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("KECAMATAN",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$districtName",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("KOTA",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$cityName",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("PROVINSI",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$provName",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    WidgetHelper().textQ("KODE POS",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                    WidgetHelper().textQ("$kodePos",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
                                  ],
                                )

                              ],
                            )
                          // child: WidgetHelper().textQ(
                          //     "nama jalan : ${mainAddressController.text==""?"":mainAddressController.text.split(",")[0]}\nrt : ${mainAddressController.text==""?"":mainAddressController.text.split(",")[1]}\nrw : ${mainAddressController.text==""?"":mainAddressController.text.split(",")[2]}\nKelurahan : ${mainAddressController.text==""?"":mainAddressController.text.split(",")[3]}\nKecamatan : $districtName\Kota : $cityName\Provinsi : $provName\n",
                          //     10,
                          //     Colors.grey,
                          //     FontWeight.bold
                          // ),
                        ),
                      ],
                    )
                ),


              ],
            ),
          )
        ],
      ),
    );
  }

  Widget tempAdd(String title,bool isErr,Function callback){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return WidgetHelper().animShakeWidget(
        context,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).focusColor.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          padding: EdgeInsets.only(left:10.0,right:10.0,top:0),
          child: ListTile(
            onTap: callback,
            contentPadding: EdgeInsets.all(0.0),
            title: WidgetHelper().textQ("$title",scaler.getTextSize(9),LightColor.black,FontWeight.normal),
            trailing: Icon(Icons.arrow_right,size: scaler.getTextSize(9),color: LightColor.black),
          ),
        ),
        enable: isErr
    );
  }
}
