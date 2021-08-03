import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/detail_cart_model.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/pages/widget/product/detail/bottom_bar_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/detail/tab_detail_product_widget.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';

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
  int _tabIndex = 0,qty=0,hargaFinish=0,hargaUkuran=0,hargaWarna=0,totalCart=0,total=0;
  String idVarian="",idSubVarian="",hargaMaster="0";
  bool isLoadingDetail=true;
  Future loadDetail()async{
    final res = await HandleHttp().getProvider("barang/${widget.data["id"]}", detailProductTenantModelFromJson,context: context);
    if(res!=null){
      DetailProductTenantModel result=DetailProductTenantModel.fromJson(res.toJson());
      if(int.parse(result.result.disc1)>0){
        setState(() {
          result.result.harga = FunctionHelper().double_diskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']).toString();
          hargaFinish = FunctionHelper().double_diskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']);
          hargaMaster = FunctionHelper().double_diskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']).toString();
        });
      }
      hargaMaster = result.result.harga;
      hargaFinish = int.parse(result.result.harga);
      isLoadingDetail=false;
      detail = result;
      getCountCart();
      if(this.mounted) setState(() {});
    }
  }
  Future handleCart()async{
    final res = detail.result;
    if(int.parse(res.stock)<1){
      WidgetHelper().showFloatingFlushbar(context,"failed","maaf stock barang kosong");
      return;
    }
    else{
      if(this.mounted) setState(() {qty+=1;});
      checkingPrice(
        res.idTenant,
        widget.data["id"],
        res.kode,
        idVarian,
        idSubVarian,
        qty,
        res.harga,
        res.disc1,
        res.disc2,
        res.hargaBertingkat.length>0?true:false,
        hargaMaster,
        hargaWarna,
        hargaUkuran
      );
    }
  }
  Future checkingPrice(idTenant,id,kode,idVarian,idSubVarian,qty,price,disc1,disc2,bool isTrue,hargaMaster, hargaVarian, hargaSubVarian)async{
    WidgetHelper().loadingDialog(context,title: 'pengecekan harga bertingkat');
    var res = await FunctionHelper().checkingPriceComplex(idTenant, id, kode, idVarian, idSubVarian, qty.toString(), price.toString(), disc1.toString(), disc2.toString(), isTrue, hargaMaster.toString(), hargaVarian.toString(), hargaSubVarian.toString());
    Navigator.pop(context);
    int hrg = 0;
    res.forEach((element) {hrg = int.parse(element['harga']);});
    getSubTotal();
    final resCart = await BaseProvider().getCart(idTenant);
    if(this.mounted){
      setState(() {
        detail.result.harga = hrg.toString();
        hargaFinish = hrg;
        totalCart = resCart.result.length;
      });
    }
  }
  Future getSubTotal()async{
    await getQty();
    if(this.mounted) setState(() {total = qty>1?qty*(hargaFinish+hargaWarna+hargaUkuran):hargaFinish+hargaWarna+hargaUkuran;});
  }
  Future getQty()async{
    var res = await HandleHttp().getProvider('cart/detail/${detail.result.idTenant}/${widget.data["id"]}', detailCartModelFromJson,context: context);
    if(res is DetailCartModel){
      DetailCartModel result = res;
      if(this.mounted) setState(() {qty = int.parse(result.result.qty);});
    }
  }
  Future getCountCart() async{
    final res = await BaseProvider().getCart(detail.result.idTenant);
    print(res.result.length);
    if(this.mounted) setState(() {totalCart = res.result.length;});
    getSubTotal();
  }
  @override
  void initState() {
    _tabController = TabController(length: 3, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    loadDetail();
    super.initState();
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
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomBarDetailProductWidget(callback: (){
        handleCart();
      }),
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(AntDesign.back, color: Theme.of(context).hintColor),
            onPressed: () => Navigator.of(context).pop()
          ),
          actions: <Widget>[
            WidgetHelper().iconAppBarBadges(context: context,icon:FlutterIcons.cart_outline_mco,isActive:true,callback: (){
              Navigator.of(context).pushNamed('/${StringConfig.cart}').whenComplete((){
                getCountCart();
              });
            }),
            Container(
              padding: scaler.getPaddingLTRB(0,0,2,0),
              alignment: Alignment.center,
                child: WidgetHelper().myRipple(
                  isRadius: true,
                  radius: 300,
                  callback: () {
                    Navigator.of(context).pushNamed('/${StringConfig.cart}');
                  },
                  child:Container(
                    height: scaler.getHeight(2),
                    width: scaler.getWidth(5),
                    child:  CircleAvatar(
                      backgroundImage: AssetImage('assets/img/user2.jpg'),
                    ),
                  ),
                )),
          ],
          backgroundColor: Theme.of(context).primaryColor,
          expandedHeight: 350,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Hero(
              tag:widget.data["heroTag"] + widget.data["id"],
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
                Tab(child: buttonTabs(context: context,title: "Product")),
                Tab(child: buttonTabs(context: context,title: "Detail")),
                Tab(child: buttonTabs(context: context,title: "Review")),
              ]),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Offstage(
              offstage: 0 != _tabIndex,
              child: Column(
                children: <Widget>[
                  TabProductWidget(detailProductTenantModel: detail,isLoading: isLoadingDetail)
                ],
              ),
            ),
            Offstage(
              offstage: 1 != _tabIndex,
              child: Column(
                children: <Widget>[
                  // ProductDetailsTabWidget(
                  //   product: widget._product,
                  // )
                ],
              ),
            ),
            Offstage(
              offstage: 2 != _tabIndex,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: scaler.getPadding(1,2),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(
                        FlutterIcons.star_box_outline_mco,
                        color: Theme.of(context).hintColor,
                      ),
                      title:config.MyFont.title(context: context,text:"Product reviews")
                    ),
                  ),
                  // ReviewsListWidget()
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
