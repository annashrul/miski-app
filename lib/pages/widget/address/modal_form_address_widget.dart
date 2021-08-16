import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/model/address/detail_address_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/widget/address/maps_widget.dart';
import 'package:netindo_shop/pages/widget/address/modal_kecamatan_widget.dart';
import 'package:netindo_shop/pages/widget/address/modal_kota_widget.dart';
import 'package:netindo_shop/pages/widget/address/modal_provinsi_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';

// ignore: must_be_immutable
class ModalFormAddressWidget extends StatefulWidget {
  String id;
  Function(String param) callback;
  ModalFormAddressWidget({this.id, this.callback});
  @override
  _ModalFormAddressWidgetState createState() => _ModalFormAddressWidgetState();
}

class _ModalFormAddressWidgetState extends State<ModalFormAddressWidget> {
  DetailAddressModel detailAddressModel;
  var titleController = TextEditingController();
  final FocusNode titleFocus = FocusNode();
  var provinsiController = TextEditingController();
  final FocusNode provinsiFocus = FocusNode();
  var kotaController = TextEditingController();
  final FocusNode kotaFocus = FocusNode();
  var kecamatanController = TextEditingController();
  final FocusNode kecamatanFocus = FocusNode();
  var receiverController = TextEditingController();
  final FocusNode receiverFocus = FocusNode();
  var mainAddressController = TextEditingController();
  final FocusNode mainAddressFocus = FocusNode();
  var telpController = TextEditingController();
  final FocusNode telpFocus = FocusNode();
  var detailAddressController = TextEditingController();
  bool isLoading = false,
      isError = false,
      isErrorProv = false,
      isErrorCity = false,
      isErrorDistrcit = false;
  String prov = '', provName = '';
  int idxProv = 0;
  String city = '', cityName = '';
  int idxCity = 0;
  String district = '', districtName = '';
  int idxDistrict = 0;
  String hintMainAddress = "nama jalan, rt,rw,keluarahan,kode pos";
  String namaJalan = "", rt = '', rw = '', keluarahan = '', kodePos = '';
  dynamic placeholderPinPoint;
  Future<bool> validate() async {
    if (titleController.text == '') {
      titleFocus.requestFocus();
      return false;
    } else if (receiverController.text == '') {
      receiverFocus.requestFocus();
      return false;
    } else if (telpController.text == '') {
      telpFocus.requestFocus();
      return false;
    } else if (provinsiController.text == '') {
      provinsiFocus.requestFocus();
      return false;
    } else if (kotaController.text == '') {
      kotaFocus.requestFocus();
      return false;
    } else if (kecamatanController.text == '') {
      kecamatanFocus.requestFocus();
      return false;
    } else if (mainAddressController.text == '') {
      mainAddressFocus.requestFocus();
      return false;
    } else if (namaJalan == '' || rt == '' || rw == '' || kodePos == '') {
      WidgetHelper().showFloatingFlushbar(context, "failed","sesuaikan format pengisian detail alamat dengan contoh");
      mainAddressFocus.requestFocus();
      return false;
    } else {
      return true;
    }
  }
  Future<Map<String,Object>> dataAddress()async{
    final idMember = await UserHelper().getDataUser(StringConfig.id_user);
    return {
      "id_member": "$idMember",
      "title": "${titleController.text}",
      "penerima": "${receiverController.text}",
      "main_address":"$namaJalan,$rt,$rw,$keluarahan,$districtName,$cityName,$provName,$kodePos".toUpperCase(),
      "kd_prov": "$prov",
      "kd_kota": "$city",
      "kd_kec": "$district",
      "no_hp": "${telpController.text}",
      "pinpoint":placeholderPinPoint!=null?"${placeholderPinPoint[StringConfig.latitude]},${placeholderPinPoint[StringConfig.longitude]}":"-"
    };
  }

  Future insertAddress() async {
    var valid = await validate();
    if (valid == true) {
      WidgetHelper().loadingDialog(context);
      final data = await dataAddress();
      var res = await HandleHttp().postProvider("member_alamat", data, context: context);
      if (res != null) {
        Navigator.pop(context);
        Navigator.pop(context);
        widget.callback('berhasil');
        await FunctionHelper().rmPinPoint();
      }
    }
  }
  Future updateAddress() async {
    var valid = await validate();
    if (valid == true) {
      WidgetHelper().loadingDialog(context);
      final data = await dataAddress();
      data.remove("id_member");
      var res = await HandleHttp().putProvider("member_alamat/${widget.id}", data, context: context);
      if (res != null) {
        Navigator.pop(context);
        Navigator.pop(context);
        await FunctionHelper().rmPinPoint();
        widget.callback('berhasil');
      }
    }
  }
  Future getDetail() async {
    var res = await HandleHttp().getProvider("member_alamat/${widget.id}", detailAddressModelFromJson,context: context);
    if (res != null) {
      if (res is DetailAddressModel) {
        DetailAddressModel result = res;
        String mainAdd = result.result.mainAddress;
        print(mainAdd);
        print(mainAdd.split(","));
        setState(() {
          placeholderPinPoint = {StringConfig.fullAddress:"-",StringConfig.latitude:result.result.pinpoint.split(",")[0],StringConfig.longitude:result.result.pinpoint.split(",")[1]};
          detailAddressModel = DetailAddressModel.fromJson(result.toJson());
          isLoading = false;
          isError = false;
          titleController.text = result.result.title;
          receiverController.text = result.result.penerima;
          telpController.text = result.result.noHp;
          provinsiController.text = result.result.provinsi;
          kotaController.text = result.result.kota;
          kecamatanController.text = result.result.kecamatan;
          prov = result.result.kdProv;
          provName = result.result.provinsi;
          city = result.result.kdKota;
          cityName = result.result.kota;
          district = result.result.kdKec;
          districtName = result.result.kecamatan;
          mainAddressController.text = "${mainAdd.split(",")[0]},${mainAdd.split(",")[1]},${mainAdd.split(",")[2]},${mainAdd.split(",")[3]},${mainAdd.split(",")[7]}";
          namaJalan = mainAdd.split(",")[0];
          rt = mainAdd.split(",")[1];
          rw = mainAdd.split(",")[2];
          keluarahan = mainAdd.split(",")[3];
          kodePos = mainAdd.split(",")[7];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.id != '') {
      isLoading = true;
      getDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      height: MediaQuery.of(context).size.height / 1.1,
      padding: scaler.getPadding(1, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      // color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidgetHelper().titleQ(context, "${widget.id == '' ? 'Tambah' : 'Ubah'} Alamat",icon: UiIcons.information),
              WidgetHelper().myRipple(
                callback: ()=> widget.id == ''?insertAddress():updateAddress(),
                child: config.MyFont.title(context: context,text: "Simpan",color: config.Colors.mainColors))
            ],
          ),
          Divider(),
          SizedBox(height: 10.0),
          isLoading
              ? WidgetHelper().loadingWidget(context)
              : Expanded(
                  child: ListView(
                    children: [
                      _entryField(
                          context,
                          "Simpan Alamat Sebagai (Contoh:Alamat rumah, Alamat kantor, Alamat pacar)",
                          TextInputType.text,
                          TextInputAction.next,
                          titleController,
                          titleFocus,
                          submited: (e) => WidgetHelper().fieldFocusChange(
                              context, titleFocus, receiverFocus)),
                      _entryField(
                          context,
                          "Penerima",
                          TextInputType.text,
                          TextInputAction.next,
                          receiverController,
                          receiverFocus,
                          submited: (e) => WidgetHelper().fieldFocusChange(
                              context, receiverFocus, telpFocus)),
                      _entryField(context, "No.Telepon", TextInputType.number,
                          TextInputAction.next, telpController, telpFocus,
                          submited: (e) => WidgetHelper().fieldFocusChange(
                              context, telpFocus, provinsiFocus)),
                      _entryField(
                          context,
                          "Provinsi",
                          TextInputType.text,
                          TextInputAction.next,
                          provinsiController,
                          provinsiFocus,
                          readOnly: true, onTap: () {
                        WidgetHelper().myModal(
                            context,
                            ModalProvinsiWidget(
                              callback: (id, name, idx) {
                                setState(() {
                                  provinsiController.text = name;
                                  prov = id;
                                  provName = name;
                                  idxProv = idx;
                                  city = '';
                                  kotaController.text = "";
                                  kecamatanController.text = "";
                                });
                                Navigator.pop(context);
                              },
                              id: prov,
                              idx: idxProv,
                            ));
                      }),
                      _entryField(context, "Kota", TextInputType.text,
                          TextInputAction.next, kotaController, kotaFocus,
                          readOnly: true, onTap: () {
                        if (prov != '') {
                          WidgetHelper().myModal(
                              context,
                              ModalKotaWIdget(
                                callback: (id, name, idx) {
                                  setState(() {
                                    kotaController.text = name;
                                    city = id;
                                    cityName = name;
                                    idxCity = idx;
                                    district = '';
                                    kecamatanController.text = "";
                                  });
                                  Navigator.pop(context);
                                },
                                id: city,
                                idProv: prov,
                                idx: idxCity,
                              ));
                        }
                      }
                          // submited: (e)=>WidgetHelper().fieldFocusChange(context,telpFocus, telpFocus)
                          ),
                      _entryField(
                          context,
                          "Kecamatan",
                          TextInputType.text,
                          TextInputAction.next,
                          kecamatanController,
                          kecamatanFocus,
                          readOnly: true, onTap: () {
                        if (prov != '') {
                          WidgetHelper().myModal(
                              context,
                              ModalKecamatanWidget(
                                callback: (id, name, idx) {
                                  setState(() {
                                    kecamatanController.text = name;
                                    district = id;
                                    districtName = name;
                                    idxDistrict = idx;
                                  });
                                  Navigator.pop(context);
                                },
                                id: district,
                                idCity: city,
                                idx: idxDistrict,
                              ));
                        }
                      }),
                      _entryField(
                          context,
                          "Detail alamat (format : nama jalan, rt, rw, keluarahan, kode pos)",
                          TextInputType.text,
                          TextInputAction.done,
                          mainAddressController,
                          mainAddressFocus,
                          maxLines: 2, onChange: (e) {
                        if (e != '') {
                          if (mainAddressController.text.split(",").length >
                              4) {
                            setState(() {
                              namaJalan =
                                  mainAddressController.text.split(",")[0];
                              rt = mainAddressController.text.split(",")[1];
                              rw = mainAddressController.text.split(",")[2];
                              keluarahan =
                                  mainAddressController.text.split(",")[3];
                              kodePos =
                                  mainAddressController.text.split(",")[4];
                            });
                          }
                        }
                        else {
                          setState(() {
                            mainAddressController.text = '';
                            namaJalan = "";
                            rt = "";
                            rw = "";
                            kodePos = "";
                          });
                        }
                      }
                          // submited: (e)=>WidgetHelper().fieldFocusChange(context,telpFocus, provinsiFocus)
                          ),
                      SizedBox(height: scaler.getHeight(1)),
                      config.MyFont.subtitle(
                          context: context,
                          text: "Alamat ini digunakan untuk pengiriman",
                          color: Theme.of(context)
                              .textTheme
                              .headline1
                              .color
                              .withOpacity(0.5)),
                      SizedBox(height: scaler.getHeight(0.5)),
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:Theme.of(context).focusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          padding: scaler.getPadding(1, 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              rowTextBetween(context: context,title: "Jalan",desc: namaJalan),
                              rowTextBetween(context: context,title: "rt",desc: rt),
                              rowTextBetween(context: context,title: "rw",desc: rw),
                              rowTextBetween(context: context,title: "kelurahan",desc: keluarahan),
                              rowTextBetween(context: context,title: "Kecamatan",desc: districtName),
                              rowTextBetween(context: context,title: "Kota",desc: cityName),
                              rowTextBetween(context: context,title: "Provinsi",desc: provName),
                              rowTextBetween(context: context,title: "Kode pos",desc: kodePos),
                            ],
                          )),
                      SizedBox(height: scaler.getHeight(0.5)),
                      WidgetHelper().myRipple(
                        callback: (){
                          WidgetHelper().myPush(context, MapsWidget(callback: (address){
                            placeholderPinPoint = address;
                            if(this.mounted)this.setState(() {});
                            Navigator.of(context).pop();
                          },latlong: widget.id == ''?null:placeholderPinPoint));
                        },
                        child: Wrap(
                          children: [
                            WidgetHelper().titleQ(context, "Lokasi pick up untuk instant kurir ( opsional )",
                              icon: UiIcons.placeholder,
                              fontSize: 9,
                              fontWeight: FontWeight.normal,
                              colorTitle: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .color
                                  .withOpacity(0.5),
                              callback: () {

                              },
                            ),
                            SizedBox(height: scaler.getHeight(0.5)),
                            config.MyFont.subtitle(context: context,text:placeholderPinPoint!=null?placeholderPinPoint[StringConfig.fullAddress]:"-",color: Theme.of(context).textTheme.bodyText2.color)
                          ],
                        )
                      ),
                      Divider(),
                      config.MyFont.subtitle(context: context,
                          text:"pastikan lokasi yang anda tandai di peta sesuai dengan alamat yang anda isi",color:Theme.of(context)
                          .textTheme
                          .headline1
                          .color
                          .withOpacity(0.5),
                        fontSize: 8
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  Widget rowTextBetween({BuildContext context,title="",desc=""}){
    return  Row(
      mainAxisAlignment:MainAxisAlignment.spaceBetween,
      children: [
        config.MyFont.subtitle(context: context, text: title),
        config.MyFont.subtitle(context: context, text: desc),
      ],
    );
  }

  Widget _entryField(
      BuildContext context,
      String title,
      TextInputType textInputType,
      TextInputAction textInputAction,
      TextEditingController textEditingController,
      FocusNode focusNode,
      {bool readOnly = false,
      int maxLines = 1,
      Function(String) submited,
      Function onTap,
      Function(String e) onChange}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            readOnly: readOnly,
            maxLines: maxLines,
            style: config.MyFont.style(
                context: context,
                style: Theme.of(context).textTheme.bodyText2,
                fontWeight: FontWeight.normal,
                fontSize: 10),
            focusNode: focusNode,
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: title,
              hintStyle: config.MyFont.style(
                  context: context,
                  style: Theme.of(context).textTheme.bodyText2,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context)
                      .textTheme
                      .headline1
                      .color
                      .withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .textTheme
                          .headline1
                          .color
                          .withOpacity(0.2))),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.headline1.color)),
            ),
            keyboardType: textInputType,
            textInputAction: textInputAction,
            onTap: () => onTap(),
            onSubmitted: (e) => submited(e),
            onChanged: (e) => onChange(e),
            inputFormatters: <TextInputFormatter>[
              if (textInputType == TextInputType.number)
                LengthLimitingTextInputFormatter(13),
              if (textInputType == TextInputType.number)
                FilteringTextInputFormatter.digitsOnly
            ],
          )
        ],
      ),
    );
  }
}
