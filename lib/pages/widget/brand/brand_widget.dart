import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/tenant/list_brand_product_model.dart';
import 'package:miski_shop/pages/widget/loading_widget.dart';
import 'package:miski_shop/provider/handle_http.dart';

import '../empty_widget.dart';

class BrandWidget extends StatefulWidget {
  @override
  _BrandWidgetState createState() => _BrandWidgetState();
}

class _BrandWidgetState extends State<BrandWidget> {
  ListBrandProductModel listBrandProductModel;
  ScrollController controller;
  bool isLoading=true,isLoadMore=false;
  int perPage=10;
  void scrollListener({BuildContext context}) {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perPage<int.parse(listBrandProductModel.result.total)){
          isLoadMore=true;
          perPage+=StringConfig.perpage;
          loadData();
          setState(() {});
        }else{
          isLoadMore=false;
        }
      }
    }
  }
  Future loadData()async{
    final res=await HandleHttp().getProvider("brand?page=1&status=1&perpage=$perPage",listBrandProductModelFromJson,context: context);
    if(res!=null){
      ListBrandProductModel result=ListBrandProductModel.fromJson(res.toJson());
      listBrandProductModel = result;
      isLoading=false;
      if(this.mounted){
        this.setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    controller = new ScrollController()..addListener(scrollListener);
  }
  @override
  void dispose() {
    super.dispose();
    controller.removeListener(scrollListener);
  }
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Column(
      children: [
        isLoading?LoadingProductTenant(tot: 4):listBrandProductModel.result.data.length<1?EmptyDataWidget(
          iconData: UiIcons.folder,
          title: StringConfig.noData,
          isFunction: false,
        ):StaggeredGridView.countBuilder(
          primary: false,
          shrinkWrap: true,
          padding: scaler.getPaddingLTRB(2, 1, 2, 0),
          crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
          itemCount:listBrandProductModel.result.data.length,
          controller: controller,
          itemBuilder: (BuildContext context, int index) {
            final res=listBrandProductModel.result.data[index];
            List<Color> col = [config.hexToColors("${res.color}"),config.hexToColors("${res.color}").withOpacity(double.parse("0.$index"))];
            String image=res.image;
            return WidgetHelper().myRipple(
              callback: () {
                Navigator.of(context).pushNamed("/${StringConfig.productByBrand}",arguments: {
                  "color":config.hexToColors("${res.color}"),
                  "hero":"brand$index",
                  "image":image,
                  "data":res.toJson()
                });
              },
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(0),
                    alignment: AlignmentDirectional.topCenter,
                    padding: scaler.getPadding(2,2),
                    width: double.infinity,
                    height: scaler.getHeight(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
                        ],
                        gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors:col)),
                    child: Hero(
                      tag: "brand$index",
                      child: WidgetHelper().baseImage(image,width: scaler.getWidth(16)),
                      // child: SvgPicture.network(
                      //   image,
                      //   color: Theme.of(context).primaryColor,
                      //   width: scaler.getWidth(16),
                      //   placeholderBuilder: (context) => Icon(Icons.error),
                      // ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    bottom: -100,
                    child: Container(
                      width: scaler.getWidth(44),
                      height: scaler.getHeight(22),
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
                      width: scaler.getWidth(22),
                      height: scaler.getHeight(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(150),
                      ),
                    ),
                  ),
                  Container(
                    margin:scaler.getMarginLTRB(0, 8, 0, 1),
                    padding: scaler.getPadding(0.5,1.5),
                    width: scaler.getWidth(30),
                    height: scaler.getHeight(6),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        config.MyFont.title(context: context,text:res.title,color: Theme.of(context).textTheme.bodyText2.color,maxLines: 1,fontSize: 9),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: config.MyFont.subtitle(context: context,text:"${res.jumlahBarang} produk",color: Theme.of(context).textTheme.bodyText1.color,fontSize: 9),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            config.MyFont.subtitle(context: context,text:"${res.jumlahReview}",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8),

                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
          mainAxisSpacing: 15.0,
          crossAxisSpacing: 15.0,
        ),
        !isLoading&&isLoadMore?CupertinoActivityIndicator():SizedBox()
      ],
    );
  }
}
