import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/pages/widget/slider_widget.dart';
import 'package:miski_shop/provider/slider_provider.dart';
import 'package:provider/provider.dart';

class SliderHomeWidget extends StatefulWidget {
  @override
  _SliderHomeWidgetState createState() => _SliderHomeWidgetState();
}

class _SliderHomeWidgetState extends State<SliderHomeWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final slider = Provider.of<SliderProvider>(context, listen: false);
    slider.read(context);
  }

  @override
  Widget build(BuildContext context) {
    final scaler =config.ScreenScale(context).scaler;
    final slider = Provider.of<SliderProvider>(context);
    return  slider.isLoading?WidgetHelper().baseLoading(context,Container(
      padding: scaler.getPadding(1,2),
      child: WidgetHelper().shimmer(context: context,height: 20,width: MediaQuery.of(context).size.width/1),
    )):Container(
      padding: scaler.getPaddingLTRB(0,0,0,1),
      child: SliderWidget(data:slider.listSliderModel.result.data),
    );
  }
}

