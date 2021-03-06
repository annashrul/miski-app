import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/home/function_home.dart';
import 'package:miski_shop/model/tenant/list_product_tenant_model.dart';
import 'package:miski_shop/pages/widget/product/product_grid_widget.dart';
import '../empty_widget.dart';
import '../loading_widget.dart';

class BrandProductTabWidget extends StatefulWidget {
  ListProductTenantModel listProductTenantModel;
  BrandProductTabWidget({this.listProductTenantModel});
  @override
  _BrandProductTabWidgetState createState() => _BrandProductTabWidgetState();
}

class _BrandProductTabWidgetState extends State<BrandProductTabWidget> {
  // bool isLoadingProduct=true;
  // ListProductTenantModel listProductTenantModel;
  //
  // Future loadProduct()async{
  //   final res = await FunctionHome().loadProduct(context: context,where: "&brand=${widget.data["id"]}&perpage=${widget.perPage}");
  //   listProductTenantModel=res;
  //   isLoadingProduct=false;
  //   if(this.mounted){this.setState(() {});}
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   loadProduct();
  //   print(widget.data);
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        new StaggeredGridView.countBuilder(
          primary: false,
          shrinkWrap: true,
          crossAxisCount: 4,
          itemCount:widget.listProductTenantModel.result.data.length,
          itemBuilder: (BuildContext context, int index) {
            final res=widget.listProductTenantModel.result.data[index];
            return ProductGridWidget(
              productId: res.id,
              productName: res.title,
              productImage: res.gambar,
              productPrice: res.harga,
              productSales: res.stockSales,
              productRate: res.rating,
              productStock: res.stock,
              heroTag: 'brand_products_grid_${res.id}',
              callback: (){
                // widget.callback("norefresh");
              },
            );
          },
          staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
          mainAxisSpacing: 15.0,
          crossAxisSpacing: 15.0,
        ),
        // CupertinoActivityIndicator()
      ],
    );
  }
}
