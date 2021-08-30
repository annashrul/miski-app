import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/review/review_model.dart';
import 'package:miski_shop/pages/widget/brand/brand_home_tab_widget.dart';
import 'package:miski_shop/pages/widget/brand/brand_product_tab_widget.dart';
import 'package:miski_shop/pages/widget/review/review_widget.dart';
import 'package:miski_shop/provider/handle_http.dart';
import '../../empty_widget.dart';
import '../../loading_widget.dart';

class ProductByBrand extends StatefulWidget {
  final dynamic data;
  ProductByBrand({this.data});
  @override
  _ProductByBrandState createState() => _ProductByBrandState();
}

class _ProductByBrandState extends State<ProductByBrand> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _tabIndex = 0;
  ReviewModel reviewModel;
  bool isLoading=true;
  Future loadReview()async{
    final res=await HandleHttp().getProvider("review?brand=${widget.data["data"]["id"]}", reviewModelFromJson,context: context);
    // final res=await HandleHttp().getProvider("review?page=1", reviewModelFromJson,context: context);
    if(res!=null){
      ReviewModel result=ReviewModel.fromJson(res.toJson());
      reviewModel=result;
      isLoading=false;
      if(this.mounted){
        this.setState(() {

        });
      }
      print("review ${result.result.toJson()}");
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
    loadReview();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          snap: true,
          floating: true,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(UiIcons.return_icon, color: Theme.of(context).hintColor),
            onPressed: () => Navigator.of(context).pop(),
          ),

          backgroundColor: widget.data["color"],
          expandedHeight: 250,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                        widget.data["color"],
                        Theme.of(context).primaryColor.withOpacity(0.5),
                      ])),
                  child: Center(
                    child: Hero(
                      tag: widget.data["hero"],
                      child:WidgetHelper().baseImage(widget.data["image"],width: scaler.getWidth(23))
                      // child: SvgPicture.network(
                      //
                      //   widget.data["image"],
                      //   // StringConfig.imageProduct,
                      //   color: Theme.of(context).primaryColor,
                      //   width: 130,
                      //   placeholderBuilder: (context) => Icon(Icons.error),
                      // ),
                    ),
                  ),
                ),
                Positioned(
                  right: -60,
                  bottom: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(300),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  top: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(150),
                    ),
                  ),
                )
              ],
            ),
          ),
          bottom: TabBar(
            // indicatorWeight: 0,
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: config.Colors.mainColors,
            labelColor: config.Colors.mainColors,
            unselectedLabelStyle: config.MyFont.textStyle,
            labelStyle:  config.MyFont.textStyle,
            // indicatorColor: config.Colors.mainColors,
            labelPadding: EdgeInsets.symmetric(horizontal: 0),
            tabs: [
              tab(context, "Detail",_tabController.index==0),
              tab(context, "Produk",_tabController.index==1),
              tab(context, "Ulasan",_tabController.index==2),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Offstage(
              offstage: 0 != _tabIndex,
              child: Column(
                children: <Widget>[
                  BrandHomeTabWidget(data: widget.data["data"]),
                ],
              ),
            ),
            Offstage(
              offstage: 1 != _tabIndex,
              child: Column(
                children: <Widget>[
                  Padding(
                    child: BrandProductTabWidget(data: widget.data["data"]),
                    padding: scaler.getPadding(0, 2),
                  )

                ],
              ),
            ),
            Offstage(
              offstage: 2 != _tabIndex,
              child:  isLoading?Container(
                padding: scaler.getPadding(0,2),
                child: LoadingHistory(tot: 10),
              ):reviewModel.result.data.length<1?EmptyTenant():Column(
                children: <Widget>[
                  Container(
                    margin: scaler.getMarginLTRB(2,1,2,1),
                    child: WidgetHelper().titleQ(context,"Ulasan Produk",icon: UiIcons.chat_1),
                  ),
                 ListView.separated(
                    padding: scaler.getPadding(0,2),
                    itemBuilder: (context, index) {
                      final res=reviewModel.result.data[index];
                      return ReviewWidget(
                        id: res.id,
                        idMember: res.idMember,
                        kdBrg: res.kdBrg,
                        nama: res.nama,
                        caption: res.caption,
                        rate: res.rate.toString(),
                        foto: res.foto,
                        time: res.time,
                        createdAt: res.createdAt.toString(),
                        updatedAt: res.updatedAt.toString(),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount:reviewModel.result.data.length,
                    // itemCount:100,
                    primary: false,
                    shrinkWrap: true,
                  )
                  // ReviewsListWidget()
                ],
              ),
            )
          ]),
        )
      ]),
    );
  }


  Widget tab(BuildContext context,String label,bool isActive){
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: Theme.of(context).primaryColor.withOpacity(0.09)
        ),
        child: Align(
          alignment: Alignment.center,
          child: config.MyFont.title(context: context,text:label,color: Theme.of(context).textTheme.bodyText1.color),
        ),
      ),
    );
  }
}
