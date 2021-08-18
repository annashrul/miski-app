import 'package:flutter/material.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';

class ImageUserWidget extends StatefulWidget {

  @override
  _ImageUserWidgetState createState() => _ImageUserWidgetState();
}

class _ImageUserWidgetState extends State<ImageUserWidget> {
  String img="";
  @override
  void initState() {
    super.initState();
    UserHelper().getDataUser(StringConfig.foto).then((value)=>this.setState(()=>img=value));

  }
  @override
  Widget build(BuildContext context) {
    return WidgetHelper().imageUser(context: context,img: img);
  }
}
