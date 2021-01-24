import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/promo/detail_promo_screen.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';

class ListPromoScreen extends StatefulWidget {
  @override
  _ListPromoScreenState createState() => _ListPromoScreenState();
}

class _ListPromoScreenState extends State<ListPromoScreen> {
  Random random = new Random();
  // int random_number = random.nextInt(10000000);
  bool mode=false;
  Future getMode()async{
    var res = await FunctionHelper().getSite();
    setState(() {
      mode=res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mode?SiteConfig().darkMode:Colors.white,
      appBar: WidgetHelper().appBarWithButton(context,"Daftar Promo",(){Navigator.pop(context);},<Widget>[],brightness: mode?Brightness.dark:Brightness.light),
      body: RefreshWidget(
        widget: ListView.separated(
            padding: EdgeInsets.all(10.0),
            itemCount: 10,
            itemBuilder: (context,index){
              return Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  WidgetHelper().myPress(
                      (){WidgetHelper().myPush(context, DetailPromoScreen(id: '',mode: mode));},
                      Container(
                        padding: EdgeInsets.only(bottom:10.0),
                        // margin: EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(width:3.0,color: Colors.grey[200]),
                          boxShadow: [
                            BoxShadow(
                              color: mode?Colors.grey[200].withOpacity(0.1):Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height:  MediaQuery.of(context).size.height/3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage("https://appboy-images.com/appboy/communication/assets/image_assets/images/5fc5e3d045732b6af558241c/original.jpg?1606804432"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: EdgeInsets.all(1.5),
                            ),
                            SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: WidgetHelper().textQ("Selamat datang di ${SiteConfig().siteName}", 14,mode?Colors.grey[200]:SiteConfig().darkMode,FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: WidgetHelper().textQ("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. ${SiteConfig().siteName}", 10,Colors.grey,FontWeight.normal),
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                      color: mode?Colors.white10:Colors.black38
                  ),
                  BadgesQ(val: 'Periode 10-20 Desember',)
                ],
              );
            },
          separatorBuilder: (context,index){
              return SizedBox(height:10);
          },
        ),
        callback: (){},
      ),
    );
  }
}
