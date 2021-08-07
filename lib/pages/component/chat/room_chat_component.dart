import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/ticket/detail_ticket_model.dart';
import 'package:netindo_shop/model/ticket/list_ticket_model.dart';
import 'package:netindo_shop/pages/widget/chat/room_chat_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';

class RoomChatComponent extends StatefulWidget {
  final Map<String, Object> data;
  RoomChatComponent({this.data});
  @override
  _RoomChatComponentState createState() => _RoomChatComponentState();
}

class _RoomChatComponentState extends State<RoomChatComponent> {
  Map<String,Object> resTenant;
  final myController = TextEditingController();
  String txtLoading="tulis pesan disini ..";
  List chat=[];
  DetailTicketModel detailTicketModel;
  bool isLoading=true,isShow=true;
  String idMember="";
  Future loadData()async{

    final tenant=await FunctionHelper().getTenant();
    final member = await UserHelper().getDataUser(StringConfig.id_user);
    resTenant = tenant;
    final res=await HandleHttp().getProvider("chat/${widget.data["id"]}", detailTicketModelFromJson,context: context);
    if(res!=null){
      DetailTicketModel result=res;
      for(int i=0;i<result.result.detail.length;i++){
        chat.add({"msg":result.result.detail[i].msg,"id_member":result.result.detail[i].idMember});
      }
      idMember = member;
      isLoading=false;
      detailTicketModel = DetailTicketModel.fromJson(result.toJson());
      WidgetsBinding.instance.addPostFrameCallback((_){
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,

          );
        }
      });
      if(this.mounted)this.setState(() {});

    }
  }

  Future replyTicket()async{
    final idMember = await UserHelper().getDataUser(StringConfig.id_user);
    final data={
      "id_master":widget.data["id"],
      "id_member":idMember,
      // "id_user":"543f3d34-a5df-4be1-b667-6ed4e53a84b1",
      "msg":"${myController.text}"
    };
    print(data);
    await HandleHttp().postProvider("chat/reply", data);
    myController.text="";
  }
  ScrollController _scrollController = new ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();



  }

  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    print(widget.data);
    if(WidgetsBinding.instance.window.viewInsets.bottom > 0.0)
    {
      //Keyboard is visible.
      print("visible");
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent*2,
        duration: Duration(seconds: 10),
        curve: Curves.fastOutSlowIn,
      );
    }
    else
    {
      print("not visible");
      //Keyboard is not visible.
    }
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, isLoading?"loading ..":resTenant[StringConfig.namaTenant], (){},<Widget>[
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
              color: Colors.blueGrey,
              boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
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
              controller: _scrollController,
              // reverse: false,
              shrinkWrap: true,
              padding: scaler.getPadding(1,2),
              itemCount: chat.length,
              itemBuilder: (context, index) {
                return buildContent(
                  context,
                  chat[index],
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
                      setState(() {
                        chat.insert(chat.length, {"msg":myController.text,"id_member":idMember});
                      });
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent*2,
                        duration: Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                      );
                      await replyTicket();
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
    return data["id_member"]==null ? getSentMessageLayout(context,data) : getReceivedMessageLayout(context,data);
    // return new SizeTransition(
    //   sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.decelerate),
    //   child:data["id_member"]!=null ? getSentMessageLayout(context,data) : getReceivedMessageLayout(context,data),
    // );
  }
  Widget getSentMessageLayout(context,var data) {
    final scaler=config.ScreenScale(context).scaler;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).focusColor.withOpacity(0.2),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
        padding:scaler.getPadding(0.7,1),
        margin: scaler.getMargin(0.5,0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  config.MyFont.subtitle(context: context,text:"acuy",color: Theme.of(context).textTheme.bodyText2.color,fontSize: 8,fontWeight: FontWeight.bold),
                  new Container(
                    // child: new Text(widget.data["msg"]),
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
                    child: new CircleAvatar(
                      backgroundImage: AssetImage(StringConfig.userImage),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getReceivedMessageLayout(context,var data) {
    final scaler=config.ScreenScale(context).scaler;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
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
                      backgroundImage: AssetImage(StringConfig.userImage),
                    )),
              ],
            ),
            new Flexible(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  config.MyFont.subtitle(context: context,text:"acuy",color: Theme.of(context).primaryColor,fontSize: 8,fontWeight: FontWeight.bold),
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
