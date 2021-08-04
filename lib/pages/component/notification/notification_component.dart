import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

class NotificationComponent extends StatefulWidget {
  @override
  _NotificationComponentState createState() => _NotificationComponentState();
}

class _NotificationComponentState extends State<NotificationComponent> {
  List data=[
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
    {"title":"Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy text of the printing and typesetting industry"},
  ];
  bool isLoading=true;

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 7),
        child: Column(
          children: <Widget>[
            Padding(
              padding: scaler.getPadding(0,2),
              child: SearchBarWidget(),
            ),
            !isLoading?Padding(padding: scaler.getPadding(0,2),child: LoadingCart(total:7)):ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 15),
              shrinkWrap: true,
              primary: false,
              itemCount: data.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 7);
              },
              itemBuilder: (context, index) {
                return buildItem(context: context,index: index);
              },
            ),

          ],
        ),
      ),
    );
  }
  Widget buildItem({BuildContext context,int index}) {
    final scaler=config.ScreenScale(context).scaler;

    return WidgetHelper().myRipple(
      callback: (){},
      child: Dismissible(
        key: Key(index.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding:scaler.getPadding(0,2),
              child: Icon(
                FlutterIcons.remove_circle_outline_mdi,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // onDismissed: (direction) {
        //   setState(() {});
          // data.removeAt(index);
          // Scaffold.of(context).showSnackBar(SnackBar(content: Text(" dismissed")));
        // },
        child: Container(
          color: index%2==0 ? Colors.transparent : Theme.of(context).focusColor.withOpacity(0.15),
          padding: scaler.getPadding(1,2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height:  scaler.getHeight(5),
                width:  scaler.getHeight(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(image: AssetImage(StringConfig.localAssets+"man1.webp"), fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 15),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    config.MyFont.title(context: context,text:data[index]["title"],fontSize: 9,fontWeight:index%2==0 ? FontWeight.w300:FontWeight.w600,maxLines: 2),
                    config.MyFont.subtitle(context: context,text:"33 menit yang lalu",fontSize: 8,color:  Theme.of(context).textTheme.caption.color),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
