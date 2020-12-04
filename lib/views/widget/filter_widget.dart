import 'package:flutter/material.dart';
import 'package:netindo_shop/config/database_config.dart';
import 'package:netindo_shop/config/site_config.dart';
import 'package:netindo_shop/helper/database_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

class FilterWidget extends StatefulWidget {
  Function(List data) callback;
  List idx;
  FilterWidget({this.callback,this.idx});
  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  List returnCategory = [],returnGroup = [],returnBrand = [];
  bool isLoading=false;
  int valueCategory,valueGroup,valueBrand;
  String qCategory,qGroup,qBrand;
  List returnCallback = [];
  void clearSelection() {
    setState(() {
      valueCategory=null;
      valueGroup=null;
      valueBrand=null;
    });
  }
  final DatabaseConfig _helper = new DatabaseConfig();

  Future loadCategory()async{
    var kategori = await _helper.getData(CategoryQuery.TABLE_NAME);
    List category = [];
    kategori.forEach((element) {
      category.add({
        "id": element['id_category'],
        "title":element['title'],
        "image": element['image'],
        "status": element['image'],
        "isSelected":false
      });
    });
    setState(() {
      returnCategory=category;
    });

  }
  Future loadGroup()async{
    var group = await _helper.getData(GroupQuery.TABLE_NAME);
    List groups = [];
    group.forEach((element) {
      groups.add({
        "id": element['id_group'],
        "title": element['title'],
        "id_kategori":element['id_categories'],
        "kategori":element['category'],
        "status": element['status'],
        "image": element['image'],
        "isSelected":false
      });
    });
    setState(() {
      returnGroup=groups;
    });
  }
  Future loadBrand()async{
    var brand = await _helper.getData(BrandQuery.TABLE_NAME);
    List brands = [];
    brand.forEach((element) {
      brands.add({
        "id": element['id_brand'],
        "title":element['title'],
        "image": element['image'],
        "status": element['image'],
        "isSelected":false
      });
    });
    setState(() {
      returnBrand=brands;
    });

  }
  Future loadData()async{
    await loadCategory();
    await loadGroup();
    await loadBrand();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    valueCategory=widget.idx[0];
    valueGroup=widget.idx[1];
    valueBrand=widget.idx[2];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        clearSelection();
                      });
                    },
                    child: WidgetHelper().textQ("hapus",10, SiteConfig().secondColor,FontWeight.bold),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                primary: true,
                shrinkWrap: true,
                children: <Widget>[
                  ExpansionTile(
                    initiallyExpanded: true,
                    title: WidgetHelper().textQ("Kategori",14,SiteConfig().mainColor,FontWeight.bold),
                    children: List.generate(returnCategory.length, (index) {
                      return RadioListTile(
                        value: index,
                        groupValue: valueCategory,
                        onChanged: (ind){
                          setState((){
                            valueCategory = ind;
                            qCategory = returnCategory[index]['title'];
                          });
                        },
                        secondary: SizedBox(
                          width: 40,
                          height: 30,
                          child: Image.network(
                            returnCategory[index]['image'],
                          ),
                        ),
                        title: WidgetHelper().textQ(returnCategory[index]['title'],12,SiteConfig().secondColor,FontWeight.bold),
                      );
                    }),
                  ),
                  ExpansionTile(
                    initiallyExpanded: true,
                    title: WidgetHelper().textQ("Kelompok",14,SiteConfig().mainColor,FontWeight.bold),
                    children: List.generate(returnGroup.length, (index) {
                      return RadioListTile(
                        value: index,
                        groupValue: valueGroup,
                        onChanged: (ind){
                          setState((){
                            valueGroup = ind;
                            qGroup = returnGroup[index]['title'];
                          });
                        },
                        secondary: SizedBox(
                          width: 40,
                          height: 30,
                          child: Image.network(
                            returnGroup[index]['image'],
                          ),
                        ),
                        title: WidgetHelper().textQ(returnGroup[index]['title'],12,SiteConfig().secondColor,FontWeight.bold),
                      );
                    }),
                  ),
                  ExpansionTile(
                    initiallyExpanded: true,
                    title: WidgetHelper().textQ("Brand",14,SiteConfig().mainColor,FontWeight.bold),
                    children: List.generate(returnBrand.length, (index) {
                      return RadioListTile(
                        value: index,
                        groupValue: valueBrand,
                        onChanged: (ind){
                          setState((){
                            valueBrand = ind;
                            returnCallback.add({"category":valueCategory,"kelompok":valueGroup,"brand":ind});
                            qBrand = returnBrand[index]['title'];
                          });
                        },
                        secondary: SizedBox(
                          width: 40,
                          height: 30,
                          child: Image.network(
                            returnBrand[index]['image'],
                          ),
                        ),
                        title: WidgetHelper().textQ(returnBrand[index]['title'],12,SiteConfig().secondColor,FontWeight.bold),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            FlatButton(
              onPressed: () {
                widget.callback([{"category":qCategory,"group":qGroup,"brand":qBrand,"idxCategory":valueCategory,"idxGroup":valueGroup,"idxBrand":valueBrand}]);
              },
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              color: Theme.of(context).accentColor,
              shape: StadiumBorder(),
              child: WidgetHelper().textQ("Simpan",12.0,Colors.white,FontWeight.bold),
            ),
            SizedBox(height: 15)
          ],
        ),
      ),
    );
  }



}
