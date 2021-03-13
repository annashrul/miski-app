import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final DatabaseConfig _helper = new DatabaseConfig();
  DetailProductTenantModel detailProductTenantModel;
  ReviewModel reviewModel;
  ListProductTenantModel productTenantModel;
  List hargaBertingkat=[], varian=[], subVarian=[], review=[];
  bool isLoadmore=false,isError=false,isLoading=false,isLoadingReview=false,isLoadingPoductOther=false,isSelectedFavorite=false,isSubVarian=false;
  int perpageReview=10,_current=0,totalReview=0,totalCart=0,total=0,stock=0,qty=0,hargaFinish=0,hargaWarna=0,hargaUkuran=0,diskon1=0,diskon2=0;
  int selectedVarian=0,selectedSubVarian=0;
  String stockSales='',title,kode,harga,hargaMaster,hargaCoret,rating,deskripsi,idTenant,warna,ukuran,gambar,kelompok,idVarian,idSubVarian;

  Future getDetail()async{
    var res = await BaseProvider().getProvider("barang/${widget.id}", detailProductTenantModelFromJson);
    // print(res);
    if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
      setState(() {
        isLoading=false;isError=true;
      });
    }
    else{
      if(res is DetailProductTenantModel){
        DetailProductTenantModel result = res;
        if(int.parse(result.result.disc1)>0){
          setState(() {
            harga = FunctionHelper().double_diskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']).toString();
            hargaFinish = FunctionHelper().double_diskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']);
            hargaMaster = FunctionHelper().double_diskon(result.result.harga, ['${result.result.disc1.toString()}','${result.result.disc2.toString()}']).toString();
          });
        }
        else{
          setState(() {
            harga = result.result.harga;
            hargaMaster = result.result.harga;
            hargaFinish=int.parse(result.result.harga);
          });
        }
        setState(() {
          detailProductTenantModel = DetailProductTenantModel.fromJson(result.toJson());
          idTenant = result.result.idTenant;
          stockSales=result.result.stockSales;
          kode = result.result.kode;
          deskripsi = result.result.deskripsi;
          varian = result.result.varian;
          hargaBertingkat=result.result.hargaBertingkat;
          review=result.result.review;
          title = result.result.title;
          gambar = result.result.gambar;
          hargaCoret = result.result.hargaCoret;
          rating = result.result.rating.toString();
          stock = int.parse(result.result.stock);
          diskon1 = int.parse(result.result.disc1);
          diskon2 = int.parse(result.result.disc2);
          kelompok = res.result.idKelompok;
        });
        if(varian.length>0){
          print("VARIAN ${varian[0].id}");
          print("SUB VARIAN ${subVarian.length}");
          getVarian(0);
          idVarian = varian[0].id;
          if(subVarian.length>0){
            idSubVarian = subVarian[0].id;
          }
          setState(() {});
        }
        getCountCart();
        getReleatedProduct();
        getReview();
        // loadReleatedProduct();
        // loadReview();
        // getFavorite();
        // getSubTotal();
        getFavorite();

      }
      setState(() {
        isLoading=false;
        isError=false;
      });
    }
  }
  Future checkingPrice(idTenant,id,kode,idVarian,idSubVarian,qty,price,disc1,disc2,bool isTrue,hargaMaster, hargaVarian, hargaSubVarian)async{
    WidgetHelper().loadingDialog(context,title: 'pengecekan harga bertingkat');
    var res = await FunctionHelper().checkingPriceComplex(idTenant, id, kode, idVarian, idSubVarian, qty.toString(), price.toString(), disc1.toString(), disc2.toString(), isTrue, hargaMaster.toString(), hargaVarian.toString(), hargaSubVarian.toString());
    print('ceking ${res}');
    Navigator.pop(context);
    int hrg = 0;
    res.forEach((element) {
      setState(() {
        hrg = int.parse(element['harga']);
        // harga = element['harga'];
      });
    });
    setState(() {
      harga = hrg.toString();
      hargaFinish = hrg;
    });
    getSubTotal();
    final resCart = await BaseProvider().getCart(idTenant);
    setState(() {
      totalCart = resCart.result.length;
    });
  }
  Future getSubTotal()async{
    await getQty();
    setState(() {
      total = qty>1?qty*(hargaFinish+hargaWarna+hargaUkuran):hargaFinish+hargaWarna+hargaUkuran;
    });
    print("TOTAL $total");

  }
  Future getCountCart() async{
    // checkingPrice(idTenant, widget.id, kode, idVarian, idSubVarian, qty, harga, diskon1, diskon2, hargaBertingkat.length>0?true:false, hargaMaster, hargaWarna, hargaUkuran);
    final res = await BaseProvider().getCart(idTenant);
    setState(() {
      totalCart = res.result.length;
    });
    getSubTotal();
    print("total cart ${res.result.length}");
  }
  Future getQty()async{
    var res = await BaseProvider().getProvider('cart/detail/$idTenant/${widget.id}', detailCartModelFromJson);
    if(res is DetailCartModel){
      DetailCartModel result = res;
      setState(() {
        qty = int.parse(result.result.qty);
      });
      print(result.result.qty);
    }
  }
  void getVarian(int idx){
    setState(() {
      warna = varian[idx].title;
      selectedVarian = idx;
    });
    if(varian[idx].subVarian.length>0){
      setState(() {
        subVarian=varian[idx].subVarian;
        isSubVarian=true;
        hargaWarna = int.parse(varian[idx].harga);
      });
    }
    else{
      setState(() {
        isSubVarian=false;
        hargaUkuran = 0;
        ukuran = '-';
        if(subVarian.length>0)getSubVarian(0);
      });
    }
  }
  void getSubVarian(idx){
    setState(() {
      selectedSubVarian = idx;
      hargaUkuran = int.parse(subVarian[idx].harga);
      ukuran = subVarian[idx].title;
    });
    getSubTotal();
  }
  void add()async{
    if(stock<1){
      WidgetHelper().showFloatingFlushbar(context,"failed","maaf stock barang kosong");
    }
    else{
      setState(() {
        qty+=1;
      });
      checkingPrice(idTenant, widget.id, kode, idVarian, idSubVarian, qty, harga, diskon1, diskon2, hargaBertingkat.length>0?true:false, hargaMaster, hargaWarna, hargaUkuran);
    }

  }
  Future getReleatedProduct()async{
    final res = await BaseProvider().getProvider("barang?id_tenant=$idTenant&kelompok=$kelompok&id_brg=${widget.id}", listProductTenantModelFromJson);
    if(res is ListProductTenantModel){
      setState(() {
        productTenantModel = ListProductTenantModel.fromJson(res.toJson());
        isLoadingPoductOther=false;
      });
    }

  }
  Future getReview()async{
    print("review?page=1&perpage=$perpageReview&kd_brg=$kode");
    final res = await BaseProvider().getProvider("review?page=1&perpage=$perpageReview&kd_brg=$kode", reviewModelFromJson);
    if(res is ReviewModel){
      setState(() {
        reviewModel = ReviewModel.fromJson(res.toJson());
        isLoadingReview=false;
        isLoadmore=false;
      });

    }
  }
  Future insertFavorite()async{
    final getWhere = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME, idTenant,'id_product','${widget.id}');
    getWhere.forEach((element)async {
      if(element['is_favorite']=='true'){
        await _helper.updateData(ProductQuery.TABLE_NAME,"is_favorite","false", idTenant, widget.id);
        setState(() {
          isSelectedFavorite=false;
        });
      }
      else{
        await _helper.updateData(ProductQuery.TABLE_NAME,"is_favorite","true", idTenant, widget.id);
        setState(() {
          isSelectedFavorite=true;
        });
      }
    });
  }
  Future getFavorite()async{
    final getWhere = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME, idTenant,'id_product','${widget.id}');
    getWhere.forEach((element) {
      if(element['is_favorite']=="true"){
        setState(() {
          isSelectedFavorite=true;
        });
      }
      else{
        setState(() {
          isSelectedFavorite=false;
        });
      }
    });
  }
  Future insertClickProduct()async{
    await FunctionHelper().storeClickProduct(widget.id);
  }
  ScrollController controller;
  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {

      if(perpageReview<reviewModel.result.total){
        setState((){
          isLoadmore=true;
          perpageReview = perpageReview+6;
        });
        getReview();
        print("LOADING $isLoadmore");
      }
      else{
        print('else');
      }

    }
  }
  int maxLengthDesc=2;
  int _tabIndex = 0;
  TabController _tabController;
  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }
  @override
  void dispose() {
    controller.removeListener(_scrollListener);

    _tabController.dispose();

    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    insertClickProduct();
    isLoading=true;
    isLoadingPoductOther=true;
    isLoadingReview=true;
    getDetail();
    controller = new ScrollController()..addListener(_scrollListener);

  }
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: isLoading||isLoadingPoductOther||isLoadingReview?LoadingDetailProduct():buildContent(context),
      bottomNavigationBar: isLoading||isLoadingPoductOther||isLoadingReview?Text(''):Container(
        padding:scaler.getPadding(1,5),
        decoration: BoxDecoration(
          // color: site?SiteConfig().darkMode:Colors.grey[200],
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, -2)),],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                  onPressed: () {},
                  padding:scaler.getPadding(1,0),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child:WidgetHelper().textQ(FunctionHelper().formatter.format(total),scaler.getTextSize(10), Colors.white, FontWeight.bold)
                  // child:Text("abus")
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: FlatButton(
                  onPressed: () {add();},
                  padding:scaler.getPadding(1,0),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child:WidgetHelper().textQ("Keranjang", scaler.getTextSize(10), SiteConfig().secondDarkColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            onStretchTrigger: (){
              return;
            },
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            snap: false,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: new IconButton(
              icon: new Icon(AntDesign.back, color:SiteConfig().secondColor),
              onPressed: () => Navigator.pop(context,false),
            ),
            actions: <Widget>[
              new CartWidget(
                iconColor:SiteConfig().secondColor,
                labelColor: totalCart>0?Colors.redAccent:Colors.transparent,
                labelCount: totalCart,
                callback: (){
                  if(totalCart>0){
                    WidgetHelper().myPushAndLoad(context,CartScreen(idTenant: idTenant),(){getCountCart();});
                  }
                },
              ),
              Container(
                  width: scaler.getWidth(5),
                  height: 30,
                  margin: EdgeInsets.only(top: 12.5, bottom: 12.5, right:  scaler.getHeight(2)),
                  child: InkWell(
                    focusColor: SiteConfig().darkMode,
                    borderRadius: BorderRadius.circular(300),
                    onTap: () {
                      insertFavorite();
                      // Navigator.of(context).pushNamed('/Tabs', arguments: 1);
                    },
                    child: Icon(AntDesign.hearto,size:  scaler.getTextSize(15),color: isSelectedFavorite?Colors.red:SiteConfig().secondColor),
                  )
              ),
            ],
            // backgroundColor: Theme.of(context).primaryColor,
            expandedHeight:scaler.getHeight(30),
            elevation: 0,
            flexibleSpace: sliderQ(context),
            bottom: TabBar(
              indicatorWeight: 0.0,
                indicatorPadding:  EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                unselectedLabelColor: Colors.white,
                labelColor: Colors.white,
                indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color:SiteConfig().secondColor),
                tabs: [
                  Tab(
                    iconMargin:  EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color:SiteConfig().secondColor, width: 1)
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: WidgetHelper().textQ("Produk",scaler.getTextSize(9),Colors.grey,FontWeight.bold),
                      ),
                    ),
                  ),
                  Tab(
                    iconMargin:  EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: SiteConfig().secondColor, width: 1)),
                      child: Align(
                        alignment: Alignment.center,
                        child: WidgetHelper().textQ("Detail",scaler.getTextSize(9),Colors.grey,FontWeight.bold),
                      ),
                    ),
                  ),
                  Tab(
                    iconMargin:  EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color:SiteConfig().secondColor, width: 1)),
                      child: Align(
                        alignment: Alignment.center,
                        child: WidgetHelper().textQ("Ulasan",scaler.getTextSize(9),Colors.grey,FontWeight.bold),
                      ),
                    ),
                  ),
                ]
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Offstage(
                offstage: 0 != _tabIndex,
                child: Container(
                  decoration: BoxDecoration(
                    // color: site?SiteConfig().darkMode:Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding:scaler.getPadding(1,2),
                        child: Row(
                          children: [
                            Expanded(
                              child: WidgetHelper().textQ(title,scaler.getTextSize(9),SiteConfig().darkMode,FontWeight.normal,maxLines: title.length),
                            ),
                            SizedBox(width: 5.0),
                            diskon1>0?Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Theme.of(context).accentColor),
                              alignment: AlignmentDirectional.topEnd,
                              child: WidgetHelper().textQ('$diskon1 + $diskon2 %', scaler.getTextSize(9),Colors.white,FontWeight.bold),
                            ):Container()
                          ],
                        ),
                      ),
                      Padding(
                        padding:scaler.getPadding(0,2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                WidgetHelper().textQ(FunctionHelper().formatter.format(int.parse(harga)),scaler.getTextSize(9),SiteConfig().mainColor,FontWeight.bold),
                                SizedBox(width: 5.0),
                                WidgetHelper().textQ(FunctionHelper().formatter.format(int.parse(hargaCoret)),scaler.getTextSize(9),SiteConfig().accentDarkColor,FontWeight.bold,textDecoration: TextDecoration.lineThrough),
                              ],
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  RatingBar.builder(
                                    itemSize: 15.0,
                                    initialRating: double.parse(rating),
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    unratedColor: SiteConfig().secondColor,
                                    itemPadding: EdgeInsets.only(right: 0.0),
                                    itemBuilder: (context, index) {
                                      switch (index) {
                                        case 0:
                                          return Icon(
                                            Icons.sentiment_very_dissatisfied,
                                            color: Colors.red,
                                          );
                                        case 1:
                                          return Icon(
                                            Icons.sentiment_dissatisfied,
                                            color: Colors.redAccent,
                                          );
                                        case 2:
                                          return Icon(
                                            Icons.sentiment_neutral,
                                            color: Colors.amber,
                                          );
                                        case 3:
                                          return Icon(
                                            Icons.sentiment_satisfied,
                                            color: Colors.lightGreen,
                                          );
                                        case 4:
                                          return Icon(
                                            Icons.sentiment_very_satisfied,
                                            color: Colors.green,
                                          );
                                        default:
                                          return Container();
                                      }
                                    },
                                    onRatingUpdate:null,
                                  ),
                                  if(int.parse(stockSales)>0)  WidgetHelper().textQ(stockSales+" terjual",12,SiteConfig().darkMode,FontWeight.normal,maxLines: title.length),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),

                      varian.length>0?Padding(
                        padding:scaler.getPadding(0,2),
                        child: ListTile(
                          dense: true,
                          contentPadding:scaler.getPadding(0,0),
                          leading: Icon(
                            FontAwesome.object_group,
                            color: Theme.of(context).hintColor,
                          ),
                          title: WidgetHelper().textQ("Varian", scaler.getTextSize(10),SiteConfig().secondColor, FontWeight.bold),
                        ),
                      ):Container(),
                      varian.length>0?Container(
                        width: double.infinity,
                        padding:scaler.getPadding(0,2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 1,
                              runSpacing: 0,
                              children: List.generate(varian.length, (index) {
                                return SizedBox(
                                  child: FilterChip(
                                    label: WidgetHelper().textQ(varian[index].title,  scaler.getTextSize(8), selectedVarian==index?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
                                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                    backgroundColor: selectedVarian==index?SiteConfig().mainColor:Colors.grey[200],
                                    selectedColor: SiteConfig().mainColor,
                                    // selected:  selectedVarian==index?true:false,
                                    shape: StadiumBorder(),
                                    onSelected: (bool value) {
                                      setState(() {
                                        idVarian = varian[index].id;
                                      });
                                      getVarian(index);
                                    },
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height:isSubVarian==true?scaler.getHeight(0):0),
                            isSubVarian==true?Wrap(
                              spacing: 1,
                              runSpacing: 0,
                              children: List.generate(subVarian.length, (index) {
                                return SizedBox(
                                  child: FilterChip(

                                    label: WidgetHelper().textQ(subVarian[index].title, scaler.getTextSize(8), selectedSubVarian==index?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
                                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                    backgroundColor: selectedSubVarian==index?SiteConfig().mainColor:Colors.grey[200],
                                    selectedColor: SiteConfig().mainColor,
                                    // selected:selectedSubVarian==index?true: false,
                                    shape: StadiumBorder(),
                                    onSelected: (bool value) {
                                      setState(() {
                                        idSubVarian = subVarian[index].id;
                                      });
                                      getSubVarian(index);
                                    },
                                  ),
                                );
                              }),
                            ):Container()
                          ],
                        ),
                      ):Container(),

                      Padding(
                        padding:scaler.getPadding(0,2),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            FontAwesome.product_hunt,
                            color: Theme.of(context).hintColor,
                          ),
                          title: WidgetHelper().textQ("Produk Terkait", scaler.getTextSize(10), SiteConfig().secondColor, FontWeight.bold),
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height/3,
                          margin: EdgeInsets.only(top: 10),
                          child: isLoadingPoductOther?Container():productTenantModel.result.data.length<1?EmptyTenant():ListView.builder(
                            itemCount: productTenantModel.result.data.length,
                            itemBuilder: (context, index) {
                              return  SecondProductWidget(
                                id: productTenantModel.result.data[index].id,
                                gambar: productTenantModel.result.data[index].gambar,
                                title: productTenantModel.result.data[index].title,
                                harga: productTenantModel.result.data[index].harga,
                                hargaCoret: productTenantModel.result.data[index].hargaCoret,
                                rating: productTenantModel.result.data[index].rating.toString(),
                                stock: productTenantModel.result.data[index].stock.toString(),
                                stockSales: productTenantModel.result.data[index].stockSales.toString(),
                                disc1: productTenantModel.result.data[index].disc1.toString(),
                                disc2: productTenantModel.result.data[index].disc2.toString(),
                                countCart: getCountCart,
                              );
                            },
                            scrollDirection: Axis.horizontal,
                          )
                      ),
                    ],
                  ),
                ),
              ),
              Offstage(
                offstage: 1 != _tabIndex,
                child: Container(
                  // padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      WidgetHelper().titleQ(context,"Deskripsi",param: '',color:SiteConfig().secondColor,icon: Icon(AntDesign.file1,color: SiteConfig().secondColor),padding: EdgeInsets.only(left:10,right:10)),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: WidgetHelper().textQ(deskripsi, 12, SiteConfig().darkMode, FontWeight.normal,maxLines: 10000),
                      ),
                      if(hargaBertingkat.length>0) WidgetHelper().titleQ(context,"Harga Spesial",param: '',color:SiteConfig().secondColor,icon: Icon(FontAwesome.money,color:SiteConfig().secondColor,),padding: EdgeInsets.only(left:10,right:10)),
                      if(hargaBertingkat.length>0) Padding(
                        padding: EdgeInsets.all(10.0),
                        child: hargaGrosir(context)
                      ),
                    ],
                  ),
                ),
              ),
              Offstage(
                  offstage: 2 != _tabIndex,
                  child: Column(
                    children: [
                      isLoadmore?WidgetHelper().loadingWidget(context):Text(''),
                      Container(
                        padding: EdgeInsets.only(bottom:10.0),
                        height: MediaQuery.of(context).size.height/1,
                        child: isLoadingReview?Text(''):reviewModel.result.data.length>0?reviewContent(context):EmptyTenant(),
                      ),
                      // Expanded(
                      //   child: Text("loading ......"),
                      // )
                    ],
                  ),
                )
            ]),
          )
        ]
    );
  }
  Widget sliderQ(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);

    return FlexibleSpaceBar(
      stretchModes: [
        StretchMode.zoomBackground,
        StretchMode.blurBackground,
        StretchMode.fadeTitle
      ],

      collapseMode: CollapseMode.parallax,
      background: detailProductTenantModel.result.listImage.length>1?Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1.0,
                height: scaler.getHeight(30),
                onPageChanged: (index,reason) {
                  print(index);
                  setState(() {
                    _current=index;
                  });
                },
              ),
              items:detailProductTenantModel.result.listImage.map((e){
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 30),

                      // margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      height: scaler.getHeight(30),
                      child:CachedNetworkImage(
                        imageUrl:e.image,
                        width: double.infinity ,
                        fit:BoxFit.fill,
                        // height: 110.0,
                        placeholder: (context, url) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
                        errorWidget: (context, url, error) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),

                      ),
                    );
                  },
                );
              }).toList()
          ),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: detailProductTenantModel.result.listImage.map((e){
                return Container(
                  width: 20.0,
                  height: 3.0,
                  margin: EdgeInsets.symmetric(vertical: 50.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      color: _current ==  detailProductTenantModel.result.listImage.indexOf(e)? Theme.of(context).hintColor : Theme.of(context).hintColor.withOpacity(0.3)),
                );
              }).toList()
          ),
        ],
      ):Builder(
        builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            child: CachedNetworkImage(
              imageUrl:gambar,
              width: double.infinity ,
              fit:BoxFit.contain,
              placeholder: (context, url) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
              errorWidget: (context, url, error) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
            ),
            // height: 100,
            decoration: BoxDecoration(
              // image: DecorationImage(image: NetworkImage(gambar), fit: BoxFit.fill),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).hintColor.withOpacity(0.2), offset: Offset(0, 4), blurRadius: 9)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget hargaGrosir(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height/1,
      child:ListView.separated(
        padding:EdgeInsets.all(0.0),
        shrinkWrap: true,
        primary: false,
        // padding: EdgeInsets.zero,
        itemCount: hargaBertingkat.length,
        itemBuilder: (context,index){
          return Padding(
            padding: EdgeInsets.only(top:10,bottom:10),
            child: WidgetHelper().textQ("Beli produk ini sebanyak ${hargaBertingkat[index].dari} sampai ${hargaBertingkat[index].sampai} mendapatkan harga hanya ${FunctionHelper().formatter.format(int.parse(hargaBertingkat[index].harga))}", 12,SiteConfig().darkMode, FontWeight.normal),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
          );
        },
      ),

    );
  }

  Widget reviewContent(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);

    return ListView.separated(
      controller: controller,
      padding: scaler.getPadding(0,2),
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
      // shrinkWrap: true,
      // primary: false,
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

