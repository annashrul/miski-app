import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/general_model.dart';
import 'package:miski_shop/model/ticket/list_ticket_model.dart';
import 'package:miski_shop/pages/widget/chat/modal_form_chat_widget.dart';
import 'package:miski_shop/provider/chat_provider.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:miski_shop/provider/notification_provider.dart';
import 'package:miski_shop/provider/tenant_provider.dart';
import 'package:provider/provider.dart';
import '../../widget/empty_widget.dart';
import '../../widget/loading_widget.dart';
import '../../widget/refresh_widget.dart';

class ChatComponent extends StatefulWidget {
  @override
  _ChatComponentState createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent> {

  @override
  void initState() {
    super.initState();
    final chat = Provider.of<ChatProvider>(context, listen: false);
    chat.read(context);
    chat.controller = new ScrollController()..addListener(chat.scrollListener);
    initializeDateFormatting('id');
  }
  @override
  void dispose() {
    super.dispose();
    final chat = Provider.of<ChatProvider>(context, listen: false);
    chat.controller.removeListener(chat.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    final chat = Provider.of<ChatProvider>(context);
    return Scrollbar(
        child: RefreshWidget(
          callback: ()async {
            chat.reload(context);
          },
          widget: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  controller: chat.controller,
                  physics:AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      chat.isLoading? Container(padding: scaler.getPadding(0, 2),child: LoadingTicket(total: 10)): Offstage(
                        offstage: chat.listTicketModel.result.data.isEmpty,
                        child: ListView.separated(
                          padding: scaler.getPadding(1, 2),
                          shrinkWrap: true,
                          primary: false,
                          itemCount: chat.listTicketModel.result.data.length,
                          separatorBuilder: (context, index) {
                            return SizedBox(height: scaler.getHeight(0.5));
                          },
                          itemBuilder: (context, index) {
                            return buildItem(context: context, index: index);
                          },
                        ),
                      ),
                      if (!chat.isLoading) Offstage(
                          offstage: chat.listTicketModel.result.data.isNotEmpty,
                          child: EmptyDataWidget(
                            iconData: UiIcons.chat,
                            title: StringConfig.noData,
                            isFunction: false,
                          ),
                        ),
                      if(chat.isLoadMore) CupertinoActivityIndicator()
                    ],
                  ),
                ),
              ),
              new Positioned(
                bottom: 0,
                right: scaler.getWidth(5),
                child: new Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: WidgetHelper().animShakeWidget(
                        context,
                        InkWell(
                          borderRadius: BorderRadius.circular(50.0),
                          onTap: () {
                            WidgetHelper().myModal(context, ModalFormChatWidget(
                              callback: (status) {
                                // if (status) chat.read(context);
                              },
                            ));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: config.Colors.mainColors,
                            ),
                            child: Icon(UiIcons.chat, color: Colors.white),
                          ),
                        )
                    )
                ),
              )
            ],
          ),
        )
    );
  }

  Widget buildItem({BuildContext context, int index}) {
    final tenant = Provider.of<TenantProvider>(context);
    final chat = Provider.of<ChatProvider>(context);
    final scaler = config.ScreenScale(context).scaler;
    final res = chat.listTicketModel.result.data[index];
    return Dismissible(
      key: Key(index.hashCode.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: scaler.getPadding(0, 2),
            child: Icon(
              UiIcons.trash,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
        print("onDismissed");
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: config.MyFont.title(context: context,text: "Informasi",color: config.Colors.mainColors),
                  content: config.MyFont.title(context: context,text: "Anda yakin akan mengahpus pesan ini ?",fontSize: 9),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () =>Navigator.of(context).pop(),
                      child:config.MyFont.title(context: context, text: "Batal")
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        WidgetHelper().loadingDialog(context);
                        chat.delete(context, index);
                      },
                      child: config.MyFont.title(context: context,text: "Oke",color: config.Colors.mainColors)
                    )
                  ],
                );
              });
          return res;
        }
        return null;
      },
      child: WidgetHelper().myRipple(
        radius: 10,
        callback: () {
          Navigator.of(context).pushNamed('/${StringConfig.roomChat}', arguments: res.toJson());
        },
        child: Container(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Hero(
                    tag: "chat${res.id}",
                    child: WidgetHelper().baseImage(
                      tenant.logoTenant,
                      height: scaler.getHeight(4),
                      width: scaler.getWidth(10),
                      shape: BoxShape.circle
                    )
                  ),
                  Positioned(
                    bottom: scaler.getHeight(0.3),
                    right: scaler.getWidth(0.3),
                    width: scaler.getWidth(1.2),
                    height: scaler.getHeight(1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
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
                          child: config.MyFont.title(context: context, text: res.title, fontSize: 9),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: config.MyFont.subtitle(
                            context: context,
                            text:"${DateFormat.yMMMMEEEEd('id').format(res.createdAt)} ${DateFormat.Hms().format(res.createdAt)}",
                            color: Theme.of(context).textTheme.caption.color,
                            fontSize: 8
                          ),
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
