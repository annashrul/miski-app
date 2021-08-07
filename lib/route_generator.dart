import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/app_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/pages/component/auth/signin_component.dart';
import 'package:netindo_shop/pages/component/auth/signup_component.dart';
import 'package:netindo_shop/pages/component/brand/brand_component.dart';
import 'package:netindo_shop/pages/component/chat/room_chat_component.dart';
import 'package:netindo_shop/pages/component/checkout/checkout_component.dart';
import 'package:netindo_shop/pages/component/checkout/success_checkout_component.dart';
import 'package:netindo_shop/pages/component/history/history_order_component.dart';
import 'package:netindo_shop/pages/component/home/home_component.dart';
import 'package:netindo_shop/pages/component/main_component.dart';
import 'package:netindo_shop/pages/component/on_boarding_component.dart';
import 'package:netindo_shop/pages/component/splash_screen_component.dart';
import 'file:///E:/NETINDO/netindo_shop/lib/pages/widget/product/detail/detail_product_widget.dart';
import 'package:netindo_shop/pages/widget/product/cart/cart_widget.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreenComponent());
      case '/${StringConfig.onBoarding}':
        return MaterialPageRoute(builder: (_) => OnBoardingComponent());
      case '/${StringConfig.signUp}':
        return MaterialPageRoute(builder: (_) => SignUpComponent());
      case '/${StringConfig.signIn}':
        return MaterialPageRoute(builder: (_) => SignInComponent());
      case '/${StringConfig.main}':
        return MaterialPageRoute(builder: (_) => MainComponent(currentTab: args));
      case '/${StringConfig.home}':
        return MaterialPageRoute(builder: (_) => HomeComponent());
      case '/${StringConfig.detailProduct}':
        return MaterialPageRoute(builder: (_) => DetailProductWidget(data: args));
      case '/${StringConfig.cart}':
        return MaterialPageRoute(builder: (_) => CartWidget());
      case '/${StringConfig.checkout}':
        return MaterialPageRoute(builder: (_) => CheckoutComponent());
      case '/${StringConfig.successCheckout}':
        return MaterialPageRoute(builder: (_) => SuccessCheckoutComponent(data: args));
      case '/${StringConfig.roomChat}':
        return MaterialPageRoute(builder: (_) => RoomChatComponent(data: args));
      case '/${StringConfig.historyOrder}':
        return MaterialPageRoute(builder: (_) => HistoryOrderComponent(currentTab: args));
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
