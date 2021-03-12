import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
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
      print("LOKASI ${place.name}");
      print("LOKASI ${place.administrativeArea}");
      print("LOKASI ${place.country}");
      print("LOKASI ${place.isoCountryCode}");
      print("LOKASI ${place.locality}");
      print("LOKASI ${place.postalCode}");
      print("LOKASI ${place.subAdministrativeArea}");
      print("LOKASI ${place.subLocality}");
      print("LOKASI ${place.subThoroughfare}");
      print("LOKASI ${place.thoroughfare}");
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
    final countTbl = await _helper.queryRowCount(TenantQuery.TABLE_NAME);
    if(countTbl>1){
      final tenant = await _helper.getData(TenantQuery.TABLE_NAME);
      print("USE DATA TENANT LOCAL SERVER");
      setState(() {
        returnTenant = tenant;
        isTimeout=false;
        isLoading=false;
        countTenant=countTbl;
      });
    }
    else{
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
          insertTenant(listTenantModel.result.perPage,listTenantModel.result.lastPage);
          print("USE DATA TENANT SERVER");
          setState(() {
            isTimeout=false;
            isLoading=false;
          });
        }
      }
      await FunctionHelper().getFilterLocal('');
    }
  }

  Future insertTenant(perpage,lastpage)async{
    ListTenantModel _listTenantModel;
    var res = await BaseProvider().getProvider('tenant?page=1&perpage=${perpage*lastpage}', listTenantModelFromJson);
    if(res is ListTenantModel){
      ListTenantModel result = res;
      setState(() {});
      result.result.data.forEach((element)async {
        var data={
          "id_tenant":element.id.toString(),
          "nama":element.nama.toString(),
          "email":element.email.toString(),
          "telp":element.telp.toString(),
          "alamat":element.alamat.toString(),
          "long":element.long.toString(),
          "lat":element.lat.toString(),
          "status":element.status.toString(),
          "logo":element.logo.toString(),
          "unique_code":element.uniqueCode.toString(),
          "is_favorite":"false",
          "is_click":"false"
        };
        await _helper.insert(TenantQuery.TABLE_NAME, data);
      });

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
    return buildContents(context);
  }

  Widget buildContents(BuildContext context){
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
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              snap: true,
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              expandedHeight: 200,
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
                          padding: EdgeInsets.only(left:20,right:10,top:0,bottom: 10),
                          child:WidgetHelper().myPress((){WidgetHelper().myPush(context,ListPromoScreen());},
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  WidgetHelper().textQ("Lihat semua promo",12,SiteConfig().secondColor,FontWeight.bold,textAlign: TextAlign.right),
                                  Icon(Icons.arrow_right,color: SiteConfig().secondColor,)
                                ],
                              ),color:Colors.black38

                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left:20,right:20),
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
                                    Icon(UiIcons.placeholder,color: SiteConfig().darkMode),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          if (_currentPosition != null && _currentAddress != null)
                                            WidgetHelper().textQ(_currentAddress,10,SiteConfig().darkMode,FontWeight.normal)
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ),
                        Container(
                          padding: EdgeInsets.only(left:20,right:20,top:0),
                          child: isLoading?LoadingTenant():returnTenant.length>0?tenantLocal():tenantServer(),
                        ),
                        WidgetHelper().titleQ("${StringConfig().selesaikanPesananAnda}",color:SiteConfig().secondColor,param: '',callback: (){},icon: Icon(
                          UiIcons.favorites,
                          color: Theme.of(context).hintColor,
                        )),
                        Container(
                          padding: EdgeInsets.only(left:20,right:20,top:0),
                          child: StaggeredGridView.countBuilder(
                            shrinkWrap: true,
                            primary: false,
                            crossAxisCount: 3,
                            itemCount:  returnTenant.length,
                            itemBuilder: (BuildContext context, int index) {
                              print(returnTenant);
                              return WidgetHelper().myPress(
                                  (){
                                    WidgetHelper().myPush(context,CartScreen(idTenant:returnTenant[index]['id_tenant']));
                                  },
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Theme.of(context).focusColor.withOpacity(0.4),
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: AlignmentDirectional.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 0),
                                              child: Icon(
                                                UiIcons.shopping_cart,
                                                color:Theme.of(context).hintColor,
                                                size: 40,
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
                                            // WidgetHelper().textQ("NAMA TENANT",12,Colors.grey[200], FontWeight.bold,textAlign: TextAlign.center),
                                          ],
                                        ),
                                        SizedBox(height:5.0),
                                        WidgetHelper().textQ("${returnTenant[index]['nama'].toUpperCase()}",10,Colors.grey, FontWeight.normal,textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                  color: Colors.black38
                              );
                            },
                            staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
                            mainAxisSpacing: 15.0,
                            crossAxisSpacing: 15.0,
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
    return FlexibleSpaceBar(
      stretchModes: [
        StretchMode.zoomBackground,
        StretchMode.blurBackground,
        StretchMode.fadeTitle
      ],

      collapseMode: CollapseMode.parallax,
      background:  isLoadingPromo?Padding(padding: EdgeInsets.all(20.0),child: SkeletonFrame(width: double.infinity,height:250)):Stack(
        alignment: AlignmentDirectional.topStart,
        children: <Widget>[
          CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1.0,
                height: 200,
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
            top: 180,
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
    return returnTenant.length>0?StaggeredGridView.countBuilder(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 3,
      itemCount: returnTenant.length,
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
                    height: 110.0,
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
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 15.0,
    ):EmptyTenant();
  }

  Widget tenantServer(){
    return listTenantModel.result.data.length>0?StaggeredGridView.countBuilder(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 3,
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
                      height: 110.0,
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
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 15.0,
    ):EmptyTenant();
  }

}
