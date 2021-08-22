
import 'package:flutter/cupertino.dart';
import 'package:miski_shop/model/checkout/channel_model.dart';
import 'package:miski_shop/provider/handle_http.dart';

class ChannelPaymentProvider with ChangeNotifier{
  List resChannel=[];
  bool isLoading=true;

  Future read(BuildContext context)async{
    print(resChannel);
    if(resChannel==null)isLoading=true;
    final res = await HandleHttp().getProvider("transaction/payment/channel", channelModelFromJson,context: context);
    ChannelModel channelModel = ChannelModel.fromJson(res.toJson());
    resChannel = channelModel.result.data.where((element) => element.active).toList();
    isLoading=false;
    notifyListeners();
  }
}