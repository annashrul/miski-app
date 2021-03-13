import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';

import '../loading_widget.dart';

class ClickProductWidget extends StatefulWidget {
  final String idTenant;
  ClickProductWidget({this.idTenant});
  @override
  _ClickProductWidgetState createState() => _ClickProductWidgetState();
}

class _ClickProductWidgetState extends State<ClickProductWidget> {
  List resRecomendedProduct = [];
  DatabaseConfig _helper = DatabaseConfig();
  bool isLoading=false;
  Future getProductRecomended()async{
    final res = await _helper.getWhereByTenant(ProductQuery.TABLE_NAME,widget.idTenant,"is_click","true");
    setState(() {
      resRecomendedProduct = res;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    getProductRecomended();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          resRecomendedProduct.length>0?WidgetHelper().titleQ(context,"Kamu Sempat Lihat Barang Barang ini",param: '',callback: (){},icon: Icon(
            AntDesign.heart,
            color: Theme.of(context).hintColor,
          )):Container(),
          resRecomendedProduct.length>0?isLoading?LoadingProductTenant(tot: 4):Padding(
            padding: EdgeInsets.only(left:20.0,right:20.0,top:10.0),
            child: new StaggeredGridView.countBuilder(
              primary: false,
              shrinkWrap: true,
              crossAxisCount: 4,
              itemCount: resRecomendedProduct.length,
              itemBuilder: (BuildContext context, int index) {
                return FirstProductWidget(
                  id: resRecomendedProduct[index]['id_product'],
                  gambar: resRecomendedProduct[index]['gambar'],
                  title: resRecomendedProduct[index]['title'],
                  harga: resRecomendedProduct[index]['harga'],
                  hargaCoret: resRecomendedProduct[index]['harga_coret'],
                  rating: resRecomendedProduct[index]['rating'],
                  stock: resRecomendedProduct[index]['stock'],
                  stockSales: resRecomendedProduct[index]['stock_sales'],
                  disc1: resRecomendedProduct[index]['disc1'],
                  disc2: resRecomendedProduct[index]['disc2'],
                  countCart: (){},
                );
              },
              staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
            ),
          ):Container(),
        ],
      ),
    );
  }
}
