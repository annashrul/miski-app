import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/skeleton_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/promo/global_promo_model.dart';
import 'package:netindo_shop/model/tenant/list_product_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeScreen extends StatefulWidget {
  final String id;
  final String nama;
  HomeScreen({Key key,this.id,this.nama}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin  {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey key = GlobalKey();

  final userRepository = UserHelper();
  final DatabaseConfig _helper = new DatabaseConfig();
  ListProductTenantModel productTenantModel;
  GlobalPromoModel globalPromoModel;
  ScrollController controller;
  bool isLoading=false,isLoadingSlider=false,isLoadmore=false,isTimeout=false,site=false,isShowChild=false;
  int _current=0,perpage=10,totalCart=0,total=0;
  Future getProduct()async{
    var resProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? LIMIT $perpage",[widget.id]);
    var resTotalProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=?",[widget.id]);
    print("RES PRODUK LOKAL $resProductLocal");
    if(q!=''&&brand!=''){
      resProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%$q%' and id_brand=?",[widget.id,brand]);
      resTotalProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%$q%' and id_brand=?",[widget.id,brand]);
    }
    if(brand!=''){
      resProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and id_brand=?",[widget.id,brand]);
      resTotalProductLocal = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and id_brand=?",[widget.id,brand]);
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
  Future getPromo()async{
    var res = await BaseProvider().getProvider("promo?page=1", globalPromoModelFromJson);
    print(res);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isLoadingSlider=false;
        isTimeout=true;
      });
    }
    else{
      if(res is GlobalPromoModel){
        GlobalPromoModel result = res;
        setState(() {
          globalPromoModel = GlobalPromoModel.fromJson(result.toJson());
          isLoadingSlider=false;
          isTimeout=true;
        });
      }
    }

  }
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }
  List returnProductLocal = [];
  String q='',group='',category='',brand='';
  List returnGroup = [];
  List returnCategory = [];
  List returnBrand = [];
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
  Future loadCategory()async{
    var cat = await _helper.getData(CategoryQuery.TABLE_NAME);
    print(cat);
    List catagories = [];
    cat.forEach((element) {
      catagories.add({
        "id": element['id_category'],
        "title": element['title'],
        "isSelected":false
      });
    });
    setState(() {
      returnCategory=catagories;
    });
  }
  Future loadBrand()async{
    var br = await _helper.getData(BrandQuery.TABLE_NAME);
    List brand = [];
    br.forEach((element) {
      brand.add({
        "id": element['id_brand'],
        "title": element['title'],
        "image": element['image'],
        "isSelected":false
      });
    });
    setState(() {
      returnBrand=brand;
    });
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
    await getPromo();
    await countCart();
    var totalProduct = await _helper.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=?",[widget.id]);
    await FunctionHelper().setSession("id_tenant", widget.id);
    if(totalProduct.length<1){
      await _helper.delete(ProductQuery.TABLE_NAME, "id_tenant", widget.id);
      await FunctionHelper().insertProduct(widget.id);
    }
    if(param=='refresh'){
      await _helper.delete(ProductQuery.TABLE_NAME, "id_tenant", widget.id);
      await FunctionHelper().insertProduct(widget.id);
    }
    if(totalProduct.length<5&&totalProduct.length>1&&param!='refresh'){
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBrand();
    loadGroup();
    loadCategory();
    loadData('');
    controller = new ScrollController()..addListener(_scrollListener);
    getSite();
  }
  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: buildContents(context),
    );
  }


  Widget buildContents(BuildContext context){
    return RefreshWidget(
      widget: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverAppBar(
              title: WidgetHelper().textQ("${widget.nama}", 12,SiteConfig().secondColor,FontWeight.bold),
              stretch: true,
              onStretchTrigger: (){
                print("CIK");
                return;
              },
              // brightness: site?Brightness.dark:Brightness.light,
              // backgroundColor: SiteConfig().darkMode,
              snap: false,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              leading: new IconButton(
                icon: new Icon(UiIcons.home, color:SiteConfig().secondColor,size: 28,),
                onPressed:null,
              ),
              actions: <Widget>[
                new CartWidget(
                  iconColor: SiteConfig().secondColor,
                  labelColor:Colors.redAccent,
                  labelCount: totalCart,
                  callback: (){
                    if(totalCart>0){
                      WidgetHelper().myPushAndLoad(context, CartScreen(idTenant: widget.id), countCart);
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
                        WidgetHelper().myModal(
                            context,
                            ModalSearch(mode:site,idTenant:widget.id,callback:(par){
                              q=par;
                              isLoading=true;
                              getProduct();
                            })
                        );
                        // insertFavorite();
                        // Navigator.of(context).pushNamed('/Tabs', arguments: 1);
                      },
                      child: Icon(UiIcons.filter,size: 30,color:SiteConfig().secondColor),
                    )
                ),
              ],
              // backgroundColor: Theme.of(context).primaryColor,
              expandedHeight: 200,
              elevation: 0,
              flexibleSpace:sliderQ(context),
            ),
            SliverStickyHeader(
              header: Container(
                color: site?SiteConfig().darkMode:Colors.white,
                height: 65,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        itemCount: returnBrand.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          double _marginLeft = 0;
                          (index == 0) ? _marginLeft = 12 : _marginLeft = 0;
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            margin: EdgeInsets.only(left:_marginLeft, top: 10, bottom: 10),
                            child: WidgetHelper().myPress((){
                              setState(() {
                                brand=returnBrand[index]['id'];
                                isLoading=true;
                              });
                              getProduct();
                            }, AnimatedContainer(
                              duration: Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: brand==returnBrand[index]['id']?site?Colors.white:SiteConfig().darkMode:SiteConfig().mainColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: <Widget>[
                                  AnimatedSize(
                                    duration: Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                    vsync: this,
                                    child: WidgetHelper().textQ(returnBrand[index]['title'],12.0, brand==returnBrand[index]['id']?site?Colors.black87:Colors.white:Colors.white,FontWeight.bold),
                                  )
                                ],
                              ),
                            )),
                            // child: InkWell(
                            //   splashColor: Theme.of(context).accentColor,
                            //   highlightColor: Theme.of(context).accentColor,
                            //   onTap: () {
                            //     setState(() {
                            //       brand=returnBrand[index]['id'];
                            //       isLoading=true;
                            //     });
                            //     getProduct();
                            //   },
                            //   child: AnimatedContainer(
                            //     duration: Duration(milliseconds: 350),
                            //     curve: Curves.easeInOut,
                            //     padding: EdgeInsets.symmetric(horizontal: 15),
                            //     decoration: BoxDecoration(
                            //       color: brand==returnBrand[index]['id']?Theme.of(context).primaryColor:SiteConfig().mainColor,
                            //       borderRadius: BorderRadius.circular(50),
                            //     ),
                            //     child: Row(
                            //       children: <Widget>[
                            //         AnimatedSize(
                            //           duration: Duration(milliseconds: 350),
                            //           curve: Curves.easeInOut,
                            //           vsync: this,
                            //           child: WidgetHelper().textQ(returnBrand[index]['title'],12.0, brand==returnBrand[index]['id']?Colors.black87:Colors.white,FontWeight.bold),
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
              ),
              sliver:SliverList(
                delegate: SliverChildListDelegate([
                  Offstage(
                    offstage: false,
                    child: Container(

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          isLoading?Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            child: LoadingProductTenant(tot: 10),
                          ):returnProductLocal.length>0?Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              child:new StaggeredGridView.countBuilder(
                                // padding: EdgeInsets.all(0.0),
                                primary: false,
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 4,
                                itemCount: returnProductLocal.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var valProductServer =  returnProductLocal[index];
                                  return ProductWidget(
                                    id: valProductServer['id_product'],
                                    gambar: valProductServer['gambar'],
                                    title: '${valProductServer['title']}\n${valProductServer['brand']}',
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

                ]),
              ),
            )

          ]
      ),
      callback: (){_handleRefresh();},
    );
  }
  Widget sliderQ(BuildContext context){
    return FlexibleSpaceBar(
      stretchModes: [
        StretchMode.zoomBackground,
        StretchMode.blurBackground,
        StretchMode.fadeTitle
      ],
      collapseMode: CollapseMode.none,
      background:  isLoadingSlider?Padding(padding: EdgeInsets.all(20.0),child: SkeletonFrame(width: double.infinity,height:250)):Stack(
        alignment: AlignmentDirectional.topStart,
        children: <Widget>[
          CarouselSlider(
              options: CarouselOptions(
                // viewportFraction: 1.0,
                autoPlay: true,
                height: 300,
                onPageChanged: (index,reason) {
                  print(index);
                  setState(() {
                    _current=index;
                  });
                },
              ),
              items:globalPromoModel.result.data.map((e){
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      // height: 70,
                      child:Image.asset(
                        "assets/img/slide1.jpg",
                        fit: BoxFit.fill,
                        width:
                        MediaQuery.of(context).size.width,
                      ),
                    );
                  },
                );
              }).toList()
          ),
          Positioned(
            top: 200,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: globalPromoModel.result.data.map((e){
                  return Container(
                    width: 20.0,
                    height: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: _current == globalPromoModel.result.data.indexOf(e)
                            ? Theme.of(context).hintColor
                            : Theme.of(context).hintColor.withOpacity(0.3)),
                    // color: _current ==  detailProductTenantModel.result.listImage.indexOf(e)? Theme.of(context).hintColor : Theme.of(context).hintColor.withOpacity(0.3)),
                  );
                }).toList()
            ),
          )
        ],
      ),
    );
  }

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
      var res = await db.getRow("SELECT * FROM ${ProductQuery.TABLE_NAME} WHERE id_tenant=? and title LIKE '%${qController.text}%' or deskripsi LIKE '%${qController.text}%'",[widget.idTenant]);
      // var res = await db.readData(ProductQuery.TABLE_NAME, widget.idTenant,colWhere: ['title'],valWhere: ['${qController.text}']);
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
              color: Theme.of(context).focusColor.withOpacity(0.1),
              // color:widget.mode?Theme.of(context).focusColor.withOpacity(0.15):SiteConfig().secondColor,
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
              flex: resClick.length,
              child: Scrollbar(child: ListView.separated(
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
                      title: WidgetHelper().textQ("${resProduct[index]['title']}",10,widget.mode?Colors.white:Colors.black87,FontWeight.normal),
                    );
                  },
                  separatorBuilder:(context,index){
                    return  Divider(height: 1);
                  },
                  itemCount: resProduct.length
              ))
          ):
          (resSearch.length>0?Expanded(
              flex: resClick.length,
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
                      title: WidgetHelper().textQ("${resSearch[index]['title']}",10,widget.mode?Colors.white:Colors.black87,FontWeight.normal),
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
          resClick.length>0?WidgetHelper().titleQ("Barang yang pernah dilihat",param: ""):Container(),
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
                                                    child: WidgetHelper().textQ("${val['tenant']}", 12, SiteConfig().mainColor, FontWeight.normal),
                                                  ),
                                                  Positioned(
                                                    child:Icon(UiIcons.home,color:SiteConfig().mainColor,size: 8),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(child: WidgetHelper().textQ("${val['title']}", 12, widget.mode?Colors.white:SiteConfig().darkMode, FontWeight.normal)),
                                                  int.parse(val['disc1'])==0?Container():SizedBox(width: 5),
                                                  int.parse(val['disc1'])==0?Container():WidgetHelper().textQ("( diskon ${val['disc1']} + ${val['disc2']} )", 10,Colors.grey,FontWeight.normal),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga_coret']))}", 10,Colors.green,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                                                  SizedBox(width: 5),
                                                  WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga']))}", 12,Colors.green,FontWeight.normal),
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