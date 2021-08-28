import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/widget/promo/detail_promo_widget.dart';
import 'package:miski_shop/provider/promo_provider.dart';
import 'package:provider/provider.dart';

class PromoHomeWidget extends StatefulWidget {
  @override
  _PromoHomeWidgetState createState() => _PromoHomeWidgetState();
}

class _PromoHomeWidgetState extends State<PromoHomeWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final promo = Provider.of<PromoProvider>(context, listen: false);
    promo.read(context);
  }
  @override
  Widget build(BuildContext context) {
    final scaler =config.ScreenScale(context).scaler;
    final promo = Provider.of<PromoProvider>(context);
    return promo.isLoading?WidgetHelper().baseLoading(context,Padding(
      padding: scaler.getPadding(1, 2),
      child:  WidgetHelper().shimmer(context: context,height: 10,width: 30),
    )):promo.globalPromoModel.result.data.length<1?SizedBox():Container(
      padding: scaler.getPaddingLTRB(2,0,0,1.5),
      height: scaler.getHeight(15),
      child: Column(
        children: <Widget>[
          WidgetHelper().titleQ(context,"Promo spesial untuk kamu",icon: UiIcons.gift,padding: scaler.getPaddingLTRB(0,0,0,1),),
          Flexible(
            child: ListView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: promo.globalPromoModel.result.data.length ,
                itemBuilder: (context, index){
                  return Container(
                    margin: scaler.getMarginLTRB(index==0?0:2, 0,index+1==promo.globalPromoModel.result.data.length?2:0, 0),
                    child: WidgetHelper().myRipple(
                        callback: (){
                          WidgetHelper().myPush(
                            context,
                            DetailPromoWidget(
                              data: {
                                "id":promo.globalPromoModel.result.data[index].id,
                                "image":promo.globalPromoModel.result.data[index].gambar,
                                "hero":"promo_image_${promo.globalPromoModel.result.data[index].id}",
                              }
                            )
                          );
                        },
                        child: Container(
                          padding: scaler.getPadding(0, 0),
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Hero(
                            tag:"promo_image_${promo.globalPromoModel.result.data[index].id}"+promo.globalPromoModel.result.data[index].id,
                            child: WidgetHelper().baseImage(
                              promo.globalPromoModel.result.data[index].gambar,
                              width: MediaQuery.of(context).size.width / 1.2,
                              fit: BoxFit.cover
                            ),
                          ),
                        )
                    ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}
