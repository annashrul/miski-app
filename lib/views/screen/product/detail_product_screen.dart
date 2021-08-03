import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/detail_cart_model.dart';
import 'package:netindo_shop/model/review/review_model.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/second_product_widget.dart';
import 'package:netindo_shop/views/widget/review_widget.dart';

class DetailProducrScreen extends StatefulWidget {
  final String id;
  DetailProducrScreen({this.id});
  @override
  _DetailProducrScreenState createState() => _DetailProducrScreenState();
}

class _DetailProducrScreenState extends State<DetailProducrScreen> with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Scaffold(
      backgroundColor: Colors.white,
    );
  }




}

class ModalReview extends StatefulWidget {
  String kode;
  String title;
  bool site;

  ModalReview({this.kode,this.title,this.site});
  @override
  _ModalReviewState createState() => _ModalReviewState();
}

class _ModalReviewState extends State<ModalReview> {
  ReviewModel reviewModel;
  ScrollController controller;
  bool isLoadmore=false,isLoading=false;
  int perpage=10,total=0;
  Future getReview()async{
    print(widget.kode);
    print("review?page=1&perpage=$perpage&kd_brg=${widget.kode}");
    final res = await BaseProvider().getProvider("review?page=1&perpage=$perpage&kd_brg=${widget.kode}", reviewModelFromJson);
    if(res is ReviewModel){
      setState(() {
        reviewModel = ReviewModel.fromJson(res.toJson());
        total = res.result.total;
        isLoading=false;
        isLoadmore=false;
      });

    }
  }
  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if(perpage<total){
        setState((){
          isLoadmore=true;
          perpage+=10;
        });
        getReview();
      }
      else{
        print('else');
      }

    }
  }
  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    getReview();
    controller = new ScrollController()..addListener(_scrollListener);
  }
  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        isLoading?Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WidgetHelper().loadingWidget(context)
            ],
          ),
        ):reviewModel.result.data.length>0?Container(
          height: MediaQuery.of(context).size.height/1,
          child: ListView.separated(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemBuilder: (context, index) {
              return WidgetHelper().myPress((){},ReviewWidget(
                foto: SiteConfig().noImage,
                nama: reviewModel.result.data[index].nama,
                tgl: "Sebulan yang lalu ${index+1}",
                rate: reviewModel.result.data[index].rate.toString(),
                desc: reviewModel.result.data[index].caption,
              ));
            },
            separatorBuilder: (context, index) {
              return Divider(
                height: 10,
              );
            },
            itemCount:reviewModel.result.data.length,
            shrinkWrap: true,
            primary: false,
          ),
        ):EmptyTenant(),
        isLoadmore?Padding(
          padding: EdgeInsets.all(10.0),
          child: WidgetHelper().loadingWidget(context),
        ):Text('')

      ],
    );


  }
}

