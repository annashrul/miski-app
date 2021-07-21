import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/kurir_model.dart';
import 'package:netindo_shop/model/address/list_address_model.dart';
import 'package:netindo_shop/model/bank/bank_model.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/checkout/check_ongkir_model.dart';
import 'package:netindo_shop/model/checkout/checkout_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/address/address_screen.dart';
import 'package:netindo_shop/views/screen/checkout/detail_checkout_screen.dart';
import 'package:netindo_shop/views/screen/product/detail_product_screen.dart';
import 'package:netindo_shop/views/widget/product/first_product_widget.dart';


class CheckoutScreen extends StatefulWidget {
  final String idTenant;
  CheckoutScreen({this.idTenant});
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  KurirModel kurirModel;
  CartModel cartModel;
  CheckOngkirModel checkOngkirModel;
  BankModel bankModel;
  ListAddressModel listAddressModel;
  var detailProduct = [];
  bool isLoading=false,isLoadingKurir=false,isLoadingBank=false,isSelectedKurir=false,isSelectedBank=false;
  String title='',penerima='',noHp='',mainAddress='';
  int isMainAddress=0;
  String alamat='', idMember='',kurirTitle='',kurirDeskripsi='',service='',idBankTujuan='',atasNama='',noRekening='';
  int grandTotal=0,subTotal=0,ongkirTotal=0,hrgPerBarang=0;
  int cost=0;
  bool isPostLoading=false;

  Future getProduct()async{
    var res = await BaseProvider().getProvider('cart/${widget.idTenant}', cartModelFromJson);
    final userRepository = UserHelper();
    final idUser = await userRepository.getDataUser('id_user');
    if(res is CartModel){
      setState(() {
        idMember = idUser;
        cartModel = CartModel.fromJson(res.toJson());
        isLoading=false;
      });
      // print("CART")
      for(var i=0;i<cartModel.result.length;i++){
        int disc1Nominal = FunctionHelper().percentToRp(int.parse(cartModel.result[i].disc1), int.parse(cartModel.result[i].hargaMaster));
        int disc2Nominal = FunctionHelper().percentToRp(int.parse(cartModel.result[i].disc2), int.parse(cartModel.result[i].hargaMaster));
        detailProduct.add({
          "kode_barang":cartModel.result[i].kodeBarang,
          "id_varian":cartModel.result[i].idVarian,
          "id_subvarian":cartModel.result[i].idSubvarian,
          "qty":cartModel.result[i].qty,
          "harga_jual":"${int.parse(cartModel.result[i].hargaMaster)+int.parse(cartModel.result[i].varianHarga)+int.parse(cartModel.result[i].subvarianHarga)}",
          "disc":disc1Nominal+disc2Nominal,
          "subtotal":(int.parse(cartModel.result[i].hargaJual)*int.parse(cartModel.result[i].qty)).toString(),
          "tax":"0"
        });
      }
      print('id member $idMember');
      print('id tenant ${widget.idTenant}');
      getGrandTotal();
      getSubtotal();
      getBank();
    }
  }
  Future getKurir()async{
    var res = await BaseProvider().getProvider(
        'kurir', kurirModelFromJson
    );
    if(res is KurirModel){
      kurirModel = KurirModel.fromJson(res.toJson());
      setState(() {
        isLoadingKurir=false;
      });
      selectedKurir(0,'-');
      print("KURIR $kurirTitle");
    }
  }
  Future getAlamat()async{
    final idUser = await UserHelper().getDataUser("id_user");
    var res = await BaseProvider().getProvider("member_alamat?page=1&id_member=$idUser", listAddressModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        // isError=true;
        isLoading=false;
        // isLoadmore=false;
      });
    }
    else{
      if(res is ListAddressModel){
        ListAddressModel resullt = res;
        print("ALAMAT ${resullt.toJson()}");
        setState(() {
          idxAddress=0;
          title=resullt.result.data[0].title;
          penerima = resullt.result.data[0].penerima;
          noHp = resullt.result.data[0].noHp;
          mainAddress = resullt.result.data[0].mainAddress;
          isMainAddress=resullt.result.data[0].ismain;
          // listAddressModel = ListAddressModel.fromJson(resullt.toJson());
          // isError=false;
          isLoading=false;
        });
      }
    }
  }
  Future selectedKurir(idx,param)async{
    print(kurirModel.result[idx].kurir);
    setState(() {
      isSelectedKurir = true;
      kurirTitle = kurirModel.result[idx].kurir;
    });
    WidgetHelper().loadingDialog(context);
    await getOngkir( kurirModel.result[idx].kurir);
    if(param==''){
      Navigator.pop(context);
    }
  }
  void selectedLayanan(idx){
    setState(() {
      service = checkOngkirModel.result.ongkir[idx].service;
      kurirDeskripsi = "${checkOngkirModel.result.ongkir[idx].service} | ${FunctionHelper().formatter.format(checkOngkirModel.result.ongkir[idx].cost)} | ${checkOngkirModel.result.ongkir[idx].estimasi}";
      cost = checkOngkirModel.result.ongkir[idx].cost;
    });
    getGrandTotal();
    Navigator.pop(context);
  }
  Future getOngkir(kurir)async{
    var res = await BaseProvider().postProvider(
        'kurir/cek/ongkir',{
      "ke":"1470",
      "berat":"100",
      "kurir":"$kurir"
    }
    );
    print(res);
    if(res == 'TimeoutException'|| res=='SocketException'){
      WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Mohon maaf server kami sedang dalam masalah", (){},(){});
    }
    else{
      Navigator.pop(context);
      setState(() {
        isPostLoading = false;
      });
      if(res is General){
        print('terjadi kesalahan');
      }
      else{
        var resLayanan = CheckOngkirModel.fromJson(res);
        print(resLayanan.toJson());
        setState(() {
          checkOngkirModel = CheckOngkirModel.fromJson(resLayanan.toJson());
          kurirDeskripsi = "${resLayanan.result.ongkir[0].service} | ${FunctionHelper().formatter.format(resLayanan.result.ongkir[0].cost)} | ${resLayanan.result.ongkir[0].estimasi}";
          service = checkOngkirModel.result.ongkir[0].service;
          cost = resLayanan.result.ongkir[0].cost;
        });
        getGrandTotal();
      }
    }
  }
  getGrandTotal(){
    int st = 0;
    for(var i=0;i<cartModel.result.length;i++){
      st = st+int.parse(cartModel.result[i].hargaJual)*int.parse(cartModel.result[i].qty);
    }
    grandTotal = st+cost;
  }
  getSubtotal(){
    int st = 0;
    int hrg = 0;
    for(var i=0;i<cartModel.result.length;i++){
      // hrg = hrg+
      st = st+int.parse(cartModel.result[i].hargaJual)*int.parse(cartModel.result[i].qty);
    }

    subTotal = st;
  }
  Future getBank()async{
    var res = await BaseProvider().getProvider('bank', bankModelFromJson);
    if(res is BankModel){
      bankModel = BankModel.fromJson(res.toJson());
      setState(() {
        isLoadingBank=false;
      });
    }
  }
  selectedBank(idx){
    idBankTujuan = bankModel.result.data[idx].id;
    atasNama = bankModel.result.data[idx].atasNama;
    noRekening = bankModel.result.data[idx].noRekening;
    isSelectedBank=!isSelectedBank;
  }
  Future checkout()async{
    WidgetHelper().loadingDialog(context);
    Map<String, Object> data =  {
      "id_tenant":"${widget.idTenant}",
      "id_member":"$idMember",
      "subtotal":"$subTotal",
      "ongkir":"$cost",
      "disc":"0",
      "tax":"0",
      "grandtotal":"$grandTotal",
      "kurir":"$kurirTitle",
      "service":"$service",
      "metode_pembayaran":"transfer",
      "id_promo":"-",
      "kode_voucher":"-",
      "id_alamat_member":"f3f7bd6f-cd4a-4191-ac25-9aa6fd092d1b",
      "id_bank_tujuan":"${idBankTujuan==''?bankModel.result.data[0].id:idBankTujuan}",
      "atas_nama":"${atasNama==''?bankModel.result.data[0].atasNama:atasNama}",
      "no_rek":"${noRekening==''?bankModel.result.data[0].noRekening:noRekening}",
      "detail":"$detailProduct"
    };
    print("DATA $data");
    var res = await BaseProvider().postProvider("transaction", data);
    if(res == '${SiteConfig().errTimeout}'|| res=='${SiteConfig().errSocket}'){
      Navigator.pop(context);
      WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Mohon maaf server kami sedang dalam masalah", (){},(){});
    }
    else{
      Navigator.pop(context);
      if(res is General){
        Navigator.pop(context);
        WidgetHelper().notifDialog(context,"Terjadi Kesalahan","Checkout gagal", (){},(){});
      }
      else{
        var resposneCheckout = CheckoutModel.fromJson(res);
        WidgetHelper().myPush(context,DetailCheckoutScreen(
          invoice_no:"${resposneCheckout.result.invoiceNo}",
          grandtotal:"${resposneCheckout.result.grandtotal}",
          kode_unik:"${resposneCheckout.result.kodeUnik}",
          total_transfer:"${resposneCheckout.result.totalTransfer}",
          bank_logo:"${resposneCheckout.result.bankLogo}",
          bank_name:"${resposneCheckout.result.bankName}",
          bank_atas_nama:"${resposneCheckout.result.bankAtasNama}",
          bank_acc:"${resposneCheckout.result.bankAcc}",
          bank_code:"${resposneCheckout.result.bankCode}",
        ));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    isLoadingKurir=true;
    isLoadingBank=true;
    getKurir();
    getProduct();
    getAlamat();
  }
  int idxKurir=0;
  int idxLayanan=0;
  int idxAddress=100000;
  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Scaffold(
      backgroundColor:Colors.white,
      key: _scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context,"Pengiriman", (){Navigator.pop(context);},<Widget>[]),
      body:isLoading||isLoadingKurir||isLoadingBank?WidgetHelper().loadingWidget(context):ListView(
        physics:AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding:scaler.getPadding(0,2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHelper().titleQ(context,isMainAddress==1?"Utama".toUpperCase():title.toUpperCase(),icon: AntDesign.home,color: SiteConfig().secondColor,param: '-',callback: (){
                  WidgetHelper().myModal(context, ModalAddress(
                      idx:idxAddress,callback:(int index,int isMain,String id,String ttl, String pnrm, String no, String main){
                    setState(() {
                      idxAddress = index;
                      title=ttl;
                      penerima = pnrm;
                      noHp = no;
                      mainAddress = main;
                      isMainAddress=isMain;
                    });
                  }
                  ));
                }),
                SizedBox(height: scaler.getHeight(0.5)),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetHelper().textQ("$penerima ( $noHp )",scaler.getTextSize(9),Colors.black87, FontWeight.normal),
                      SizedBox(height: scaler.getHeight(0.5)),
                      WidgetHelper().textQ("$mainAddress",scaler.getTextSize(9),Colors.black87, FontWeight.normal),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: scaler.getHeight(1)),
          WidgetHelper().pembatas(context),
          SizedBox(height: scaler.getHeight(1)),
          Container(
            padding:scaler.getPadding(0,2),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHelper().titleQ(context,'Jasa Pengiriman'.toUpperCase(),icon:FontAwesome.truck,param: '',color: SiteConfig().secondColor),
                SizedBox(height: scaler.getHeight(0.5)),
                jasaPengiriman(context,"PILIH KURIR", kurirTitle, (){modalKurir(context);}),
                SizedBox(height: scaler.getHeight(0.5)),
                jasaPengiriman(context,"PILIH LAYANAN", kurirDeskripsi, (){if(kurirTitle!='')modalLayanan(context);}),
                SizedBox(height: scaler.getHeight(0.5)),
                jasaPengiriman(context,"GUNAKAN VOUCHER", '-', (){}),
              ],
            ),
          ),
          SizedBox(height: scaler.getHeight(1)),
          WidgetHelper().pembatas(context),
          SizedBox(height: scaler.getHeight(1)),
          Padding(
            padding:scaler.getPadding(0,2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WidgetHelper().titleQ(context,"RINGKASAN BELANJA",icon: AntDesign.shoppingcart,color: SiteConfig().secondColor,param: ''),
                    new Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: new BoxDecoration(
                        color: SiteConfig().mainColor,
                        shape: BoxShape.circle,
                      ),
                      child:WidgetHelper().textQ("${cartModel.result.length}",10,SiteConfig().secondDarkColor, FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height:scaler.getHeight(0.5)),
                Container(
                  child: ListView.builder(
                    padding: EdgeInsets.all(0),
                      addRepaintBoundaries: true,
                      primary: false,
                      shrinkWrap: true,
                      itemCount: cartModel.result.length,
                      itemBuilder: (context,index){
                        var val = cartModel.result[index];
                        var subTot=int.parse(val.hargaJual)*int.parse(val.qty);
                        return InkWell(
                          onTap: (){WidgetHelper().myPush(context,DetailProducrScreen(id: val.id));},
                          child: Container(
                            color:Colors.transparent,
                            child: Row(
                              children: [
                                CachedNetworkImage(
                                  height: 50,
                                  imageUrl: SiteConfig().noImage,
                                  fit:BoxFit.fill,
                                  placeholder: (context, url) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width: 50),
                                  errorWidget: (context, url, error) => Image.network(SiteConfig().noImage, fit:BoxFit.fill,width:50),
                                ),
                                SizedBox(width:scaler.getWidth(2)),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width:scaler.getWidth(90),child: WidgetHelper().textQ(val.barang,scaler.getTextSize(9),SiteConfig().darkMode,FontWeight.normal)),
                                      SizedBox(height:scaler.getHeight(0.5)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          WidgetHelper().textSpaceBetween(
                                              context,
                                              "${val.qty} ITEM * ",
                                              "Rp ${FunctionHelper().formatter.format(int.parse("${val.hargaJual}"))} .-",
                                              titleColor: SiteConfig().moneyColor,
                                              descColor: SiteConfig().moneyColor,
                                              mainAxisAlignment: MainAxisAlignment.start
                                          ),
                                          WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse("$subTot"))} .-",scaler.getTextSize(9),SiteConfig().moneyColor,FontWeight.normal)
                                        ],
                                      ),
                                      // WidgetHelper().textQ("Rp ${FunctionHelper().formatter.format(int.parse("${cartModel.result[index].hargaJual}"))} .-",scaler.getTextSize(9),SiteConfig().moneyColor,FontWeight.normal),
                                      // WidgetHelper().textQ(cartModel.result[index].qty,scaler.getTextSize(9),SiteConfig().moneyColor,FontWeight.normal),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
                SizedBox(height:scaler.getHeight(0.5)),
                Container(
                  child: Column(
                    children: [
                      WidgetHelper().textSpaceBetween(context,"TOTAL BELANJA","Rp ${FunctionHelper().formatter.format(subTotal)} .-",descColor: SiteConfig().moneyColor),
                      Divider(),
                      WidgetHelper().textSpaceBetween(context,"TOTAL ONGKOS KIRIM","Rp ${FunctionHelper().formatter.format(cost)} .-",descColor: SiteConfig().moneyColor),
                      Divider(),
                      WidgetHelper().textSpaceBetween(context,"DISKON VOUCHER","Rp ${FunctionHelper().formatter.format(0)} .-",descColor: SiteConfig().moneyColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: scaler.getHeight(1)),
        ],
      ),
      bottomNavigationBar: _bottomNavBarBeli(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  Widget jasaPengiriman(BuildContext context,String title,String desc,Function callback){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color:SiteConfig().secondColor,width: 1)
      ),
      child: InkWell(
        onTap:callback,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          padding: EdgeInsets.only(left:10.0,right: 10.0,top:5,bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetHelper().textQ(title,scaler.getTextSize(9),SiteConfig().darkMode, FontWeight.normal),
                  SizedBox(height: 5.0),
                  WidgetHelper().textQ(desc,scaler.getTextSize(9),SiteConfig().darkMode, FontWeight.normal)
                ],
              ),
              Icon(Ionicons.ios_arrow_dropright_circle,color: SiteConfig().secondColor,size: scaler.getTextSize(10)),
            ],
          ),
        ),
      ),
    );
  }
  Widget _bottomNavBarBeli(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);
    return Container(
      padding:scaler.getPadding(0,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: scaler.getMarginLTRB(2,0,0,0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                WidgetHelper().textQ("Total Tagihan",scaler.getTextSize(10),SiteConfig().secondColor, FontWeight.bold),
                WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(grandTotal)+" .-",scaler.getTextSize(10),SiteConfig().moneyColor, FontWeight.bold),
              ],
            ),
          ),
          FlatButton(
              padding:scaler.getPadding(1,0),
              color: SiteConfig().secondColor,
              onPressed: (){
                WidgetHelper().myModal(
                    context,
                    Container(
                      height:scaler.getHeight(50),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height:scaler.getHeight(0.5)),
                          Center(
                            child: Container(
                              width: scaler.getWidth(10),
                              height:scaler.getHeight(0.5),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:  BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          SizedBox(height:scaler.getHeight(0.5)),
                          Container(
                              margin: scaler.getMargin(0, 2),
                              width: double.infinity,
                              padding:scaler.getPadding(0.5,2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color:SiteConfig().mainColor,
                                // border: Border.all(color:SiteConfig().accentDarkColor)
                              ),
                              child: Row(
                                children: [
                                  Icon(AntDesign.infocirlceo,color: Colors.white),
                                  SizedBox(width:scaler.getWidth(1)),
                                  WidgetHelper().textQ("Pilih bank untuk melanjutkan proses checkout",scaler.getTextSize(9),Colors.white, FontWeight.bold)
                                ],
                              )
                          ),
                          Expanded(
                            child: Scrollbar(
                                child: isLoading?WidgetHelper().loadingWidget(context):ModalBank(
                                  bankModel: bankModel,
                                  callback: (idx){
                                    selectedBank(idx);
                                  },
                                  // isSelected: isSelectedBank
                                )
                            ),
                          ),
                          Align(
                            widthFactor: scaler.getWidth(100),
                            alignment: Alignment.bottomCenter,
                            child:Padding(
                              padding:scaler.getPadding(0.5,2),
                              child: FlatButton(
                                // shape: StadiumBorder(),
                                onPressed: (){
                                  WidgetHelper().notifDialog(context,"Perhatian","Anda yakin akan melakukan proses checkout sekarang ??",(){Navigator.pop(context);},(){
                                    Navigator.pop(context);
                                    checkout();
                                  });
                                },
                                color: SiteConfig().secondColor,
                                child: Container(
                                  padding:scaler.getPadding(1.0,0.0),
                                  width: scaler.getWidth(100),
                                  child: WidgetHelper().textQ("BERIKUTNYA",scaler.getTextSize(10),Colors.white, FontWeight.bold,textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                );
              },
              child: WidgetHelper().textQ("Bayar", scaler.getTextSize(10), Colors.white,FontWeight.bold)
          )
        ],
      ),
    );
    return Container(
      height: scaler.getHeight(4),
      padding: scaler.getPadding(0,2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidgetHelper().textQ("Total Tagihan",scaler.getTextSize(10),SiteConfig().secondColor, FontWeight.bold),
              WidgetHelper().textQ("Rp "+FunctionHelper().formatter.format(grandTotal)+" .-",scaler.getTextSize(10),SiteConfig().moneyColor, FontWeight.bold),
            ],
          ),
          WidgetHelper().buttonQ(context,(){
            WidgetHelper().myModal(
                context,
                Container(
                  height:scaler.getHeight(50),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height:scaler.getHeight(0.5)),
                      Center(
                        child: Container(
                          width: scaler.getWidth(10),
                          height:scaler.getHeight(0.5),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:  BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height:scaler.getHeight(0.5)),
                      Container(
                          margin: scaler.getMargin(0, 2),
                          width: double.infinity,
                          padding:scaler.getPadding(0.5,2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color:SiteConfig().mainColor,
                            // border: Border.all(color:SiteConfig().accentDarkColor)
                          ),
                          child: Row(
                            children: [
                              Icon(AntDesign.infocirlceo,color: Colors.white),
                              SizedBox(width:scaler.getWidth(1)),
                              WidgetHelper().textQ("Pilih bank untuk melanjutkan proses checkout",scaler.getTextSize(9),Colors.white, FontWeight.bold)
                            ],
                          )
                      ),
                      Expanded(
                        child: Scrollbar(
                            child: isLoading?WidgetHelper().loadingWidget(context):ModalBank(
                              bankModel: bankModel,
                              callback: (idx){
                                selectedBank(idx);
                              },
                              // isSelected: isSelectedBank
                            )
                        ),
                      ),
                      Align(
                        widthFactor: scaler.getWidth(100),
                        alignment: Alignment.bottomCenter,
                        child:Padding(
                          padding:scaler.getPadding(0.5,2),
                          child: FlatButton(
                            shape: StadiumBorder(),
                            onPressed: (){
                              WidgetHelper().notifDialog(context,"Perhatian","Anda yakin akan melakukan proses checkout sekarang ??",(){Navigator.pop(context);},(){
                                Navigator.pop(context);
                                checkout();
                              });
                            },
                            color: SiteConfig().mainColor,
                            child: Container(
                              width: scaler.getWidth(100),
                              child: WidgetHelper().textQ("BERIKUTNYA",scaler.getTextSize(10),Colors.white, FontWeight.bold,textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
            );
          },"berikutnya")
          
        ],
      ),
    );
  }
 
  Widget modalKurir(BuildContext context){
    WidgetHelper().myModal(
        context,
        ModalKurir(
          kurirModel: kurirModel,
          callback: (idx){
            setState(() {
              idxKurir = idx;
            });
            selectedKurir(idx,'');
          },
          index: idxKurir,
        )
    );
  }
  Widget modalLayanan(BuildContext context){
    WidgetHelper().myModal(
        context,
        ModalLayanan(
          checkOngkirModel: checkOngkirModel,
          callback: (idx){
            setState(() {
              idxLayanan = idx;
            });
            selectedLayanan(idx);
          },
          index: idxLayanan,
        )
    );
  }
}

class ModalAddress extends StatefulWidget {
  int idx;
  Function(int index,int isMain,String id,String title, String penerima, String nohp, String mainAddress) callback;
  ModalAddress({this.idx,this.callback});
  @override
  _ModalAddressState createState() => _ModalAddressState();
}
class _ModalAddressState extends State<ModalAddress> {
  ListAddressModel listAddressModel;
  bool isLoading=false,isLoadmore=false,isError=false;
  Future loadData()async{
    final idUser = await UserHelper().getDataUser("id_user");
    var res = await BaseProvider().getProvider("member_alamat?page=1&id_member=$idUser", listAddressModelFromJson);
    if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
      setState(() {
        isError=true;
        isLoading=false;
        isLoadmore=false;
      });
    }
    else{
      if(res is ListAddressModel){
        ListAddressModel resullt = res;
        setState(() {
          listAddressModel = ListAddressModel.fromJson(resullt.toJson());
          isError=false;
          isLoading=false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    loadData();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color:Colors.transparent,
          // borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height:10.0),
          Center(
            child: Container(
              padding: EdgeInsets.only(top:10.0),
              width: 50,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:  BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          ListTile(
            dense:true,
            contentPadding: EdgeInsets.only(left: 10.0, right: 15.0),
            leading: InkWell(
              onTap: ()=>Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Center(child: Icon(AntDesign.back, color:Theme.of(context).hintColor),),
              ),
            ),
            title: WidgetHelper().textQ("Pilih Alamat Pengiriman",14,Theme.of(context).hintColor, FontWeight.bold),
            trailing: InkWell(
                onTap: ()async{
                  WidgetHelper().myModal(context,ModalForm(id:"",callback: (par){
                    if(par=='berhasil'){
                      loadData();
                      WidgetHelper().showFloatingFlushbar(context,"success","data berhasil dikirim");
                    }
                    else{
                      WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
                    }
                  }));
                  // WidgetHelper().myPushAndLoad(context,AddressScreen(mode:!widget.mode), (){loadData();});
                },
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [SiteConfig().secondColor,SiteConfig().secondColor]),
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: [BoxShadow(color: Color(0xFF6078ea).withOpacity(.3),offset: Offset(0.0, 8.0),blurRadius: 8.0)]
                  ),
                  child: WidgetHelper().textQ("Tambah Alamat",10,Colors.white,FontWeight.bold),
                )
            ),
          ),

          isLoading?Padding(
            padding: EdgeInsets.all(20.0),
            child: WidgetHelper().loadingWidget(context),
          ):Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(left:10,right:10),
                key: PageStorageKey<String>('AddressScreenModal'),
                primary: false,
                physics: ScrollPhysics(),
                itemCount: listAddressModel.result.data.length,
                itemBuilder: (context,index){
                  final val=listAddressModel.result.data[index];
                  // final valDet = historyTransactionModel.result.data[index].detail;
                  return InkWell(
                    onTap: (){
                      setState(() {
                        widget.idx=index;
                      });
                      widget.callback(index,val.ismain,val.id,val.title,val.penerima,val.noHp,val.mainAddress);
                      Navigator.pop(context);
                    },
                    child: Card(
                      color:Colors.white,
                      elevation: 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left:10,right:10,top:0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    WidgetHelper().textQ("${val.title}",12,Colors.black,FontWeight.bold),
                                    val.ismain==1?Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          color:Colors.grey
                                      ),
                                      child: WidgetHelper().textQ("Alamat Utama", 10,Colors.white,FontWeight.bold),
                                    ):Container()
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(AntDesign.checkcircleo,color: widget.idx==index?Colors.grey:Colors.transparent),
                                  onPressed: (){
                                    // setState(() {
                                    //   widget.idx=index;
                                    // });
                                    // widget.callback(index,val.ismain,val.id,val.title,val.penerima,val.noHp,val.mainAddress);
                                  },
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10,right:10,top:0,bottom:5),
                            child: Container(
                              color: Colors.grey[200],
                              height: 1.0,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left:10,right:10,top:0,bottom:10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WidgetHelper().textQ("${val.penerima}",10,Colors.black,FontWeight.normal),
                                // WidgetHelper().textQ("PENERIMA",10,Colors.black,FontWeight.normal),
                                SizedBox(height:5.0),
                                WidgetHelper().textQ("${val.noHp}",10,Colors.black,FontWeight.normal),
                                // WidgetHelper().textQ("NOHP",10,Colors.black,FontWeight.normal),
                                SizedBox(height:5.0),
                                WidgetHelper().textQ("${val.mainAddress}",10,Colors.grey,FontWeight.normal,maxLines: 3),
                                // WidgetHelper().textQ("MAIN ADDRESS",10,Colors.grey,FontWeight.normal,maxLines: 3),
                                SizedBox(height:5.0),
                                InkWell(
                                  onTap: (){
                                    WidgetHelper().myModal(context, ModalForm(id:"${val.id}",callback:(String par){
                                      if(par=='berhasil'){
                                        loadData();
                                        WidgetHelper().showFloatingFlushbar(context,"success","data berhasil disimpan");
                                      }
                                      else{
                                        WidgetHelper().showFloatingFlushbar(context,"success","terjadi kesalahan koneksi");
                                      }
                                    },));
                                  },
                                  child: Container(
                                    padding:EdgeInsets.all(10.0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: SiteConfig().secondColor
                                    ),
                                    child: WidgetHelper().textQ("Ubah Alamat",10,Colors.white,FontWeight.bold,textAlign: TextAlign.center),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            ),
          ),

        ],
      ),
    );
  }
}



class ModalKurir extends StatefulWidget {
  ModalKurir({
    Key key,
    @required this.kurirModel,
    @required this.callback,
    @required this.index,
  }) : super(key: key);
  final KurirModel kurirModel;
  Function(int idx) callback;
  final int index;

  @override
  _ModalKurirState createState() => _ModalKurirState();
}

class _ModalKurirState extends State<ModalKurir> {
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }
  int idx=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSite();
    idx = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height/2,
      decoration: BoxDecoration(
        color: site?SiteConfig().darkMode:Colors.transparent,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height:10.0),
          Center(
            child: Container(
              padding: EdgeInsets.only(top:10.0),
              width: 50,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:  BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: SiteConfig().accentDarkColor,
                  // border: Border.all(color:SiteConfig().accentDarkColor)
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,color: Colors.white),
                    SizedBox(width: 5),
                    WidgetHelper().textQ("Perkiraan tiba dihitung sejak pesanan dikirim",12,Colors.white, FontWeight.bold)
                  ],
                )
            ),
          ),
          Expanded(
            child: Scrollbar(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: widget.kurirModel.result.length,
                  itemBuilder: (context,index){
                    return InkWell(
                      onTap: (){
                        setState(() {
                          idx =index;
                        });
                        widget.callback(index);
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left:10,right:10,top:0,bottom:0),
                        leading: Image.network(widget.kurirModel.result[index].gambar,width: 50,height: 50,),
                        title: WidgetHelper().textQ("${widget.kurirModel.result[index].kurir}", 14,site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                        subtitle: WidgetHelper().textQ("${widget.kurirModel.result[index].deskripsi}", 12, SiteConfig().secondColor, FontWeight.bold),
                        trailing: widget.index==index?Icon(AntDesign.checkcircleo,color: site?Colors.grey[200]:SiteConfig().darkMode):Text(
                          ''
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {return Divider(height: 1);},
                )
            ),
          )
        ],
      ),
    );
  }
}



class ModalLayanan extends StatefulWidget {
  ModalLayanan({
    Key key,
    @required this.checkOngkirModel,
    @required this.callback,
    @required this.index,
  }) : super(key: key);

  final CheckOngkirModel checkOngkirModel;
  Function(int idx) callback;
  final int index;
  @override
  _ModalLayananState createState() => _ModalLayananState();
}

class _ModalLayananState extends State<ModalLayanan> {
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSite();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: site?SiteConfig().darkMode:Colors.transparent,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
      ),
      height: MediaQuery.of(context).size.height/2,
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height:10.0),
          Center(
            child: Container(
              padding: EdgeInsets.only(top:10.0),
              width: 50,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:  BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: SiteConfig().accentDarkColor,
                  // border: Border.all(color:SiteConfig().accentDarkColor)
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,color: Colors.white),
                    SizedBox(width: 5),
                    WidgetHelper().textQ("Perkiraan tiba dihitung sejak pesanan dikirim",12,Colors.white, FontWeight.bold)
                  ],
                )
            ),
          ),
          Expanded(
            child: Scrollbar(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: widget.checkOngkirModel.result.ongkir.length,
                  itemBuilder: (context,index){
                    return InkWell(
                      onTap: (){
                        widget.callback(index);
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left:10,right:10,top:0,bottom:0),
                        title: WidgetHelper().textQ("${widget.checkOngkirModel.result.ongkir[index].service} | ${widget.checkOngkirModel.result.ongkir[index].cost} | ${widget.checkOngkirModel.result.ongkir[index].estimasi}", 12,site?Colors.white:Colors.black, FontWeight.bold),
                         trailing: widget.index==index?Icon(AntDesign.checkcircleo,color: site?Colors.grey[200]:SiteConfig().darkMode):Text('')
                      )
                    );
                  },
                  separatorBuilder: (context, index) {return Divider(height: 1);},
                )
            ),
          )
        ],
      ),
    );
  }

}


class ModalBank extends StatefulWidget {
  ModalBank({
    Key key,
    @required this.bankModel,
    @required this.callback,
  }) : super(key: key);

  final BankModel bankModel;
  Function(int idx) callback;
  @override
  _ModalBankState createState() => _ModalBankState();
}

class _ModalBankState extends State<ModalBank> {
  bool isSelect=false;
  int num = 0;
  void isSelectedBank(idx){
    // print(widget.isSelected);
    setState(() {
      num = idx;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.bankModel.result.data.length,
      itemBuilder: (context,index){
        return InkWell(
          onTap: (){
            print(widget.bankModel.result.data[index].atasNama);
            widget.callback(index);
            isSelectedBank(index);
          },
          child: ListTile(
            trailing: num==index?Icon(AntDesign.checkcircleo,color:SiteConfig().darkMode):Text(''),
            contentPadding: EdgeInsets.only(left:5,right:10,top:0,bottom:0),
            leading:WidgetHelper().baseImage(widget.bankModel.result.data[index].logo,width: scaler.getWidth(15)),
            title: WidgetHelper().textQ("${widget.bankModel.result.data[index].atasNama}", scaler.getTextSize(9),SiteConfig().darkMode, FontWeight.bold),
            subtitle: WidgetHelper().textQ(widget.bankModel.result.data[index].noRekening,  scaler.getTextSize(9), SiteConfig().secondColor, FontWeight.bold),
          ),
        );
      },
      separatorBuilder: (context, index) {return Divider(height: 1);},
    );
  }
}

