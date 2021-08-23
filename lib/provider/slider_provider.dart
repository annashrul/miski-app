
import 'package:flutter/cupertino.dart';
import 'package:miski_shop/model/promo/global_promo_model.dart';
import 'package:miski_shop/model/slider/ListSliderModel.dart';
import 'package:miski_shop/provider/handle_http.dart';

class SliderProvider with ChangeNotifier{
  ListSliderModel listSliderModel;
  bool isLoading=true;
  reload(BuildContext context){
    isLoading=true;
    notifyListeners();
    read(context);
  }
  Future read(BuildContext context)async{
    if(listSliderModel==null) isLoading=true;
    final res = await HandleHttp().getProvider("slider?page=1",listSliderModelFromJson,context: context);
    listSliderModel = ListSliderModel.fromJson(res.toJson());
    isLoading=false;
    notifyListeners();
  }
}