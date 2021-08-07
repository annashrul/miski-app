import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/history/history_transaction_model.dart';

class HistoryGridItemWidget extends StatefulWidget {
  final HistoryTransactionModel data;
  final int i;
  HistoryGridItemWidget({this.data,this.i});
  @override
  _HistoryGridItemWidgetState createState() => _HistoryGridItemWidgetState();
}

class _HistoryGridItemWidgetState extends State<HistoryGridItemWidget> {
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).accentColor.withOpacity(0.08),
      onTap: () {

      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: "historyGridOrder${this.widget.i.hashCode.toString()}",
              child: Image.asset(StringConfig.imageProduct),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: config.MyFont.title(context: context,text:"Digital Display Bracelet Watch",fontSize: 9),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: config.MyFont.subtitle(context: context,text:config.MyFont.toMoney("9000000"),color: config.Colors.moneyColors),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: config.MyFont.subtitle(context: context,text:"RB4551532214564",color: Theme.of(context).textTheme.bodyText1.color),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
