import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/detail_cart_model.dart';
import 'package:netindo_shop/model/review/review_model.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/review_widget.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

class ProductDetailPage extends StatefulWidget {
  final id;
  ProductDetailPage({this.id,Key key}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  ReviewModel reviewModel;
  DetailProductTenantModel detailProductTenantModel;
  String image = 'https://onlinewhiskeystore.com/images/default.png';
  bool isFavorite=false,isShowDesc=false,isLoading=true,isLoadingReview=true;
  List thumbnailList=[];
  List hargaBertingkat=[], varian=[], subVarian=[], review=[];
  int perpageReview=10,_current=0,totalReview=0,totalCart=0,total=0,stock=0,qty=0,hargaFinish=0,hargaWarna=0,hargaUkuran=0,diskon1=0,diskon2=0;
  int selectedVarian=0,selectedSubVarian=0;
  String stockSales='',title,kode,harga,hargaMaster,hargaCoret,rating,deskripsi,idTenant,tenant,warna,ukuran,gambar,idKelompok,kelompok,idVarian,idSubVarian;
  String brand='',idBrand='';
  int perpage=3;

  Future getDetail()async{
    final data = await BaseProvider().getProvider("barang/${widget.id}", detailProductTenantModelFromJson);
    if(data is DetailProductTenantModel){
      DetailProductTenantModel res = DetailProductTenantModel.fromJson(data.toJson());
      if(int.parse(res.result.disc1)>0){
        setState(() {
          harga = FunctionHelper().double_diskon(res.result.harga, ['${res.result.disc1.toString()}','${res.result.disc2.toString()}']).toString();
          hargaFinish = FunctionHelper().double_diskon(res.result.harga, ['${res.result.disc1.toString()}','${res.result.disc2.toString()}']);
          hargaMaster = FunctionHelper().double_diskon(res.result.harga, ['${res.result.disc1.toString()}','${res.result.disc2.toString()}']).toString();
        });
      }
      else{
        setState(() {
          harga = res.result.harga;
          hargaMaster = res.result.harga;
          hargaFinish=int.parse(res.result.harga);
        });
      }
      thumbnailList.add({"image":res.result.gambar});
      res.result.listImage.forEach((element) {thumbnailList.add({"image":element.image});});

      if(this.mounted){
        setState(() {
          isLoading=false;
          detailProductTenantModel = DetailProductTenantModel.fromJson(res.toJson());
          image = detailProductTenantModel.result.gambar;
          idTenant = res.result.idTenant;
          tenant = res.result.tenant;
          stockSales=res.result.stockSales;
          kode = res.result.kode;
          kelompok=res.result.kelompok;
          idKelompok=res.result.idKelompok;
          brand=res.result.brand;
          idBrand=res.result.idBrand;
          deskripsi = detailProductTenantModel.result.deskripsi.length>200?res.result.deskripsi.substring(0,200)+" ..":res.result.deskripsi;
          // deskripsi =StringConfig.lorem.length>200?StringConfig.lorem.substring(0,200)+" ..":StringConfig.lorem;
          varian = res.result.varian;
          hargaBertingkat=res.result.hargaBertingkat;
          review=res.result.review;
          title = res.result.title;
          gambar = res.result.gambar;
          hargaCoret = res.result.hargaCoret;
          rating = res.result.rating.toString();
          stock = int.parse(res.result.stock);
          diskon1 = int.parse(res.result.disc1);
          diskon2 = int.parse(res.result.disc2);
          kelompok = res.result.idKelompok;
        });
      }
      getCountCart();
      getReview(res.result.kode);
      getFavorite();
    }
  }
  Future getReview(String kode)async{
    final res = await HandleHttp().getProvider("review?page=1&perpage=$perpage", reviewModelFromJson,context: context,callback: (){
      print("callback");
    });
    if(res is ReviewModel){
      ReviewModel result=ReviewModel.fromJson(res.toJson());
      if(this.mounted){
        setState(() {
          reviewModel = result;
          isLoadingReview=false;
          totalReview=result.result.total;
        });
      }
    }
  }
  void add()async{
    if(stock<1){
      WidgetHelper().showFloatingFlushbar(context,"failed","maaf stock barang kosong");
      return;
    }else{
      if(this.mounted) setState(() {qty+=1;});
      checkingPrice(idTenant, widget.id, kode, idVarian, idSubVarian, qty, harga, diskon1, diskon2, hargaBertingkat.length>0?true:false, hargaMaster, hargaWarna, hargaUkuran);
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
        harga = hrg.toString();
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
    var res = await BaseProvider().getProvider('cart/detail/$idTenant/${widget.id}', detailCartModelFromJson);
    if(res is DetailCartModel){
      DetailCartModel result = res;
      if(this.mounted) setState(() {qty = int.parse(result.result.qty);});
    }
  }
  Future getCountCart() async{
    final res = await BaseProvider().getCart(idTenant);
    if(this.mounted) setState(() {totalCart = res.result.length;});
    getSubTotal();
  }

  final DatabaseConfig _helper = new DatabaseConfig();

  Future insertFavorite()async{
    var parseData={
      "id_product": widget.id.toString(),
      "id_tenant": idTenant.toString(),
      "kode": kode.toString(),
      "title": title.toString(),
      "tenant": tenant.toString(),
      "id_kelompok": idKelompok.toString(),
      "kelompok":kelompok.toString(),
      "id_brand":idBrand.toString(),
      "brand": brand.toString(),
      "deskripsi": deskripsi.toString(),
      "harga":harga.toString(),
      "harga_coret": hargaCoret.toString(),
      "berat": "0",
      "pre_order": "0",
      "free_return":"0",
      "gambar":gambar.toString(),
      "disc1": diskon1.toString(),
      "disc2": diskon2.toString(),
      "stock": stock.toString(),
      "stock_sales": stockSales.toString(),
      "rating": rating.toString(),
      "is_favorite":"true",
      "is_click":"false"
    };
    final getWhere = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME, idTenant,'id_product','${widget.id}');

    if(getWhere.length==0){
      await _helper.insert(ProductQuery.TABLE_NAME, parseData);
      setState(() {
        isFavorite=true;
      });
      print("insert");
    }
    else{
      await _helper.delete(ProductQuery.TABLE_NAME, "id_product", widget.id);
      setState(() {
        isFavorite=false;
      });
      print("delete");

    }
    // print(getWhere);
  }
  Future getFavorite()async{
    final getWhere = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME, idTenant,'id_product','${widget.id}');
    print("get $getWhere");
    getWhere.forEach((element) {
      if(element['is_favorite']=="true"){
        setState(() {
          isFavorite=true;
        });
      }
      else{
        setState(() {
          isFavorite=false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller =  AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: Curves.easeInToLinear));
    controller.forward();
    getDetail();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Widget _productImage() {
    return AnimatedBuilder(
      builder: (context, child) {
        return AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: animation.value,
          child: child,
        );
      },
      animation: animation,
      child: Stack(
        alignment: Alignment.bottomCenter,
        // alignment: Alignment.bottomCenter,
        children: <Widget>[
          CachedNetworkImage(imageUrl: image,fit: BoxFit.cover, height: MediaQuery.of(context).size.height/2.2, width: MediaQuery.of(context).size.width/1,),
          Positioned(
            bottom: 70,
            child: _categoryWidget(),
          ),
          // WidgetHelper().textQ("AIP", scaler.getTextSize(12), LightColor.lightGrey, FontWeight.bold),
        ],
      ),
    );
  }
  Widget _categoryWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
      width: MediaQuery.of(context).size.width/1,
      height: 40,
      child: Center(
        child: !isLoading&&detailProductTenantModel.result.listImage.length>0?ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: thumbnailList.length,
            itemBuilder: (context,index){
              return _thumbnail(thumbnailList[index]["image"]);
            }
        ):Container(),
      ),
    );
  }
  Widget _thumbnail(String res) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) => AnimatedOpacity(
          opacity: animation.value,
          duration: Duration(milliseconds: 500),
          child: child,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: WidgetHelper().myRipple(
              child: Container(
                height: 40,
                width: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: res==image?2:1,
                      color: res==image?LightColor.orange:Colors.grey,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                        image: NetworkImage(res),
                        fit: BoxFit.cover
                    )
                  // color: Theme.of(context).backgroundColor,
                ),
              ),
              callback: (){
                setState(() {
                  image=res;
                });
              }
          ),
        )
    );
  }
  Widget _detailWidget() {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return DraggableScrollableSheet(
      maxChildSize: 0.8,
      initialChildSize: 0.53,
      minChildSize: 0.53,
      builder: (context, scrollController) {
        return Container(
          padding:ScreenScaler().getPadding(1, 1),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: Colors.white
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: 5),
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: LightColor.iconColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
                WidgetHelper().myRipple(
                  callback: ()async{
                    insertFavorite();
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(int.parse(harga)), scaler.getTextSize(12), LightColor.orange, FontWeight.bold),
                    subtitle:  int.parse(hargaCoret)<1?WidgetHelper().textQ(detailProductTenantModel.result.title, scaler.getTextSize(9), LightColor.lightblack, FontWeight.normal,maxLines: 100):Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(int.parse("200000")),scaler.getTextSize(9),SiteConfig().accentDarkColor,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                        WidgetHelper().textQ(detailProductTenantModel.result.title, scaler.getTextSize(9), LightColor.lightblack, FontWeight.normal,maxLines: 100),
                      ],
                    ),
                    trailing: Icon(Ionicons.ios_heart,color: isFavorite?LightColor.orange:LightColor.lightblack),
                  )
                ),
                WidgetHelper().myRipple(
                  callback: (){
                    setState(() {
                      isShowDesc = !isShowDesc;
                    });
                  },
                    child: ListTile(
                      contentPadding: EdgeInsets.all(0.0),
                      title: WidgetHelper().textQ("Deskripsi produk", scaler.getTextSize(10), LightColor.black, FontWeight.bold),
                      subtitle: RichText(
                        text: TextSpan(
                            text: isShowDesc?detailProductTenantModel.result.deskripsi:deskripsi,

                            style: GoogleFonts.robotoCondensed().copyWith(color:LightColor.lightblack,fontSize: scaler.getTextSize(9)),
                            children: <TextSpan>[
                              detailProductTenantModel.result.deskripsi.length>200?TextSpan(text: ' lihat lebih ${isShowDesc?'sedikit':'banyak'}',
                                  style: GoogleFonts.robotoCondensed().copyWith(color: LightColor.mainColor,fontSize: scaler.getTextSize(9),fontWeight: FontWeight.w700),

                              ):TextSpan(text:'')
                            ]
                        ),
                      )
                    )
                ),
                if(detailProductTenantModel.result.review.length>0)Divider(),
                if(detailProductTenantModel.result.review.length>0)WidgetHelper().myRipple(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WidgetHelper().textQ("Ulasan produk", scaler.getTextSize(10), LightColor.black, FontWeight.bold),
                        WidgetHelper().textQ("Lihat semua", scaler.getTextSize(9), LightColor.mainColor, FontWeight.bold),
                      ],
                    ),
                  )
                ),
                if(detailProductTenantModel.result.review.length>0)Container(
                  child: ListView.separated(
                    padding:EdgeInsets.all(0.0),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: detailProductTenantModel.result.review.length,
                    itemBuilder: (context,index){
                      var val=detailProductTenantModel.result.review[index];
                      return ReviewWidget(
                        foto: val.foto,
                        nama: val.nama,
                        tgl: val.time,
                        rate: val.rate.toString(),
                        desc: val.caption,
                      );
                    },
                    separatorBuilder: (context,index){return Divider();},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context,"",(){}, <Widget>[
        new CartWidget(
          iconColor: LightColor.lightblack,
          labelColor: totalCart>0?Colors.redAccent:Colors.transparent,
          labelCount: totalCart,
          callback: (){
            if(totalCart>0){
              WidgetHelper().myPushAndLoad(context,CartScreen(idTenant: idTenant),(){getCountCart();});
            }
          },
        ),
        IconButton(
          icon: Icon(
              Ionicons.md_share,color: LightColor.lightblack,
          ),
          onPressed: () {

          },
        )
      ],param: "default"),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xfffbfbfb),
                  Color(0xfff7f7f7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  _productImage(),
                ],
              ),
              isLoading?WidgetHelper().loadingWidget(context):_detailWidget(),


            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding:scaler.getPadding(0,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: scaler.getMarginLTRB(2,0,0,0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(total)+" .-",scaler.getTextSize(10),SiteConfig().moneyColor, FontWeight.bold),
                ],
              ),
            ),
            FlatButton(
                padding:scaler.getPadding(1,0),
                color: SiteConfig().secondColor,
                onPressed: (){add();},
                child: Icon(AntDesign.shoppingcart,color: Colors.white,)
            )
          ],
        ),
      ),
    );
  }


  

}
