import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import '../loading_widget.dart';

class SectionProductWidget extends StatefulWidget {
  final List data;
  final Function callback;
  SectionProductWidget({this.data,this.callback});
  @override
  _SectionProductWidgetState createState() => _SectionProductWidgetState();
}

class _SectionProductWidgetState extends State<SectionProductWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPadding(0,2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          WidgetHelper().titleQ(context, "Keranjang",icon: UiIcons.checked),
          SizedBox(height: scaler.getHeight(0.5)),
          Container(
           child:  widget.data.length>0?ListView.separated(
             padding: scaler.getPadding(0,0),
             addRepaintBoundaries: true,
             primary: false,
             shrinkWrap: true,
             itemBuilder: (context,index){
               final res=widget.data[index];
               return WidgetHelper().myRipple(
                   callback: (){
                     Navigator.of(context).pushNamed("/${StringConfig.detailProduct}",arguments: {
                       "heroTag":"product_checkout",
                       "id":res["id"],
                       "image":res["gambar"],
                     }).whenComplete(() => {widget.callback()});
                   },
                 child: WidgetHelper().chip(
                   padding: scaler.getPaddingLTRB(0,0,2,0),
                   ctx: context,
                   child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: <Widget>[
                         Hero(
                           tag: "product_checkout${res["id"]}",
                           child: Container(
                             height: scaler.getHeight(5),
                             width: scaler.getWidth(12),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.all(Radius.circular(5)),
                               image: DecorationImage(image: NetworkImage(res["gambar"]), fit: BoxFit.cover),
                             ),
                           ),
                         ),
                         SizedBox(width:scaler.getWidth(1.5)),
                         Flexible(
                           child: Row(
                             crossAxisAlignment: CrossAxisAlignment.center,
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: <Widget>[
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: <Widget>[
                                     config.MyFont.subtitle(context: context,text:res["title"],fontSize: 9),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Row(
                                           crossAxisAlignment: CrossAxisAlignment.center,
                                           children: <Widget>[
                                             config.MyFont.subtitle(context: context,text:config.MyFont.toMoney(res["qty"]),color:Theme.of(context).textTheme.caption.color),
                                             SizedBox(width:scaler.getWidth(0.2)),
                                             config.MyFont.subtitle(context: context,text:'*',fontSize: 8,color: Theme.of(context).textTheme.caption.color),
                                             SizedBox(width:scaler.getWidth(0.2)),
                                             config.MyFont.subtitle(context: context,text:config.MyFont.toMoney(res["harga_jual"]),color: config.Colors.moneyColors),
                                           ],
                                         ),
                                         config.MyFont.title(context: context,text:config.MyFont.toMoney(res["subtotal"]),fontSize: 9,color:config.Colors.moneyColors),

                                       ],
                                     )
                                   ],
                                 ),
                               ),
                               // SizedBox(width: 8),
                               // config.MyFont.title(context: context,text:config.MyFont.toMoney(res["subtotal"]),fontSize: 9,color:config.Colors.moneyColors),
                             ],
                           ),
                         )
                       ],
                     )
                 )
               );
             },
             itemCount: widget.data.length,
             separatorBuilder: (context,index){return SizedBox(height: scaler.getHeight(0.5));},
           ):LoadingTicket(total: 3,),
         )
        ],
      ),
    );
  }
}
