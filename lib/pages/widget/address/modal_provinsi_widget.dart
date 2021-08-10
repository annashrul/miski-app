import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/light_color.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/provinsi_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// ignore: must_be_immutable
class ModalProvinsiWidget extends StatefulWidget {
  ModalProvinsiWidget({
    Key key,
    @required this.callback,
    @required this.id,
    @required this.idx,
  }) : super(key: key);
  Function(String id,String name,int idx) callback;
  final String id;
  int idx;
  @override
  _ModalProvinsiWidgetState createState() => _ModalProvinsiWidgetState();
}

class _ModalProvinsiWidgetState extends State<ModalProvinsiWidget> {
  ProvinsiModel provinsiModel;
  bool isLoadingProv=false;
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  int idx=0;
  String id='';
  Future getProv()async{
    var data = await HandleHttp().getProvider("kurir/provinsi",provinsiModelFromJson,context:context,callback: (){
      print("callback");
    });
    if(data is ProvinsiModel){
      ProvinsiModel resullt = data;
      setState(() {
        provinsiModel = ProvinsiModel.fromJson(resullt.toJson());
        isLoadingProv=false;
        id = widget.id==""?resullt.result[0].id:widget.id;
        idx = widget.idx;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("ID PROVINSI ${widget.id}");
    isLoadingProv=true;
    getProv();
  }
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      padding: scaler.getPadding(1,2),
      height: MediaQuery.of(context).size.height/1.1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          WidgetHelper().titleQ(context, "Provinsi",icon: UiIcons.information),
          Expanded(
            child: Scrollbar(
                child: isLoadingProv?WidgetHelper().loadingWidget(context):ScrollablePositionedList.separated(
                  padding: scaler.getPadding(0.5,0),
                  itemScrollController: _scrollController,
                  itemCount: provinsiModel.result.length,
                  initialScrollIndex: idx,
                  itemBuilder: (context,index){
                    return WidgetHelper().titleQ(
                      context,
                      provinsiModel.result[index].name,
                      iconAct: UiIcons.checked,
                      param:widget.id==provinsiModel.result[index].id?"-":"",
                      fontWeight: FontWeight.normal,
                      fontSize: 9,
                      padding: scaler.getPadding(0.5,0),
                      radius: 0,
                      callback: (){
                        setState(() {
                          idx = index;
                          id = provinsiModel.result[index].id;
                        });
                        widget.callback(provinsiModel.result[index].id,provinsiModel.result[index].name,index);
                      }
                    );

                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                )
            ),
          ),

        ],
      ),
    );
  }
}
