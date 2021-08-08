import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/address/function_address.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/list_address_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/pages/widget/address/modal_form_address_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';

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
  ListAddressModel listAddressModel;
  bool isLoading=false,isLoadmore=false,isError=false;
  int idx=SiteConfig().noDataCode;
  Future loadData()async{
    final idUser = await UserHelper().getDataUser("id_user");
    var res = await FunctionAddress().loadData(context: context,isChecking: false);
    listAddressModel = res;
    isLoading=false;
    this.setState(() {

    });
  }
  Future deleteAddress(id)async{
    WidgetHelper().loadingDialog(context);
    var res = await HandleHttp().deleteProvider("member_alamat/$id", generalFromJson,context: context);
    if(res!=null){
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
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: WidgetHelper().appBarWithButton(context,"Daftar Alamat",(){Navigator.pop(context);},<Widget>[
        WidgetHelper().iconAppbar(context: context,icon: Ionicons.ios_add,callback: (){
          WidgetHelper().myModal(context, ModalFormAddressWidget(id:"",callback:(String par){
            if(par=='berhasil'){
              loadData();
              WidgetHelper().showFloatingFlushbar(context,"success","data berhasil dikirim");
            }
            else{
              WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
            }
          },));
        })
        // Container(
        //   color: Colors.transparent,
        //   padding: EdgeInsets.only(right: 0.0,top:5),
        //   child: Stack(
        //     alignment: AlignmentDirectional.topEnd,
        //     children: <Widget>[
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 0),
        //         child: FlatButton(
        //             onPressed: (){
        //               // WidgetHelper().myModal(context, ModalForm(id:"",callback:(String par){
        //               //   if(par=='berhasil'){
        //               //     loadData();
        //               //     WidgetHelper().showFloatingFlushbar(context,"success","data berhasil dikirim");
        //               //   }
        //               //   else{
        //               //     WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
        //               //   }
        //               // },));
        //             },
        //             child: WidgetHelper().textQ("Tambah Alamat",scaler.getTextSize(9),LightColor.mainColor,FontWeight.bold)
        //         ),
        //       ),
        //     ],
        //   ),
        // )
      ],brightness: Brightness.light),
      body: Container(
        padding: scaler.getPadding(0,2),
        child: isLoading?LoadingHistory(tot: 10):listAddressModel.result.data.length>0?Column(
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
                              // WidgetHelper().myModal(context, ModalForm(id:"${val.id}",callback:(String par){
                              //   if(par=='berhasil'){
                              //     loadData();
                              //     WidgetHelper().showFloatingFlushbar(context,"success","data berhasil disimpan");
                              //   }
                              //   else{
                              //     WidgetHelper().showFloatingFlushbar(context,"failed","terjadi kesalahan koneksi");
                              //   }
                              // },));
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
                                        // WidgetHelper().myModal(context, ModalForm(id:"${val.id}",callback:(String par){
                                        //   if(par=='berhasil'){
                                        //     loadData();
                                        //     WidgetHelper().showFloatingFlushbar(context,"success","data berhasil disimpan");
                                        //   }
                                        //   else{
                                        //     WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
                                        //   }
                                        // },));
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
