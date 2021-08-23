import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/address/function_address.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/address/list_address_model.dart';
import 'package:miski_shop/model/general_model.dart';
import 'package:miski_shop/pages/widget/address/maps_widget.dart';
import 'package:miski_shop/pages/widget/address/modal_form_address_widget.dart';
import 'package:miski_shop/provider/address_provider.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:provider/provider.dart';
import '../../widget/empty_widget.dart';
import '../../widget/loading_widget.dart';

class AddressComponent extends StatefulWidget {
  final Function(dynamic data) callback;
  final int indexArr;
  AddressComponent({this.callback,this.indexArr});

  @override
  _AddressComponentState createState() => _AddressComponentState();
}

class _AddressComponentState extends State<AddressComponent> {
  ScrollController controller;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  int idx=StringConfig.noDataNumber;

  @override
  void initState() {
    super.initState();
    final address = Provider.of<AddressProvider>(context, listen: false);
    address.readList(context);
    idx=widget.indexArr;
  }

  @override
  Widget build(BuildContext context) {
    final address = Provider.of<AddressProvider>(context);
    print(address.isError);
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      key: scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context,"Daftar Alamat",(){Navigator.pop(context);},<Widget>[
        WidgetHelper().iconAppbar(context: context,icon: Ionicons.ios_add,callback: (){
          WidgetHelper().myModal(context, ModalFormAddressWidget(id:"",callback:(String par)=>address.readList(context)));
        })
      ],brightness: Brightness.light),
      body: Container(
        padding: scaler.getPadding(1,2),
        child: address.isLoading?LoadingHistory(tot: 10):address.listAddressModel.result.data.length>0?Column(
          children: [
            Expanded(
                flex:16,
                child: ListView.separated(
                  padding: EdgeInsets.all(0.0),
                  key: PageStorageKey<String>('AddressScreen'),
                  primary: false,
                  physics: ScrollPhysics(),
                  itemCount: address.listAddressModel.result.data.length,
                  itemBuilder: (context,index){
                    final val=address.listAddressModel.result.data[index];
                    Widget btn=WidgetHelper().myRipple(
                      child:WidgetHelper().icons(ctx: context,icon: UiIcons.trash),
                      callback: (){
                        WidgetHelper().notifDialog(context, "Perhatian !!","anda yakin akan menghapus data ini ??", (){Navigator.pop(context);},()async{
                          Navigator.pop(context);
                          address.delete(context, val.id);
                        });
                      },
                    );
                    if(widget.callback!=null){
                      btn=WidgetHelper().myRipple(
                        child: idx==index?WidgetHelper().icons(ctx: context,icon: UiIcons.checked):Text(""),
                        callback: (){},
                      );
                    }
                    return WidgetHelper().chip(
                      ctx: context,
                      child: WidgetHelper().myRipple(
                          callback: (){
                            if(widget.callback!=null){
                              setState(() {idx=index;});
                              widget.callback(val.toJson()..addAll({"index":index}));
                              Navigator.pop(context);
                            }else{
                              WidgetHelper().myModal(context, ModalFormAddressWidget(id:"${val.id}",callback:(String par)=>address.readList(context)));
                            }
                          },
                          child:  Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      config.MyFont.subtitle(context: context,text:"${val.title}"),
                                      val.ismain==1?Container(
                                        margin: scaler.getMarginLTRB(1, 0, 0, 0),
                                        padding: scaler.getPadding(0,1),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                            border: Border.all(color: config.Colors.mainColors,width: 2)
                                        ),
                                        child: config.MyFont.subtitle(context: context,text:"Utama"),
                                      ):Container()
                                    ],
                                  ),
                                  btn
                                ],
                              ),
                              Divider(),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      config.MyFont.subtitle(context: context,text:"${val.penerima}",color: Theme.of(context).textTheme.caption.color),
                                      Row(
                                        children: [
                                          Icon(UiIcons.placeholder,size: scaler.getTextSize(8),),
                                          SizedBox(width:scaler.getWidth(1)),
                                          config.MyFont.subtitle(context: context,text:val.pinpoint!="-"?"bisa kurir instant":"pilih lokasi pick up",color: Theme.of(context).textTheme.caption.color,fontSize: 8),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height:5.0),
                                  config.MyFont.subtitle(context: context,text:"${val.noHp}",color: Theme.of(context).textTheme.caption.color),
                                  SizedBox(height:5.0),
                                  config.MyFont.subtitle(context: context,text:"${val.mainAddress}, "
                                  "kecamatan ${val.kecamatan}, "
                                  "kota ${val.kota}, "
                                  "provinsi ${val.provinsi}".toLowerCase(),color: Theme.of(context).textTheme.caption.color),
                                  SizedBox(height:5.0),

                                  SizedBox(height:5.0),
                                  WidgetHelper().myRipple(
                                    callback: (){
                                      WidgetHelper().myModal(context, ModalFormAddressWidget(id:val.id,callback:(String par)=>address.readList(context)));
                                    },
                                    child: Container(
                                      padding:EdgeInsets.all(10.0),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: config.Colors.mainColors
                                      ),
                                      child: config.MyFont.title(context: context,text:"Ubah alamat",color: Theme.of(context).primaryColor,textAlign: TextAlign.center),
                                    ),
                                  )
                                ],
                              ),

                            ],
                          )
                      ),
                    );
                  },
                  separatorBuilder: (context,index){return SizedBox(height:10.0);},
                )
            ),
          ],
        ):EmptyTenant(),
      ),
    );
  }
}
