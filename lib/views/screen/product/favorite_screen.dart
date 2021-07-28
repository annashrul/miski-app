import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

import 'detail_product_screen.dart';

class FavoriteScreen extends StatefulWidget {

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final DatabaseConfig _helper = new DatabaseConfig();
  ScrollController controller;
  List resFavoriteProduct=[];
  bool isLoading=false,isLoadmore=false;
  int perpage=15;
  int total=0;
  Future deleteFavorite(id)async{
    final res = await _helper.update(ProductQuery.TABLE_NAME, {"id":id.toString(),"is_favorite":"false"});
    if(res==true){
      WidgetHelper().showFloatingFlushbar(context,"success","data berhasil dihapus dari favorite anda");
      getFavorite();
    }
    else{
      WidgetHelper().showFloatingFlushbar(context,"failed","Terjadi kesalahan");
    }
  }
  Future getFavorite()async{
    final countFav = await _helper.getWhere(ProductQuery.TABLE_NAME, "is_favorite","true","");
    final res = await _helper.getWhere(ProductQuery.TABLE_NAME,"is_favorite","true","$perpage");
    setState(() {
      total = countFav.length;
      resFavoriteProduct = res;
      isLoading=false;
      isLoadmore=false;
    });
  }
  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if(perpage<total){
        setState((){
          perpage+=7;
          isLoadmore=true;
        });
        getFavorite();
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
    controller = new ScrollController()..addListener(_scrollListener);
    isLoading=true;
    getFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading?LoadingCart(total: 10):resFavoriteProduct.length>0?Container(
      padding: EdgeInsets.all(0.0),
      child: Column(
        children: [
          Expanded(
            flex: 17,
            child: buildContent(context),
          ),
          isLoadmore?Expanded(
            flex: 3,
            child: LoadingCart(total: 1)
          ):Container()
        ],
      ),
    ):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EmptyTenant()
      ],
    );
  }


  Widget buildContent(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return ListView.separated(
      controller: controller,
      itemCount: resFavoriteProduct.length,
      itemBuilder: (context,index){
        var val = resFavoriteProduct[index];
        print(val);
        return Dismissible(
          key: Key(hashCode.toString()),
          background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: scaler.getPadding(0,0),
                child: Icon(
                  FontAwesome.trash,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          confirmDismiss: (DismissDirection direction)async{
            return await WidgetHelper().notifDialog(context,"Informasi !!", "Anda yakin akan menghapus data ini ??", (){Navigator.pop(context);}, (){
              Navigator.pop(context);
              deleteFavorite(val['id']);
            });
          },

          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                InkWell(
                  onTap: (){
                    WidgetHelper().myPush(context,DetailProducrScreen(id: val['id_product']));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).focusColor.withOpacity(0.15),

                      // color: widget.mode?Colors.white:Theme.of(context).primaryColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                      ],
                      // borderRadius: BorderRadius.circular(10.0)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        WidgetHelper().baseImage(val['gambar'],width: scaler.getWidth(15),height: scaler.getHeight(5)),
                        SizedBox(width:scaler.getWidth(2)),
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height:scaler.getHeight(0.5)),
                                    Stack(
                                      alignment: AlignmentDirectional.topEnd,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(right:10.0),
                                          child: WidgetHelper().textQ("${val['tenant']}", scaler.getTextSize(9), SiteConfig().mainColor, FontWeight.bold),
                                        ),
                                        Positioned(
                                          child:Icon(AntDesign.home,color:SiteConfig().mainColor,size: 8),
                                        )
                                      ],
                                    ),
                                    SizedBox(height:scaler.getHeight(0.5)),
                                    Row(
                                      children: [
                                        Container(
                                          child: WidgetHelper().textQ("${val['title']}", scaler.getTextSize(9), SiteConfig().darkMode, FontWeight.bold),
                                          width: scaler.getWidth(60),
                                        ),
                                        int.parse(val['disc1'])==0?Container():SizedBox(width: 5),
                                        int.parse(val['disc1'])==0?Container():WidgetHelper().textQ("( diskon ${val['disc1']} + ${val['disc2']} )", scaler.getTextSize(8),Colors.grey,FontWeight.bold),
                                      ],
                                    ),
                                    SizedBox(height:scaler.getHeight(0.5)),
                                    Row(
                                      children: [
                                        WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga_coret']))}", scaler.getTextSize(9),Colors.green,FontWeight.normal,textDecoration: TextDecoration.lineThrough),
                                        SizedBox(width: 5),
                                        WidgetHelper().textQ("${FunctionHelper().formatter.format(int.parse(val['harga']))}", scaler.getTextSize(9),Colors.green,FontWeight.bold),
                                      ],
                                    ),
                                    SizedBox(height:scaler.getHeight(0.5)),

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

                Positioned(
                  right: 0,
                  child: IconButton(
                    onPressed: (){
                      WidgetHelper().notifDialog(context,"Informasi !!", "Anda yakin akan menghapus data ini ??", (){Navigator.pop(context);}, (){
                        Navigator.pop(context);
                        deleteFavorite(val['id']);
                      });
                      // deleteFavorite(val['id']);
                      // deleted(cartModel.result[index].id,'');
                    },
                    iconSize: scaler.getTextSize(12),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    icon: Icon(AntDesign.heart),
                    color: Colors.red,
                  ),
                )
              ],
            ),
          )
        );
      },separatorBuilder: (context,index){return SizedBox(height: scaler.getHeight(0.5));},
    );
  }
}
