import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/list_brand_product_model.dart';
import 'package:netindo_shop/pages/component/brand/brand_component.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class BrandWidget extends StatefulWidget {
  @override
  _BrandWidgetState createState() => _BrandWidgetState();
}

class _BrandWidgetState extends State<BrandWidget> {
  ListBrandProductModel listBrandProductModel;
  bool isLoading=true;
  Future loadData()async{
    final res=await HandleHttp().getProvider("brand?page=1&status=1",listBrandProductModelFromJson,context: context);
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
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;

    return StaggeredGridView.countBuilder(
      primary: false,
      shrinkWrap: true,
      padding: scaler.getPaddingLTRB(2, 1, 2, 0),
      crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
      itemCount: isLoading?10:listBrandProductModel.result.data.length,
      itemBuilder: (BuildContext context, int index) {
        if(isLoading){
          return WidgetHelper().baseLoading(context, Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(0),
                alignment: AlignmentDirectional.topCenter,
                child: WidgetHelper().shimmer(context: context,width: 100,height: 20),
              ),

            ],
          ));
        }
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
                  child: SvgPicture.network(
                    image,
                    color: Theme.of(context).primaryColor,
                    width: scaler.getWidth(16),
                    placeholderBuilder: (context) => Icon(Icons.error),
                  ),
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
                margin:scaler.getMarginLTRB(0, 7, 0, 1),
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
    );
  }
}
