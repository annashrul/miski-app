import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/model/tenant/slider_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:netindo_shop/views/widget/slider_widget.dart';

class PrivateHomeScreen extends StatefulWidget {
  final String id;
  final String nama;
  PrivateHomeScreen({this.id,this.nama});
  @override
  _PrivateHomeScreenState createState() => _PrivateHomeScreenState();
}

class _PrivateHomeScreenState extends State<PrivateHomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();
  int perpage=10;
  final userRepository = UserHelper();
  ListProductTenantModel productTenantModel;
  SliderModel sliderModel;
  int totalCart=0;
  ScrollController controller;
  bool isLoading=false,isLoadingSlider=false,isLoadmore=false,isTimeout=false,isShowChild=false;
  int total=0;
  AnimationController colorAnimationController;
  Animation appBarColorTween, iconColorTween, fieldColorTween;
  Brightness brightnessCutom = Brightness.light;
  GlobalKey key = GlobalKey();
  ScrollController scrollControlllerSingle;
  int current = 0;
  bool secondAppBar = false;
  int selectedkategori = 0;
  double containerHeight = 70;

  List resFavoriteProduct = [];
  final DatabaseConfig _helper = new DatabaseConfig();
  List returnProductLocal = [];
  String q='',group='';
  List returnGroup = [];
  Future loadGroup()async{
    var group = await _helper.getData(GroupQuery.TABLE_NAME);
    List groups = [];
    group.forEach((element) {
      groups.add({
        "id": element['id_groups'],
        "title": element['title'],
        "id_kategori":element['id_category'],
        "kategori":element['category'],
        "status": element['status'],
        "image": element['image'],
        "isSelected":false
      });
    });
    setState(() {
      returnGroup=groups;
    });
  }
  Future getProduct()async{
    var resProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? LIMIT $perpage",[widget.id]);
    var resTotalProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=?",[widget.id]);
    if(q!=''&&group!=''){
      resProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%$q%' and id_kelompok=?",[widget.id,group]);
      resTotalProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%$q%' and id_kelompok=?",[widget.id,group]);
    }
    if(group!=''){
      print("GROUP $group");
      resProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and id_kelompok=?",[widget.id,group]);
      resTotalProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and id_kelompok=?",[widget.id,group]);
    }

    if(q!=''){
      resProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%$q%'",[widget.id]);
      resTotalProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%$q%'",[widget.id]);
    }

    if(resProductLocal.length>0){
      setState(() {
        returnProductLocal = resProductLocal;
        total=resTotalProductLocal.length;
        isLoading=false;
        isLoadmore=false;
      });
      print("RESPONSE $resProductLocal");
    }
    else{
      var resProduct = await FunctionHelper().baseProduct('perpage=$perpage&tenant=${widget.id}');
      if(resProduct[0]['total']>0){
        setState(() {
          returnProductLocal = resProductLocal;
          total=resTotalProductLocal.length;
          productTenantModel = resProduct[0]['data'];
          total=resProduct[0]['total'];
          isLoading=false;
          isLoadmore=false;
        });
      }
      else{
        setState(() {
          returnProductLocal = resProductLocal;
          total=resTotalProductLocal.length;
          isLoading=false;
          isTimeout=true;
        });
      }
    }
  }
  Future getSlider()async{
    var resSlider = await BaseProvider().getProvider('slider?page=1', sliderModelFromJson);
    if(resSlider is SliderModel){
      setState(() {
        sliderModel = SliderModel.fromJson(resSlider.toJson());
        isLoadingSlider=false;
      });
    }
  }
  Future countCart() async{
    final res = await BaseProvider().countCart(widget.id);
    setState(() {
      totalCart = res;
    });
  }
  Future loadData(param)async{
    setState(() {
      isTimeout=false;
      isLoading=true;
      isLoadingSlider=true;
    });
    await getSlider();
    await countCart();
    var totalProduct = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=?",[widget.id]);
    await FunctionHelper().setSession("id_tenant", widget.id);
    if(totalProduct.length<1){
      await _helper.delete(ProductQuery.TABLE_NAME, "id_tenant", widget.id);
      print('hapus produk lokal sukses');
      await FunctionHelper().insertProduct(widget.id);
      print('insert produk lokal sukses');
    }
    if(param=='refresh'){
      await _helper.delete(ProductQuery.TABLE_NAME, "id_tenant", widget.id);
      await FunctionHelper().insertProduct(widget.id);
    }
    await getProduct();
  }
  Future<void> _handleRefresh()async {
    await FunctionHelper().getFilterLocal(widget.id);
    await FunctionHelper().handleRefresh((){
      setState(() {
        q='';
      });
      loadData('refresh');
    });
  }
  void _scrollListener() {
    if (!isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if(perpage<total){
          setState((){
            perpage+=10;
            isLoadmore=true;
            isShowChild=false;
          });
          getProduct();
        }
        else{
          isShowChild=true;
        }
      }
    }
  }
  bool scrollListener(ScrollNotification scrollInfo) {
    RenderBox box = key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    double y = position.dy;
    if (scrollInfo.metrics.axis == Axis.vertical) {
      colorAnimationController.animateTo(scrollInfo.metrics.pixels / 100);
      if (y > 83) {
        setState(() {
          secondAppBar = false;
        });
        if (scrollInfo.metrics.pixels > 100) {
          setState(() {
            brightnessCutom = Brightness.dark;
          });
        } else {
          setState(() {
            brightnessCutom = Brightness.light;
          });
        }
      } else if (y < 83) {
        setState(() {
          secondAppBar = true;
        });

        if (y > 50) {
          setState(() {
            containerHeight = 70;
          });
        } else if (y < 20) {
          setState(() {
            containerHeight = 60;
          });
        }
      }

      return true;
    }
    return null;
  }
  static bool site=false;
  Color appBar = site?SiteConfig().darkMode:Colors.white;
  Color titleBar = site?Colors.white:Colors.transparent;
  Color iconBar = site?Colors.white:SiteConfig().secondColor;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      appBar = res?SiteConfig().darkMode:Colors.white;
      titleBar = res?Colors.white:Colors.transparent;
      iconBar = res?Colors.white:SiteConfig().secondColor;
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
    super.initState();
    loadGroup();
    loadData('');
    getSite();
    controller = new ScrollController()..addListener(_scrollListener);
    colorAnimationController = AnimationController(vsync: this, duration: Duration(seconds: 0));
    appBarColorTween = ColorTween(begin: Colors.transparent, end: appBar).animate(colorAnimationController);
    fieldColorTween = ColorTween(begin: Colors.transparent, end: Colors.transparent).animate(colorAnimationController);
    iconColorTween = ColorTween(begin: Colors.white, end: iconBar).animate(colorAnimationController);
  }

  List index=[];
  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.ac_unit,
      Icons.account_balance,
      Icons.adb,
      Icons.add_photo_alternate,
      Icons.format_line_spacing
    ];
    return buildItem(context);
  }
  Widget buildItem(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: brightnessCutom),
      child: Scaffold(
        key: _scaffoldKey,
        body: NotificationListener<ScrollNotification>(
          onNotification: scrollListener,
          child: RefreshWidget(
            widget: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Color(0xFF05AA10),
                          ),
                          child: SliderWidget(),
                        ),
                        isLoading?Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: LoadingProductTenant(tot: 10),
                        ):returnProductLocal.length>0?Container(
                            key: key,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            child:new StaggeredGridView.countBuilder(
                              primary: false,
                              shrinkWrap: true,
                              crossAxisCount: 4,
                              itemCount: returnProductLocal.length,
                              itemBuilder: (BuildContext context, int index) {
                                var valProductServer =  returnProductLocal[index];
                                return ProductWidget(
                                  id: valProductServer['id_product'],
                                  gambar: valProductServer['gambar'],
                                  title: valProductServer['title'],
                                  harga: valProductServer['harga'],
                                  hargaCoret: valProductServer['harga_coret'],
                                  rating: valProductServer['rating'].toString(),
                                  stock: valProductServer['stock'].toString(),
                                  stockSales: valProductServer['stock_sales'].toString(),
                                  disc1: valProductServer['disc1'].toString(),
                                  disc2: valProductServer['disc2'].toString(),
                                  countCart: countCart,
                                );
                              },
                              staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                              mainAxisSpacing: 15.0,
                              crossAxisSpacing: 15.0,
                            )
                        ):EmptyTenant(),
                        isLoadmore?Container(
                          padding: const EdgeInsets.only(left: 20,right:20,top:0,bottom:0),
                          child: LoadingProductTenant(tot: 4),
                        ):Container(),
                      ],
                    ),
                  ),
                ),
                createAppBarAnimation(),
              ],
            ),
            callback: (){_handleRefresh();},
          ),
        ),
        backgroundColor: site?SiteConfig().darkMode:Colors.white,
      ),
    );

  }
  // NOTE: AppBar Animation
  Widget createAppBarAnimation() => AnimatedBuilder(
    animation: colorAnimationController,
    builder: (context, child) => Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: appBarColorTween.value,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0, right: 20, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.58,
                    height: 40,
                    decoration: BoxDecoration(
                      color: fieldColorTween.value,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Row(
                          children: [
                            new IconButton(
                              icon: new Icon(UiIcons.home, color:iconColorTween.value),
                              onPressed:null,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            WidgetHelper().textQ("${widget.nama}", 16,iconColorTween.value,FontWeight.bold)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        InkWell(
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                  height: 24,
                                  width: 24,
                                  child:Icon(UiIcons.shopping_cart, size: 24, color: iconColorTween.value)
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  child:WidgetHelper().textQ("$totalCart", 10, Theme.of(context).primaryColor, FontWeight.bold),
                                  padding: EdgeInsets.only(left:4.0),
                                  decoration: BoxDecoration(color:SiteConfig().mainColor, borderRadius: BorderRadius.all(Radius.circular(10))),
                                  constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
                                ),
                              ),
                            ],
                          ),
                          onTap: (){
                            if(totalCart>0){
                              WidgetHelper().myPushAndLoad(context, CartScreen(idTenant: widget.id), countCart);
                            }
                          },
                        ),
                        SizedBox(width: 10.0),
                        Container(
                          height: 24,
                          width: 24,
                          child: FlatButton(
                              padding: EdgeInsets.only(right:10),
                              onPressed: (){
                                WidgetHelper().myModal(
                                  context,
                                  ModalSearch(mode:site,idTenant:widget.id,callback:(par){
                                    q=par;
                                    isLoading=true;
                                    getProduct();
                                  })
                                );
                              },
                              child: Icon(UiIcons.filter, size: 24, color: iconColorTween.value)
                              // child: UiIcons.filter
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );


}



class ModalSearch extends StatefulWidget {
  bool mode;
  String idTenant;
  Function(String q) callback;
  ModalSearch({this.mode,this.idTenant,this.callback});
  @override
  _ModalSearchState createState() => _ModalSearchState();
}

class _ModalSearchState extends State<ModalSearch> {
  DatabaseConfig db= DatabaseConfig();
  final qController = TextEditingController();
  List resProduct=[];
  List resSearch=[];
  List resClick=[];
  Future loadData()async{
    if(qController.text!=''){
      var res = await db.readData(ProductQuery.TABLE_NAME, widget.idTenant,colWhere: ['title'],valWhere: ['${qController.text}']);
      setState(() {
        resProduct=res;
      });
    }else{
      setState(() {
        resProduct=[];
      });
      loadSearch();
    }

  }
  Future loadSearch()async{
    var res = await db.getRow("SELECT * FROM ${SearchingQuery.TABLE_NAME} ORDER BY title DESC");
    // var res = await db.getData(SearchingQuery.TABLE_NAME,orderBy: 'title');
    setState(() {
      resSearch = res;
    });
  }
  Future loadClick()async{
    var res = await db.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and is_click=?",["${widget.idTenant}","true"]);
    print("RESPONSE CLICK $res");
    setState(() {
      resClick=res;
    });
  }
  String idProduct='';
  Future store()async{
    if(qController.text!=''){
      final check = await db.getWhere(SearchingQuery.TABLE_NAME, "id_product","$idProduct", '');
      if(check.length>0){
        await db.delete(SearchingQuery.TABLE_NAME,"id_product","$idProduct");
        await db.insert(SearchingQuery.TABLE_NAME,{"id_product":"${idProduct.toString()}","title":"${qController.text.toString()}"});
      }
      else{
        await db.insert(SearchingQuery.TABLE_NAME,{"id_product":"${idProduct.toString()}","title":"${qController.text.toString()}"});
      }
    }

    loadSearch();
    Navigator.of(context).pop();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadClick();
    loadSearch();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height/2.0,
      decoration: BoxDecoration(
          color:widget.mode?SiteConfig().darkMode:Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30.0),
          Container(
            decoration: BoxDecoration(
              color:widget.mode?Theme.of(context).focusColor.withOpacity(0.15):SiteConfig().secondColor,
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)
              ],
            ),
            child: TextFormField(
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.multiline,
              cursorColor: Theme.of(context).focusColor.withOpacity(0.8),
              controller: qController,
              style:TextStyle(color: Theme.of(context).focusColor.withOpacity(0.8),fontFamily: SiteConfig().fontStyle),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20),
                hintText: 'Tulis sesuatu disini ...',
                hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.8),fontFamily: SiteConfig().fontStyle),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(right: 30),
                  onPressed: () {
                    // replyTicket();
                    // _scrollToBottom();
                    if(qController.text!=''){
                      setState(() {
                        qController.text='';
                      });
                      loadData();
                    }
                  },
                  icon: Icon(
                    qController.text==''?Icons.search:Icons.close,
                    color:Theme.of(context).focusColor.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ),
              onChanged: (e)async{
                loadData();
              },
              onFieldSubmitted: (e){

                widget.callback(qController.text);
                store();

              },
            ),
          ),
          resProduct.length>0?Expanded(
            flex: 7,
              child: ListView.separated(
                  itemBuilder: (context,index){
                    return ListTile(
                      onTap: ()async{
                        setState(() {
                          qController.text = resProduct[index]['title'];
                          idProduct = resProduct[index]['id_product'];
                        });
                        loadData();
                        widget.callback(resProduct[index]['title']);
                        store();
                      },
                      title: WidgetHelper().textQ("${resProduct[index]['title']}",10,Colors.white,FontWeight.bold),
                    );
                  },
                  separatorBuilder:(context,index){
                    return  Divider(height: 1);
                  },
                  itemCount: resProduct.length
              )
          ):
          (resSearch.length>0?Expanded(
            flex: 7,
              child: ListView.separated(
                  itemBuilder: (context,index){
                    return ListTile(
                      onTap: (){
                        setState(() {
                          qController.text = resSearch[index]['title'];
                          idProduct = resSearch[index]['id_product'];
                        });
                        loadData();
                        widget.callback(resSearch[index]['title']);
                        store();
                      },
                      trailing: IconButton(
                          icon: Icon(Icons.close,color:Colors.grey),
                          onPressed:()async{
                            await db.delete(SearchingQuery.TABLE_NAME,"id",resSearch[index]['id']);
                            loadSearch();
                          }
                      ),
                      title: WidgetHelper().textQ("${resSearch[index]['title']}",10,Colors.white,FontWeight.bold),
                    );
                  },
                  separatorBuilder:(context,index){
                    return  Divider(height: 1);
                  },
                  itemCount: resSearch.length
              )
          ):Expanded(
            child: ListView(
              children: [
                EmptyTenant()
              ],
            ),
          )),
          WidgetHelper().titleQ("Barang yang pernah dilihat",param: ""),
          Expanded(
            flex: 13,
            child: ListView.separated(
              itemBuilder: (context,index){
                var val = resClick[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      InkWell(
                        onTap: (){
                          WidgetHelper().myPush(context,DetailProducrScreen(id: val['id_product']));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor.withOpacity(0.15),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                            ],
                            // borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Hero(
                                tag: "${val['id']}${val['id_product']}${val['id_tenant']}",
                                child: Container(
                                  height: 90,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    image: DecorationImage(image: NetworkImage(val['gambar']), fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Flexible(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Stack(
                                            alignment: AlignmentDirectional.topEnd,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(right:10.0),
                                                child: WidgetHelper().textQ("${val['tenant']}", 12, SiteConfig().mainColor, FontWeight.bold),
                                              ),
                                              Positioned(
                                                child:Icon(UiIcons.home,color:SiteConfig().mainColor,size: 8),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              WidgetHelper().textQ("${val['title']}", 12, widget.mode?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                                              int.parse(val['disc1'])==0?Container():SizedBox(width: 5),
                                              int.parse(val['disc1'])==0?Container():WidgetHelper().textQ("( diskon ${val['disc1']} + ${val['disc2']} )", 10,Colors.grey,FontWeight.bold),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga_coret']))}", 10,Colors.green,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                                              SizedBox(width: 5),
                                              WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga']))}", 12,Colors.green,FontWeight.bold),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context,index){return Divider(height: 1);},
              itemCount: resClick.length
            )
          )

        ],
      ),
    );
  }
}
