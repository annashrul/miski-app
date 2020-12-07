import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
import 'package:netindo_shop/views/screen/home/private_home_screen.dart';
import 'package:netindo_shop/views/screen/product/cart_screen.dart';
import 'package:netindo_shop/views/screen/promo/list_promo_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:netindo_shop/views/widget/slider_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';

class PublicHomeScreen extends StatefulWidget {
  @override
  _PublicHomeScreenState createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  ListTenantModel listTenantModel;
  bool isLoading=false,isLoadingPromo=false;
  bool isTimeout=false,isTimeoutPromo=false;
  int perpage=0;
  int lastpage=0;
  int countTenant=0;
  final DatabaseConfig _helper = new DatabaseConfig();
  List returnTenant=[];
  bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }
  Future getTenant()async{
    await getSite();
    print("INSETR BERES");
    final countTbl = await _helper.queryRowCount(TenantQuery.TABLE_NAME);
    if(countTbl>1){
      final tenant = await _helper.getData(TenantQuery.TABLE_NAME);
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
          setState(() {
            isTimeout=false;
            isLoading=false;
            listTenantModel = ListTenantModel.fromJson(res.toJson());
          });
          insertTenant(listTenantModel.result.perPage,listTenantModel.result.lastPage);
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
      setState(() {
      });
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
        isTimeoutPromo=false;
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
    getTenant();
    getPromo();
  }
  bool changeTap=false;
  int _current=0;
  @override
  Widget build(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent));
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    return RefreshWidget(
     widget: isTimeout||isTimeoutPromo?TimeoutWidget(callback: ()async{
       setState(() {
         isTimeout=false;
         isLoading=true;
       });
       getTenant();
     }):ListView(
       children: <Widget>[
         Container(
           height: 250,
           width: MediaQuery.of(context).size.width,
           decoration: BoxDecoration(
             color: Colors.grey[200],
           ),
           child:isLoadingPromo?SkeletonFrame(width: double.infinity,height:250):Stack(
             alignment: AlignmentDirectional.bottomEnd,
             children: <Widget>[
               CarouselSlider(
                 options: CarouselOptions(
                   enableInfiniteScroll: true,
                   height: 250,
                   enlargeCenterPage: false,
                   viewportFraction: 1,
                   onPageChanged: (index, reason) {
                     setState(() {
                       _current = index;
                     });
                   },
                 ),
                 items: globalPromoModel.result.data.map((slide) => Container(
                   width: double.infinity,
                   height: 250,
                   child: Container(
                     width: double.infinity,
                     // child: Image.network(
                     //   slide.gambar,
                     //   fit: BoxFit.fill,
                     //   width:
                     //   MediaQuery.of(context).size.width,
                     // ),
                     child: Image.asset(
                       "assets/img/slide1.jpg",
                       fit: BoxFit.fill,
                       width:
                       MediaQuery.of(context).size.width,
                     ),
                   ),
                 )).toList(),
               ),
               Positioned(
                 bottom: 25,
                 right: 41,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: globalPromoModel.result.data.map((slide) {
                     return Container(
                       width: 20.0,
                       height: 3.0,
                       margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.all(
                             Radius.circular(8),
                           ),
                           color: _current == globalPromoModel.result.data.indexOf(slide)
                               ? Theme.of(context).hintColor
                               : Theme.of(context).hintColor.withOpacity(0.3)),
                     );
                   }).toList(),
                 ),
               ),
             ],
           ),
         ),
         WidgetHelper().titleQ(
           "",
           color:site?SiteConfig().mainColor:SiteConfig().secondColor,
           param: StringConfig().lihatSemuaPromo,
           callback: (){
             WidgetHelper().myPush(context,ListPromoScreen());
           },
           // icon: Icon(UiIcons.favorites, color: site?Colors.white:Theme.of(context).hintColor,)
         ),
         Container(
           padding: EdgeInsets.only(left:20,right:20,top:10),
           child: isLoading?LoadingTenant():returnTenant.length>0?tenantLocal():tenantServer(),
         ),
         WidgetHelper().titleQ("${StringConfig().selesaikanPesananAnda}",color:site?Colors.white:SiteConfig().secondColor,param: '',callback: (){},icon: Icon(
           UiIcons.favorites,
           color: site?Colors.white:Theme.of(context).hintColor,
         )),
         Container(
           padding: EdgeInsets.only(left:20,right:20,top:10),
           child: StaggeredGridView.countBuilder(
             shrinkWrap: true,
             primary: false,
             crossAxisCount: 3,
             itemCount: 10,
             itemBuilder: (BuildContext context, int index) {
               return WidgetHelper().myPress(
                   (){
                     WidgetHelper().myPush(context,CartScreen(idTenant: '272da72e-0287-4ab9-ac9f-ee3498fcdc97'));
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
                                 color:site?Colors.white:Theme.of(context).hintColor,
                                 size: 40,
                               ),
                             ),
                             Positioned(
                                 right: 0.0,
                                 top:5.0,
                                 child: Container(
                                   child: WidgetHelper().textQ("1",9,Theme.of(context).primaryColor, FontWeight.bold,textAlign: TextAlign.center),
                                   padding: EdgeInsets.only(top:0.0),
                                   decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.all(Radius.circular(10))),
                                   constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
                                 )
                             ),
                             // WidgetHelper().textQ("NAMA TENANT",12,Colors.grey[200], FontWeight.bold,textAlign: TextAlign.center),
                           ],
                         ),
                         SizedBox(height:5.0),
                         WidgetHelper().textQ("Bandung Trade Mall",10,site?Colors.grey[200]:Colors.grey, FontWeight.bold,textAlign: TextAlign.center),
                       ],
                     ),
                   ),
                   color: site?Colors.grey[200]:Colors.black38
               );
             },
             staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
             mainAxisSpacing: 15.0,
             crossAxisSpacing: 15.0,
           ),
         ),

       ],
     ),
      callback: (){_handleRefresh();},
    );
  }


  Widget tenantServer(){
    return listTenantModel.result.data.length>0?StaggeredGridView.countBuilder(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 3,
      itemCount: listTenantModel.result.data.length,
      itemBuilder: (BuildContext context, int index) {
        return new InkWell(
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).accentColor.withOpacity(0.08),
          onTap: (){
            WidgetHelper().myPush(context,PrivateHomeScreen(id: listTenantModel.result.data[index].id,nama:listTenantModel.result.data[index].nama));
          },
          child: Container(
            padding: EdgeInsets.only(bottom:5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]),
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
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left:10,top:5,right:10),
                  child: WidgetHelper().textQ(listTenantModel.result.data[index].nama, 12, site?Colors.white:SiteConfig().darkMode,FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 15.0,
    ):EmptyTenant();
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
              WidgetHelper().myPush(context,PrivateHomeScreen(id: returnTenant[index]['id_tenant'],nama:returnTenant[index]['nama']));
            },
            Container(
              padding: EdgeInsets.only(bottom:5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                  border: Border.all(width:2.0,color: site?Colors.grey:Colors.grey[200])

                  // border: Border.all(width:3.0,color: Colors.grey[200]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft:Radius.circular(10),topRight:Radius.circular(10)),
                    child: Image.network(
                      returnTenant[index]['logo'],
                      width: MediaQuery.of(context).size.width/1,
                      height: 110.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:10,top:5,right:10),
                    child: WidgetHelper().textQ(returnTenant[index]['nama'], 12, site?Colors.white:Colors.grey,FontWeight.bold,textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          color: site?Colors.grey[200]:Colors.black38
        );
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 15.0,
    ):EmptyTenant();
  }

}
