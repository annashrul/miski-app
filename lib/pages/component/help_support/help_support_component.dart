
import 'package:flutter/material.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/help_support/list_help_support_category_model.dart';
import 'package:miski_shop/model/help_support/list_help_support_model.dart';
import 'package:miski_shop/pages/widget/help_support/help_support_widget.dart';
import 'package:miski_shop/provider/handle_http.dart';

class HelpSupportComponent extends StatefulWidget {
  @override
  _HelpSupportComponentState createState() => _HelpSupportComponentState();
}

class _HelpSupportComponentState extends State<HelpSupportComponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ListHelpSupportModel listHelpSupportModel;
  ListHelpSupportCatergoryModel listHelpSupportCatergoryModel;
  bool isLoadingList=true,isLoadingCategory=true;
  List<Widget> tabWidget;
  Future loadData(i)async{
    final res=await HandleHttp().getProvider("faq?page=1&kategori=${listHelpSupportCatergoryModel.result.data[i].id}", listHelpSupportModelFromJson,context: context);
    if(res!=null){
      ListHelpSupportModel result=ListHelpSupportModel.fromJson(res.toJson());
      listHelpSupportModel = result;
      isLoadingList=false;
      if(this.mounted){this.setState(() {});}
    }
  }
  Future loadDataCategory()async{
    final res=await HandleHttp().getProvider("faq_category?page=1", listHelpSupportCatergoryModelFromJson,context: context);
    if(res!=null){
      ListHelpSupportCatergoryModel result=ListHelpSupportCatergoryModel.fromJson(res.toJson());
      listHelpSupportCatergoryModel = result;
      loadData(0);
      isLoadingCategory=false;
      if(this.mounted){this.setState(() {});}
    }
  }

  @override
  void initState() {
    super.initState();

    loadDataCategory();
  }
  
  
  @override
  Widget build(BuildContext context) {
    final scaler=config.ScreenScale(context).scaler;
    return isLoadingCategory||isLoadingList?Scaffold(
      body: WidgetHelper().loadingWidget(context),
    ):DefaultTabController(
      length: listHelpSupportCatergoryModel.result.data.length,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: WidgetHelper().icons(ctx: context,icon: UiIcons.return_icon,color: Theme.of(context).hintColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          bottom: TabBar(
            onTap: (i){
              print(i);
              loadData(i);
            },
            isScrollable: true,
            tabs: listHelpSupportCatergoryModel.result.data.map((e) => Tab(child: config.MyFont.subtitle(context: context,text: e.title,color:config.Colors.secondColors),)).toList(),
            labelColor: Theme.of(context).textTheme.caption.color,
          ),
          title: config.MyFont.title(context: context,text:"Pusat bantuan",color: Theme.of(context).hintColor),
        ),
        body: TabBarView(
          children: List.generate(listHelpSupportCatergoryModel.result.data.length, (index) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  WidgetHelper().titleQ(context, "Faq",icon: Icons.help),
                  SizedBox(height: scaler.getHeight(1),),
                  ListView.separated(
                    padding: EdgeInsets.all(0),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: listHelpSupportModel.result.data.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 15);
                    },
                    itemBuilder: (context, index) {
                      return HelpSupportWidget(index: index,listHelpSupportModel: listHelpSupportModel,);
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
