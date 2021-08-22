import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/widget/address/maps_widget.dart';
import 'package:miski_shop/pages/widget/address/modal_kecamatan_widget.dart';
import 'package:miski_shop/pages/widget/address/modal_kota_widget.dart';
import 'package:miski_shop/pages/widget/address/modal_provinsi_widget.dart';
import 'package:miski_shop/provider/address_provider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ModalFormAddressWidget extends StatefulWidget {
  String id;
  Function(String param) callback;
  ModalFormAddressWidget({this.id, this.callback});
  @override
  _ModalFormAddressWidgetState createState() => _ModalFormAddressWidgetState();
}

class _ModalFormAddressWidgetState extends State<ModalFormAddressWidget> {
  @override
  void initState() {
    super.initState();
    final address = Provider.of<AddressProvider>(context, listen: false);
    if (widget.id != '') {
      address.readDetail(context, widget.id);
    }
    else{
      address.resetField(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    final address = Provider.of<AddressProvider>(context);
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
                callback: ()=>address.validate(context,widget.id,(res){widget.callback(res);}),
                child: config.MyFont.title(context: context,text: "Simpan",color: config.Colors.mainColors))
            ],
          ),
          Divider(),
          SizedBox(height: 10.0),
          address.isLoading? WidgetHelper().loadingWidget(context): Expanded(
            child: ListView(
              children: [
                _entryField(
                  context,
                  "Simpan Alamat Sebagai (Contoh:Alamat rumah, Alamat kantor, Alamat pacar)",
                  TextInputType.text,
                  TextInputAction.next,
                  address.titleController,
                  address.titleFocus,
                  submited: (e)=>WidgetHelper().fieldFocusChange(context, address.titleFocus, address.receiverFocus),
                ),
                _entryField(
                    context,
                    "Penerima",
                    TextInputType.text,
                    TextInputAction.next,
                    address.receiverController,
                    address.receiverFocus,
                    submited: (e) => WidgetHelper().fieldFocusChange(context, address.receiverFocus, address.phoneFocus)
                ),
                _entryField(
                    context,
                    "No.Telepon",
                    TextInputType.number,
                    TextInputAction.next, address.phoneController, address.phoneFocus,
                    submited: (e) => WidgetHelper().fieldFocusChange(context, address.phoneFocus, address.provinceFocus)
                ),
                _entryField(
                    context,
                    "Provinsi",
                    TextInputType.text,
                    TextInputAction.next,
                    address.provinceController,
                    address.provinceFocus,
                    readOnly: true,
                    onTap: (){
                      WidgetHelper().myModal(
                          context,
                          ModalProvinsiWidget(
                            callback: (id, name, idx){
                              address.provinceController.text = name;
                              address.provCode = id;
                              address.idxProv = idx;
                              address.cityCode = '';
                              address.districtCode = '';
                              address.cityController.text = "";
                              address.districtController.text = "";
                              Navigator.of(context).pop();
                            },
                            id: address.provCode,
                            idx: address.idxProv,
                          )
                      );
                    }
                ),
                _entryField(
                    context,
                    "Kota",
                    TextInputType.text,
                    TextInputAction.next,
                    address.cityController,
                    address.cityFocus,
                    readOnly: true,
                    onTap: (){
                      if (address.provinceController.text != '') {
                        WidgetHelper().myModal(
                            context,
                            ModalKotaWIdget(
                              callback: (id, name, idx) {
                                address.cityController.text = name;
                                address.cityCode = id;
                                address.idxCity = idx;
                                address.districtController.text = "";
                                address.districtCode="";
                                Navigator.pop(context);
                              },
                              id: address.cityCode,
                              idProv: address.provCode,
                              idx: address.idxCity,
                            )
                        );
                      }
                      else{
                        WidgetHelper().showFloatingFlushbar(context, "failed","silahkan pilih provinsi terlebih dahulu");
                      }
                    }
                 ),
                _entryField(
                    context,
                    "Kecamatan",
                    TextInputType.text,
                    TextInputAction.next,
                    address.districtController,
                    address.districtFocus,
                    readOnly: true,
                    onTap: (){
                      if(address.provinceController.text==""){
                        WidgetHelper().showFloatingFlushbar(context, "failed","silahkan pilih provinsi terlebih dahulu");
                      }
                      else if(address.cityController.text==""){
                        WidgetHelper().showFloatingFlushbar(context, "failed","silahkan pilih kota terlebih dahulu");
                      }
                      else{
                        WidgetHelper().myModal(
                            context,
                            ModalKecamatanWidget(
                              callback: (id, name, idx) {
                                address.districtController.text = name;
                                address.districtCode = id;
                                address.idxDistrict = idx;
                                Navigator.pop(context);
                              },
                              id: address.districtCode,
                              idCity: address.cityCode,
                              idx: address.idxDistrict,
                            )
                        );
                      }
                    }
                  ),
                _entryField(
                  context,
                  "tambahkan catatan untuk melengkapi alamat",
                  TextInputType.text,
                  TextInputAction.done,
                  address.mainAddressController,
                  address.mainAddressFocus,
                  maxLines: 2,
                ),
                WidgetHelper().myRipple(
                  callback: (){
                    WidgetHelper().myPush(context, MapsWidget(callback: (res){
                      address.addressFromLatLong=res;
                    },latlong: widget.id == ''?null:address.addressFromLatLong));
                  },
                  child: Container(
                    padding: scaler.getPadding(1,0),
                    child: Row(
                      children: [
                        WidgetHelper().icons(ctx: context,icon:UiIcons.placeholder,color: Theme.of(context).textTheme.headline1.color.withOpacity(0.5)),
                        SizedBox(width: scaler.getWidth(1)),
                        Flexible(
                          child: config.MyFont.subtitle(context: context,text:address.addressFromLatLong!=null?address.addressFromLatLong[StringConfig.fullAddress]:"-",color: Theme.of(context).textTheme.bodyText2.color),
                        )
                      ],
                    ),
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
        Function(String e) change
    }) {
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
            onChanged: (e){
              if(change!=null) change(e);
            },
            onSubmitted: (e) => submited(e),
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
