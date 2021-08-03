import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/helper/widget_helper.dart';

class CartWidget extends StatefulWidget {
  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Shopping Cart",(){}, <Widget>[],param: "default"),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 150),
            padding:scaler.getPadding(1,2),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: Container(
                      child: Icon(
                        FlutterIcons.cart_outline_mco,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    title: config.MyFont.title(context: context,text:'Verify your quantity and click checkout',fontWeight: FontWeight.normal,fontSize: 9),
                  )
                  // ListView.separated(
                  //   padding: EdgeInsets.symmetric(vertical: 15),
                  //   scrollDirection: Axis.vertical,
                  //   shrinkWrap: true,
                  //   primary: false,
                  //   itemCount: _productsList.cartList.length,
                  //   separatorBuilder: (context, index) {
                  //     return SizedBox(height: 15);
                  //   },
                  //   itemBuilder: (context, index) {
                  //     return CartItemWidget(product: _productsList.cartList.elementAt(index), heroTag: 'cart');
                  //   },
                  // ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 170,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(child:config.MyFont.title(context: context,text:'Subtotal',fontWeight: FontWeight.normal)),
                        config.MyFont.title(context: context,text:'\$50.23',fontWeight: FontWeight.normal,color: config.Colors.mainColors),
                        // Text('\$50.23', style: Theme.of(context).textTheme.subhead),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(child:config.MyFont.title(context: context,text:'Tax (20%)',fontWeight: FontWeight.normal)),
                        config.MyFont.title(context: context,text:'\$13.23',fontWeight: FontWeight.normal,color: config.Colors.mainColors),
                      ],
                    ),
                    SizedBox(height: 10),
                    Stack(
                      fit: StackFit.loose,
                      alignment: AlignmentDirectional.centerEnd,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/Checkout');
                            },
                            padding: EdgeInsets.symmetric(vertical: 14),
                            color: Theme.of(context).accentColor,
                            shape: StadiumBorder(),
                            child:config.MyFont.title(context: context,text:'Checkout',fontWeight: FontWeight.bold,color:  Theme.of(context).primaryColor)
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:config.MyFont.title(context: context,text:'\$55.36',fontWeight: FontWeight.bold,color:  Theme.of(context).primaryColor)

                        )
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
