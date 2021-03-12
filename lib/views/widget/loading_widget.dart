import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/skeleton_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class LoadingTenant extends StatefulWidget {
  @override
  _LoadingTenantState createState() => _LoadingTenantState();
}

class _LoadingTenantState extends State<LoadingTenant> {
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    setState(() {
      site = res;
    });
  }

  @override
  void initState() {
    super.initState();
    getSite();
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
              color:site?Theme.of(context).focusColor.withOpacity(0.1):Colors.white,
              // color:Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              // border: Border.all(color: site?Colors.transparent:Colors.grey[200]),
            ),
            width: double.infinity,
            height: 100
        ));
        return Container(
          padding: EdgeInsets.only(bottom:5.0),
          decoration: BoxDecoration(
            // color: Theme.of(context).focusColor.withOpacity(0.1),
            // borderRadius: BorderRadius.only(topRight:Radius.circular(10.0),topLeft: Radius.circular(10.0)),
            // border: Border.all(color: site?Colors.transparent:Colors.grey[200]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(topRight:Radius.circular(10.0),topLeft: Radius.circular(10.0)),
                child: SkeletonFrame(width: double.infinity,height: 100),
              ),

            ],
          ),
        );
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
  static bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    if(this.mounted){
      setState(() {
        site = res;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSite();
  }
  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 4,
      itemCount: widget.tot,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              WidgetHelper().baseLoading(context,Container(width: double.infinity,height: 130.0,color: site?Theme.of(context).focusColor.withOpacity(0.1):Colors.white)),
              SizedBox(height: 12),
              WidgetHelper().baseLoading(context,Container(width: MediaQuery.of(context).size.width/2,height: 5.0,color: site?Theme.of(context).focusColor.withOpacity(0.1):Colors.white)),
              SizedBox(height:5),
              WidgetHelper().baseLoading(context,Container(width: MediaQuery.of(context).size.width/2,height: 5.0,color: site?Theme.of(context).focusColor.withOpacity(0.1):Colors.white)),
            ],
          ),
        );
        return Container(
          decoration: BoxDecoration(
            // color: site?Colors.transparent:Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(6),
            // boxShadow: [
            //   BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, 4), blurRadius: 10)
            // ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: 'LOADING HERO PRODUCT $index',
                child:SkeletonFrame(width: double.infinity,height:130.0 ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonFrame(width: MediaQuery.of(context).size.width/2,height: 5.0),
                    SizedBox(height:5),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 5.0),
                    SizedBox(height:5),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/6,height: 5.0),
                    SizedBox(height:5),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 5.0),
                    SizedBox(height:5),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/5,height: 5.0),
                    SizedBox(height:5),
                    SkeletonFrame(width: MediaQuery.of(context).size.width/3,height: 5.0),
                  ],
                ),
              ),
            ],
          ),
        );
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
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        double _marginLeft = 0;
        (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
        return InkWell(
          onTap: () {

          },
          child: Container(
            margin: EdgeInsets.only(left:7, right: 20),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Hero(
                    tag: 'LOADING RELEATED PRODUCT $index',
                    child:SkeletonFrame(width: 160, height: 200)

                ),

                Container(
                  margin: EdgeInsets.only(top: 170),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  width: 140,
                  height: 113,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SkeletonFrame(width: double.infinity, height: 15),
                      SizedBox(height: 10),
                      SkeletonFrame(width: double.infinity, height: 15),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
      scrollDirection: Axis.horizontal,
    );
  }
}


class LoadingDetailProduct extends StatelessWidget {
  bool site;
  LoadingDetailProduct({this.site});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          decoration: BoxDecoration(
            // color: site?Colors.black87:Colors.white,
            // boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 5, offset: Offset(0, -2)),],
          ),
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonFrame(width:double.infinity,height:MediaQuery.of(context).size.height/3),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/1,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/2,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/3,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/1,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/2,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/3,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/1,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/2,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/3,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/1,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/2,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/3,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/1,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/2,height: 10.0),
              SizedBox(height: 10.0),
              SkeletonFrame(width:MediaQuery.of(context).size.width/3,height: 10.0),

            ],
          ),
        )
      ],
    );
  }
}

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
        return  Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.0)

          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: index,
                child: Container(
                  height: 90,
                  width: 90,
                  child: SkeletonFrame(width: 90,height: 90,),
                ),
              ),
              SizedBox(width: 15),
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SkeletonFrame(width: MediaQuery.of(context).size.width/2,height: 5),
                          SizedBox(height: 5.0),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/3,height: 5),
                          SizedBox(height: 5.0),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 5),
                          SizedBox(height: 5.0),
                          SkeletonFrame(width: double.infinity,height: 5),
                          SizedBox(height: 5.0),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/2,height: 5),
                          SizedBox(height: 5.0),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/3,height: 5),
                          SizedBox(height: 5.0),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
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
  static bool site=false;
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
    return ListView.separated(
      primary: false,
      physics: ScrollPhysics(),
      itemCount:widget.tot,
      itemBuilder: (context,index){
        return WidgetHelper().myPress(
                (){
            },
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0),
                // boxShadow: [
                //   BoxShadow(color: site?Colors.transparent:Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)
                // ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left:10,right:10,top:10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonFrame(width: MediaQuery.of(context).size.width/2,height: 5.0),
                                  SizedBox(height: 5.0),
                                  SkeletonFrame(width: MediaQuery.of(context).size.width/1.5,height: 5.0)
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10,right:10,top:5,bottom:5),
                    child: Container(
                      color: site?Colors.white10:Colors.grey[200],
                      height: 1.0,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:10,right:10,top:0),
                    child: Row(
                      children: [
                        SkeletonFrame(width:50,height: 50.0),
                        SizedBox(width: 10.0),
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: SkeletonFrame(width:MediaQuery.of(context).size.width/1.5,height:5.0),
                            ),
                            SizedBox(height: 5.0),
                            SkeletonFrame(width:MediaQuery.of(context).size.width/3,height:5.0),
                            SizedBox(height: 5.0),

                            SkeletonFrame(width:MediaQuery.of(context).size.width/3.5,height:5.0),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left:10,right:10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonFrame(width:MediaQuery.of(context).size.width/3,height:5.0),
                                  SizedBox(height: 5.0),

                                  SkeletonFrame(width:MediaQuery.of(context).size.width/3.5,height:5.0),
                                ],
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
        );
      },
      separatorBuilder: (context,index){
        return SizedBox(height: 10.0);
      },
    );
  }
}


class LoadingFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SkeletonFrame(width: double.infinity,height: 15),
    );
  }
}

class LoadingSecondProduct extends StatefulWidget {
  @override
  _LoadingSecondProductState createState() => _LoadingSecondProductState();
}

class _LoadingSecondProductState extends State<LoadingSecondProduct> {


  @override
  void initState() {
    super.initState();
  }

  double width;
  double height;
  @override
  Widget build(BuildContext context) {
    double widthSize = MediaQuery.of(context).size.width;
    width=120;
    height=double.infinity;
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context,index){
          return Padding(
            padding: EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 15,
              right: 0,
            ),
            child: Container(
              width: 120,
              height: height,
              decoration: BoxDecoration(
                  color: Colors.transparent
              ),
              child: Column(
                children: [
                  Container(
                    height:  MediaQuery.of(context).size.height/6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),

                    ),
                    child: SkeletonFrame(width:double.infinity,height:MediaQuery.of(context).size.height/6 ,),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left:0,right:0,top:10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonFrame(width: MediaQuery.of(context).size.width/2,height:5),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/4,height:5),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/6,height:5),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/4,height:5),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/2,height:5),
                          SkeletonFrame(width: MediaQuery.of(context).size.width/6,height:5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}


class LoadingTicket extends StatelessWidget {
  int total;
  LoadingTicket({this.total});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: false,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 15),
              shrinkWrap: true,
              primary: false,
              itemCount: total,
              separatorBuilder: (context, index) {
                return SizedBox(height: 7);
              },
              itemBuilder: (context, index) {
                return Container(
                  color: Theme.of(context).focusColor.withOpacity(0.15),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color:Colors.transparent,
                          // border: Border.all(color:SiteConfig().accentDarkColor)
                        ),
                        child:SkeletonFrame(width: 60,height: 60),
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
                                  padding: EdgeInsets.only(right:10.0,bottom: 5.0),
                                  child: SkeletonFrame(width: MediaQuery.of(context).size.width/4,height: 10),
                                ),
                              ],
                            ),
                            SkeletonFrame(width: MediaQuery.of(context).size.width/2,height: 10),
                            SizedBox(height: 5.0),
                            SkeletonFrame(width: MediaQuery.of(context).size.width/3,height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
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



