import 'package:flutter/material.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "", (){}, <Widget>[]),

    );
  }
}
