import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_screen_scaler/flutter_screen_scaler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/model/ticket/detail_ticket_model.dart';
import 'package:netindo_shop/model/ticket/list_ticket_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/checkout/detail_checkout_screen.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';
import 'package:netindo_shop/views/widget/refresh_widget.dart';
import 'package:netindo_shop/views/widget/timeout_widget.dart';

class TicketScreen extends StatefulWidget {

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
    ScreenScaler scaler = ScreenScaler()..init(context);

    return isLoading?LoadingTicket(total: 10):isError?TimeoutWidget(callback: ()async{
      setState(() {
        isLoading=true;
      });
      await loadTicket();
    }):RefreshWidget(
        widget: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: listTicketModel.result.data.length>0?SingleChildScrollView(
                controller: controller,
                padding: EdgeInsets.symmetric(),
                child: Column(
                  children: <Widget>[
                    Offstage(
                      offstage: false,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(),
                        shrinkWrap: true,
                        primary: false,
                        itemCount: listTicketModel.result.data.length,
                        separatorBuilder: (context, index) {
                          return Divider(height:1);
                        },
                        itemBuilder: (context, index) {
                          var val = listTicketModel.result.data[index];
                          return InkWell(
                            onTap: () {
                              // print(val.id);
                              print(listTicketModel.result.data);
                              WidgetHelper().myPush(context,RoomTicketScreen(
                                  id: val.id,
                                  tenant:val.tenant,title:val.title,desc:val.deskripsi,createdAt:val.createdAt,status:val.status
                              ));
                            },
                            child: Container(
                              color:Theme.of(context).focusColor.withOpacity(0.1),
                              padding: scaler.getPadding(1,2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    children: <Widget>[
                                      SizedBox(
                                        width: scaler.getWidth(17),
                                        height: scaler.getHeight(7),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            // shape: BoxShape.circle,
                                            borderRadius: BorderRadius.all(Radius.circular(50)),
                                            color:Theme.of(context).focusColor.withOpacity(0.15),
                                            // border: Border.all(color:SiteConfig().accentDarkColor)
                                          ),
                                          child: Center(
                                            child: WidgetHelper().textQ("${DateFormat().add_yMMMd().format(val.createdAt)} \n${DateFormat().add_jm().format(val.createdAt)}", scaler.getTextSize(8), SiteConfig().darkMode,FontWeight.normal,textAlign: TextAlign.center),
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
                                              child: WidgetHelper().textQ("${val.tenant}", scaler.getTextSize(9), SiteConfig().mainColor, FontWeight.bold),
                                            ),
                                            Positioned(
                                              child:Icon(AntDesign.home,color:SiteConfig().mainColor,size: 8),
                                            )
                                          ],
                                        ),
                                        WidgetHelper().textQ("${val.title}", scaler.getTextSize(9),SiteConfig().darkMode,FontWeight.normal),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Expanded(
                                              child:  WidgetHelper().textQ("${val.deskripsi}", scaler.getTextSize(8),Colors.grey,FontWeight.normal),
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
              ):EmptyTenant(),
            ),
            new Positioned(
              bottom: scaler.getHeight(1),
              right: scaler.getWidth(5),
              child: new Align(
                  alignment: Alignment.bottomRight,
                  child:WidgetHelper().animShakeWidget(context,InkWell(
                    borderRadius: BorderRadius.circular(50.0),
                    onTap: (){
                      WidgetHelper().myModal(context, ModalTicket(callback:(String par){
                        if(par=='berhasil'){
                          loadTicket();
                          WidgetHelper().showFloatingFlushbar(context,"success","ticket komplain berhasil dikirim");
                        }
                        else{
                          WidgetHelper().showFloatingFlushbar(context,"success","ticket komplain gagal dikirim");
                        }
                      },));
                    },
                    child:Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color:SiteConfig().mainColor,
                      ),

                      child:isLoadmore?CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey), backgroundColor: Colors.white): Icon(AntDesign.message1,color: Colors.white),
                    ),
                  ))
              ),
            )
          ],
        ),
        callback: (){
          FunctionHelper().handleRefresh((){loadTicket();});
        },
    );
  }

}

class RoomTicketScreen extends StatefulWidget {
  String id;
  String tenant;
  String title;
  String desc;
  DateTime createdAt;
  int status;
  RoomTicketScreen({this.id,this.tenant,this.title,this.desc,this.createdAt,this.status});
  @override
  _RoomTicketScreenState createState() => _RoomTicketScreenState();
}

class _RoomTicketScreenState extends State<RoomTicketScreen> {
  final msgController = TextEditingController();
  final FocusNode msgFocus = FocusNode();
  List myTicket=[];
  DetailTicketModel detailTicketModel;
  bool isLoading=false,isLoadmore=false,isError=false;
  DatabaseConfig db = DatabaseConfig();
  ScrollController _scrollController = ScrollController();
  bool _keyboardVisible = false;
  _scrollToBottom() {
    if (_scrollController != null && _scrollController.positions.isNotEmpty)
      _scrollController.animateTo(
        -0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 1000),
      );
  }
  Future loadDetailTicket(param)async{
    print("####################### PARAM $param #############################");
    final countTicket = await db.queryRowCountWhere(TicketQuery.TABLE_NAME,"id_master", widget.id);
    if(countTicket>0){
      if(param!=''){
        await db.delete(TicketQuery.TABLE_NAME,"id_ticket", widget.id);
        var res = await BaseProvider().getProvider("chat/${widget.id}", detailTicketModelFromJson);
        DetailTicketModel result = res;
        setState(() {
          detailTicketModel = DetailTicketModel.fromJson(result.toJson());
        });
        await storeTicket();
      }
      var res = await db.getWhere(TicketQuery.TABLE_NAME, "id_master", widget.id,"",orderBy: 'id');
      setState(() {
        myTicket = res;
        isLoading=false;
        isError=false;
        isLoadmore=false;
      });
    }
    else{
      var res = await BaseProvider().getProvider("chat/${widget.id}", detailTicketModelFromJson);
      if(res==SiteConfig().errTimeout||res==SiteConfig().errSocket){
        setState(() {
          isLoading=false;
          isLoadmore=false;
          isError=true;
        });
      }
      else{
        DetailTicketModel result = res;
        if(result.status=='success'){
          setState(() {
            detailTicketModel = DetailTicketModel.fromJson(result.toJson());
            isLoading=false;
            isError=false;
            isLoadmore=false;
          });
          storeTicket();
        }
      }
    }

  }
  Future replyTicket()async{
    if(msgController.text==''){
      msgFocus.requestFocus();
    }
    else{
      final id_member = await UserHelper().getDataUser("id_user");
      final member = await UserHelper().getDataUser("nama");
      final data={
        "id_master":widget.id,
        "id_member":id_member,
        "msg":"${msgController.text}"
      };
      final dataLocal =  {
        "id_ticket": widget.id.toString(),
        "id_master": widget.id.toString(),
        "id_member": id_member.toString(),
        "member":member.toString(),
        "id_user": "null",
        "users": "null",
        "msg": "${msgController.text}",
        "created_at": "${DateFormat("dd-MM-yyyy h:mma").format(DateTime.now()).toString()}",
        "updated_at": "${DateFormat("dd-MM-yyyy h:mma").format(DateTime.now()).toString()}"
      };
      await db.insert(TicketQuery.TABLE_NAME,dataLocal);
      loadDetailTicket('');
      msgController.text='';
      // msgFocus.unfocus();
      await BaseProvider().postProvider("chat/reply", data);

    }
  }
  Future storeTicket()async{
    print(widget.id);
    // await db.delete(TicketQuery.TABLE_NAME,"id_master", widget.id);
    var res = await BaseProvider().getProvider("chat/${widget.id}", detailTicketModelFromJson);

    detailTicketModel.result.detail.forEach((element)async {
      final data =  {
        "id_ticket": widget.id.toString(),
        "id_master": widget.id.toString(),
        "id_member": element.idMember==null?"null":element.idMember.toString(),
        "member":element.member==null?"null":element.member.toString(),
        "id_user": element.idUser==null?"null":element.idUser.toString(),
        "users": element.users==null?"null":element.users.toString(),
        "msg": element.msg.toString(),
        "created_at": "${DateFormat("dd-MM-yyyy h:mma").format(element.createdAt).toString()}",
        "updated_at": "${DateFormat("dd-MM-yyyy h:mma").format(element.createdAt).toString()}"
      };
      var insert = await db.insert(TicketQuery.TABLE_NAME,data);
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _scrollToBottom();
        timer.cancel();
      }
    });

    loadDetailTicket('pertama');

  }

  @override
  Widget build(BuildContext context) {
    ScreenScaler scaler = ScreenScaler()..init(context);

    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WidgetHelper().appBarWithButton(context,widget.tenant,(){Navigator.pop(context);},<Widget>[],brightness:Brightness.light),
      body: isLoading?WidgetHelper().loadingWidget(context):Column(
        children: [
          Container(
            color: Theme.of(context).focusColor.withOpacity(0.15),
            padding: scaler.getPadding(0.5,2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    SizedBox(
                      width: scaler.getWidth(17),
                      height: scaler.getHeight(7),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color:Theme.of(context).focusColor.withOpacity(0.15),
                          // border: Border.all(color:SiteConfig().accentDarkColor)
                        ),
                        child: Center(
                          child: WidgetHelper().textQ("${DateFormat().add_yMMMd().format(widget.createdAt)} \n${DateFormat().add_jm().format(widget.createdAt)}", scaler.getTextSize(8), SiteConfig().darkMode,FontWeight.normal,textAlign: TextAlign.center),
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
                          color: widget.status==0?Colors.green:Colors.red,
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
                      WidgetHelper().textQ("${widget.title}",scaler.getTextSize(9),SiteConfig().darkMode,FontWeight.bold),
                      WidgetHelper().textQ("${widget.desc}",scaler.getTextSize(8),Colors.grey,FontWeight.normal,maxLines: null)
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: myTicket.length>0?buildLocal(context):buildServer(context)
          ),
          Container(
            decoration: BoxDecoration(
              color:Theme.of(context).focusColor.withOpacity(0.15)
              // boxShadow: [
              //   BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)
              // ],
            ),
            child: TextFormField(
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              cursorColor: Theme.of(context).focusColor.withOpacity(0.8),
              toolbarOptions: ToolbarOptions(
                copy: true,
                cut: true,
                paste: true,
                selectAll: true
              ),
              controller: msgController,
              focusNode: msgFocus,
              style:TextStyle(color: Theme.of(context).focusColor.withOpacity(0.8),fontFamily: SiteConfig().fontStyle),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20),
                hintText: 'Tulis sesuatu disini ...',
                hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.8),fontFamily: SiteConfig().fontStyle),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(right: 30),
                  onPressed: () {
                    replyTicket();
                    _scrollToBottom();
                  },
                  icon: Icon(
                    Ionicons.ios_send,
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
  
  Widget buildLocal(BuildContext context){
    ScreenScaler scaler = ScreenScaler()..init(context);

    return ListView.builder(
        padding: EdgeInsets.only(left:20,right:20),
        controller: _scrollController,
        itemCount: myTicket.length,
        reverse: true,
        itemBuilder: (context,index){
          var val = myTicket[index];
          print(val);
          return Align(
            alignment: val['id_member']=='null'?Alignment.centerRight:Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                  color:SiteConfig().secondColor,
                  borderRadius: val['id_member']=='null'?BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)):BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)
                  )
              ),
              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Flexible(
                    child: new Column(
                      crossAxisAlignment: val['id_member']=='null'?CrossAxisAlignment.end:CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: WidgetHelper().textQ(val['msg'], scaler.getTextSize(9), Colors.white,FontWeight.normal),
                        ),
                        WidgetHelper().textQ(TimeAgo.timeAgoSinceDate(val['created_at']), scaler.getTextSize(8), Colors.grey,FontWeight.normal),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  
  Widget buildServer(BuildContext context){
    return ListView.builder(
        padding: EdgeInsets.only(left:20,right:20),
        controller: _scrollController,
        itemCount: detailTicketModel.result.detail.length,
        reverse: true,
        itemBuilder: (context,index){
          var val = detailTicketModel.result.detail[index];
          return Align(
            alignment: val.idMember==null?Alignment.centerRight:Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor.withOpacity(0.2),
                  borderRadius: val.idMember==null?BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)):BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)
                  )
              ),
              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Flexible(
                    child: new Column(
                      crossAxisAlignment: val.idMember==null?CrossAxisAlignment.end:CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: WidgetHelper().textQ(val.msg, 10, Colors.black,FontWeight.normal),
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
    );
  }

}

class ModalTicket extends StatefulWidget {
  Function(String param) callback;
  ModalTicket({this.callback});
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
    print(tenant);
    setState(() {
      resTenant = tenant;
    });
  }
  Future postTicket()async{
    if(resTenant.length<1){
      setState(() {isErrorTenant=true;});
      Timer(Duration(seconds:1), (){
        setState(() {isErrorTenant=false;});
      });
      print(isErrorTenant);
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
    getTenant();
  }
  @override
  Widget build(BuildContext context) {
    Widget childTenant;
    if(resTenant.length>0){
      childTenant = Image.network(resTenant[idx]['logo'],fit: BoxFit.contain,width: 50,);
    }

    return Container(
      height: _image==null?MediaQuery.of(context).size.height/1.7:MediaQuery.of(context).size.height/1.0,
      padding: EdgeInsets.only(top:10.0,left:0,right:0),
      decoration: BoxDecoration(
        color: Colors.white,
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
                child: Center(child: Icon(AntDesign.back, color:Theme.of(context).hintColor),),
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
                WidgetHelper().animShakeWidget(context,Container(
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
                        leading: Padding(padding: EdgeInsets.all(5.0),child: childTenant,),
                        title: WidgetHelper().textQ("${resTenant.length>0?'${resTenant[idx]['nama']}':'Silahkan pilih tenant terlebih dahulu'}",10,Colors.grey,FontWeight.bold),
                        trailing: Icon(Icons.arrow_forward_ios,size: 15,color: Colors.grey),
                      ),
                    )
                ),enable: isErrorTenant),
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
                            Icon(AntDesign.upload,color: SiteConfig().darkMode),
                            WidgetHelper().textQ("Lampirkan File",10,SiteConfig().darkMode,FontWeight.bold)
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
    @required this.callback,
    @required this.index,
  }) : super(key: key);
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
    ScreenScaler scaler = ScreenScaler()..init(context);

    return Container(
      height: MediaQuery.of(context).size.height/1.1,
      decoration: BoxDecoration(
          color: Colors.transparent,
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
                        leading: Padding(padding: EdgeInsets.all(5.0),child:  Image.network(resTenant[index]['logo'],fit: BoxFit.contain,width: 50,),),
                        // leading: Image.network(resTenant[index]['logo'],width: 30,height: 30,),
                        title: WidgetHelper().textQ("${resTenant[index]['nama']}", 14,SiteConfig().darkMode, FontWeight.bold),
                        // subtitle: WidgetHelper().textQ("${widget.kurirModel.result[index].deskripsi}", 12, SiteConfig().secondColor, FontWeight.bold),
                        trailing: widget.index==index?Icon(AntDesign.checkcircleo,color:SiteConfig().darkMode):Text(
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

class TimeAgo{
  static String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    DateTime notificationDate = DateFormat("dd-MM-yyyy h:mma").parse(dateString);
    final date2 = DateTime.now();
    final difference = date2.difference(notificationDate);

    if (difference.inDays > 8) {
      return dateString;
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 minggu yang lalu' : 'minggu lalu';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 hari yang lalu' : 'kemari';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 jam yang lalu' : '1 jam yang lalu';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 menit yang lalu' : 'menit yang lalu';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} detik yang lalu';
    } else {
      return 'Just now';
    }
  }

}