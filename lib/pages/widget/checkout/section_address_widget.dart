import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/address/address_component.dart';
import 'package:netindo_shop/views/screen/address/address_screen.dart';

// ignore: must_be_immutable
class SectionAddressWidget extends StatefulWidget {
  final Map<String,Object> address;
  final bool isLoading;
  Function(Map<String,Object> data) callback;
  SectionAddressWidget({this.isLoading,this.address,this.callback});
  @override
  _SectionAddressWidgetState createState() => _SectionAddressWidgetState();
}

class _SectionAddressWidgetState extends State<SectionAddressWidget> {
  int indexAddress=0;
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPadding(0,2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: scaler.getHeight(1)),
          WidgetHelper().titleQ(context, "Alamat pengiriman",icon: UiIcons.checked),
          WidgetHelper().myRipple(
              callback: (){
                WidgetHelper().myPushAndLoad(context, AddressComponent(callback: (data){
                  indexAddress=data["index"];
                  widget.callback(data);
                  setState(() {});
                },indexArr: indexAddress), (){});
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: scaler.getHeight(0.5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WidgetHelper().chip(
                        ctx: context,
                        child: widget.isLoading?WidgetHelper().shimmer(context: context,width:10):config.MyFont.subtitle(context: context,text:"${widget.address["is_main_address"]==1?"Utama":widget.address["title"]}")
                      ),
                      config.MyFont.subtitle(context: context,text:"alamat lain",color: config.Colors.mainColors)
                    ],
                  ),
                  SizedBox(height: scaler.getHeight(0.5)),
                  widget.isLoading?WidgetHelper().shimmer(context: context,width:30):config.MyFont.subtitle(context: context,text:widget.address["penerima"]),
                  widget.isLoading?WidgetHelper().shimmer(context: context,width:50):config.MyFont.subtitle(context: context,text:"${widget.address["main_address"]}".toLowerCase(),color: Theme.of(context).textTheme.caption.color)
                ],
              )
          ),

        ],
      ),
    );
  }
}
