import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/model/help_support/list_help_support_model.dart';

// ignore: must_be_immutable
class HelpSupportWidget extends StatefulWidget {
  HelpSupportWidget({Key key, this.index = 1,this.listHelpSupportModel}) : super(key: key);
  final index;
  ListHelpSupportModel listHelpSupportModel;

  @override
  _HelpSupportWidgetState createState() => _HelpSupportWidgetState();
}

class _HelpSupportWidgetState extends State<HelpSupportWidget> {
  @override
  Widget build(BuildContext context) {
    final res = widget.listHelpSupportModel.result.data[widget.index];
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Theme.of(context).hintColor.withOpacity(0.1),
          offset: Offset(0, 5),
          blurRadius: 15,
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: config.MyFont.subtitle(context: context,text: res.question,fontSize: 9,color: Theme.of(context).textTheme.bodyText1.color),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5))),
            child: config.MyFont.subtitle(context: context,text: res.answer,fontSize: 9),
          ),
        ],
      ),
    );
  }
}
