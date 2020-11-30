import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';

class RefreshWidget extends StatefulWidget {
  Widget widget;
  Function() callback;
  RefreshWidget({this.widget,this.callback});
  @override
  _RefreshWidgetState createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();
  Future<void> handleRefresh()async {
    final Completer<void> completer = Completer<void>();
    await Future.delayed(Duration(seconds: 1));
    completer.complete();
    return completer.future.then<void>((_) {
      widget.callback();
    });
  }
  bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSite();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
      child: widget.widget,
      backgroundColor:site?Colors.white:SiteConfig().mainColor,
      color: site?SiteConfig().darkMode:Colors.white,
      key: _refreshIndicatorKey,
      onRefresh:handleRefresh,
      showChildOpacityTransition: false,
    );
  }
}
