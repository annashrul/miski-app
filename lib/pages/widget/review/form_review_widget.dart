import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/provider/handle_http.dart';


// ignore: must_be_immutable
class FormReviewWidget extends StatefulWidget {
  dynamic data;
  FormReviewWidget({this.data});
  @override
  _FormReviewWidgetState createState() => _FormReviewWidgetState();
}

class _FormReviewWidgetState extends State<FormReviewWidget> {
  String titleRating="";
  String captionRating="";
  double rate=0.0;
  final userRepository = UserHelper();
  var captionController = TextEditingController();
  final FocusNode captionFocus = FocusNode();
  Color color;
  void rateWithCaption(rating)async{
    final nama=await userRepository.getDataUser("nama");
    setState(() {rate=rating;});
    if(rating<=1.0){
      setState(() {
        color = Colors.red;
        titleRating = "Kecewa";
        captionRating = "Hi $nama, tolong bantu kami untuk mengerti masalah dengan pembelianmu.";
      });
    }
    if(rating>1.0&&rating<=2.0){
      setState(() {
        color = Colors.redAccent;
        titleRating = "Kurang";
        captionRating = "Hi $nama, tolong bantu kami untuk mengerti masalah dengan pembelianmu.";
      });
    }
    if(rating>2.0&&rating<=3.0){
      setState(() {
        color = Colors.amber;
        titleRating = "Lumayan";
        captionRating = "Hi $nama, sepertinya kamu nggak suka dengan pembelian ini. Boleh tahu kenapa ?";
      });
    }
    if(rating>3.0&&rating<=4.0){
      setState(() {
        color = Colors.lightGreen;
        titleRating = "Suka";
        captionRating = "Hi $nama, yuk bantu calon pembeli lain dengan membagikan pemgalamanmu !";
      });
    }
    if(rating>4.0&&rating<=5.0){
      setState(() {
        color = Colors.green;
        titleRating = "Puas Banget";
        captionRating = "Hi $nama, yuk bantu calon pembeli lain dengan membagikan pemgalamanmu !";
      });
    }
  }


  Future store()async{
    if(captionController.text==""){
      captionFocus.requestFocus();
      return;
    }
    WidgetHelper().loadingDialog(context);
    final idMember=await userRepository.getDataUser(StringConfig.id_user);
    final data={
      "id_member":"$idMember",
      "kd_brg":widget.data["kode_barang"],
      "caption":captionController.text,
      "rate":"$rate".toString()
    };
    var res = await HandleHttp().postProvider("review",data,context: context);
    print(data);
    if(res!=null){
      Navigator.of(context).pop();
      WidgetHelper().notifOneBtnDialog(context, "Berhasil", "Ulasan kamu berhasil dikirim",(){
        Navigator.of(context).pushNamedAndRemoveUntil("/${StringConfig.main}", (route) => false,arguments: StringConfig.defaultTab);
      });

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rateWithCaption(widget.data["rating"]);

  }

  @override
  Widget build(BuildContext context) {
    print(widget.data);
    final scaler=config.ScreenScale(context).scaler;
    return Padding(
      padding: scaler.getPadding(1, 2 ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidgetHelper().titleQ(context, "Beri ulasan",icon: UiIcons.information),
              WidgetHelper().myRipple(
                callback: (){
                  store();
                },
                  child: config.MyFont.title(context: context,text:"Simpan",fontSize: 9,color: config.Colors.mainColors)
              )
            ],
          ),
          SizedBox(height: scaler.getHeight(1)),
          WidgetHelper().titleQ(context, widget.data["barang"],image: widget.data["gambar"],param: ""),
          ListView(
            addRepaintBoundaries: true,
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            children: [
              SizedBox(height:10.0),
              Container(
                child: Column(
                  children: [
                    RatingBar.builder(
                      unratedColor:Colors.black,
                      glowColor: Colors.white,
                      itemSize: 40.0,
                      initialRating: rate,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemPadding: EdgeInsets.only(right: 4.0),
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.star,
                              color: Colors.yellowAccent,
                            );
                          case 1:
                            return Icon(
                              Icons.star,color: Colors.yellowAccent,
                            );
                          case 2:
                            return Icon(
                              Icons.star,color: Colors.yellowAccent,
                            );
                          case 3:
                            return Icon(
                              Icons.star,color: Colors.yellowAccent,
                            );
                          case 4:
                            return Icon(
                              Icons.star,color: Colors.yellowAccent,
                            );
                          default:
                            return Container();
                        }
                      },
                      onRatingUpdate: (rate) {
                        rateWithCaption(rate);
                      },
                    ),
                    SizedBox(height:10.0),
                    config.MyFont.subtitle(context: context,text:titleRating.toUpperCase(),textAlign: TextAlign.center,color: color),

                    SizedBox(height:10.0),
                    config.MyFont.subtitle(context: context,text:captionRating,textAlign: TextAlign.center)
                  ],
                ),
              ),
              SizedBox(height:10.0),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      maxLines: 10,
                      style:config.MyFont.style(context: context,style: Theme.of(context).textTheme.bodyText2,fontWeight: FontWeight.normal),
                      focusNode: captionFocus,
                      controller: captionController,
                      decoration: InputDecoration(
                        hintText: "Ceritakan pengalamanmu terkait barang ini ... ",
                        hintStyle: config.MyFont.style(context: context,style: Theme.of(context).textTheme.bodyText2,fontWeight: FontWeight.normal,color: Theme.of(context).textTheme.headline1.color.withOpacity(0.5)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color.withOpacity(0.2))),
                        focusedBorder:UnderlineInputBorder(borderSide: BorderSide(color:Theme.of(context).textTheme.headline1.color)),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (e){

                      },

                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
