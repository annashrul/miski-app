import 'package:flutter/material.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/config/app_config.dart' as config;

class ModalKurirWidget extends StatefulWidget {
  final List data;
  final Function(int index) callback;
  final int index;
  ModalKurirWidget({this.data,this.callback,this.index});
  @override
  _ModalKurirWidgetState createState() => _ModalKurirWidgetState();
}

class _ModalKurirWidgetState extends State<ModalKurirWidget> {
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
                    return WidgetHelper().myRipple(
                        callback: ()=> widget.callback(index),
                        child: WidgetHelper().titleQ(context,widget.data[index]["deskripsi"],
                        fontSize: 9,
                        param: widget.index==index?"-":"",
                        image:widget.data[index]["gambar"],
                        iconAct: widget.index==index?UiIcons.checked:null
                    ),
                    );
                  },
                  separatorBuilder: (context, index) {return Divider(height:scaler.getHeight(0.5));},
                )
            ),
          ),
        ],
      ),
    );
  }
}

