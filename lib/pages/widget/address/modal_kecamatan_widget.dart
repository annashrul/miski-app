import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/address/kecamatan_model.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// ignore: must_be_immutable
class ModalKecamatanWidget extends StatefulWidget {
  ModalKecamatanWidget({
    Key key,
    @required this.callback,
    @required this.id,
    @required this.idCity,
    @required this.idx,
  }) : super(key: key);
  Function(String id,String name,int idx) callback;
  final String id;
  final String idCity;
  int idx;
  @override
  _ModalKecamatanWidgetState createState() => _ModalKecamatanWidgetState();
}

class _ModalKecamatanWidgetState extends State<ModalKecamatanWidget> {
  KecamatanModel kecamatanModel;
  bool isLoading=false;
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  int idx=0;
  String id='';
  int no=0;
  Widget child;
  Future getData()async{
    var data = await HandleHttp().getProvider("kurir/kecamatan?id=${widget.idCity}",kecamatanModelFromJson,context:context,callback: (){
      print("callback");
    });
    if(data is KecamatanModel){
      KecamatanModel resullt = data;
      setState(() {
        kecamatanModel = KecamatanModel.fromJson(resullt.toJson());
        isLoading=false;
        id = widget.id==""?resullt.result[0].id:widget.id;
        idx = widget.idx;
      });
    }

  }

  @override
  void initState() {
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
          WidgetHelper().titleQ(context, "Kecamatan",icon: UiIcons.information),
          Expanded(
            child: Scrollbar(
                child: isLoading?WidgetHelper().loadingWidget(context):ScrollablePositionedList.separated(
                  padding: scaler.getPadding(0.5,0),
                  itemScrollController: _scrollController,
                  itemCount: kecamatanModel.result.length,
                  initialScrollIndex: idx,
                  itemBuilder: (context,index){
                    return WidgetHelper().titleQ(
                        context,
                        kecamatanModel.result[index].kecamatan,
                        iconAct: UiIcons.checked,
                        param:widget.id==kecamatanModel.result[index].id?"-":"",
                        fontWeight: FontWeight.normal,
                        fontSize: 9,
                        padding: scaler.getPadding(0.5,0),
                        radius: 0,
                        callback: (){
                          setState(() {
                            idx = index;
                            id = kecamatanModel.result[index].id;
                          });
                          widget.callback(kecamatanModel.result[index].id,kecamatanModel.result[index].kecamatan,index);
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
