import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/model/ticket/list_ticket_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/detail_checkout_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';

class TicketScreen extends StatefulWidget {
  bool mode;
  TicketScreen({this.mode});
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  ListTicketModel listTicketModel;
  bool isLoading=false,isLoadmore=false,isError=false;
  int perpage=10;
  Future loadTicket()async{
    print("########################## load tiket chat?page=1&limit=$perpage #########################");
    var res = await BaseProvider().getProvider("chat?page=1&perpage=$perpage", listTicketModelFromJson);
    if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
      setState(() {
        isLoading=false;
        isLoadmore=false;
        isError=true;
      });
    }
    else{
      ListTicketModel result = res;
      if(result.status=='success'){
        setState(() {
          listTicketModel = ListTicketModel.fromJson(result.toJson());
          isLoading=false;
          isError=false;
          isLoadmore=false;
        });
        print("PERPAGE $perpage");
        print("PERPAGE ${listTicketModel.result.total}");
      }
    }

  }
  ScrollController controller;
  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if(perpage<int.parse(listTicketModel.result.total)){
        setState((){
          perpage+=10;
          isLoadmore=true;
        });
        loadTicket();

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
    isLoading=true;
    loadTicket();
    controller = new ScrollController()..addListener(_scrollListener);

  }

  @override
  Widget build(BuildContext context){
    return isLoading?LoadingTicket():RefreshWidget(
      widget: Stack(
        // alignment: FractionalOffset.bottomCenter,

        // alignment: isLoadmore?Alignment.bottomCenter:Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              controller: controller,
              padding: EdgeInsets.symmetric(vertical: 7),
              child: Column(
                children: <Widget>[
                  Offstage(
                    offstage: false,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shrinkWrap: true,
                      primary: false,
                      itemCount: listTicketModel.result.data.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 7);
                      },
                      itemBuilder: (context, index) {
                        var val = listTicketModel.result.data[index];
                        return InkWell(
                          onTap: () {
                            WidgetHelper().myPushAndLoad(context,RoomTicketScreen(mode:widget.mode),(){loadTicket();});
                            // Navigator.of(context).pushNamed('/Tabs', arguments: 5);
                          },
                          child: Container(
                            color: Theme.of(context).focusColor.withOpacity(0.15),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(50)),
                                          color:Theme.of(context).focusColor.withOpacity(0.15),
                                          // border: Border.all(color:SiteConfig().accentDarkColor)
                                        ),
                                        child: Center(
                                          child: WidgetHelper().textQ("${DateFormat().add_yMMMd().format(val.createdAt)} \n${DateFormat().add_jm().format(val.createdAt)}", 8, widget.mode?Colors.white:SiteConfig().darkMode,FontWeight.normal,textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 3,
                                      right: 3,
                                      width: 12,
                                      height: 12,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // color: widget.message.user.userState == UserState.available ? Colors.green : widget.message.user.userState == UserState.away ? Colors.orange : Colors.red,
                                          color: val.status==0?Colors.green:Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(width: 15),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Stack(
                                        alignment: AlignmentDirectional.topEnd,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right:10.0),
                                            child: WidgetHelper().textQ("${val.tenant}", 12, SiteConfig().mainColor, FontWeight.bold),
                                          ),
                                          Positioned(
                                            child:Icon(UiIcons.home,color:SiteConfig().mainColor,size: 8),
                                          )
                                        ],
                                      ),
                                      WidgetHelper().textQ("${val.title}",12,widget.mode?Colors.white:Colors.grey,FontWeight.bold),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Expanded(
                                            child:  WidgetHelper().textQ("${val.deskripsi}",10,widget.mode?Colors.grey[200]:Colors.grey,FontWeight.normal),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
          new Positioned(
            bottom: 20,
            right: 20,
            child: new Align(
                alignment: Alignment.bottomRight,
                child:InkWell(
                    borderRadius: BorderRadius.circular(50.0),
                    onTap: (){
                      WidgetHelper().myModal(context, ModalTicket(mode: widget.mode,callback:(String par){
                        if(par=='berhasil'){
                          loadTicket();
                          WidgetHelper().showFloatingFlushbar(context,"success","ticket komplain berhasil dikirim");
                        }
                        else{
                          WidgetHelper().showFloatingFlushbar(context,"success","ticket komplain gagal dikirim");
                        }
                      },));
                    },
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        color: widget.mode?Theme.of(context).focusColor.withOpacity(0.15):SiteConfig().mainColor,
                      ),
                      child:isLoadmore?CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey), backgroundColor: Colors.white): Icon(UiIcons.cursor,color: Colors.white),
                    )
                )
            ),
          )
        ],
      ),
      callback: (){
        print("refresh");
        FunctionHelper().handleRefresh((){loadTicket();});
      },
    );
  }


}

class RoomTicketScreen extends StatefulWidget {
  bool mode;
  RoomTicketScreen({this.mode});
  @override
  _RoomTicketScreenState createState() => _RoomTicketScreenState();
}

class _RoomTicketScreenState extends State<RoomTicketScreen> {
  final _myListKey = GlobalKey<AnimatedListState>();
  final myController = TextEditingController();
  List myTicket=[];
  ListTicketModel listTicketModel;

  bool isLoading=false,isLoadmore=false,isError=false;
  Future loadTicket()async{
    var res = await BaseProvider().getProvider("chat?page=1", listTicketModelFromJson);
    if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
      setState(() {
        isLoading=false;
        isLoadmore=false;
        isError=true;
      });
    }
    else{
      ListTicketModel result = res;
      if(result.status=='success'){
        setState(() {
          listTicketModel = ListTicketModel.fromJson(result.toJson());
          isLoading=false;
          isError=false;
          isLoadmore=false;
        });
      }
    }
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
  void load(){
    for(var i=0;i<20;i++){
      setState(() {
        myTicket.add({
          "nama":"acuy $i",
          "desc":"blabla"
        });
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
    isLoading=true;
    loadTicket();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.mode?SiteConfig().darkMode:Colors.white,
      appBar: WidgetHelper().appBarWithButton(context,"Room ${isLoading?"...":listTicketModel.result.data.length}",(){Navigator.pop(context);},<Widget>[],brightness: widget.mode?Brightness.dark:Brightness.light),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: AnimatedList(
              key: _myListKey,
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              initialItemCount: myTicket.length,
              itemBuilder: (context, index, Animation<double> animation) {
                return new SizeTransition(
                  sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.decelerate),
                  child:index%2==0 ? getSentMessageLayout(context) : getReceivedMessageLayout(context),
                  // child: getReceivedMessageLayout(context),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color:Theme.of(context).focusColor.withOpacity(0.15),
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)
              ],
            ),
            child: TextField(
              onTap: (){
                WidgetHelper().myModal(context, ModalTicket(mode: widget.mode));
              },
              readOnly: true,
              controller: myController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20),
                hintText: 'Tulis sesuatu disini ...',
                hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.8),fontFamily: SiteConfig().fontStyle),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(right: 30),
                  onPressed: () {},
                  icon: Icon(
                    UiIcons.cursor,
                    color:Theme.of(context).focusColor.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget getSentMessageLayout(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
          width:MediaQuery.of(context).size.width/1.5,
        decoration: BoxDecoration(
            color: Theme.of(context).focusColor.withOpacity(0.2),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
        ),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      WidgetHelper().myModal(context,previewImage(SiteConfig().noImage));
                    },
                    child: new Container(
                      height:  MediaQuery.of(context).size.height/3,
                      decoration: BoxDecoration(
                        color: Color(0xFF9FA6B0),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                        image: DecorationImage(
                          image: NetworkImage(SiteConfig().noImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: WidgetHelper().textQ("haiii", 10, Colors.white,FontWeight.normal),
                  ),
                  WidgetHelper().textQ("1 bulan yang lalu",8, Colors.grey,FontWeight.normal),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
  Widget getReceivedMessageLayout(context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width:MediaQuery.of(context).size.width/1.5,
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      WidgetHelper().myModal(context,previewImage(SiteConfig().noImage));
                    },
                    child: new Container(
                      height:  MediaQuery.of(context).size.height/3,
                      decoration: BoxDecoration(
                        color: Color(0xFF9FA6B0),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                        image: DecorationImage(
                          image: NetworkImage(SiteConfig().noImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: WidgetHelper().textQ("blablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablablabla", 10, Colors.white,FontWeight.normal),
                  ),
                  WidgetHelper().textQ("1 bulan yang lalu",8, Colors.grey,FontWeight.normal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget previewImage(String img){
    return Container(
      height: MediaQuery.of(context).size.height/1.2,
      padding: EdgeInsets.only(top:10.0,left:0,right:0),
      decoration: BoxDecoration(
        color: widget.mode?SiteConfig().darkMode:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight:Radius.circular(10.0) ),
      ),
      // color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'imageHero',
                  child: Image.asset(
                      "assets/img/hp_samsung.jpg"
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}

class ModalTicket extends StatefulWidget {
  bool mode;
  Function(String param) callback;
  ModalTicket({this.mode,this.callback});
  @override
  _ModalTicketState createState() => _ModalTicketState();
}

class _ModalTicketState extends State<ModalTicket> {
  int idx=0;
  List resTenant=[];
  DatabaseConfig _helper = DatabaseConfig();
  var titleController = TextEditingController();
  var messageController = TextEditingController();
  final FocusNode titleFocus = FocusNode();
  final FocusNode messageFocus = FocusNode();
  File _image;
  String fileName;
  String base64Image;
  bool isErrorTenant=false;
  Future getTenant()async{
    final tenant = await _helper.getData(TenantQuery.TABLE_NAME);
    setState(() {
      resTenant = tenant;
    });
  }
  Future postTicket()async{
    if(resTenant.length<1){
      setState(() {
        isErrorTenant=true;
      });
    }else if(titleController.text==''){
      titleFocus.requestFocus();
    }
    else if(messageController.text==''){
      messageFocus.requestFocus();
    }
    else{
      WidgetHelper().loadingDialog(context);
      if(_image!=null){
        fileName = _image.path.split("/").last;
        var type = fileName.split('.');
        base64Image = 'data:image/' + type[1] + ';base64,' + base64Encode(_image.readAsBytesSync());
      }
      else{
        base64Image = "-";
      }
      final data={
        "title":titleController.text,
        "deskripsi":messageController.text,
        "lampiran":base64Image,
        "layanan":"Barang",
        "prioritas":"0",
        "status":"0",
        "id_tenant":resTenant[idx]['id_tenant']
      };
      print(data);
      var res = await BaseProvider().postProvider("chat", data);
      Navigator.pop(context);
      if(res==SiteConfig().errSocket||res==SiteConfig().errTimeout){
        widget.callback("gagal");
        WidgetHelper().notifDialog(context,"Perhatian", "Terjadi kesalahan koneksi",(){Navigator.pop(context);}, (){postTicket();},titleBtn1: "kembali",titleBtn2: "coba lagi");
      }
      else{
        Navigator.pop(context,"berhasil");
        widget.callback("berhasil");
        // print("RESPONSE $res");
        // Navigator.pop(context);
        // WidgetHelper().notifDialog(context,"Berhasil", "Pengiriman tiket komplain berhasil dikirim",(){Navigator.pop(context);}, (){WrapperScreen(currentTab: 2);},titleBtn1: "kembali",titleBtn2: "Beranda");
      }
    }



  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Widget childTenant;
    if(resTenant.length>0){
      childTenant = CircleAvatar(
        backgroundImage: NetworkImage(resTenant[idx]['logo']),
      );
    }
    return Container(
      height: _image==null?MediaQuery.of(context).size.height/1.7:MediaQuery.of(context).size.height/1.0,
      padding: EdgeInsets.only(top:10.0,left:0,right:0),
      decoration: BoxDecoration(
        color: widget.mode?SiteConfig().darkMode:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight:Radius.circular(10.0) ),
      ),
      // color: Colors.white,
      child: Column(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.only(top:0.0),
              width: 50,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:  BorderRadius.circular(10.0),
              ),
            ),
          ),
          ListTile(
            dense:true,
            contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            leading: InkWell(
              onTap: ()=>Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Center(child: Icon(UiIcons.return_icon, color: widget.mode?Colors.white:Theme.of(context).hintColor),),
              ),
            ),
            trailing: InkWell(
                onTap: ()async{
                  postTicket();
                },
                child: Container(
                  padding: EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [SiteConfig().secondColor,SiteConfig().secondColor]),
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: [BoxShadow(color: Color(0xFF6078ea).withOpacity(.3),offset: Offset(0.0, 8.0),blurRadius: 8.0)]
                  ),
                  child: WidgetHelper().textQ("Kirim",14,Colors.white,FontWeight.bold),
                )
            ),
          ),
          Divider(),
          SizedBox(height:10.0),
          Expanded(
            child: ListView(
              children: [
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: isErrorTenant?Colors.red:Colors.grey[200]),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                        ),
                      ),
                      padding: EdgeInsets.only(left:10.0,right:10.0),
                      child: ListTile(
                        onTap: (){
                          messageFocus.unfocus();
                          FocusScope.of(context).unfocus();
                          WidgetHelper().myModal(context,ModalTenant(
                              mode: widget.mode,
                              callback: (index)async{
                                WidgetHelper().loadingDialog(context);
                                setState(() {
                                  idx=index;
                                  isErrorTenant=false;
                                });
                                await getTenant();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            index: idx,
                          ));
                        },
                        contentPadding: EdgeInsets.all(0.0),
                        leading: childTenant,
                        title: WidgetHelper().textQ("${resTenant.length>0?'${resTenant[idx]['nama']}':'Silahkan pilih tenant terlebih dahulu'}",10,Colors.grey,FontWeight.bold),
                        trailing: Icon(Icons.arrow_forward_ios,size: 15,color: Colors.grey),
                      ),
                    )
                ),
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                        ),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: TextField(
                        style: TextStyle(color:Colors.grey,fontSize:12,fontFamily: SiteConfig().fontStyle,fontWeight: FontWeight.bold),
                        controller: titleController,
                        focusNode: titleFocus,
                        autofocus: false,
                        maxLines: 1,
                        decoration: InputDecoration.collapsed(
                            hintText: "contoh : Refund belum sampai",
                            hintStyle: TextStyle(color:Colors.grey,fontSize: 12,fontFamily: SiteConfig().fontStyle,fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                ),
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                        ),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: TextField(
                        style: TextStyle(color:Colors.grey,fontSize:12,fontFamily: SiteConfig().fontStyle,fontWeight: FontWeight.bold),
                        controller: messageController,
                        focusNode: messageFocus,
                        autofocus: false,
                        maxLines: 5,
                        decoration: InputDecoration.collapsed(
                            hintText: "contoh : Selamat siang, kenapa ketika saya refund status nya belum sampai terus ? ",
                            hintStyle: TextStyle(color:Colors.grey,fontSize: 12,fontFamily: SiteConfig().fontStyle,fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                ),
                InkWell(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10.0)
                  ),
                  onTap: ()async{
                    var img = await FunctionHelper().getImage('galeri');
                    setState(() {
                      _image = img;
                    });
                    messageFocus.unfocus();
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).focusColor.withOpacity(0.15),
                          border: Border.all(color: Colors.grey[200]),
                          borderRadius: BorderRadius.all(
                              Radius.circular(10.0)
                          ),
                        ),
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Icon(UiIcons.upload,color: widget.mode?Colors.white:SiteConfig().darkMode),
                            WidgetHelper().textQ("Lampirkan File",10,Colors.white,FontWeight.bold)
                          ],
                        ),
                      )
                  ),
                ),
                Divider(),
                Container(
                  padding:EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    borderRadius:  BorderRadius.circular(10.0),
                  ),
                  child: _image == null ?Container(): new Image.file(_image,width: MediaQuery.of(context).size.width/1,height: MediaQuery.of(context).size.height/2,filterQuality: FilterQuality.high,fit: BoxFit.cover),
                ),
              ],
            ),
          )
        ],
      ),
    );

  }
}


class ModalTenant extends StatefulWidget {
  ModalTenant({
    Key key,
    @required this.mode,
    @required this.callback,
    @required this.index,
  }) : super(key: key);
  bool mode;
  Function(int idx) callback;
  final int index;
  @override
  _ModalTenantState createState() => _ModalTenantState();
}

class _ModalTenantState extends State<ModalTenant> {

  DatabaseConfig _helper = DatabaseConfig();
  List resTenant = [];
  int idx=0;
  Future getTenant()async{
    final tenant = await _helper.getData(TenantQuery.TABLE_NAME);
    setState(() {
      resTenant = tenant;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTenant();
    idx = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height/2,
      decoration: BoxDecoration(
          color: widget.mode?SiteConfig().darkMode:Colors.transparent,
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
          Expanded(
            child: Scrollbar(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: resTenant.length,
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
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(resTenant[index]['logo']),
                        ),
                        // leading: Image.network(resTenant[index]['logo'],width: 30,height: 30,),
                        title: WidgetHelper().textQ("${resTenant[index]['nama']}", 14,widget.mode?Colors.white:SiteConfig().darkMode, FontWeight.bold),
                        // subtitle: WidgetHelper().textQ("${widget.kurirModel.result[index].deskripsi}", 12, SiteConfig().secondColor, FontWeight.bold),
                        trailing: widget.index==index?Icon(UiIcons.checked,color: widget.mode?Colors.grey[200]:SiteConfig().darkMode):Text(
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

