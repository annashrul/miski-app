import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/user_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:netindo_shop/model/general_model.dart';
import 'package:netindo_shop/model/history/detail_history_transaction_model.dart';
import 'package:netindo_shop/provider/base_provider.dart';
import 'package:netindo_shop/views/screen/wrapper_screen.dart';

class FormReviewWidget extends StatefulWidget {
  DetailHistoryTransactionModel detailHistoryTransactionModel;
  FormReviewWidget({this.detailHistoryTransactionModel});
  @override
  _FormReviewWidgetState createState() => _FormReviewWidgetState();
}

class _FormReviewWidgetState extends State<FormReviewWidget> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  double rate=0.0;
  String caption="";
  int retry=0;
  Future sendReviewAgain(rate,txt,kdBrg)async{
    await sendReview(rate,txt,kdBrg);
    setState(() {
      retry+=1;
    });
  }
  Future sendReview(rate,txt,kdBrg)async{
    WidgetHelper().loadingDialog(context);
    var res = await BaseProvider().postProvider("review",{
      "id_member":widget.detailHistoryTransactionModel.result.idMember,
      "kd_brg":kdBrg,
      "caption":txt,
      "rate":"$rate"
    });
    if(res == '${SiteConfig().errTimeout}'|| res=='${SiteConfig().errSocket}'){
      Navigator.pop(context);
      WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Mohon maaf server kami sedang dalam masalah", (){},(){});
    }
    else{
      if(res is General){
        General result = res;
        Navigator.pop(context);
        if(retry>=3){
          WidgetHelper().notifDialog(context,"Terjadi Kesalahan Server","Silahkan lakukan pembuatan tiket komplain di halaman tiket", (){
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,));
          },(){
            WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,));
          },titleBtn1: "kembali",titleBtn2: "home");
        }
        else{
          WidgetHelper().notifDialog(context,"Terjadi Kesalahan","${result.msg}", (){
            Navigator.pop(context);
          },(){
            Navigator.pop(context);
            sendReviewAgain(rate,txt,kdBrg);
          },titleBtn1: "kembali",titleBtn2: "Coba lagi");
        }
      }
      else{
        Navigator.pop(context);
        Navigator.pop(context);
        WidgetHelper().notifDialog(context,"Ulasan Kamu Berhasil Dikirim","Terimakasih telah memberi ulasan", (){
          WidgetHelper().myPushRemove(context, WrapperScreen(currentTab: 2,));
        },(){
          Navigator.pop(context);
        },titleBtn2: "Kembali",titleBtn1: "Belanja Lagi");
      }
    }
  }
  bool site=false;
  Future getSite()async{
    final res = await FunctionHelper().getSite();
    print("SITE $res");
    setState(() {
      site = res;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting('id');
    getSite();

  }

  void onShowModal(rating,gambar,barang,kodeBarang){
    WidgetHelper().myModal(context, ReviewContent(
      img:gambar,
      name:barang,
      rating: rating,
      callback: (rating,txt){
        setState(() {
          rate = rating;
          caption=txt;
        });
        sendReview(rating,txt,kodeBarang);
      },
      site: site,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: site?SiteConfig().darkMode:Colors.white,
        appBar: WidgetHelper().appBarWithButton(context, "Ulasan", (){Navigator.pop(context);},<Widget>[],brightness: site?Brightness.dark:Brightness.light),
        body:Container(
          padding: EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: widget.detailHistoryTransactionModel.result.barang.length,
            itemBuilder: (context,index){
              return Card(
                shadowColor: Colors.black,
                elevation: 1.0,
                child: ListTile(
                  onTap: (){
                    onShowModal(
                        5.0,
                        widget.detailHistoryTransactionModel.result.barang[index].gambar,
                        widget.detailHistoryTransactionModel.result.barang[index].barang,
                        widget.detailHistoryTransactionModel.result.barang[index].kodeBarang
                    );
                  },
                  contentPadding: EdgeInsets.all(10.0),
                  leading: Image.network(SiteConfig().noImage),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetHelper().textQ("${DateFormat.yMMMMEEEEd('id').format(widget.detailHistoryTransactionModel.result.barang[index].createdAt)}",10.0,Colors.grey,FontWeight.bold),
                      SizedBox(height: 2.0),
                      WidgetHelper().textQ(widget.detailHistoryTransactionModel.result.barang[index].barang,12.0,SiteConfig().secondColor,FontWeight.bold),
                      SizedBox(height: 5.0),
                      RatingBar.builder(
                        itemSize: 15.0,
                        initialRating: 5,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemPadding: EdgeInsets.only(right: 4.0),
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent,
                              );
                            case 2:
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                              );
                            case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                            default:
                              return Container();
                          }
                        },
                        onRatingUpdate: (rating) {
                          onShowModal(rating,widget.detailHistoryTransactionModel.result.barang[index].gambar,widget.detailHistoryTransactionModel.result.barang[index].barang,widget.detailHistoryTransactionModel.result.barang[index].kodeBarang);

                        },
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
    );
  }
  Widget reviewItem(BuildContext context){
    return Container(
      height: MediaQuery.of(context).size.height/2,
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height:10.0),
          Center(
            child: Container(
              padding: EdgeInsets.only(top:10.0),
              width: 50,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:  BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.all(10),
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: SiteConfig().accentDarkColor,
                  // border: Border.all(color:SiteConfig().accentDarkColor)
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,color: Colors.white),
                    SizedBox(width: 5),
                    WidgetHelper().textQ("Perkiraan tiba dihitung sejak pesanan dikirim",12,Colors.white, FontWeight.bold)
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }
  Widget buildContent(BuildContext context){
    return Card(
      shadowColor: Colors.black,
      elevation: 1.0,
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: Image.network(SiteConfig().noImage),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetHelper().textQ("2 Nov 2020",10.0,Colors.grey,FontWeight.normal),
            SizedBox(height: 2.0),
            WidgetHelper().textQ("Nama Barang",12.0,SiteConfig().secondColor,FontWeight.bold),
            SizedBox(height: 5.0),
            RatingBar.builder(
              itemSize: 40.0,
              initialRating: 5,
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: EdgeInsets.only(right: 4.0),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Icon(
                      Icons.sentiment_very_dissatisfied,
                      color: Colors.red,
                    );
                  case 1:
                    return Icon(
                      Icons.sentiment_dissatisfied,
                      color: Colors.redAccent,
                    );
                  case 2:
                    return Icon(
                      Icons.sentiment_neutral,
                      color: Colors.amber,
                    );
                  case 3:
                    return Icon(
                      Icons.sentiment_satisfied,
                      color: Colors.lightGreen,
                    );
                  case 4:
                    return Icon(
                      Icons.sentiment_very_satisfied,
                      color: Colors.green,
                    );
                  default:
                    return Container();
                }
              },
              onRatingUpdate: (rating) {
                print(rating);
                setState(() {
                  // _rating = rating;
                });
              },
              // updateOnDrag: true,
            )
          ],
        ),
      ),
    );
  }
}


class ReviewContent extends StatefulWidget {
  String img;
  String name;
  double rating;
  Function(double rating,String txt) callback;
  bool site;
  ReviewContent({this.img,this.name,this.rating,this.callback,this.site});
  @override
  _ReviewContentState createState() => _ReviewContentState();
}

class _ReviewContentState extends State<ReviewContent> {
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
    if(rating==1.0){
      setState(() {
        color = Colors.red;
        titleRating = "Kecewa";
        captionRating = "Hi $nama, tolong bantu kami untuk mengerti masalah dengan pembelianmu.";
      });
    }
    if(rating==2.0){
      setState(() {
        color = Colors.redAccent;
        titleRating = "Kurang";
        captionRating = "Hi $nama, tolong bantu kami untuk mengerti masalah dengan pembelianmu.";
      });
    }
    if(rating==3.0){
      setState(() {
        color = Colors.amber;
        titleRating = "Lumayan";
        captionRating = "Hi $nama, sepertinya kamu nggak suka dengan pembelian ini. Boleh tahu kenapa ?";
      });
    }
    if(rating==4.0){
      setState(() {
        color = Colors.lightGreen;
        titleRating = "Suka";
        captionRating = "Hi $nama, yuk bantu calon pembeli lain dengan membagikan pemgalamanmu !";
      });
    }
    if(rating==5.0){
      setState(() {
        color = Colors.green;
        titleRating = "Puas Banget";
        captionRating = "Hi $nama, yuk bantu calon pembeli lain dengan membagikan pemgalamanmu !";
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rateWithCaption(widget.rating);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height/1.3,
      padding: EdgeInsets.only(top:10.0,left:0,right:0),
      decoration: BoxDecoration(
        color: widget.site?SiteConfig().darkMode:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight:Radius.circular(10.0) ),
      ),
      // color: Colors.white,
      child: Column(
        children: [
          SizedBox(height:10.0),
          Center(
            child: Container(
              padding: EdgeInsets.only(top:10.0),
              width: 50,
              height: 10.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:  BorderRadius.circular(10.0),
              ),
            ),
          ),
          ListTile(
            dense:true,
            contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
            title: WidgetHelper().textQ("Tulis Ulasan", 14, widget.site?Colors.white:SiteConfig().secondColor,FontWeight.bold),
            leading: InkWell(
              onTap: ()=>Navigator.pop(context),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Center(child: Icon(UiIcons.return_icon, color: widget.site?Colors.white:Theme.of(context).hintColor),),
              ),
            ),
            trailing: InkWell(
                onTap: ()async{
                  if(captionController.text==""){
                    captionFocus.requestFocus();
                  }
                  else{
                    widget.callback(rate,captionController.text);
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [SiteConfig().secondColor,SiteConfig().secondColor]),
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: [BoxShadow(color: Color(0xFF6078ea).withOpacity(.3),offset: Offset(0.0, 8.0),blurRadius: 8.0)]
                  ),
                  child: WidgetHelper().textQ("Kirim",14,Colors.white,FontWeight.bold),
                )
            ),
          ),
          Divider(),
          SizedBox(height:10.0),
          Expanded(
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(left:10.0,right:10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: widget.site?Colors.grey[200]:SiteConfig().secondColor
                      ),
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      leading: Image.network(SiteConfig().noImage),
                      title:WidgetHelper().textQ(widget.name,12.0,SiteConfig().secondColor,FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height:10.0),
                Container(
                  child: Column(
                    children: [
                      RatingBar.builder(
                        unratedColor: widget.site?Colors.grey:Colors.black,
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
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent,
                              );
                            case 2:
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                              );
                            case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
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
                      WidgetHelper().textQ(titleRating.toUpperCase(), 14,color,FontWeight.bold),
                      SizedBox(height:10.0),
                      Padding(
                          padding: EdgeInsets.only(left:20.0,right:20.0),
                          child: RichText(
                              textAlign: TextAlign.center,
                              // overflow: TextOverflow.fade,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              text: TextSpan(
                                text:captionRating,
                                style: TextStyle(
                                  fontSize:10,color:Colors.grey,fontFamily:SiteConfig().fontStyle,fontWeight:FontWeight.bold,
                                ),
                              )
                          )
                      )
                    ],
                  ),
                ),
                SizedBox(height:10.0),
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)
                        ),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: TextField(
                        style: TextStyle(color:Colors.grey,fontSize:12,fontFamily: SiteConfig().fontStyle,fontWeight: FontWeight.bold),
                        controller: captionController,
                        focusNode: captionFocus,
                        autofocus: false,
                        maxLines: 25,
                        decoration: InputDecoration.collapsed(
                            hintText: "Ceritakan pengalamanmu terkait barang ini ... ",
                            hintStyle: TextStyle(color:Colors.grey,fontSize: 12,fontFamily: SiteConfig().fontStyle,fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
