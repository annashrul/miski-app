import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/kota_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ModalKotaWIdget extends StatefulWidget {
  ModalKotaWIdget({
    Key key,
    @required this.callback,
    @required this.id,
    @required this.idProv,
    @required this.idx,
  }) : super(key: key);
  Function(String id,String name,int idx) callback;
  final String id;
  final String idProv;
  int idx;
  @override
  _ModalKotaWIdgetState createState() => _ModalKotaWIdgetState();
}

class _ModalKotaWIdgetState extends State<ModalKotaWIdget> {
  KotaModel kotaModel;
  bool isLoading=false;
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  int idx=0;
  String id='';
  int no=0;
  Widget child;
  Future getData()async{
    var data = await HandleHttp().getProvider("kurir/kota?id=${widget.idProv}",kotaModelFromJson,context:context,callback: (){
      print("callback");
    });
    if(data is KotaModel){
      KotaModel resullt = data;
      setState(() {
        kotaModel = KotaModel.fromJson(resullt.toJson());
        isLoading=false;
        id = widget.id==""?resullt.result[0].id:widget.id;
        idx = widget.idx;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading=true;
    getData();
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
          WidgetHelper().titleQ(context, "Kota",icon: UiIcons.information),


          Expanded(
            child: Scrollbar(
                child: isLoading?WidgetHelper().loadingWidget(context):ScrollablePositionedList.separated(
                  padding: scaler.getPadding(0.5,0),
                  itemScrollController: _scrollController,
                  itemCount: kotaModel.result.length,
                  initialScrollIndex: idx,
                  itemBuilder: (context,index){
                    return WidgetHelper().titleQ(
                        context,
                        kotaModel.result[index].name,
                        iconAct: UiIcons.checked,
                        param:widget.id==kotaModel.result[index].id?"-":"",
                        fontWeight: FontWeight.normal,
                        fontSize: 9,
                        padding: scaler.getPadding(0.5,0),
                        radius: 0,
                        callback: (){
                          setState(() {
                            idx = index;
                            id = kotaModel.result[index].id;
                          });
                          widget.callback(kotaModel.result[index].id,kotaModel.result[index].name,index);
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
