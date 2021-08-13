import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/listGroupProductModel.dart';
import 'package:netindo_shop/model/tenant/list_category_product_model.dart';
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
    final resCategory=await HandleHttp().getProvider("kategori?page=1&status=1",listCategoryProductModelFromJson,context: context);
    // final resGroup=await HandleHttp().getProvider("kelomok?page=1&status=1",listGroupProductModelFromJson,context: context);
    if(resCategory!=null){
      if(resCategory==StringConfig.errNoData) return;
      ListCategoryProductModel resultCategory=ListCategoryProductModel.fromJson(resCategory.toJson());
      for(int iCategory=0;iCategory<resultCategory.result.data.length;iCategory++){
        var rowCategory=resultCategory.result.data[iCategory];
        data.add({"id":rowCategory.id,"title":rowCategory.title,"image":rowCategory.image,"kelompok":[]});
        final resGroup = await HandleHttp().getProvider("kelompok?page=1&kategori=${rowCategory.id}",listGroupProductModelFromJson,context: context);
        if(resGroup!=null){
          ListGroupProductModel resultGroup=ListGroupProductModel.fromJson(resGroup.toJson());
          resultGroup.result.data.forEach((rowGroup) {
            data[iCategory]["kelompok"].add({
              "id":rowGroup.id,
              "title":rowGroup.title,
              "kategori":rowGroup.kategori,
              "image":rowGroup.image
            });
          });
          if(this.mounted){
            this.setState(() {
              isLoading=false;
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Kategori", (){},<Widget>[],param: "default"),
      body: isLoading?WidgetHelper().loadingWidget(context):SingleChildScrollView(
        padding:scaler.getPadding(1,2),
        child: Wrap(
          runSpacing: 20,
          children: <Widget>[
            Wrap(
              runSpacing: 30,
              children: List.generate(data.length, (index) {
                return index.isEven ? data[index]["kelompok"].length>0?buildEvenCategory(context,index):Text("") : data[index]["kelompok"].length>0?buildOddCategory(context,index):Text("");
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEvenCategory(BuildContext context,int idxCategory) {
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
                      tag: "categoryImage${data[idxCategory]["id"]}",
                      child: SvgPicture.network(
                        data[idxCategory]["image"],
                        height: scaler.getHeight(2.5),
                        placeholderBuilder: (context) => Icon(Icons.error),
                      ),
                    ),
                    SizedBox(height: 5),
                    config.MyFont.title(context: context,text:data[idxCategory]["title"],color:Theme.of(context).primaryColor,fontSize: 8 )
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
              children: List.generate(data[idxCategory]["kelompok"].length, (index) {
                return Material(
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed("/${StringConfig.productByCategory}",arguments:data[idxCategory]..addAll({"index":index}));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: scaler.getPadding(0.3,1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2)),
                      ),
                      child: config.MyFont.subtitle(context: context,text:data[idxCategory]["kelompok"][index]["title"],color: Theme.of(context).textTheme.bodyText2.color,fontSize: 7),
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
  Widget buildOddCategory(BuildContext context,int idxCategory) {
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
              children: List.generate(data[idxCategory]["kelompok"].length, (index) {
                return Material(
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed("/${StringConfig.productByCategory}",arguments:data[idxCategory]..addAll({"index":index}));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: scaler.getPadding(0.3,1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2)),
                      ),
                      child: config.MyFont.subtitle(context: context,text:data[idxCategory]["kelompok"][index]["title"],color: Theme.of(context).textTheme.bodyText2.color,fontSize: 7),
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
                      child: SvgPicture.network(data[idxCategory]["image"],height: scaler.getHeight(2.5), placeholderBuilder: (context) => Icon(Icons.error),),
                    ),
                    SizedBox(height: 5),
                    config.MyFont.title(context: context,text:data[idxCategory]["title"],color:Theme.of(context).primaryColor,fontSize: 8 )
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
