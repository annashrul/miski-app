import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/kurir_model.dart';
import 'package:netindo_shop/model/bank/bank_model.dart';
import 'package:netindo_shop/model/cart/cart_model.dart';
import 'package:netindo_shop/model/checkout/check_ongkir_model.dart';
import 'package:netindo_shop/model/checkout/checkout_model.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/detail_checkout_screen.dart';
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
  var detailProduct = [];
  bool isLoading=false,isLoadingKurir=false,isLoadingBank=false,isSelectedKurir=false,isSelectedBank=false;
  String alamat='', idMember='',kurirTitle='',kurirDeskripsi='',service='',idBankTujuan='',atasNama='',noRekening='';
  int grandTotal=0,subTotal=0,ongkirTotal=0,hrgPerBarang=0;
  int cost=0;
  bool isPostLoading=false;
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }
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
        setState(() {
          checkOngkirModel = CheckOngkirModel.fromJson(resLayanan.toJson());
          kurirDeskripsi = "${resLayanan.result.ongkir[0].service} | ${FunctionHelper().formatter.format(resLayanan.result.ongkir[0].cost)} | ${resLayanan.result.ongkir[0].estimasi}";
          // subtotal = subtotal+1000;
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
    //
    print("id tenant = ${widget.idTenant}");
    print("id member = $idMember");
    print("subtotal = $subTotal");
    print("ongkir = $cost");
    print("grand total = $grandTotal");
    print("kurir = $kurirTitle");
    print("service = $service");
    print("id bank = $idBankTujuan");
    print("atas nama = $atasNama");
    print("no rekening = $noRekening");
    print("detail $detailProduct");
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
        // WidgetHelper().notifDialog(context,"Berhasil","Terimakasih telah melakukan transaksi",(){
        //   Navigator.pop(context);
        // },(){
        //   print('lihat detail');
        // },titleBtn1: 'Kembali',titleBtn2: 'Lihat Detail');
      }
    }
    print(data);
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
    getSite();

  }
  int idxKurir=0;
  int idxLayanan=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: site?SiteConfig().darkMode:Colors.transparent,
      key: _scaffoldKey,
      appBar: WidgetHelper().appBarWithButton(context,"Pengiriman", (){Navigator.pop(context);},<Widget>[],brightness: site?Brightness.dark:Brightness.light),
      body:isLoading||isLoadingKurir||isLoadingBank?WidgetHelper().loadingWidget(context):ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left:20.0,right: 20.0,top:10,bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(UiIcons.map,size: 20,color: site?Colors.white:SiteConfig().darkMode),
                          SizedBox(width:5.0),
                          WidgetHelper().textQ("Alamat Pengiriman",12,site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                        ],
                      ),
                      InkWell(
                        child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.grey[200])
                            ),
                            child: WidgetHelper().textQ("Pilih Alamat Pengiriman",10,site?Colors.white:SiteConfig().darkMode, FontWeight.bold)
                        ),
                      )
                    ],
                  ),
                ),
                Divider(),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          WidgetHelper().textQ("Asli",12,site?SiteConfig().secondDarkColor:Colors.grey, FontWeight.bold),
                          SizedBox(width: 5.0),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color:Colors.grey[200]),
                            alignment: AlignmentDirectional.topEnd,
                            child: WidgetHelper().textQ("Utama",12, Theme.of(context).hintColor, FontWeight.bold),
                          )
                        ],
                      ),
                      WidgetHelper().textQ("Annashrul Yusuf (081223165037)",12,site?Colors.white:Colors.black87, FontWeight.normal),
                      WidgetHelper().textQ("Jalan kebon manggu rt 02/04 kelurahan padasuka kecamata cimahi tengah kota cimahi",12,site?Colors.white:Colors.black87, FontWeight.normal),
                    ],
                  ),
                ),
              ],
            ),
          ),
          site?Container():WidgetHelper().pembatas(context),
          Container(
            padding: EdgeInsets.only(left:20.0,right:20.0,top:10.0,bottom: 10.0),
            child:Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.grey[200])
                  ),
                  child: InkWell(
                    onTap: (){
                      modalKurir(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only(left:10.0,right: 10.0,top:5,bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetHelper().textQ("Pilih Kurir",14,site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                              SizedBox(height: 5.0),
                              WidgetHelper().textQ(kurirTitle,12,site?Colors.white:SiteConfig().darkMode, FontWeight.normal)
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios,size: 15,color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.grey[200])
                  ),
                  child: InkWell(
                    onTap: (){
                      if(kurirTitle!=''){
                        modalLayanan(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(left:10.0,right: 10.0,top:5,bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetHelper().textQ("Pilih Layanan",14,site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                              SizedBox(height: 5.0),
                              WidgetHelper().textQ("$kurirDeskripsi",12,site?Colors.white:SiteConfig().darkMode, FontWeight.normal)
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios,size: 15,color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.grey[200])
                  ),
                  child: InkWell(
                    onTap: (){
                      if(kurirTitle!=''){
                        modalLayanan(context);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.only(left:10.0,right: 10.0,top:5,bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetHelper().textQ("Gunakan Voucher",14,site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                              SizedBox(height: 5.0),
                              WidgetHelper().textQ("Sentuh dan masukan kode voucher yang kamu punya",12,site?Colors.white:SiteConfig().darkMode, FontWeight.normal)
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios,size: 15,color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          site?Container():WidgetHelper().pembatas(context),
          Padding(
            padding: EdgeInsets.only(left: 20.0,right: 20.0,top: 10.0,bottom: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHelper().textQ("Ringkasan Belanja",14,site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                SizedBox(height: 10),
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WidgetHelper().textQ("Total Harga",12,site?Colors.white:SiteConfig().darkMode, FontWeight.normal),
                          WidgetHelper().textQ(FunctionHelper().formatter.format(subTotal),12,Colors.green, FontWeight.normal),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WidgetHelper().textQ("Total Ongkos Kirim",12,site?Colors.white:SiteConfig().darkMode, FontWeight.normal),
                          WidgetHelper().textQ(FunctionHelper().formatter.format(cost),12,Colors.green, FontWeight.normal),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          site?Container():WidgetHelper().pembatas(context),
          Padding(
            padding: EdgeInsets.only(left:20.0,right: 20.0,top:10,bottom: 10),
            child: Container(
              // height: MediaQuery.of(context).size.height/2,
              child: new StaggeredGridView.countBuilder(
                addRepaintBoundaries: true,
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 4,
                itemCount: cartModel.result.length,
                itemBuilder: (context,index){
                  return ProductWidget(
                    id: cartModel.result[index].idBarang,
                    gambar: SiteConfig().noImage,
                    title: cartModel.result[index].barang,
                    harga: cartModel.result[index].hargaJual,
                    hargaCoret: cartModel.result[index].hargaCoret,
                    rating: '0',
                    stock: cartModel.result[index].stock,
                    stockSales: cartModel.result[index].stock,
                    disc1: "${cartModel.result[index].qty}",
                    disc2: cartModel.result[index].disc2,
                    countCart: (){},
                  );
                },
                staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNavBarBeli(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  Widget _bottomNavBarBeli(BuildContext context){
    return Container(
      color: site?SiteConfig().darkMode:SiteConfig().mainColor,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidgetHelper().textQ("Total Tagihan",14,Colors.white, FontWeight.bold),
              WidgetHelper().textQ(FunctionHelper().formatter.format(grandTotal),14,Colors.white, FontWeight.bold),
            ],
          ),
          Container(
              height: kBottomNavigationBarHeight,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.grey[200])
              ),
              child: FlatButton(
                onPressed: (){
                  modalBank(context);
                },
                child: WidgetHelper().textQ("Pilih Pembayaran",14,Colors.white, FontWeight.bold),
                // child: Text("Bayar", style: TextStyle(color: Colors.white,fontFamily: ThaibahFont().fontQ,fontWeight: FontWeight.bold,fontSize: ScreenUtilQ.getInstance().setSp(34))),
              )
          )
        ],
      ),
    );
  }
  Widget modalBank(BuildContext context){
    WidgetHelper().myModal(
        context,
        Container(
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
                        WidgetHelper().textQ("Pilih bank untuk melanjutkan proses checkout",12,Colors.white, FontWeight.bold)
                      ],
                    )
                ),
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
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: (){
                    WidgetHelper().notifDialog(context,"Perhatian","Anda yakin akan melakukan proses checkout sekarang ??",(){Navigator.pop(context);},(){
                      Navigator.pop(context);
                      checkout();
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                            color: SiteConfig().mainColor,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
                            ]),
                        child: Center(
                          child: WidgetHelper().textQ("Lanjut",14,Colors.white, FontWeight.bold),
                        )
                    ),
                  ),
                ),
              )
            ],
          ),
        )
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
                        trailing: widget.index==index?Icon(UiIcons.checked,color: site?Colors.grey[200]:SiteConfig().darkMode):Text(
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
                         trailing: widget.index==index?Icon(UiIcons.checked,color: site?Colors.grey[200]:SiteConfig().darkMode):Text('')
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
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.bankModel.result.data.length,
      itemBuilder: (context,index){
        return InkWell(
          onTap: (){
            print(widget.bankModel.result.data[index].atasNama);
            widget.callback(index);
            // isSelectedBank();
            isSelectedBank(index);
          },
          child: ListTile(
            trailing: num==index?Icon(UiIcons.checked,color:site?Colors.grey[200]:SiteConfig().darkMode):Text(''),
            contentPadding: EdgeInsets.only(left:10,right:10,top:0,bottom:0),
            leading: Image.network(SiteConfig().noImage,width: 50,height: 50,),
            title: WidgetHelper().textQ("${widget.bankModel.result.data[index].atasNama}", 12,site?Colors.white:SiteConfig().darkMode, FontWeight.bold),
            subtitle: WidgetHelper().textQ(widget.bankModel.result.data[index].noRekening, 12, SiteConfig().secondColor, FontWeight.bold),
          ),
        );
      },
      separatorBuilder: (context, index) {return Divider(height: 1);},
    );
  }
}

