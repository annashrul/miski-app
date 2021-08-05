import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/detail/function_detail.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/tenant/detail_product_tenant_model.dart';
import 'package:netindo_shop/pages/widget/product/detail/bottom_bar_detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/detail/tab_detail_product_widget.dart';
class BrandComponent extends StatefulWidget {
  final dynamic data;
  BrandComponent({@required this.data,Key key}) : super(key: key);
  @override
  _BrandComponentState createState() => _BrandComponentState();
}

class _BrandComponentState extends State<BrandComponent> with SingleTickerProviderStateMixin {
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DetailProductTenantModel detail;
  int _tabIndex = 0,qty=0,hargaFinish=0,hargaUkuran=0,hargaWarna=0,totalCart=0,total=0,harga=0;
  String idVarian="",idSubVarian="",hargaMaster="0";
  bool isLoadingDetail=true,isFavorite=false;
  dynamic dataDetail;
  Future loadDetail()async{
    final funcData = await FunctionDetail().loadDetail(context: context,idProduct:widget.data["id"]);
    dataDetail = funcData["data"];
    qty = funcData["data"]["qty"];
    harga = int.parse(funcData["data"]["harga"]);
    hargaMaster=funcData["data"]["harga_master"];
    hargaFinish=funcData["data"]["harga_finish"];
    totalCart = funcData["data"]["total_cart"];
    isFavorite = await FunctionDetail().handleFavorite(context: context,data: dataDetail,method: "get");
    isLoadingDetail=false;
    if(this.mounted) setState(() {});

  }
  Future handleCart()async{
    if(this.mounted) setState(() {qty+=1;});
    dynamic data = dataDetail;
    data["qty"] = qty;
    data["harga_finish"] =hargaFinish;
    data["harga_master"] =hargaMaster;
    data["harga_warna"] =hargaWarna;
    data["harga_ukuran"] =hargaUkuran;
    final res = await FunctionDetail().addToCart(context: context,data: data);
    totalCart = res["totalCart"];
    print("total cart $totalCart");
    if(this.mounted) setState(() {});
  }

  Future handleFavorite()async{
    final res = await FunctionDetail().handleFavorite(context: context,data: dataDetail);
    if(this.mounted){
      setState(() {
        isFavorite=res;
      });
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    loadDetail();
    super.initState();
    print("halaman brands");
  }
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
    );
  }


}
