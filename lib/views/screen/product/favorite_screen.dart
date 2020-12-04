import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

import 'detail_product_screen.dart';

class FavoriteScreen extends StatefulWidget {
  bool mode;
  FavoriteScreen({this.mode});
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final DatabaseConfig _helper = new DatabaseConfig();
  ScrollController controller;
  List resFavoriteProduct=[];
  bool isLoading=false,isLoadmore=false;
  int perpage=7;
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
    return ListView.builder(
      controller: controller,
      itemCount: resFavoriteProduct.length,
      itemBuilder: (context,index){
        var val = resFavoriteProduct[index];
        return Dismissible(
          key: Key(hashCode.toString()),
          background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  UiIcons.trash,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          onDismissed: (direction) {
            deleteFavorite(val['id']);
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                InkWell(
                  onTap: (){},
                  child: Container(

                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
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

                Positioned(
                  right: 10,
                  child: IconButton(
                    onPressed: (){
                      deleteFavorite(val['id']);
                      // deleted(cartModel.result[index].id,'');
                    },
                    iconSize: 30,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    icon: Icon(UiIcons.heart),
                    color: Colors.red,
                  ),
                )
              ],
            ),
          )
        );
      }
    );
  }
}
