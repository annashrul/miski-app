import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/helper/skeleton_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';

class LoadingTenant extends StatefulWidget {
  @override
  _LoadingTenantState createState() => _LoadingTenantState();
}
class _LoadingTenantState extends State<LoadingTenant> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new StaggeredGridView.countBuilder(
      shrinkWrap: true,
      primary: false,
      crossAxisCount: 3,
      itemCount: 9,
      itemBuilder: (BuildContext context, int index) {
        return WidgetHelper().baseLoading(context,Container(
            padding: EdgeInsets.only(bottom:5.0),
            decoration: BoxDecoration(
              color:Colors.white,
              // color:Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              // border: Border.all(color: site?Colors.transparent:Colors.grey[200]),
            ),
            width: double.infinity,
            height: 100
        ));
      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 15.0,
    );
  }
}
class LoadingProductTenant extends StatefulWidget {
  final int tot;
  LoadingProductTenant({this.tot});
  @override
  _LoadingProductTenantState createState() => _LoadingProductTenantState();
}
class _LoadingProductTenantState extends State<LoadingProductTenant> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return StaggeredGridView.countBuilder(
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 4,
      itemCount: widget.tot,
      itemBuilder: (BuildContext context, int index) {
        return WidgetHelper().baseLoading(context, Container(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidgetHelper().shimmer(context: context,height: index%2==0?double.parse("${index+11}"):13,width:MediaQuery.of(context).size.width/1),
              SizedBox(height:scaler.getHeight(0.5)),
              WidgetHelper().shimmer(context: context,height: 1,width:MediaQuery.of(context).size.width/1),
              SizedBox(height:scaler.getHeight(0.5)),
              WidgetHelper().shimmer(context: context,height: 1,width:20),

            ],
          ),
        ));

      },
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
      mainAxisSpacing: 15.0,
      crossAxisSpacing: 15.0,
    );
  }
}
class LoadingReleatedProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return ListView.builder(
      padding: scaler.getPadding(0, 2),
      itemCount: 4,
      itemBuilder: (context, index) {
        return WidgetHelper().baseLoading(context, Container(
          margin: EdgeInsets.only(left:0, right: 20),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Container(
                child: WidgetHelper().shimmer(context:context,width: 24,height:20 ),
              ),
            ],
          ),
        ));
      },
      scrollDirection: Axis.horizontal,
    );
  }
}
// ignore: must_be_immutable
class LoadingCart extends StatelessWidget {
  int total;
  LoadingCart({this.total});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 15),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      primary: false,
      itemCount: total,
      separatorBuilder: (context, index) {
        return SizedBox(height: 15);
      },
      itemBuilder: (context, index) {
        return  WidgetHelper().baseLoading(context, Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              WidgetHelper().shimmer(context: context,width: 10,height: 5),
              SizedBox(width: 15),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          WidgetHelper().shimmer(context: context,width: 40),
                          SizedBox(height: 5.0),
                          WidgetHelper().shimmer(context: context,width: 30),
                          SizedBox(height: 5.0),
                          WidgetHelper().shimmer(context: context,width: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
      },
    );
  }
}
class LoadingHistory extends StatefulWidget {
  final int tot;
  LoadingHistory({this.tot});
  @override
  _LoadingHistoryState createState() => _LoadingHistoryState();
}
class _LoadingHistoryState extends State<LoadingHistory> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount:widget.tot,
      itemBuilder: (context,index){
        return WidgetHelper().baseLoading(context, Wrap(
          direction: Axis.horizontal,
          runSpacing: 10,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                WidgetHelper().shimmer(context: context, height:5, width:12),
                SizedBox(width: scaler.getWidth(1.5)),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                WidgetHelper().shimmer(context: context,width: scaler.getWidth(5)),
                                SizedBox(width: scaler.getHeight(0.5)),
                                Row(
                                  children: <Widget>[
                                    WidgetHelper().shimmer(context: context,width: scaler.getWidth(10)),
                                  ],
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            WidgetHelper().shimmer(context: context,width: scaler.getWidth(10)),
            WidgetHelper().shimmer(context: context,width: scaler.getWidth(20)),
            WidgetHelper().shimmer(context: context,width: scaler.getWidth(30)),

          ],
        ));
      },
      separatorBuilder: (context,index){
        return SizedBox(height: 10.0);
      },
    );
  }
}
// ignore: must_be_immutable
class LoadingTicket extends StatelessWidget {
  int total;
  LoadingTicket({this.total});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: false,
            child: ListView.separated(
              // padding: EdgeInsets.symmetric(vertical: 15),
              shrinkWrap: true,
              primary: false,
              itemCount: total,
              separatorBuilder: (context, index) {
                return SizedBox(height: 7);
              },
              itemBuilder: (context, index) {
                return Container(
                  // color: Theme.of(context).focusColor.withOpacity(0.15),
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical:0),
                  child:WidgetHelper().baseLoading(context, Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 60,height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color:Colors.grey,
                        ),
                      ),
                      SizedBox(width: 15),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width/4,height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                    color:Colors.grey,
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width/2,height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                color:Colors.grey[200],
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: MediaQuery.of(context).size.width/3,height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                                color:Colors.grey[200],
                              ),
                            ),

                          ],
                        ),
                      )
                    ],
                  )),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}

class LoadingRoomTicket extends StatelessWidget {
  final _myListKey = GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          flex: 3,
          child:LoadingTicket(total: 1),
        ),
        Expanded(
          flex: 16,
          child: AnimatedList(
            key: _myListKey,
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            initialItemCount: 100,
            itemBuilder: (context, index, Animation<double> animation) {
              return new SizeTransition(
                sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.decelerate),
                child: Align(
                  alignment: index%2==0?Alignment.centerRight:Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                        color: index%2==0?Theme.of(context).focusColor.withOpacity(0.2):Theme.of(context).accentColor.withOpacity(0.2),
                        borderRadius: index%2==0?BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)):BorderRadius.only(topRight: Radius.circular(15), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: SkeletonFrame(width: 100,height: 20),
                  ),
                ),
                // child:index%2==0 ? getSentMessageLayout(context) : getReceivedMessageLayout(context),
                // child: getReceivedMessageLayout(context),
              );
            },
          ),
        ),

      ],
    );
  }
}




