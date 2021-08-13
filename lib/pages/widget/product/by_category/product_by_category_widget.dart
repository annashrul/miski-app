import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/home/function_home.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/pages/widget/category_product_tab_widget.dart';
import '../../empty_widget.dart';
import '../../loading_widget.dart';

import '../../searchbar_widget.dart';

class ProductByCategory extends StatefulWidget {
  final dynamic data;
  ProductByCategory({this.data});
  @override
  _ProductByCategoryState createState() => _ProductByCategoryState();
}

class _ProductByCategoryState extends State<ProductByCategory> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _handleTabSelection() {
    if (_tabController.indexIsChanging) {

      setState(() {
        widget.data["index"] = _tabController.index;
        isLoadingProduct=true;
        // widget.routeArgument.id = _tabController.index;
      });
      loadProduct(widget.data["kelompok"][_tabController.index]["title"]);

    }
  }
  String any="";
  ListProductTenantModel listProductTenantModel;
  bool isLoadingProduct=true;
  Future loadProduct(id)async{
    String where="&kelompok=$id";
    if(any!="")where+="&q=$any";
    final res = await FunctionHome().loadProduct(context: context,where: where);
    listProductTenantModel=res;
    isLoadingProduct=false;
    if(this.mounted){this.setState(() {});}

  }

  @override
  void initState() {
    _tabController = TabController(length: widget.data["kelompok"].length, initialIndex: widget.data["index"], vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
    loadProduct(widget.data["kelompok"][widget.data["index"]]["title"]);
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;

    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          // snap: true,
          floating: true,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(UiIcons.return_icon, color: Theme.of(context).primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
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
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
                      ],
                      gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                        Theme.of(context).accentColor,
                        Theme.of(context).focusColor,
                      ])),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                        tag: "categoryImage${widget.data["id"]}",
                        child: SvgPicture.network(
                          widget.data["image"],height: scaler.getHeight(2.5),
                          placeholderBuilder: (context) => Icon(Icons.error),
                        ),
                      ),

                      SizedBox(height: 5),
                      Text(
                        widget.data["title"],
                        style:
                        Theme.of(context).textTheme.headline1.merge(TextStyle(color: Theme.of(context).primaryColor)),
                      )
                    ],
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
            controller: _tabController,
            indicatorWeight: 5,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Theme.of(context).primaryColor.withOpacity(0.6),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelStyle: config.MyFont.textStyle.copyWith(fontWeight: FontWeight.bold,fontSize: scaler.getTextSize(10)),
            isScrollable: true,
            indicatorColor: Theme.of(context).primaryColor,
            labelStyle: config.MyFont.textStyle.copyWith(fontWeight: FontWeight.bold,fontSize: scaler.getTextSize(10)),
            tabs: List.generate(widget.data["kelompok"].length, (index) {
              return Tab(text: widget.data["kelompok"][index]["title"]);
            }),
          ),
        ),
        SliverToBoxAdapter(
          child:  Column(
            children: [
              Padding(
                padding: scaler.getPadding(1,2),
                child: SearchBarWidget(callback: (e){
                  this.setState(() {
                    isLoadingProduct=true;
                    any=e;
                  });
                  loadProduct(widget.data["kelompok"][widget.data["index"]]["title"]);
                }),
              ),
              isLoadingProduct?Padding(
                padding: scaler.getPadding(0,2),
                child: LoadingProductTenant(tot: 10,),
              ):listProductTenantModel.result.data.length<1?EmptyTenant():CategoryProductTabWidget(
                  listProductTenantModel: listProductTenantModel,
                  category:widget.data["kelompok"][widget.data["index"]]
              )
            ],
          )
        ),
      ]),
    );
  }
}
