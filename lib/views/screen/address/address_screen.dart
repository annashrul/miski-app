import 'dart:async';

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
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AddressScreen extends StatefulWidget {
  final Function(dynamic data) callback;
  final int indexArr;
  AddressScreen({this.callback,this.indexArr});
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  ScrollController controller;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ListAddressModel listAddressModel;
  bool isLoading=false,isLoadmore=false,isError=false;
  int idx=SiteConfig().noDataCode;
  Future loadData()async{
    final idUser = await UserHelper().getDataUser("id_user");
    var res = await BaseProvider().getProvider("member_alamat?page=1&id_member=$idUser", listAddressModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isError=true;
        isLoading=false;
        isLoadmore=false;
      });
    }
    else{
      if(res is ListAddressModel){
        ListAddressModel resullt = res;
        setState(() {
          listAddressModel = ListAddressModel.fromJson(resullt.toJson());
          isError=false;
          isLoading=false;
        });
      }
    }
  }
  Future deleteAddress(id)async{
    WidgetHelper().loadingDialog(context);
    var res = await BaseProvider().deleteProvider("member_alamat/$id", generalFromJson);
    if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
      Navigator.pop(context);
      WidgetHelper().showFloatingFlushbar(context,"failed","terjadi kesalahan koneksi");
    }
    else{
      Navigator.pop(context);
      WidgetHelper().showFloatingFlushbar(context,"success","data berhasil dihapus");
      loadData();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    loadData();
    idx=widget.indexArr;

  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: WidgetHelper().appBarWithButton(context,"Daftar Alamat",(){Navigator.pop(context);},<Widget>[
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(right: 0.0,top:5),
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: FlatButton(
                    onPressed: (){
                      WidgetHelper().myModal(context, ModalForm(id:"",callback:(String par){
                        if(par=='berhasil'){
                          loadData();
                          WidgetHelper().showFloatingFlushbar(context,"success","data berhasil dikirim");
                        }
                        else{
                          WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
                        }
                      },));
                    },
                    child: WidgetHelper().textQ("Tambah Alamat",scaler.getTextSize(9),LightColor.mainColor,FontWeight.bold)
                ),
              ),
            ],
          ),
        )
      ],brightness: Brightness.light),
      body: Container(
        padding: scaler.getPadding(0,2),
        child: isLoading?LoadingHistory(tot: 10):isError?TimeoutWidget(callback: (){}):listAddressModel.result.data.length>0?Column(
          children: [
            Expanded(
                flex:16,
                child: ListView.separated(
                  padding: EdgeInsets.all(0.0),
                    key: PageStorageKey<String>('AddressScreen'),
                    primary: false,
                    physics: ScrollPhysics(),
                    controller: controller,
                    itemCount: listAddressModel.result.data.length,
                    itemBuilder: (context,index){
                      final val=listAddressModel.result.data[index];
                      Widget btn=IconButton(
                        icon: Icon(Ionicons.ios_close_circle_outline,color: Colors.red),
                        onPressed: (){
                          WidgetHelper().notifDialog(context, "Perhatian !!","anda yakin akan menghapus data ini ??", (){Navigator.pop(context);},()async{
                            Navigator.pop(context);
                            await deleteAddress(val.id);
                          });
                        },
                      );
                    if(widget.callback!=null){
                      btn=IconButton(
                        icon: Icon(Ionicons.ios_checkmark_circle_outline,color:idx==index?LightColor.lightblack:Colors.transparent),
                        onPressed: (){},
                      );
                    }
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[200],
                              spreadRadius: 0,
                              blurRadius: 5,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child:WidgetHelper().myRipple(
                            callback: (){
                              if(widget.callback!=null){
                                setState(() {idx=index;});
                                widget.callback(val.toJson()..addAll({"index":index}));
                                Navigator.pop(context);
                              }else{
                                WidgetHelper().myModal(context, ModalForm(id:"${val.id}",callback:(String par){
                                  if(par=='berhasil'){
                                    loadData();
                                    WidgetHelper().showFloatingFlushbar(context,"success","data berhasil disimpan");
                                  }
                                  else{
                                    WidgetHelper().showFloatingFlushbar(context,"failed","terjadi kesalahan koneksi");
                                  }
                                },));
                              }
                            },
                            child:  Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:scaler.getPadding(0,2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          WidgetHelper().textQ("${val.title}".toUpperCase(),scaler.getTextSize(9),LightColor.black,FontWeight.bold),
                                          val.ismain==1?Container(
                                            margin: scaler.getMarginLTRB(1,0, 0, 0),
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                border: Border.all(color: LightColor.mainColor,width: 2)
                                            ),
                                            child: WidgetHelper().textQ("Alamat Utama", scaler.getTextSize(9),LightColor.mainColor,FontWeight.bold),
                                          ):Container()
                                        ],
                                      ),
                                      btn
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10,right:10,top:0,bottom:5),
                                  child: Container(
                                    color: Colors.grey[200],
                                    height: 1.0,
                                    width: double.infinity,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left:10,right:10,top:0,bottom:10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      WidgetHelper().textQ("${val.penerima}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                                      SizedBox(height:5.0),
                                      WidgetHelper().textQ("${val.noHp}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal),
                                      SizedBox(height:5.0),
                                      WidgetHelper().textQ("${val.mainAddress}",scaler.getTextSize(9),LightColor.lightblack,FontWeight.normal,maxLines: 3),
                                      SizedBox(height:5.0),
                                      InkWell(
                                        onTap: (){
                                          WidgetHelper().myModal(context, ModalForm(id:"${val.id}",callback:(String par){
                                            if(par=='berhasil'){
                                              loadData();
                                              WidgetHelper().showFloatingFlushbar(context,"success","data berhasil disimpan");
                                            }
                                            else{
                                              WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
                                            }
                                          },));
                                        },
                                        child: Container(
                                          padding:EdgeInsets.all(10.0),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10.0),
                                              color: SiteConfig().secondColor
                                          ),
                                          child: WidgetHelper().textQ("Ubah alamat",scaler.getTextSize(9),Colors.white,FontWeight.bold,textAlign: TextAlign.center),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                              ],
                            )
                        ),
                      );
                    },
                  separatorBuilder: (context,index){return SizedBox(height:10.0);},
                )
            ),
            // isLoadmore?Expanded(flex:4,child: LoadingHistory(tot: 1)):Container()
          ],
        ):EmptyTenant(),
      ),
    );
  }
}

class ModalForm extends StatefulWidget {
  String id;
  Function(String param) callback;
  ModalForm({this.id,this.callback});
  @override
  _ModalFormState createState() => _ModalFormState();
}

class _ModalFormState extends State<ModalForm> {
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

class ModalProvinsi extends StatefulWidget {
  ModalProvinsi({
    Key key,
    this.mode,
    @required this.callback,
    @required this.id,
    @required this.idx,
  }) : super(key: key);
  bool mode;
  Function(String id,String name,int idx) callback;
  final String id;
  int idx;
  @override
  _ModalProvinsiState createState() => _ModalProvinsiState();
}

class _ModalProvinsiState extends State<ModalProvinsi> {
  ProvinsiModel provinsiModel;
  bool isLoadingProv=false;
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  int idx=0;
  String id='';
  Future getProv()async{
    var data = await HandleHttp().getProvider("kurir/provinsi",provinsiModelFromJson,context:context,callback: (){
      print("callback");
    });
    if(data is ProvinsiModel){
      ProvinsiModel resullt = data;
      setState(() {
        provinsiModel = ProvinsiModel.fromJson(resullt.toJson());
        isLoadingProv=false;
        id = widget.id==""?resullt.result[0].id:widget.id;
        idx = widget.idx;
      });
    }

    // var res = await BaseProvider().getProvider("kurir/provinsi",provinsiModelFromJson);
    // if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
    //   setState(() {
    //     isLoadingProv=false;
    //   });
    // }
    // else{
    //   if(res is ProvinsiModel){
    //     ProvinsiModel resullt = res;
    //     setState(() {
    //       provinsiModel = ProvinsiModel.fromJson(resullt.toJson());
    //       isLoadingProv=false;
    //       id = widget.id==""?resullt.result[0].id:widget.id;
    //       idx = widget.idx;
    //     });
    //   }
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("ID PROVINSI ${widget.id}");
    isLoadingProv=true;
    getProv();
  }
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      height: MediaQuery.of(context).size.height/1.1,
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
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
            title: WidgetHelper().textQ("Pilih Provinsi".toUpperCase(),scaler.getTextSize(10),Theme.of(context).hintColor, FontWeight.bold),
          ),
          // SizedBox(height: scaler.),
          Expanded(
            child: Scrollbar(
                child: isLoadingProv?WidgetHelper().loadingWidget(context):ScrollablePositionedList.separated(
                  padding: EdgeInsets.zero,
                  itemScrollController: _scrollController,
                  itemCount: provinsiModel.result.length,
                  initialScrollIndex: idx,
                  itemBuilder: (context,index){
                    return InkWell(
                      onTap: (){
                        setState(() {
                          idx = index;
                          id = provinsiModel.result[index].id;
                        });
                        widget.callback(provinsiModel.result[index].id,provinsiModel.result[index].name,index);
                      },
                      child: ListTile(
                        contentPadding:scaler.getPadding(0, 2),
                        title: WidgetHelper().textQ("${provinsiModel.result[index].name}", scaler.getTextSize(9),LightColor.black, FontWeight.normal),
                        trailing: widget.id==provinsiModel.result[index].id?Icon(AntDesign.checkcircleo,size:20,color:LightColor.black):Text(''),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 1,color: id==provinsiModel.result[index].id?Colors.grey:Colors.grey);
                  },
                )
            ),
          ),

        ],
      ),
    );
  }
}

class ModalCity extends StatefulWidget {
  ModalCity({
    Key key,
    this.mode,
    @required this.callback,
    @required this.id,
    @required this.idProv,
    @required this.idx,
  }) : super(key: key);
  bool mode;
  Function(String id,String name,int idx) callback;
  final String id;
  final String idProv;
  int idx;
  @override
  _ModalCityState createState() => _ModalCityState();
}

class _ModalCityState extends State<ModalCity> {
  KotaModel kotaModel;
  bool isLoading=false;
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  int idx=0;
  String id='';
  int no=0;
  Widget child;
  Future getData()async{
    var res = await BaseProvider().getProvider("kurir/kota?id=${widget.idProv}",kotaModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isLoading=false;
      });
    }
    else{
      if(res is KotaModel){
        KotaModel resullt = res;
        setState(() {
          kotaModel = KotaModel.fromJson(resullt.toJson());
          isLoading=false;
          id = widget.id==""?resullt.result[0].id:widget.id;
          idx = widget.idx;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      height: MediaQuery.of(context).size.height/1.1,
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
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
            title: WidgetHelper().textQ("Pilih Kota".toUpperCase(),scaler.getTextSize(10),Theme.of(context).hintColor, FontWeight.bold),
          ),
          Expanded(
            child: Scrollbar(
                child: isLoading?WidgetHelper().loadingWidget(context):ScrollablePositionedList.separated(
                  padding: EdgeInsets.zero,
                  itemScrollController: _scrollController,
                  itemCount: kotaModel.result.length,
                  initialScrollIndex: idx,
                  itemBuilder: (context,index){

                    return InkWell(
                      onTap: (){
                        setState(() {
                          idx = index;
                          id = kotaModel.result[index].id;
                        });
                        widget.callback(kotaModel.result[index].id,kotaModel.result[index].name,index);
                      },
                      child: ListTile(
                        contentPadding: scaler.getPadding(0,2),
                        title: WidgetHelper().textQ("${kotaModel.result[index].name}", scaler.getTextSize(9),LightColor.black, FontWeight.normal),
                        trailing: id==kotaModel.result[index].id?Icon(AntDesign.checkcircleo,size:20,color: LightColor.black):Text(''),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 1,color: id==kotaModel.result[index].id?Colors.grey:Colors.grey);
                  },
                )
            ),
          ),

        ],
      ),
    );
  }
}


class ModalDisctrict extends StatefulWidget {
  ModalDisctrict({
    Key key,
   this.mode,
    @required this.callback,
    @required this.id,
    @required this.idCity,
    @required this.idx,
  }) : super(key: key);
  bool mode;
  Function(String id,String name,int idx) callback;
  final String id;
  final String idCity;
  int idx;
  @override
  _ModalDisctrictState createState() => _ModalDisctrictState();
}

class _ModalDisctrictState extends State<ModalDisctrict> {
  KecamatanModel kecamatanModel;
  bool isLoading=false;
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  int idx=0;
  String id='';
  int no=0;
  Widget child;
  Future getData()async{
    var res = await BaseProvider().getProvider("kurir/kecamatan?id=${widget.idCity}",kecamatanModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isLoading=false;
      });
    }
    else{
      if(res is KecamatanModel){
        KecamatanModel resullt = res;
        setState(() {
          kecamatanModel = KecamatanModel.fromJson(resullt.toJson());
          isLoading=false;
          id = widget.id==""?resullt.result[0].id:widget.id;
          idx = widget.idx;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Container(
      height: MediaQuery.of(context).size.height/1.1,
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
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
            title: WidgetHelper().textQ("Pilih Kecamatan".toUpperCase(),scaler.getTextSize(10),Theme.of(context).hintColor, FontWeight.bold),
          ),
          Expanded(
            child: Scrollbar(
                child: isLoading?WidgetHelper().loadingWidget(context):ScrollablePositionedList.separated(
                  padding: EdgeInsets.zero,
                  itemScrollController: _scrollController,
                  itemCount: kecamatanModel.result.length,
                  initialScrollIndex: idx,
                  itemBuilder: (context,index){

                    return InkWell(
                      onTap: (){
                        setState(() {
                          idx = index;
                          id = kecamatanModel.result[index].id;
                        });
                        widget.callback(kecamatanModel.result[index].id,kecamatanModel.result[index].kecamatan,index);
                      },
                      child: ListTile(
                        contentPadding: scaler.getPadding(0,2),
                        title: WidgetHelper().textQ("${kecamatanModel.result[index].kecamatan}", scaler.getTextSize(9),LightColor.black, FontWeight.normal),
                        trailing: id==kecamatanModel.result[index].id?Icon(AntDesign.checkcircleo,size:20,color:LightColor.black):Text(''),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 1,color: id==kecamatanModel.result[index].id?Colors.grey:Colors.grey);
                  },
                )
            ),
          ),

        ],
      ),
    );
  }
}
//
// class WidgetAddress extends StatefulWidget {
//   bool mode;
//   String title;
//   int isMain;
//   String penerima;
//   String nohp;
//   String mainAddress;
//
//   @override
//   _WidgetAddressState createState() => _WidgetAddressState();
// }
//
// class _WidgetAddressState extends State<WidgetAddress> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: (){
//         // WidgetHelper().myPush(context,DetailHistoryTransactoinScreen(noInvoice:base64.encode(utf8.encode(val.kdTrx))));
//       },
//       child: Card(
//         elevation: 1.0,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(left:10,right:10,top:0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     children: [
//                       WidgetHelper().textQ("${widget.title}",12,Colors.black,FontWeight.bold),
//                       widget.isMain==1?Container(
//                         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                             color:Colors.grey
//                         ),
//                         child: WidgetHelper().textQ("Alamat Utama", 10,Colors.white,FontWeight.bold),
//                       ):Container()
//                     ],
//                   ),
//                   IconButton(
//                     icon: Icon(UiIcons.trash_1,color: Colors.red),
//                     onPressed: (){
//                       WidgetHelper().notifDialog(context, "Perhatian !!","anda yakin akan menghapus data ini ??", (){Navigator.pop(context);},()async{
//                         // Navigator.pop(context);
//
//                         // await deleteAddress(val.id);
//                       });
//                     },
//                   )
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left: 10,right:10,top:0,bottom:5),
//               child: Container(
//                 color: Colors.grey[200],
//                 height: 1.0,
//                 width: double.infinity,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(left:10,right:10,top:0,bottom:10),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   WidgetHelper().textQ("${widget.penerima}",10,Colors.black,FontWeight.normal),
//                   SizedBox(height:5.0),
//                   WidgetHelper().textQ("${widget.nohp}",10,Colors.black,FontWeight.normal),
//                   SizedBox(height:5.0),
//                   WidgetHelper().textQ("${widget.mainAddress}",10,Colors.grey,FontWeight.normal,maxLines: 3),
//                   SizedBox(height:5.0),
//                   InkWell(
//                     onTap: (){
//                       WidgetHelper().myModal(context, ModalForm(id:"${widget.id}",mode: widget.mode,callback:(String par){
//                         if(par=='berhasil'){
//                           widget.loadData;
//                           WidgetHelper().showFloatingFlushbar(context,"success","data berhasil disimpan");
//                         }
//                         else{
//                           WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
//                         }
//                       },));
//                     },
//                     child: Container(
//                       padding:EdgeInsets.all(10.0),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10.0),
//                           color: SiteConfig().secondColor
//                       ),
//                       child: WidgetHelper().textQ("Ubah Alamat",12,Colors.white,FontWeight.bold,textAlign: TextAlign.center),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
