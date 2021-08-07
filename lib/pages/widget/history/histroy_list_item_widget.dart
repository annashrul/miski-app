import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/history/history_transaction_model.dart';

class HistoryListItemWidget extends StatefulWidget {
  final HistoryTransactionModel data;
  final int i;
  HistoryListItemWidget({this.data,this.i});
  @override
  _HistoryListItemWidgetState createState() => _HistoryListItemWidgetState();
}

class _HistoryListItemWidgetState extends State<HistoryListItemWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return WidgetHelper().myRipple(
      callback: (){},
      child: Container(
        padding: scaler.getPadding(0.5, 2),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: "historyListOrder${this.widget.i.hashCode.toString()}",
              child: Container(
                height: scaler.getHeight(6),
                width: scaler.getWidth(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(image: AssetImage(StringConfig.imageProduct), fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(width: scaler.getWidth(1)),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        config.MyFont.title(context: context,text:"Digital Display Bracelet Watch",fontSize: 9),

                        SizedBox(height: scaler.getHeight(1)),
                        Wrap(
                          spacing: 10,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                WidgetHelper().icons(ctx:context,icon:UiIcons.calendar,color: Theme.of(context).focusColor),
                                SizedBox(width: scaler.getWidth(1)),
                                config.MyFont.subtitle(context: context,text:"2021-09-09",color: Theme.of(context).textTheme.bodyText1.color),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                WidgetHelper().icons(ctx:context,icon:UiIcons.line_chart,color: Theme.of(context).focusColor),
                                SizedBox(width: scaler.getWidth(1)),
                                config.MyFont.subtitle(context: context,text:"RB4551532214564",color: Theme.of(context).textTheme.bodyText1.color),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: scaler.getWidth(1)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      config.MyFont.subtitle(context: context,text:config.MyFont.toMoney("9000000"),color: config.Colors.moneyColors),
                      SizedBox(height: scaler.getHeight(0.5)),
                      Chip(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        backgroundColor: Colors.transparent,
                        shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor)),
                        label: config.MyFont.subtitle(context: context,text:"x ${config.MyFont.toMoney("1")}",color:Theme.of(context).focusColor),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
