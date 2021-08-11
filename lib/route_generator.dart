import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/address/address_component.dart';
import 'package:netindo_shop/pages/component/auth/signin_component.dart';
import 'package:netindo_shop/pages/component/auth/signup_component.dart';
import 'package:netindo_shop/pages/component/brand/brand_component.dart';
import 'package:netindo_shop/pages/component/category/category_component.dart';
import 'package:netindo_shop/pages/component/chat/room_chat_component.dart';
import 'package:netindo_shop/pages/component/checkout/checkout_component.dart';
import 'package:netindo_shop/pages/component/checkout/success_checkout_component.dart';
import 'package:netindo_shop/pages/component/debug_pages.dart';
import 'package:netindo_shop/pages/component/history/detail_history_order_component.dart';
import 'package:netindo_shop/pages/component/history/history_order_component.dart';
import 'package:netindo_shop/pages/component/home/home_component.dart';
import 'package:netindo_shop/pages/component/main_component.dart';
import 'package:netindo_shop/pages/component/on_boarding_component.dart';
import 'package:netindo_shop/pages/component/splash_screen_component.dart';
import 'package:netindo_shop/pages/component/tenant/tenant_component.dart';
import 'package:netindo_shop/pages/widget/product/by_brand/product_by_brand.dart';
import 'package:netindo_shop/pages/widget/product/by_category/product_by_category_widget.dart';
import 'file:///E:/NETINDO/netindo_shop/lib/pages/widget/product/detail/detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/cart/cart_widget.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    print(args);
    switch (settings.name) {
      case '/':
        return CupertinoPageRoute(builder: (_) => SplashScreenComponent());
      case '/${StringConfig.onBoarding}':
        return CupertinoPageRoute(builder: (_) => OnBoardingComponent());
      case '/${StringConfig.signUp}':
        return CupertinoPageRoute(builder: (_) => SignUpComponent());
      case '/${StringConfig.signIn}':
        return CupertinoPageRoute(builder: (_) => SignInComponent());
      case '/${StringConfig.main}':
        return CupertinoPageRoute(builder: (_) => MainComponent(currentTab: args));
      case '/${StringConfig.tenantPage}':
        return CupertinoPageRoute(builder: (_) => TenantComponent());
      case '/${StringConfig.home}':
        return CupertinoPageRoute(builder: (_) => HomeComponent());
      case '/${StringConfig.detailProduct}':
        return CupertinoPageRoute(builder: (_) => DetailProductWidget(data: args));
        // return CupertinoPageRoute(builder: (_) => DebugPages(data: args));
      case '/${StringConfig.cart}':
        return CupertinoPageRoute(builder: (_) => CartWidget());
      case '/${StringConfig.checkout}':
        return CupertinoPageRoute(builder: (_) => CheckoutComponent());
      case '/${StringConfig.successCheckout}':
        return CupertinoPageRoute(builder: (_) => SuccessCheckoutComponent(data: args));
      case '/${StringConfig.roomChat}':
        return CupertinoPageRoute(builder: (_) => RoomChatComponent(data: args));
      case '/${StringConfig.historyOrder}':
        return CupertinoPageRoute(builder: (_) => HistoryOrderComponent(currentTab: args));
      case '/${StringConfig.detailHistoryOrder}':
        return CupertinoPageRoute(builder: (_) => DetailHistoryOrderComponent(data: args));
      case '/${StringConfig.category}':
        return CupertinoPageRoute(builder: (_) => CategoryComponent());
      case '/${StringConfig.brand}':
        return CupertinoPageRoute(builder: (_) => BrandComponent());
      case '/${StringConfig.productByCategory}':
        return CupertinoPageRoute(builder: (_) => ProductByCategory(data: args));
      case '/${StringConfig.productByBrand}':
        return CupertinoPageRoute(builder: (_) => ProductByBrand(data: args));
      case '/${StringConfig.address}':
        return CupertinoPageRoute(builder: (_) => AddressComponent(callback:args,indexArr: 0,));
      // case '/Categories':
      //   return MaterialPageRoute(builder: (_) => CategoriesWidget());
      // case '/Orders':
      //   return MaterialPageRoute(builder: (_) => OrdersWidget());
      // case '/Brands':
      //   return MaterialPageRoute(builder: (_) => BrandsWidget());
      // case '/Tabs':
      //   return MaterialPageRoute(builder: (_) => TabsWidget(currentTab: args));
      // case '/Category':
      //   return MaterialPageRoute(builder: (_) => CategoryWidget(routeArgument: args as RouteArgument));
      // case '/Brand':
      //   return MaterialPageRoute(builder: (_) => BrandWidget(routeArgument: args as RouteArgument));
      // case '/Product':
      //   return MaterialPageRoute(builder: (_) => ProductWidget(routeArgument: args as RouteArgument));
      // case '/Cart':
      //   return MaterialPageRoute(builder: (_) => CartWidget());
      // case '/Checkout':
      //   return MaterialPageRoute(builder: (_) => CheckoutWidget());
      // case '/CheckoutDone':
      //   return MaterialPageRoute(builder: (_) => CheckoutDoneWidget());
      // case '/Help':
      //   return MaterialPageRoute(builder: (_) => HelpWidget());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyFont.title(context:context,text: "Oooopppsss terjadi kesalahan",fontSize: 12,textAlign: TextAlign.center),
              MyFont.title(context:context,text: "harap periksa koneksi internet anda",fontSize: 12,textAlign: TextAlign.center),
              SizedBox(height:ScreenScale(context).scaler.getHeight(2)),
              WidgetHelper().myRipple(
                callback: (){
                  Navigator.pop(context);
                },
                child: Container(
                  padding: ScreenScale(context).scaler.getPadding(1,3),
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(6)
                  ),
                  child: MyFont.title(context:context,text: "Coba lagi",fontSize: 12,textAlign: TextAlign.center),
                )
              )
            ],
          ),
        ),
      );
    });
  }
}
