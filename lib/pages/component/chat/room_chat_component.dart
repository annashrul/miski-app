import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/ticket/detail_ticket_model.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:miski_shop/provider/room_chat_provider.dart';
import 'package:miski_shop/provider/tenant_provider.dart';
import 'package:miski_shop/provider/user_provider.dart';
import 'package:provider/provider.dart';

class RoomChatComponent extends StatefulWidget {
  final Map<String, Object> data;
  RoomChatComponent({this.data});
  @override
  _RoomChatComponentState createState() => _RoomChatComponentState();
}

class _RoomChatComponentState extends State<RoomChatComponent> {
  final myController = TextEditingController();
  String txtLoading="tulis pesan disini ..";
  List chat=[];
  DetailTicketModel detailTicketModel;
  bool isShow=true;


  @override
  void initState() {
    super.initState();

    final tenant = Provider.of<TenantProvider>(context, listen: false);
    final dataChat = Provider.of<RoomChatProvider>(context, listen: false);
    final dataUser = Provider.of<UserProvider>(context, listen: false);
    dataUser.getUserData(context);
    tenant.read();
    dataChat.read(context: context,idChat: widget.data["id"]);
  }

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    final tenant = Provider.of<TenantProvider>(context);
    final dataChat = Provider.of<RoomChatProvider>(context);
    final dataUser = Provider.of<UserProvider>(context);
    if(WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
      dataChat.scrollController.animateTo(
        dataChat.scrollController.position.maxScrollExtent*2,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }

    print("ECHO ${dataChat.data.length}");
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, tenant.namaTenant, (){},<Widget>[
        WidgetHelper().iconAppbar(context: context,icon: !isShow?Icons.arrow_drop_down:Icons.close,callback: (){
          this.setState(() {
            isShow=!isShow;
          });
        })
      ],param: "default"),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          if(isShow)Container(
            margin: scaler.getMargin(1,2),
            decoration: BoxDecoration(
              color: config.Colors.secondColors,
              // boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
            ),
            padding: scaler.getPadding(0.5,2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: config.MyFont.subtitle(context: context,text:widget.data["title"],color:Colors.white,fontWeight: FontWeight.bold),),
                  ],
                ),
                config.MyFont.subtitle(context: context,text:widget.data["deskripsi"],fontSize:8,color:Colors.grey[300]),
                if(widget.data["lampiran"]!="") WidgetHelper().myRipple(
                  callback: (){
                    WidgetHelper().myModal(context, Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: scaler.getPadding(1, 2),
                          child: Column(
                            children: [
                              WidgetHelper().titleQ(
                                context,
                                "Lampiran anda",
                                icon: UiIcons.information,fontSize: 9,
                              ),
                              Divider(),
                              WidgetHelper().baseImage(widget.data["lampiran"],width: double.infinity)
                            ],
                          ),
                        )
                      ],
                    ));
                  },
                  child: config.MyFont.title(context: context,text:"lihat lampiran",fontSize: 9,color: config.Colors.mainDarkColors,textDecoration: TextDecoration.underline)
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: dataChat.scrollController,
              shrinkWrap: true,
              padding: scaler.getPadding(1,2),
              itemCount: dataChat.data.length,
              itemBuilder: (context, index) {
                return buildContent(
                  context,
                  dataChat.data[index],
                );
              },
            )
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)
              ],
            ),
            child: TextField(
              style: config.MyFont.style(context: context,style: Theme.of(context).textTheme.caption,fontSize: 10),
              controller: myController,
              decoration: InputDecoration(
                contentPadding: scaler.getPadding(1,2),
                hintText: txtLoading,
                hintStyle: config.MyFont.style(context: context,style: Theme.of(context).textTheme.caption,fontSize: 10),
                suffixIcon: IconButton(
                  padding: EdgeInsets.only(right: 30),
                  onPressed: ()async{
                    if(myController.text!=""){
                      final data={
                        "id_master":widget.data["id"],
                        "id_member":dataUser.data[StringConfig.id_user],
                        "msg":myController.text,
                      };
                      await dataChat.store(context: context,datas: data);
                      myController.text="";
                    }
                  },
                  icon: Icon(
                    UiIcons.cursor,
                    color: Theme.of(context).accentColor,
                    size: 30,
                  ),
                ),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context,var data) {
    return data["id_member"]!=null ? getSentMessageLayout(context,data) : getReceivedMessageLayout(context,data);

  }
  Widget getSentMessageLayout(context,var data) {
    final tenant = Provider.of<TenantProvider>(context);
    final scaler=config.ScreenScale(context).scaler;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).focusColor.withOpacity(0.2),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
        ),
        padding:scaler.getPadding(0.7,1),
        margin: scaler.getMargin(0.5,0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  config.MyFont.subtitle(context: context,text:tenant.namaTenant,color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8,fontWeight: FontWeight.bold),
                  new Container(
                    child: config.MyFont.subtitle(context: context,text:data["msg"],fontSize: 8,color: Theme.of(context).textTheme.bodyText2.color),
                  ),
                ],
              ),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  child: WidgetHelper().baseImage(
                    tenant.logoTenant,
                    height: scaler.getHeight(3),
                    width: scaler.getWidth(6),
                    shape: BoxShape.circle
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getReceivedMessageLayout(context,var data) {
    final dataUser = Provider.of<UserProvider>(context);

    final scaler=config.ScreenScale(context).scaler;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
        padding:scaler.getPadding(0.7,1),
        margin: scaler.getMargin(0.5,0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: new CircleAvatar(
                      backgroundImage: NetworkImage(dataUser.data[StringConfig.foto]),
                    )
                ),
              ],
            ),
            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  config.MyFont.subtitle(context: context,text:dataUser.data[StringConfig.nama],color: Theme.of(context).primaryColor,fontSize: 8,fontWeight: FontWeight.bold),
                  new Container(
                    child:config.MyFont.subtitle(context: context,text:data["msg"],color: Theme.of(context).primaryColor,fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
