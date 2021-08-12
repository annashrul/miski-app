import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

// ignore: must_be_immutable
class UploadImageWidget extends StatefulWidget {
  final Function(String bukti) callback;
  String title;
  UploadImageWidget({this.callback,this.title});
  @override
  _UploadImageWidgetState createState() => _UploadImageWidgetState();
}

class _UploadImageWidgetState extends State<UploadImageWidget> {
  File _image;
  String dropdownValue = 'pilih';

  @override
  void initState() {
    super.initState();
    if(widget.title==null){
      widget.title="Upload bukti transfer";
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
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
                  children: [
                    WidgetHelper().titleQ(
                        context,
                        widget.title,
                        icon: UiIcons.information,
                        fontSize: 9
                    ),
                    WidgetHelper().myRipple(
                      callback: (){
                        if(_image!=null){
                          String fileName;
                          String base64Image;
                          fileName = _image.path.split("/").last;
                          var type = fileName.split('.');
                          base64Image = 'data:image/' + type[1] + ';base64,' + base64Encode(_image.readAsBytesSync());
                          widget.callback(base64Image);
                        }
                      },
                      child: config.MyFont.subtitle(context: context,text: "Kirim",color: config.Colors.mainColors,fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Divider(),
                buildCard(context,"galeri"),
                SizedBox(height: scaler.getHeight(0.5)),
                buildCard(context,"kamera"),
                Container(
                  padding:EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    borderRadius:  BorderRadius.circular(10.0),
                  ),
                  child: _image == null ?Image.network(StringConfig.noImage,width: double.infinity,fit: BoxFit.contain): new Image.file(_image,width: MediaQuery.of(context).size.width/1,height: MediaQuery.of(context).size.height/2,filterQuality: FilterQuality.high,),
                ),
              ],
            )
        ),
      ],
    );
  }

  Widget buildCard(BuildContext context,String type){
    final scaler=config.ScreenScale(context).scaler;
    return  WidgetHelper().chip(
        ctx: context,
        child:  WidgetHelper().titleQ(
          context,
          "ambil gambar dari $type",
          param: "-",
          iconAct: UiIcons.play_button,
          padding: scaler.getPadding(0.5,0),
          fontSize: 9,
          callback: ()async{
            var img = await FunctionHelper().getImage(type);
            setState(()=>_image = img);
          },
          fontWeight: FontWeight.normal
        )
    );
  }

}
