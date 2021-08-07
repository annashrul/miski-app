import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/ticket/list_ticket_model.dart';
import 'package:netindo_shop/pages/widget/searchbar_widget.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:netindo_shop/views/widget/empty_widget.dart';
import 'package:netindo_shop/views/widget/loading_widget.dart';

class ChatComponent extends StatefulWidget {
  @override
  _ChatComponentState createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent> {
  ListTicketModel listTicketModel;
  bool isLoading=true;
  int perpage=10;
  Future loadTicket()async{
    print("########################## load tiket chat?page=1&limit=$perpage #########################");
    var res = await HandleHttp().getProvider("chat?page=1&perpage=$perpage", listTicketModelFromJson,context: context);
    if(res is ListTicketModel){
      ListTicketModel result = ListTicketModel.fromJson(res.toJson());
      listTicketModel=result;
      isLoading=false;
      if(this.mounted) this.setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTicket();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    // TODO: implement build
    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: scaler.getPadding(0, 2),
            child: SearchBarWidget(),
          ),
          isLoading?Container(
            padding: scaler.getPadding(0, 2),
            child: LoadingTicket(total: 10),
          ):Offstage(
            offstage: listTicketModel.result.data.isEmpty,
            child: ListView.separated(
              padding: scaler.getPadding(1, 2),
              shrinkWrap: true,
              primary: false,
              itemCount: listTicketModel.result.data.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                return buildItem(
                  context: context,
                  index: index
                );
              },
            ),
          ),
          if(!isLoading)Offstage(
            offstage:listTicketModel.result.data.isNotEmpty,
            child: EmptyDataWidget(
              iconData: UiIcons.chat,
              title: "D\'ont have any message",
              isFunction: false,
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem({BuildContext context,int index}) {
    final scaler = config.ScreenScale(context).scaler;
    final res=listTicketModel.result.data[index];
    return Dismissible(
      key: Key(index.hashCode.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: scaler.getPadding(0,2),
            child: Icon(
              UiIcons.trash,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
      },
      child: WidgetHelper().myRipple(
        callback: () {
          Navigator.of(context).pushNamed('/${StringConfig.roomChat}', arguments:res.toJson());
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    width: scaler.getWidth(10),
                    height: scaler.getHeight(4),
                    child: Hero(
                      tag: "${res.idTenant}${res.tenant}",
                      child:  CircleAvatar(
                        backgroundImage: AssetImage(StringConfig.userImage),
                      )
                    ),
                  ),
                  Positioned(
                    bottom: scaler.getHeight(0.3),
                    right: scaler.getWidth(0.3),
                    width: scaler.getWidth(1.2),
                    height: scaler.getHeight(1),
                    child: Container(
                      decoration: BoxDecoration(
                        color:Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(width: scaler.getWidth(1)),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child:config.MyFont.title(context: context,text:res.title,fontSize: 9),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child:config.MyFont.subtitle(context: context,text:"7 menit yang lalu",color: Theme.of(context).textTheme.caption.color,fontSize: 8),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
