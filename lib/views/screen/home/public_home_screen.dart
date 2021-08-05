import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/skeleton_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/promo/global_promo_model.dart';
import 'package:netindo_shop/model/tenant/list_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/home/home_screen.dart';
import 'package:netindo_shop/views/screen/home/private_home_screen.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/screen/promo/list_promo_screen.dart';
import 'package:netindo_shop/views/widget/cart_widget.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:netindo_shop/views/widget/slider_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../../main.dart';

class PublicHomeScreen extends StatefulWidget {
  // BuildContext context;
  // static Color cik = Theme.of(context).focusColor.withOpacity(0.1);
  final mode;
  PublicHomeScreen({this.mode});
  @override
  _PublicHomeScreenState createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  bool isLoadingLocation=false;
  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress = "${place.thoroughfare}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
        isLoadingLocation=false;
      });
    } catch (e) {
      print(e);
    }
  }
  ListTenantModel listTenantModel;
  bool isLoading=false,isLoadingPromo=false;
  bool isTimeout=false,isTimeoutPromo=false;
  int perpage=0;
  int lastpage=0;
  int countTenant=0;
  final DatabaseConfig _helper = new DatabaseConfig();
  List returnTenant=[];
  Future getTenant()async{
    var res = await BaseProvider().getProvider('tenant?page=1', listTenantModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isTimeout=true;
        isLoading=false;
      });
    }
    else{
      if(res is ListTenantModel){
        listTenantModel = ListTenantModel.fromJson(res.toJson());
        setState(() {
          isTimeout=false;
          isLoading=false;
        });
      }
    }
  }


  Future<void> _handleRefresh()async {
    await _helper.deleteAll(TenantQuery.TABLE_NAME);
    await FunctionHelper().handleRefresh(()=>getTenant());
  }

  GlobalPromoModel globalPromoModel;

  Future getPromo()async{
    var res = await BaseProvider().getProvider("promo?page=1", globalPromoModelFromJson);
    print(res);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isLoadingPromo=false;
        isTimeoutPromo=true;
      });
    }
    else{
      if(res is GlobalPromoModel){
        GlobalPromoModel result = res;
        setState(() {
          globalPromoModel = GlobalPromoModel.fromJson(result.toJson());
          isLoadingPromo=false;
          isTimeoutPromo=false;
        });
      }
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    isLoadingPromo=true;
    isLoadingLocation=true;
    getTenant();
    getPromo();
    _getCurrentLocation();

  }
  bool changeTap=false;
  int _current=0;
  @override
  Widget build(BuildContext context){
    if(!isLoading){
      if(listTenantModel.result.data.length==1){
        return HomeScreen(id: listTenantModel.result.data[0].id,nama:listTenantModel.result.data[0].nama);
      }
    }
    return buildContents(context);
  }

  Widget buildContents(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return RefreshWidget(
      widget: isTimeout||isTimeoutPromo?TimeoutWidget(callback: ()async{
        setState(() {
          isTimeout=false;
          isLoading=true;
          isTimeoutPromo=false;
          isLoadingPromo=true;
        });
        getTenant();
        getPromo();
      }):CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              stretch: true,
              onStretchTrigger: (){
                return;
              },
              title: WidgetHelper().textQ("Selamat datang & selamat belanja", scaler.getTextSize(9),SiteConfig().secondColor,FontWeight.bold),
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              snap: false,
              floating: false,
              pinned: true,
              expandedHeight:scaler.getHeight(20),
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
                      // boxShadow: [
                      //   BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, -2)),
                      // ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding:scaler.getPadding(0.5,2),
                          child:WidgetHelper().myPress((){WidgetHelper().myPush(context,ListPromoScreen());},
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  WidgetHelper().textQ("Lihat semua promo",scaler.getTextSize(9),SiteConfig().secondColor,FontWeight.bold,textAlign: TextAlign.right),
                                  SizedBox(width: scaler.getWidth(1)),
                                  Icon(Ionicons.ios_arrow_dropright_circle,color: SiteConfig().secondColor,size: scaler.getTextSize(12),)
                                ],
                              ),color:Colors.black38

                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left:scaler.getHeight(1),right:scaler.getHeight(1)),
                          child: isLoadingLocation?WidgetHelper().baseLoading(context,Container(
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: double.infinity,
                              height: 40.0,
                          )):WidgetHelper().myPress((){},Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).focusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              // border: Border.all(width:1.0,color: site?Colors.grey:Colors.grey[200])
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.place,color: SiteConfig().secondColor,size: scaler.getTextSize(12)),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    if (_currentPosition != null && _currentAddress != null)
                                      Expanded(
                                        child: WidgetHelper().textQ(_currentAddress,scaler.getTextSize(9),SiteConfig().darkMode,FontWeight.normal),
                                      ),

                                  ],
                                ),
                              ],
                            ),
                          )),
                        ),
                        Container(
                          padding: EdgeInsets.only(left:scaler.getHeight(1),right:scaler.getHeight(1),top:0),
                          child: isLoading?LoadingTenant():tenantServer(),
                        ),
                        // Padding(
                        //   padding: scaler.getPadding(1,2),
                        //   child: WidgetHelper().titleQ(context,"${StringConfig.selesaikanPesananAnda}",color:SiteConfig().secondColor,param: '',callback: (){},icon:AntDesign.shoppingcart),
                        // ),
                        Container(
                          padding: EdgeInsets.only(left:scaler.getHeight(1),right:scaler.getHeight(1),top:0),
                          child: isLoading?Container():StaggeredGridView.countBuilder(
                            padding: EdgeInsets.all(0.0),
                            shrinkWrap: true,
                            primary: false,
                            crossAxisCount: 3,
                            itemCount:  listTenantModel.result.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              var val=listTenantModel.result.data[index];
                              return WidgetHelper().myPress(
                                  (){
                                    WidgetHelper().myPush(context,CartScreen(idTenant:val.id));
                                  },
                                  Container(
                                    padding: EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context).focusColor.withOpacity(0.1),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: AlignmentDirectional.center,
                                          children: <Widget>[
                                            Padding(
                                              padding:scaler.getPadding(0,0),
                                              child: Icon(
                                                AntDesign.shoppingcart,
                                                color:Theme.of(context).hintColor,
                                                size: scaler.getTextSize(15),
                                              ),
                                            ),
                                            Positioned(
                                                right: 0.0,
                                                top:5.0,
                                                child: Container(
                                                  padding: EdgeInsets.only(top:0.0),
                                                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                  constraints: BoxConstraints(minWidth: 10, maxWidth: 10, minHeight: 10, maxHeight: 10),
                                                )
                                            ),
                                          ],
                                        ),
                                        SizedBox(height:5.0),
                                        WidgetHelper().textQ("${val.nama}",scaler.getTextSize(9),SiteConfig().secondColor, FontWeight.normal,textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                  color: Colors.black38
                              );
                            },
                            staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
                            mainAxisSpacing: scaler.getWidth(1),
                            crossAxisSpacing:scaler.getWidth(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ]),
            )
          ]
      ),
      callback: (){_handleRefresh();},
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
      background:  isLoadingPromo?Padding(padding: EdgeInsets.all(0.0),child: SkeletonFrame(width: double.infinity,height:scaler.getHeight(20))):Stack(
        alignment: AlignmentDirectional.topStart,
        children: <Widget>[
          CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1.0,
                height: scaler.getHeight(23),
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),

                      ),
                    );
                  },
                );
              }).toList()
          ),
          Positioned(
            top: scaler.getHeight(17),
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



  Widget tenantLocal(){
    ScreenScaler scaler = ScreenScaler()..init(context);

    return returnTenant.length>0?StaggeredGridView.countBuilder(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 3,
      itemCount: returnTenant.length,
      padding: EdgeInsets.only(top: scaler.getHeight(1)),
      itemBuilder: (BuildContext context, int index) {
        return WidgetHelper().myPress(
            (){
              WidgetHelper().myPush(context,HomeScreen(id: returnTenant[index]['id_tenant'],nama:returnTenant[index]['nama']));
            },
            Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).focusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(width:1.0,color: site?Colors.grey:Colors.grey[200])
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl:returnTenant[index]['logo'],
                    width: double.infinity ,
                    fit:BoxFit.scaleDown,
                    height: scaler.getHeight(10),
                    placeholder: (context, url) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
                    errorWidget: (context, url, error) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: double.infinity,),
                  )

                ],
              ),
            ),
            color: Colors.black38
        );
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
      mainAxisSpacing: scaler.getWidth(1),
      crossAxisSpacing:scaler.getWidth(1),
    ):EmptyTenant();
  }

  Widget tenantServer(){
    ScreenScaler scaler = ScreenScaler()..init(context);

    return listTenantModel.result.data.length>0?StaggeredGridView.countBuilder(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 3,
      padding: EdgeInsets.only(top: scaler.getHeight(1)),
      itemCount: listTenantModel.result.data.length,
      itemBuilder: (BuildContext context, int index) {
        return WidgetHelper().myPress(
                (){
              WidgetHelper().myPush(context,HomeScreen(id: listTenantModel.result.data[index].id,nama:listTenantModel.result.data[index].nama));
            },
            Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                // border: Border.all(width:1.0,color: site?Colors.grey:Colors.grey[200])
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(10),topRight:Radius.circular(10)),
                    child: Image.network(
                      listTenantModel.result.data[index].logo,
                      width: MediaQuery.of(context).size.width/1,
                      height: scaler.getHeight(10),
                      fit: BoxFit.scaleDown,
                    ),
                  ),

                ],
              ),
            ),
            color:Colors.black38
        );
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
      mainAxisSpacing: scaler.getWidth(1),
      crossAxisSpacing:scaler.getHeight(1),
    ):EmptyTenant();
  }

}
