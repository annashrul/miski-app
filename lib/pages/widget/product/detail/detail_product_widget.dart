import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/detail/function_detail.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:miski_shop/pages/widget/product/detail/bottom_bar_detail_product_widget.dart';
import 'package:miski_shop/pages/widget/product/detail/tab_detail_product_widget.dart';
import 'package:miski_shop/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class DetailProductWidget extends StatefulWidget {
  final dynamic data;
  DetailProductWidget({@required this.data,Key key}) : super(key: key);
  @override
  _DetailProductWidgetState createState() => _DetailProductWidgetState();
}

class _DetailProductWidgetState extends State<DetailProductWidget> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DetailProductTenantModel detail;
  int _tabIndex = 0,qty=0,hargaFinish=0,hargaVarian=0,hargaSubVarian=0,totalCart=0,total=0,harga=0;
  String imageUser="",idVarian="",idSubVarian="",hargaMaster="0";
  bool isLoadingDetail=true,isFavorite=false;
  dynamic dataDetail;
  Future loadDetail()async{
    final funcData = await FunctionDetail().loadDetail(context: context,idProduct:widget.data["id"]);
    dataDetail = funcData["data"];
    harga = int.parse(funcData["data"]["harga"]);
    hargaMaster=funcData["data"]["harga_master"];
    hargaFinish=funcData["data"]["harga_finish"];
    isFavorite = await FunctionDetail().handleFavorite(context: context,data: dataDetail,method: "get");
    isLoadingDetail=false;
    if(this.mounted) setState(() {});
  }


  Future handleFavorite()async{
    final res = await FunctionDetail().handleFavorite(context: context,data: dataDetail);
    if(this.mounted){
      setState(() {
        isFavorite=res;
      });
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    loadDetail();
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.getDetail(context, widget.data["id"]);
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
    final scaler = config.ScreenScale(context).scaler;
    final cart = Provider.of<CartProvider>(context);
    qty = cart.qtyPerProduct;
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomBarDetailProductWidget(callback: (res){
        if(res=="cart"){
          if(int.parse(dataDetail["stock"])>0){
            qty++;
            dynamic data = dataDetail;
            data["qty"] = qty;
            data["id_varian"] = idVarian;
            data["id_sub_varian"] = idSubVarian;
            data["harga_finish"] =hargaFinish;
            data["harga_master"] =hargaMaster;
            data["harga_varian"] =hargaVarian;
            data["harga_sub_varian"] = hargaSubVarian;
            cart.storeCart(context,data);
          }else{
            WidgetHelper().showFloatingFlushbar(context, "failed","stok tidak tersedia");
          }
        }else{
          handleFavorite();
        }
      },isFavorite: isFavorite,),
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          leading: new IconButton(
              icon: new Icon(UiIcons.return_icon, color: Theme.of(context).hintColor),
              onPressed: () => Navigator.of(context).pop()
          ),
          actions: <Widget>[
            WidgetHelper().iconAppBarBadges(context: context,icon:UiIcons.shopping_cart,isActive:cart.isActiveCart,callback: (){
              if(cart.isActiveCart){
                Navigator.of(context).pushNamed("/${StringConfig.cart}").whenComplete((){
                  cart.isActiveCart = cart.isActiveCart;
                  cart.getDetail(context, widget.data["id"]);
                });
              }
              else{
                WidgetHelper().showFloatingFlushbar(context,"failed", "maaf keranjang kamu kosong");
              }
            }),
          ],
          backgroundColor: Theme.of(context).primaryColor,
          expandedHeight: scaler.getHeight(35),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Hero(
              tag: widget.data["heroTag"] + widget.data["id"] ,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image:NetworkImage(widget.data["image"]),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                          Theme.of(context).primaryColor,
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0),
                          Theme.of(context).scaffoldBackgroundColor
                        ], stops: [
                          0,
                          0.4,
                          0.6,
                          1
                        ])),
                  ),
                ],
              ),
            ),
          ),
          bottom: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              unselectedLabelColor:config.Colors.mainColors,
              labelColor: Theme.of(context).primaryColor,
              indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).accentColor),
              tabs: [
                Tab(child: buttonTabs(context: context,title: "Produk")),
                Tab(child: buttonTabs(context: context,title: "Deskripsi")),
                Tab(child: buttonTabs(context: context,title: "Ulasan")),
              ]),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Offstage(
              offstage: 0 != _tabIndex,
              child: Column(
                children: <Widget>[
                  TabProductWidget(id:widget.data["id"],data: dataDetail,isLoading: isLoadingDetail,callbackVarian: (data){
                    hargaVarian=int.parse(data["VARIAN"]["harga"]);
                    idVarian=data["VARIAN"]["id"];
                    if(data["SUBVARIAN"]!=null){
                      hargaSubVarian=int.parse(data["SUBVARIAN"]["harga"]);
                      idSubVarian=data["SUBVARIAN"]["id"];
                    }
                    this.setState(() {});
                    // print("data VARIAN ${data["VARIAN"]}");
                    // print("data SUBVARIAN ${data["SUBVARIAN"]}");
                  }),
                ],
              ),
            ),
            Offstage(
              offstage: 1 != _tabIndex,
              child: Column(
                children: <Widget>[
                  if(!isLoadingDetail)TabDescProductWidget(data: dataDetail,isLoading: isLoadingDetail)
                ],
              ),
            ),
            Offstage(
              offstage: 2 != _tabIndex,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: scaler.getMarginLTRB(2,1,2,1),
                    child: WidgetHelper().titleQ(context,"Ulasan Produk",icon: UiIcons.chat_1),
                  ),
                  TabReviewProductWidget(data:dataDetail,isLoading: isLoadingDetail,)
                ],
              ),
            )
          ]),
        )
      ]),
    );
  }


  Widget buttonTabs({BuildContext context,String title}){
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Theme.of(context).accentColor.withOpacity(0.2), width: 1)),
      child: Align(
          alignment: Alignment.center,
          child:Text(
              title,
              style: config.MyFont.textStyle.copyWith(fontSize: scaler.getTextSize(11))
          )
      ),
    );
  }
}
