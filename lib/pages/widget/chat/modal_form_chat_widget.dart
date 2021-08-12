import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class ModalFormChatWidget extends StatefulWidget {
  final Function(bool status) callback;
  ModalFormChatWidget({this.callback});
  @override
  _ModalFormChatWidgetState createState() => _ModalFormChatWidgetState();
}

class _ModalFormChatWidgetState extends State<ModalFormChatWidget> {
  var titleController = TextEditingController();
  var messageController = TextEditingController();
  final FocusNode titleFocus = FocusNode();
  final FocusNode messageFocus = FocusNode();

  Map<String,Object> tenant;
  File _image;
  String fileName;
  String base64Image;
  Future loadData()async{
    final res = await FunctionHelper().getTenant();
    this.setState(() {
      tenant = res;
    });
  }
  Future store()async{
    if(titleController.text=="") return titleFocus.requestFocus();
    if(messageController.text=="") return;
    if(_image!=null){
      fileName = _image.path.split("/").last;
      var type = fileName.split('.');
      base64Image = 'data:image/' + type[1] + ';base64,' + base64Encode(_image.readAsBytesSync());
    }
    else{
      base64Image = "-";
    }
    WidgetHelper().loadingDialog(context);
    final data={
      "title":titleController.text,
      "deskripsi":messageController.text,
      "lampiran":base64Image,
      "layanan":"Barang",
      "prioritas":"0",
      "status":"0",
      "id_tenant":tenant[StringConfig.idTenant]
    };
    final res = await HandleHttp().postProvider("chat", data,context: context,callback: (){});

    if(res!=null){
      Navigator.pop(context);
      Navigator.pop(context);
      widget.callback(true);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    titleFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    print(tenant);
    final scaler = config.ScreenScale(context).scaler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: scaler.getPadding(1,2),
            child:Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WidgetHelper().titleQ(
                      context,
                      "Buat pesan",
                      icon: UiIcons.information,fontSize: 9,
                    ),
                    WidgetHelper().myRipple(
                      callback: (){store();},
                      child: config.MyFont.title(context: context,text:"Kirim pesan",fontSize: 9,color: config.Colors.mainColors)
                    )
                  ],
                ),
                Divider(),

                ListView(
                  padding: EdgeInsets.all(0),
                  addRepaintBoundaries: true,
                  primary: false,
                  shrinkWrap: true,
                  children: [
                    WidgetHelper().chip(
                      ctx: context,
                      child: WidgetHelper().titleQ(
                        context,
                        tenant[StringConfig.namaTenant],
                        image: tenant[StringConfig.logoTenant],
                        subtitle: tenant[StringConfig.telpTenant],
                        fontSize: 9,
                        padding: EdgeInsets.all(0),
                        callback: (){}
                      )
                    ),
                    _entryField(context,"Contoh : refund belum sampai",TextInputType.text,TextInputAction.next,titleController,titleFocus,
                      submited: (e)=>WidgetHelper().fieldFocusChange(context,titleFocus, messageFocus)
                    ),
                    _entryField(context,"Contoh : \nSelamat siang, kenapa ketika saya refund status nya belum sampai terus",TextInputType.text,TextInputAction.done,messageController,messageFocus,maxLines: 5,
                      submited: (e){}
                    ),
                    SizedBox(height: scaler.getHeight(1)),
                    WidgetHelper().myRipple(
                      callback: ()async{
                        var img = await FunctionHelper().getImage('galeri');
                        setState(() {
                          _image = img;
                        });
                        messageFocus.unfocus();
                        FocusScope.of(context).unfocus();
                      },
                      child:  WidgetHelper().chip(
                        ctx: context,
                        child:Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              WidgetHelper().icons(ctx: context,icon: UiIcons.upload),
                              config.MyFont.title(context: context,text:"Lampirkan file"),
                            ],
                          ),
                        ),
                      )
                    ),
                    Divider(),
                    Container(
                      padding:EdgeInsets.all(0.0),
                      decoration: BoxDecoration(
                        borderRadius:  BorderRadius.circular(10.0),
                      ),
                      child: _image == null ?Container(): new Image.file(_image,width: MediaQuery.of(context).size.width/1,height: MediaQuery.of(context).size.height/2,filterQuality: FilterQuality.high,fit: BoxFit.cover),
                    ),
                  ],
                )
              ],
            )
        ),
      ],
    );
  }


  Widget _entryField(BuildContext context,String title,TextInputType textInputType,TextInputAction textInputAction, TextEditingController textEditingController, FocusNode focusNode, {int maxLines=1,Function(String) submited}) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            maxLines: maxLines,
            style:config.MyFont.style(context: context,style: Theme.of(context).textTheme.bodyText2,fontWeight: FontWeight.normal),
            focusNode: focusNode,
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: title,
              hintStyle: config.MyFont.style(context: context,style: Theme.of(context).textTheme.bodyText2,fontWeight: FontWeight.normal,color: Theme.of(context).textTheme.headline1.color.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color.withOpacity(0.2))),
              focusedBorder:UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color)),
            ),
            keyboardType: textInputType,
            textInputAction: textInputAction,
            onSubmitted: (e)=>submited(e),

          )
        ],
      ),
    );
  }
}
