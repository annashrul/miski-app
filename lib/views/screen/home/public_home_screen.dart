import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/list_tenant_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/home/private_home_screen.dart';
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
  bool isLoading=false;
  bool isTimeout=false;
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
    // await _helper.deleteAll(ProvinceQuery.TABLE_NAME);
    // await _helper.deleteAll(CityQuery.TABLE_NAME);
    // await _helper.deleteAll(DistrictQuery.TABLE_NAME);
    // final countTableProvince = await _helper.queryRowCount(ProvinceQuery.TABLE_NAME);
    // final countTableCity = await _helper.queryRowCount(CityQuery.TABLE_NAME);
    // final countTableDistrict = await _helper.queryRowCount(DistrictQuery.TABLE_NAME);
    // var resProv = await FunctionHelper().baseProvince();
    // var resCity = await FunctionHelper().baseCity();
    // var resDistrict = await FunctionHelper().baseDistrict();
    // if(countTableProvince<1){
    //   int no=1;
    //   var resProv = await FunctionHelper().baseProvince();
    //   resProv.forEach((element)async {
    //     no++;
    //     final dataProv={
    //       "id_province":"${element.id.toString()}",
    //       "name":"${element.name.toString()}",
    //     };
    //     await _helper.insert(ProvinceQuery.TABLE_NAME, dataProv);
    //     print("################################# $no INSERT PROVINCE ${element.name} SUCCESS ########################");
    //   });
    // }
    // if(countTableCity<1){
    //   var resCity = await FunctionHelper().baseCity();
    //   resCity.forEach((element)async {
    //     final dataCity={
    //       "id_city": "${element.id.toString()}",
    //       "id_province": "${element.provinsi.toString()}",
    //       "name": "${element.name.toString()}",
    //       "postal_code": ""
    //     };
    //     await _helper.insert(CityQuery.TABLE_NAME, dataCity);
    //     print("################################# INSERT CITY ${element.name} SUCCESS ########################");
    //   });
    // }
    // if(countTableDistrict<1){
    //   var resDistrict = await FunctionHelper().baseDistrict();
    //   resDistrict.forEach((element)async {
    //     final dataDistrict={
    //       "id_district": "${element.id.toString()}",
    //       "id_city": "${element.kota.toString()}",
    //       "name": "${element.kecamatan.toString()}"
    //     };
    //     await _helper.insert(DistrictQuery.TABLE_NAME, dataDistrict);
    //     print("################################# INSERT DISTRICT ${element.kecamatan} SUCCESS ########################");
    //   });
    // }
    // print("COUNT PROV ${resProv.length} - $countTableProvince");
    // print("COUNT CITY ${resCity.length} - $countTableCity");
    // print("COUNT DITSRICT ${resDistrict.length} - $countTableDistrict");
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

      final countTbl = await _helper.queryRowCount(TenantQuery.TABLE_NAME);
    }
  }
  Future<void> _handleRefresh()async {
    await _helper.deleteAll(TenantQuery.TABLE_NAME);
    await FunctionHelper().handleRefresh(()=>getTenant());
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    getTenant();
    // getSite();
  }

  @override
  Widget build(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent));
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    return RefreshWidget(
     widget: isTimeout?TimeoutWidget(callback: ()async{
       setState(() {
         isTimeout=false;
         isLoading=true;
       });
       await getTenant();
     }):ListView(
       children: <Widget>[
         Container(
           height: 250,
           width: MediaQuery.of(context).size.width,
           decoration: BoxDecoration(
             color: Color(0xFF05AA10),
           ),
           child:SliderWidget(),
         ),
         WidgetHelper().titleQ("Pilihan Terbaik ${SiteConfig().siteName}",color:site?Colors.white:SiteConfig().secondColor,param: '',callback: (){},icon: Icon(
           UiIcons.favorites,
           color: site?Colors.white:Theme.of(context).hintColor,
         )),
         Container(
           padding: EdgeInsets.only(left:20,right:20,top:10),
           child: isLoading?LoadingTenant():(returnTenant.length>0?tenantLocal():tenantServer()),
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
        return new InkWell(
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).accentColor.withOpacity(0.08),
          onTap: (){
            WidgetHelper().myPush(context,PrivateHomeScreen(id: returnTenant[index]['id_tenant'],nama:returnTenant[index]['nama']));
          },
          child: Container(
            padding: EdgeInsets.only(bottom:5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]),
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
                  child: WidgetHelper().textQ(returnTenant[index]['nama'], 12, site?Colors.white:SiteConfig().darkMode,FontWeight.normal),
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

}
