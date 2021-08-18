import 'package:flutter/material.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/config/app_config.dart' as config;

class ModalLayananWidget extends StatefulWidget {
  final List data;
  final Function(int index) callback;
  final int index;
  ModalLayananWidget({this.data,this.callback,this.index});
  @override
  _ModalLayananWidgetState createState() => _ModalLayananWidgetState();
}

class _ModalLayananWidgetState extends State<ModalLayananWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      height: scaler.getHeight(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
              padding: scaler.getPadding(1,2),
              child:Column(
                children: [
                  WidgetHelper().titleQ(context, "perkiraan tiba dihitung sejak pesanan dikirim",icon: UiIcons.information,fontSize: 9),
                  Divider()
                ],
              )
          ),
          Expanded(
            child: Scrollbar(
                child: ListView.separated(
                  padding:scaler.getPadding(0,2),
                  itemCount: widget.data.length,
                  itemBuilder: (context,index){
                    final res = widget.data[index];
                    return WidgetHelper().titleQ(
                        context,
                        "${res["service"]} | ${res["cost"]} | ${res["estimasi"]}",
                        padding: scaler.getPadding(0.5,0),
                        fontSize: 9,
                        param: widget.index==index?"-":"",
                        iconAct: widget.index==index?UiIcons.checked:null,
                        callback: ()=>widget.callback(index)
                    );
                  },
                  separatorBuilder: (context, index) {return Divider(height:scaler.getHeight(1));},
                )
            ),
          ),
        ],
      ),
    );
  }
}
