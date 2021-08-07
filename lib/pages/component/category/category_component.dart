import 'dart:math';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_category_product_model.dart';
import 'package:netindo_shop/pages/widget/drawer_widget.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class CategoryComponent extends StatefulWidget {
  @override
  _CategoryComponentState createState() => _CategoryComponentState();
}

class _CategoryComponentState extends State<CategoryComponent> {
  ListCategoryProductModel listCategoryProductModel;

  List data=[];

  bool isLoading=true;
  Future loadData()async{
    final resCategory=await HandleHttp().getProvider("kategori?page=1",listCategoryProductModelFromJson,context: context);
    if(resCategory!=null){
      if(resCategory==StringConfig.errNoData) return;
      ListCategoryProductModel resultCategory=ListCategoryProductModel.fromJson(resCategory.toJson());

      List arrCategory=resultCategory.result.data;
      for(int i=0;i<arrCategory.length;i++){
        print("alur = eksekusi kategori");
        data.add({"id":arrCategory[i].id,"kelompok":[{
          "id":i
        }]});
        // for(int x=0;x<data.length;x++){

          // data[i].contains({"kelompok":x});
          // print(data[i]);
          // print("alur = eksekusi kelompok");
          // print(data[i]["kelompok"][x]["id"]);
          // data[i]["kelompok"][x]["id"]=x;
        // }
      }
      for(int i=0;i<data.length;i++){
        for(int x=0;x<data[i]["kelompok"].length;x++){
          // Map<String, Object> kel = data[i]["kelompok"].toJson();
          // print(kel);
          // data[i]["kelompok"].addAll({"gambar":"img"});
        }
      }
      // resultCategory.result.data.forEach((rowCategory)async {
      //   data.add({"id":rowCategory.id,"title":rowCategory.title,"image":rowCategory.image,"kelompok":[]});
      //   final resGroup=await HandleHttp().getProvider("kelomok?page=1&kategori=${rowCategory.id}",listGroupProductModelFromJson,context: context);
      //   if(resGroup!=null){
      //     if(resGroup==StringConfig.errNoData) return;
      //     ListGroupProductModel resultGroup=ListGroupProductModel.fromJson(resGroup.toJson());
      //     print("alur = eksekusi kelompok");
      //     resultGroup.result.data.forEach((rowGroup) {
      //       data.add({"kelompok":rowGroup.toJson()});
      //     });
      //   }
      // });

      print("### data = $data");
      isLoading=false;
      if(this.mounted)this.setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: WidgetHelper().appBarWithButton(context, "Kategori", (){},<Widget>[],param: "default"),
      body: SingleChildScrollView(
        padding:scaler.getPadding(1,2),
        child: Wrap(
          runSpacing: 20,
          children: <Widget>[
            SearchBarWidget(),
            Wrap(
              runSpacing: 30,
              children: List.generate(10, (index) {
                return index.isEven ? buildEvenCategory(context) : buildOddCategory(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEvenCategory(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: scaler.getWidth(25),
          child: Stack(
            children: <Widget>[
              Container(
                padding: scaler.getPadding(1,2),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
                    ],
                    gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                      Theme.of(context).accentColor,
                      Theme.of(context).accentColor.withOpacity(0.2),
                    ])),
                child: Column(
                  children: <Widget>[
                    Hero(
                      tag: "${random.nextInt(10000)}",
                      child: SvgPicture.asset(StringConfig.imageProduct,height: scaler.getHeight(2.5),),
                    ),
                    SizedBox(height: 5),
                    config.MyFont.title(context: context,text:"Sepatu",color:Theme.of(context).primaryColor )

                  ],
                ),
              ),
              Positioned(
                right: -40,
                bottom: -60,
                child: Container(
                  width: scaler.getWidth(25),
                  height: scaler.getHeight(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                top: -60,
                child: Container(
                  width: scaler.getWidth(25),
                  height: scaler.getHeight(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding:scaler.getPadding(1,2),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
              ],
            ),
            constraints: BoxConstraints(minHeight: 120),
            child: Wrap(
              runAlignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (index) {
                return Material(
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () {
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: scaler.getPadding(0.3,1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2)),
                      ),
                      child: config.MyFont.subtitle(context: context,text:"Women",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 7),
                    ),
                  ),
                );
              }),
            ),
          ),
        )
      ],
    );
  }
  Random random =  new Random();
  Widget buildOddCategory(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            padding:scaler.getPadding(1,2),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
              ],
            ),
            constraints: BoxConstraints(minHeight: 120),
            child: Wrap(
              runAlignment: WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (index) {
                return Material(
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () {
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: scaler.getPadding(0.3,1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2)),
                      ),
                      child: config.MyFont.subtitle(context: context,text:"Furniture",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 7),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        SizedBox(
          width: scaler.getWidth(25),
          child: Stack(
            children: <Widget>[
              Container(
                padding: scaler.getPadding(1,2),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
                    ],
                    gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                      Theme.of(context).accentColor,
                      Theme.of(context).accentColor.withOpacity(0.2),
                    ])),
                child: Column(
                  children: <Widget>[
                    Hero(
                      tag: "${random.nextInt(10000)}",
                      child: SvgPicture.asset(StringConfig.imageProduct,height: scaler.getHeight(2.5),),
                    ),
                    SizedBox(height: 5),
                    config.MyFont.title(context: context,text:"Sepatu",color:Theme.of(context).primaryColor )

                  ],
                ),
              ),
              Positioned(
                right: -40,
                bottom: -60,
                child: Container(
                  width: scaler.getWidth(25),
                  height: scaler.getHeight(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                top: -60,
                child: Container(
                  width: scaler.getWidth(25),
                  height: scaler.getHeight(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(150),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

}
