import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';

class DetailPromoScreen extends StatefulWidget {
  final String id;
  DetailPromoScreen({this.id});
  @override
  _DetailPromoScreenState createState() => _DetailPromoScreenState();
}

class _DetailPromoScreenState extends State<DetailPromoScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WidgetHelper().appBarWithButton(context,"Detail Promo",(){Navigator.pop(context);},<Widget>[],brightness: Brightness.light),
      body: ListView(
        padding: EdgeInsets.all(0.0),
        children: [
          Container(
            height:  MediaQuery.of(context).size.height/5,
            width: double.infinity,
            child: Image.network(
              "https://appboy-images.com/appboy/communication/assets/image_assets/images/5fc5e3d045732b6af558241c/original.jpg?1606804432",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(20.0),topLeft: Radius.circular(20.0)),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: WidgetHelper().textQ("Pasti Jago dan Berpengalaman",14,Colors.grey,FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child:WidgetHelper().textQ("Where does it come from?Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.",12,Colors.grey,FontWeight.normal,maxLines: 1000,textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child:Divider(height: 1.0,color: Colors.grey),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: WidgetHelper().textQ("Untuk mendapatkan potongan harga, gunakan kode dibawah saat melakukan checkout",10,Colors.grey,FontWeight.bold,textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child:  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: WidgetHelper().textQ("0989809",14,Colors.white,FontWeight.bold),
                        decoration: BoxDecoration(
                            color:Colors.grey,
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        padding: EdgeInsets.all(10.0),
                      ),
                      SizedBox(width: 10.0),
                      InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: (){
                          Clipboard.setData(new ClipboardData(text: "0000"));
                          WidgetHelper().showFloatingFlushbar(context,"success","Kode promo berhasil disalin");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:SiteConfig().secondColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.all(10.0),
                          child: WidgetHelper().textQ("COPY",14,Colors.white,FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: (){
                      WidgetHelper().myPush(context,WrapperScreen(currentTab: StringConfig.defaultTab));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:SiteConfig().mainColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: WidgetHelper().textQ("Belanja Sekarang",14,Colors.white,FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height:10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width/4,
                      height: 1.0,
                      color:Colors.grey,
                    ),
                    WidgetHelper().textQ("TERM & CONDITION",14,Colors.grey,FontWeight.bold),
                    Container(
                      width: MediaQuery.of(context).size.width/4,
                      height: 1.0,
                      color:Colors.grey,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child:WidgetHelper().textQ("Where does it come from?Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.",12,Colors.grey,FontWeight.normal,maxLines: 1000,textAlign: TextAlign.left),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget horizontalLine() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    child: Container(
      width: 90,
      height: 1.0,
      color:Colors.grey,
    ),
  );

}
