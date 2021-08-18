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
import 'package:miski_shop/provider/handle_http.dart';
import '../../widget/empty_widget.dart';
import '../../widget/loading_widget.dart';
import '../../widget/refresh_widget.dart';

class ChatComponent extends StatefulWidget {
  @override
  _ChatComponentState createState() => _ChatComponentState();
}

class _ChatComponentState extends State<ChatComponent> {
  ListTicketModel listTicketModel;
  bool isLoading = true;
  int perpage = 10;
  dynamic dataTenant;
  Future loadTicket() async {
    print(
        "########################## load tiket chat?page=1&limit=$perpage #########################");
    var res = await HandleHttp().getProvider(
        "chat?page=1&perpage=$perpage", listTicketModelFromJson,
        context: context);
    if (res is ListTicketModel) {
      ListTicketModel result = ListTicketModel.fromJson(res.toJson());
      listTicketModel = result;
      isLoading = false;
      if (this.mounted) this.setState(() {});
    }
  }

  Future deleteChat(index) async {
    WidgetHelper().loadingDialog(context);
    final res = await HandleHttp().deleteProvider(
        "chat/${listTicketModel.result.data[index].id}", generalFromJson,
        context: context);
    if (res != null) {
      Navigator.pop(context);
      loadTicket();
      WidgetHelper()
          .showFloatingFlushbar(context, "success", "pesan berhasil dihapus");
    }
  }

  @override
  void initState() {
    super.initState();
    loadTicket();
    initializeDateFormatting('id');
    FunctionHelper().getTenant().then((value) {
      dataTenant = value;
      this.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return RefreshWidget(
      callback: () {},
      widget: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  isLoading
                      ? Container(
                          padding: scaler.getPadding(0, 2),
                          child: LoadingTicket(total: 10),
                        )
                      : Offstage(
                          offstage: listTicketModel.result.data.isEmpty,
                          child: ListView.separated(
                            padding: scaler.getPadding(1, 2),
                            shrinkWrap: true,
                            primary: false,
                            itemCount: listTicketModel.result.data.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: scaler.getHeight(0.5));
                            },
                            itemBuilder: (context, index) {
                              return buildItem(context: context, index: index);
                            },
                          ),
                        ),
                  if (!isLoading)
                    Offstage(
                      offstage: listTicketModel.result.data.isNotEmpty,
                      child: EmptyDataWidget(
                        iconData: UiIcons.chat,
                        title: StringConfig.noData,
                        isFunction: false,
                      ),
                    )
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
                            if (status) loadTicket();
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
                    ))),
          )
        ],
      ),
    );
  }

  Widget buildItem({BuildContext context, int index}) {
    print(dataTenant);
    final scaler = config.ScreenScale(context).scaler;
    final res = listTicketModel.result.data[index];
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
        // deleteChat(index);
        print("onDismissed");
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final bool res = await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: config.MyFont.title(
                      context: context,
                      text: "Informasi",
                      color: config.Colors.mainColors),
                  content: config.MyFont.title(
                      context: context,
                      text: "Anda yakin akan mengahpus pesan ini ?",
                      fontSize: 9),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child:
                            config.MyFont.title(context: context, text: "Batal")
                        // child:textQ(titleBtn1,12,Colors.black,FontWeight.bold),
                        ),
                    FlatButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await deleteChat(index);
                        },
                        child: config.MyFont.title(
                            context: context,
                            text: "Oke",
                            color: config.Colors.mainColors))
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
          Navigator.of(context)
              .pushNamed('/${StringConfig.roomChat}', arguments: res.toJson());
        },
        child: Container(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Hero(
                      tag: "chat${listTicketModel.result.data[index].id}",
                      child: WidgetHelper().baseImage(
                          dataTenant[StringConfig.logoTenant],
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
                          child: config.MyFont.title(
                              context: context, text: res.title, fontSize: 9),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: config.MyFont.subtitle(
                              context: context,
                              text:
                                  "${DateFormat.yMMMMEEEEd('id').format(res.createdAt)} ${DateFormat.Hms().format(res.createdAt)}",
                              color: Theme.of(context).textTheme.caption.color,
                              fontSize: 8),
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
