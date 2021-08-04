import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';

// ignore: must_be_immutable
class FilterProductSliderWidget extends StatefulWidget {
  List data;
  String heroTag;
  ValueChanged<String> onChanged;

  FilterProductSliderWidget({this.data, this.heroTag, this.onChanged});
  @override
  _FilterProductSliderWidgetState createState() => _FilterProductSliderWidgetState();
}

class _FilterProductSliderWidgetState extends State<FilterProductSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor.withOpacity(1),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(60), topRight: Radius.circular(60)),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/Categories');
              },
              icon: Icon(
                UiIcons.settings_2,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Container(
                margin: EdgeInsets.only(left: 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor.withOpacity(1),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60), topLeft: Radius.circular(60)),
                ),
                child: ListView.builder(
                  itemCount: widget.data.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    double _marginLeft = 0;
                    (index == 0) ? _marginLeft = 1 : _marginLeft = 0;
                    return CategoryIconWidget(
                        heroTag: widget.heroTag,
                        marginLeft: _marginLeft,
                        data: widget.data.elementAt(index),
                        onPressed: (String id) {
                          setState(() {
                            widget.data.forEach((filter) {
                              filter["selected"] = false;
                              if (filter["title"] == id) {
                                filter["selected"] = true;
                              }
                            });
                            widget.onChanged(id);
                          });
                        });
                  },
                  scrollDirection: Axis.horizontal,
                )),
          ),
        ],
      ),
    );
  }
}



// ignore: must_be_immutable
class CategoryIconWidget extends StatefulWidget {
  dynamic data;
  String heroTag;
  double marginLeft;
  ValueChanged<String> onPressed;
  CategoryIconWidget({Key key, this.data, this.heroTag, this.marginLeft, this.onPressed}) ;
  @override
  _CategoryIconWidgetState createState() => _CategoryIconWidgetState();
}

class _CategoryIconWidgetState extends State<CategoryIconWidget> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return Container(
      padding: scaler.getPadding(0,0),
      margin: scaler.getMarginLTRB(widget.marginLeft, 0.5, 0,0.5),
      child: buildSelectedCategory(context),
    );
  }

   buildSelectedCategory(BuildContext context) {
    final scaler = config.ScreenScale(context).scaler;
    return WidgetHelper().myRipple(
      isRadius: true,
      radius: 50,
      callback: (){
        setState(() {
          widget.onPressed(widget.data["title"]);
        });
      },
      child: AnimatedContainer(
        alignment: Alignment.center,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding:scaler.getPadding(0,2),
        decoration: BoxDecoration(
          color: widget.data["selected"] ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: <Widget>[
            AnimatedSize(
              duration: Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              vsync: this,
              child:Hero(
                tag: widget.heroTag + widget.data["id"],
                child: SvgPicture.asset(
                  widget.data["image"],
                  color: widget.data["selected"] ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
                  width: scaler.getWidth(12),
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
