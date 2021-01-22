import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _DetailProducrScreenState extends State<DetailProducrScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final DatabaseConfig _helper = new DatabaseConfig();
  DetailProductTenantModel detailProductTenantModel;
  ReviewModel reviewModel;
  ListProductTenantModel productTenantModel;
  List hargaBertingkat=[], varian=[], subVarian=[], review=[];
  bool isLoadmore=false,isError=false,isLoading=false,isLoadingReview=false,isLoadingPoductOther=false,isSelectedFavorite=false,isSubVarian=false;
  int perpageReview=6,_current=0,totalReview=0,totalCart=0,total=0,stock=0,qty=0,hargaFinish=0,hargaWarna=0,hargaUkuran=0,diskon1=0,diskon2=0;
  int selectedVarian=0,selectedSubVarian=0;
  String title,kode,harga,hargaMaster,hargaCoret,rating,deskripsi,idTenant,warna,ukuran,gambar,kelompok,idVarian,idSubVarian;

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
  ScrollController controller;

  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      setState((){
        isLoadmore=true;
        perpageReview = perpageReview+6;
        // isShowChild=false;
      });
      print("LOADING $isLoadmore");
      getReview();
      // if(perpageReview<reviewModel.result.total){
      //
      // }
      // else{
      //   print('else');
      // }

    }
  }
  int maxLengthDesc=2;
  bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
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
    getSite();
    isLoading=true;
    isLoadingPoductOther=true;
    isLoadingReview=true;
    getDetail();
    controller = new ScrollController()..addListener(_scrollListener);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: site?Colors.transparent:Colors.white,
      key: _scaffoldKey,
      body: isLoading||isLoadingPoductOther||isLoadingReview?LoadingDetailProduct(site: site):buildContent(context),
      bottomNavigationBar: isLoading||isLoadingPoductOther||isLoadingReview?Text(''):Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  padding: EdgeInsets.symmetric(vertical: 14),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child:WidgetHelper().textQ(FunctionHelper().formatter.format(total),12, Theme.of(context).primaryColor, FontWeight.bold)
                  // child:Text("abus")
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: FlatButton(
                  onPressed: () {add();},
                  padding: EdgeInsets.symmetric(vertical: 14),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                  child:WidgetHelper().textQ("Keranjang", 14, SiteConfig().secondDarkColor, FontWeight.bold)
                // child:Text("abus")
              ),
            ),
            // FlatButton(
            //   onPressed: () {
            //     add();
            //   },
            //   color: Theme.of(context).accentColor,
            //   shape: StadiumBorder(),
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 10),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: <Widget>[
            //         IconButton(
            //           onPressed: () {
            //             // add();
            //           },
            //           iconSize: 30,
            //           // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            //           icon: Icon(Icons.add_circle_outline),
            //           color: Theme.of(context).primaryColor,
            //         ),
            //         WidgetHelper().textQ("Keranjang", 14, SiteConfig().secondDarkColor, FontWeight.bold),
            //
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context){
    return CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            onStretchTrigger: (){
              return;
            },
            // brightness: site?Brightness.dark:Brightness.light,
            // backgroundColor: site?SiteConfig().darkMode:Colors.white,
            snap: true,
            floating: true,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: new IconButton(
              icon: new Icon(UiIcons.return_icon, color: SiteConfig().secondColor),
              onPressed: () => Navigator.pop(context,false),
            ),
            actions: <Widget>[
              new CartWidget(
                iconColor: SiteConfig().secondColor,
                labelColor: Theme.of(context).accentColor,
                labelCount: totalCart,
                callback: (){
                  if(totalCart>0){
                    WidgetHelper().myPushAndLoad(context,CartScreen(idTenant: idTenant),(){getCountCart();});
                  }
                },
              ),
              Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsets.only(top: 12.5, bottom: 12.5, right: 20),
                  child: InkWell(
                    focusColor:  site?Colors.white:SiteConfig().darkMode,
                    borderRadius: BorderRadius.circular(300),
                    onTap: () {
                      insertFavorite();
                      // Navigator.of(context).pushNamed('/Tabs', arguments: 1);
                    },
                    child: Icon(UiIcons.heart,size: 30,color: isSelectedFavorite?Colors.red:SiteConfig().secondColor),
                  )
              ),
            ],
            // backgroundColor: Theme.of(context).primaryColor,
            expandedHeight: 300,
            elevation: 0,
            flexibleSpace: sliderQ(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Offstage(
                offstage: false,
                child: Container(
                  decoration: BoxDecoration(
                    // color: site?SiteConfig().darkMode:Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    // boxShadow: [
                    //   BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, -2)),
                    // ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.only(top:10.0),
                            width: 50,
                            height: 10.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:  BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: ListTile(
                            contentPadding: EdgeInsets.all(0.0),
                            title: Row(
                              children: [
                                Expanded(
                                  child: WidgetHelper().textQ(title,12,site?SiteConfig().secondDarkColor:SiteConfig().darkMode,FontWeight.normal,maxLines: title.length),
                                ),
                                SizedBox(width: 5.0),
                                diskon1>0?Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Theme.of(context).accentColor),
                                  alignment: AlignmentDirectional.topEnd,
                                  child: WidgetHelper().textQ('$diskon1 + $diskon2 %', 10,Colors.white,FontWeight.bold),
                                ):Container()
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                WidgetHelper().textQ(FunctionHelper().formatter.format(int.parse(harga)),14,SiteConfig().mainColor,FontWeight.bold),
                                SizedBox(width: 5.0),
                                WidgetHelper().textQ(FunctionHelper().formatter.format(int.parse(hargaCoret)),12,SiteConfig().accentDarkColor,FontWeight.bold,textDecoration: TextDecoration.lineThrough),
                              ],
                            ),
                            trailing: InkWell(
                              onTap: (){
                                showModalBottomSheet(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                                    backgroundColor: site?SiteConfig().darkMode:Colors.white,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => hargaBertingkat.length>0?Container(
                                      decoration: BoxDecoration(
                                        color: site?SiteConfig().darkMode:Colors.white,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(10.0),topLeft: Radius.circular(10.0))
                                      ),
                                      height: MediaQuery.of(context).size.height/2,
                                      child:Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height:10.0),
                                          Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top:10.0),
                                              width: 50,
                                              height: 10.0,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:  BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20.0),
                                          Center(
                                            child: WidgetHelper().textQ("LIST HARGA GROSIR", 14, site?Colors.white:SiteConfig().secondColor, FontWeight.bold),
                                          ),
                                          SizedBox(height: 20.0),
                                          Expanded(
                                            child: Scrollbar(
                                                child: ListView.separated(
                                                    padding: EdgeInsets.zero,
                                                    itemCount: hargaBertingkat.length,
                                                    itemBuilder: (context,index){
                                                      return ListTile(
                                                        title: WidgetHelper().textQ("Beli produk ini sebanyak ${hargaBertingkat[index].dari} sampai ${hargaBertingkat[index].sampai} mendapatkan harga hanya ${FunctionHelper().formatter.format(int.parse(hargaBertingkat[index].harga))}", 12, site?Colors.white:SiteConfig().secondColor, FontWeight.bold),
                                                      );
                                                    },
                                                  separatorBuilder: (context, index) {
                                                    return Divider(
                                                      height: 1,
                                                    );
                                                  },
                                                )
                                            ),
                                          )
                                        ],
                                      ),

                                    ):EmptyTenant()
                                );
                              },
                              child: Icon(Icons.arrow_right,color:  site?SiteConfig().secondDarkColor:SiteConfig().secondColor,),
                            ),
                        ),
                      ),

                      varian.length>0?Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: WidgetHelper().textQ("Pilih Warna", 12,site?SiteConfig().secondDarkColor:SiteConfig().darkMode, FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(varian.length, (index) {
                                return SizedBox(
                                  child: FilterChip(
                                    label: WidgetHelper().textQ(varian[index].title, 10, selectedVarian==index?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
                                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                                    backgroundColor: selectedVarian==index?SiteConfig().mainColor:Colors.grey[200],
                                    selectedColor: Colors.grey,
                                    selected: false,
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
                            SizedBox(height:isSubVarian==true?10:0),
                            isSubVarian==true?Row(
                              children: <Widget>[
                                Expanded(
                                  child: WidgetHelper().textQ("Pilih Ukuran", 12,site?SiteConfig().secondDarkColor:SiteConfig().darkMode, FontWeight.bold),
                                ),
                              ],
                            ):Container(),
                            SizedBox(height:isSubVarian==true?10:0),
                            isSubVarian==true?Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(subVarian.length, (index) {
                                return SizedBox(
                                  child: FilterChip(
                                    label: WidgetHelper().textQ(subVarian[index].title, 10, selectedSubVarian==index?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
                                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                                    backgroundColor: selectedSubVarian==index?SiteConfig().mainColor:Colors.grey[200],
                                    selectedColor: Colors.grey,
                                    selected: false,
                                    showCheckmark: true,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                              leading: Icon(
                                UiIcons.file_2,
                                color: site?Colors.white:Theme.of(context).hintColor,
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  WidgetHelper().textQ("Deskripsi Produk", 14, site?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
                                  WidgetHelper().myPress(
                                    (){
                                      setState(() {
                                        if(maxLengthDesc==2){
                                          maxLengthDesc = deskripsi.length;
                                        }else{
                                          maxLengthDesc = 2;
                                        }
                                      });
                                    },
                                    Icon(maxLengthDesc==2?Icons.arrow_drop_down:Icons.arrow_drop_up,color:  site?SiteConfig().secondDarkColor:SiteConfig().secondColor,),
                                    // WidgetHelper().textQ("lihat selengkapnya",10, site?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child:WidgetHelper().textQ(deskripsi, 12, site?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.normal,maxLines:maxLengthDesc),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: WidgetHelper().pembatas(context),

                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              leading: Icon(
                                UiIcons.chat_1,
                                color: site?Colors.white:Theme.of(context).hintColor,
                              ),
                              title:Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  WidgetHelper().textQ("Ulasan Produk", 14, site?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
                                  InkWell(
                                    onTap: (){
                                      showModalBottomSheet(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) =>  Container(
                                            decoration: BoxDecoration(
                                              color: site?SiteConfig().darkMode:Colors.white,
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))
                                            ),
                                            height: MediaQuery.of(context).size.height/1.2,
                                            child:ModalReview(kode: kode,title: title,site:site),
                                          )
                                      );
                                    },
                                    child:Icon(Icons.arrow_right,color:  site?SiteConfig().secondDarkColor:SiteConfig().secondColor)
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                              child: isLoadingReview?Container():review.length>0 ? ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                itemBuilder: (context, index) {
                                  return ReviewWidget(
                                    foto: review[index].foto,
                                    nama: review[index].nama,
                                    tgl: review[index].time,
                                    rate: review[index].rate.toString(),
                                    desc: review[index].caption,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    height: 30,
                                    color: site?Colors.white10:Colors.grey[200],
                                  );
                                },
                                itemCount:review.length,
                                primary: false,
                                shrinkWrap: true,
                              ):Container(
                                margin: EdgeInsets.only(left:20,bottom: 10),
                                child: WidgetHelper().textQ("belum ada ulasan untuk barang ini", 14, SiteConfig().secondColor, FontWeight.normal),
                              )
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: WidgetHelper().pembatas(context),

                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          leading: Icon(
                            UiIcons.box,
                            color: Theme.of(context).hintColor,
                          ),
                          title: WidgetHelper().textQ("Produk Terkait", 14, site?SiteConfig().secondDarkColor:SiteConfig().secondColor, FontWeight.bold),
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

            ]),
          )
        ]
    );
  }
  Widget sliderQ(BuildContext context){
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
                height: 300,
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
                      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      height: 100,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: detailProductTenantModel.result.listImage.map((e){
                return Container(
                  width: 20.0,
                  height: 3.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
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
        SizedBox(height:10.0),
        Center(
          child: Container(
            padding: EdgeInsets.only(top:10.0),
            width: 50,
            height: 10.0,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius:  BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: WidgetHelper().textQ("Ulasan Produk  ${widget.title}", 12,widget.site?Colors.white:SiteConfig().secondColor, FontWeight.normal,maxLines: widget.title.length),
        ),
        SizedBox(height: 20.0),
        isLoading?Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WidgetHelper().loadingWidget(context)
            ],
          ),
        ):reviewModel.result.data.length>0?Expanded(
          child:Scrollbar(
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
                primary: false,
                shrinkWrap: true,
              )
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

