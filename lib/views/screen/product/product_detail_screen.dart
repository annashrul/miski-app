import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/cart/detail_cart_model.dart';
import 'package:netindo_shop/model/review/review_model.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';
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
  List thumbnailList=[];
  List hargaBertingkat=[], varian=[], subVarian=[], review=[];
  bool isLoadmore=false,isError=false,isLoading=true,isLoadingReview=false,isLoadingPoductOther=false,isSelectedFavorite=false,isSubVarian=false;
  int perpageReview=10,_current=0,totalReview=0,totalCart=0,total=0,stock=0,qty=0,hargaFinish=0,hargaWarna=0,hargaUkuran=0,diskon1=0,diskon2=0;
  int selectedVarian=0,selectedSubVarian=0;
  String stockSales='',title,kode,harga,hargaMaster,hargaCoret,rating,deskripsi,idTenant,warna,ukuran,gambar,kelompok,idVarian,idSubVarian;

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
      getReview(res.result.kode);
      if(this.mounted){
        setState(() {
          isLoading=false;
          detailProductTenantModel = DetailProductTenantModel.fromJson(res.toJson());
          image = detailProductTenantModel.result.gambar;
          idTenant = res.result.idTenant;
          stockSales=res.result.stockSales;
          kode = res.result.kode;
          deskripsi = res.result.deskripsi;
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

    }
  }
  Future getReview(String kode)async{
    final res = await BaseProvider().getProvider("review?page=1&perpage=10&kd_brg=$kode", reviewModelFromJson);
    if(res is ReviewModel){
      if(this.mounted){
        print("######## REVIEW ${res.result.total}");
        setState(() {
          reviewModel = ReviewModel.fromJson(res.toJson());
        });
      }
    }
  }

  void add()async{
    if(this.mounted) setState(() {qty+=1;});
    checkingPrice(idTenant, widget.id, kode, idVarian, idSubVarian, qty, harga, diskon1, diskon2, hargaBertingkat.length>0?true:false, hargaMaster, hargaWarna, hargaUkuran);
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
    print("###########TOTAL=$total#################");
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
        if(deskripsi.length>300){
          deskripsi = deskripsi.substring(0,300)+" ...";
        }
        return Container(
          padding:ScreenScaler().getPadding(1, 1),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: Colors.grey[100]
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
                SizedBox(height: 10),
                WidgetHelper().textQ(detailProductTenantModel.result.title, scaler.getTextSize(10), LightColor.titleTextColor, FontWeight.normal,maxLines: 100),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetHelper().textQ(FunctionHelper().formatter.format(int.parse(harga)), scaler.getTextSize(12), LightColor.orange, FontWeight.bold),
                          WidgetHelper().textQ(FunctionHelper().formatter.format(int.parse(hargaCoret)),scaler.getTextSize(10),SiteConfig().accentDarkColor,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          WidgetHelper().rating(detailProductTenantModel.result.rating),
                          WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(detailProductTenantModel.result.stockSales))} terjual", scaler.getTextSize(10), LightColor.black, FontWeight.normal),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                WidgetHelper().textQ(deskripsi, scaler.getTextSize(10),LightColor.black,FontWeight.normal,maxLines: 1000),
                WidgetHelper().textQ("tampilkan lebih banyak", scaler.getTextSize(10),LightColor.black,FontWeight.normal,maxLines: 1000),
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
      // floatingActionButton: _flotingButton(),
      appBar: WidgetHelper().appBarWithButton(context,"",(){}, <Widget>[
        new CartWidget(
          iconColor: SiteConfig().secondColor,
          labelColor: Colors.redAccent,
          labelCount: 0,
          callback: (){

          },
        ),
        IconButton(
          icon: Icon(
              AntDesign.filter,color: SiteConfig().secondColor
          ),
          onPressed: () {

          },
        )
      ]),

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
