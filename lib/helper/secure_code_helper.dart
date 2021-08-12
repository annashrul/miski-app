
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:netindo_shop/helper/bezier.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import "package:netindo_shop/config/app_config.dart" as config;

typedef void DeleteCode();
typedef Future<bool> PassCodeVerify(List<int> passcode);
class SecureCodeHelper extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback fingerFunction;
  final bool fingerVerify;
  final String title;
  final int passLength;
  final bool showWrongPassDialog;
  final bool showFingerPass;
  final String wrongPassTitle;
  final String wrongPassContent;
  final String wrongPassCancelButtonText;

  final Color numColor;
  final String fingerPrintImage;
  final Color borderColor;
  final Color foregroundColor;
  final PassCodeVerify passCodeVerify;
  final String deskripsi;
  final String forgotPin;
  SecureCodeHelper({
    this.onSuccess,
    this.title="",
    this.borderColor,
    this.foregroundColor = Colors.transparent,
    this.passLength,
    this.passCodeVerify,
    this.fingerFunction,
    this.fingerVerify = false,
    this.showFingerPass = false,
    this.numColor = Colors.grey,
    this.fingerPrintImage,
    this.showWrongPassDialog = false,
    this.wrongPassTitle,
    this.wrongPassContent,
    this.wrongPassCancelButtonText,
    this.deskripsi,
    this.forgotPin,
  })  : assert(title != null),
        assert(passLength <= 8),

        assert(borderColor != null),
        assert(foregroundColor != null),
        assert(passCodeVerify != null),
        assert(onSuccess != null);
  @override
  _SecureCodeHelperState createState() => _SecureCodeHelperState();
}


class _SecureCodeHelperState extends State<SecureCodeHelper> {
  var _currentCodeLength = 0;
  var _inputCodes = <int>[];
  var _currentState = 0;
  Color circleColor = Colors.white;

  _onCodeClick(int code) {
    if (_currentCodeLength < widget.passLength) {
      setState(() {
        _currentCodeLength++;
        _inputCodes.add(code);
      });

      if (_currentCodeLength == widget.passLength) {
        widget.passCodeVerify(_inputCodes).then((onValue) {
          if (onValue) {
            setState(() {
              _currentState = 1;
            });
            widget.onSuccess();
          } else {
            _currentState = 2;
            new Timer(new Duration(milliseconds: 1000), () {
              if(this.mounted){
                setState(() {
                  _currentState = 0;
                  _currentCodeLength = 0;
                  _inputCodes.clear();
                });
              }
            });
            if (widget.showWrongPassDialog) {
              WidgetHelper().showFloatingFlushbar(context, "failed", widget.wrongPassContent);
              // WidgetHelper().notifDialog(context, widget.wrongPassTitle, widget.wrongPassContent, (){Navigator.pop(context);},(){Navigator.pop(context);});
            }
          }
        });
      }
    }
  }

  _fingerPrint() {
    if (widget.fingerVerify) {
      widget.onSuccess();
    }
  }

  _deleteCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength--;
        _inputCodes.removeAt(_currentCodeLength);
      }
    });
  }

  _deleteAllCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength = 0;
        _inputCodes.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 200), () {
      _fingerPrint();
    });
    final height = MediaQuery.of(context).size.height;
    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()
          ),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,

            padding: scaler.getPadding(2,4),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  config.MyFont.title(context: context,text:widget.deskripsi,textAlign: TextAlign.center),
                  SizedBox(
                    height: scaler.getHeight(4),
                  ),
                  CodePanel(
                    codeLength: widget.passLength,
                    currentLength: _currentCodeLength,
                    borderColor: widget.borderColor,
                    foregroundColor: widget.foregroundColor,
                    deleteCode: _deleteCode,
                    fingerVerify: widget.fingerVerify,
                    status: _currentState,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 0, top: 10),
                    child:
                    NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowGlow();
                        return null;
                      },
                      child: GridView.count(
                        primary: false,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        childAspectRatio: 1.6,
                        mainAxisSpacing: 10,
                        padding: EdgeInsets.all(5),
                        children: <Widget>[
                          buildContainerCircle(1),
                          buildContainerCircle(2),
                          buildContainerCircle(3),
                          buildContainerCircle(4),
                          buildContainerCircle(5),
                          buildContainerCircle(6),
                          buildContainerCircle(7),
                          buildContainerCircle(8),
                          buildContainerCircle(9),
                          buildRemoveIcon(Icons.close),
                          buildContainerCircle(0),
                          buildContainerIcon(Icons.arrow_back),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ex1(BuildContext context){
    return Expanded(
      flex: 4,
      child: Container(
        child: Stack(
          children: <Widget>[
            ClipPath(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    
                    SizedBox(
                      height: config.ScreenScale(context).scaler.getHeight(5),
                    ),
                   
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            config.MyFont.subtitle(context: context,color: config.Colors.secondColors,text:widget.deskripsi)
                          ],
                        ),
                      ),
                    ),
                    // RichText(overflow: TextOverflow.ellipsis, text: TextSpan(style:Theme.of(context).textTheme.title.merge(TextStyle(color: Theme.of(context).accentColor,fontSize: 12)), children: [TextSpan(text:widget.deskripsi)])),
                    SizedBox(
                      height: Platform.isIOS ? 40 : 15,
                    ),
                    CodePanel(
                      codeLength: widget.passLength,
                      currentLength: _currentCodeLength,
                      borderColor: widget.borderColor,
                      foregroundColor: widget.foregroundColor,
                      deleteCode: _deleteCode,
                      fingerVerify: widget.fingerVerify,
                      status: _currentState,
                    ),
                    widget.showFingerPass ?SizedBox(
                      height: Platform.isIOS ? 40 : 40,
                    ):Container(),
                    widget.showFingerPass ? forgotScreen() :Container(),
                    widget.showFingerPass ?SizedBox(
                      height: Platform.isIOS ? 40 : 15,
                    ):Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget ex2(BuildContext context){
    return Expanded(
      flex: Platform.isIOS ? 5 : 6,
      child: Container(
        // color:Theme.of(context).focusColor.withOpacity(0.1),
        padding: EdgeInsets.only(left: 0, top: 10),
        child:
        NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return null;
          },
          child: GridView.count(
            primary: false,
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 1.6,
            mainAxisSpacing: 10,
            padding: EdgeInsets.all(5),
            children: <Widget>[
              buildContainerCircle(1),
              buildContainerCircle(2),
              buildContainerCircle(3),
              buildContainerCircle(4),
              buildContainerCircle(5),
              buildContainerCircle(6),
              buildContainerCircle(7),
              buildContainerCircle(8),
              buildContainerCircle(9),
              buildRemoveIcon(Icons.close),
              buildContainerCircle(0),
              buildContainerIcon(Icons.arrow_back),
            ],
          ),
        ),
      ),
    );
  }
  Widget forgotScreen(){
    return InkResponse(
      onTap: (){
        widget.fingerFunction();
      },
      child: Center(
        child:config.MyFont.subtitle(context: context,color: config.Colors.mainDarkColors,text:widget.forgotPin)
      ),
    );
  }

  Widget buildContainerCircle(int number) {
    return InkResponse(
      highlightColor: Colors.black38,
      splashColor:  Colors.black38,
      onTap: () {
        _onCodeClick(number);
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          border: Border.all(color: config.Colors.secondDarkColors),
          boxShadow: [
            BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.1), offset: Offset(0, 3), blurRadius: 10)
          ],
          shape: BoxShape.circle,
        ),
        child: Center(
            child:config.MyFont.title(context: context,color: config.Colors.mainColors,text:number.toString(),fontSize: 10)
        ),
      ),
    );
  }


  Widget buildRemoveIcon(IconData icon) {
    return InkResponse(
      highlightColor: Colors.black38,
      splashColor:  Colors.black38,
      onTap: () {
        if (0 < _currentCodeLength) {
          _deleteAllCode();
        }
      },
      child: Container(
        margin: EdgeInsets.all(10.0),

        height: 50,
        width: 50,
        decoration: BoxDecoration(
            // color:  Colors.grey[200],
            shape: BoxShape.rectangle,
            borderRadius:  BorderRadius.circular(10.0),

            ),
        child: Center(
          child:Icon(Ionicons.ios_close_circle_outline,color:config.Colors.secondDarkColors,size: config.ScreenScale(context).scaler.getTextSize(15),),
          // child: Text('Ulangi',style:TextStyle(fontSize: ScreenUtilQ.getInstance().setSp(40),color:widget.numColor,fontWeight:FontWeight.bold,fontFamily:ThaibahFont().fontQ)),
        ),
      ),
    );
  }

  Widget buildContainerIcon(IconData icon) {
    return InkResponse(
      highlightColor: Colors.black38,
      splashColor:  Colors.black38,
      onTap: () {
        if (0 < _currentCodeLength) {
          setState(() {
            circleColor =  Colors.grey[200];
          });
          Future.delayed(Duration(milliseconds: 200)).then((func) {
            setState(() {
              circleColor =  Colors.grey[200];
            });
          });
        }
        _deleteCode();
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius:  BorderRadius.circular(10.0),
        ),
        child: Center(
          child:Icon(Ionicons.ios_backspace,color:config.Colors.secondDarkColors,size: config.ScreenScale(context).scaler.getTextSize(15)),
        ),
      ),
    );
  }
// void _onTextViewCreated(TextViewController controller) {
//   controller.setText('Hello from Android!');
// }
}

class CodePanel extends StatelessWidget {
  final codeLength;
  final currentLength;
  final borderColor;
  final bool fingerVerify;
  final foregroundColor;
  final H = 30.0;
  final W = 30.0;
  final DeleteCode deleteCode;
  final int status;
  CodePanel(
      {this.codeLength,
        this.currentLength,
        this.borderColor,
        this.foregroundColor,
        this.deleteCode,
        this.fingerVerify,
        this.status})
      : assert(codeLength > 0),
        assert(currentLength >= 0),
        assert(currentLength <= codeLength),
        assert(deleteCode != null),
        assert(status == 0 || status == 1 || status == 2);

  @override
  Widget build(BuildContext context) {
    var circles = <Widget>[];
    var color = borderColor;
    int circlePice = 1;

    if (fingerVerify == true) {
      do {
        circles.add(
          SizedBox(
            width: W,
            height: H,
            child: new Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: color, width: 1.0),
                color: Colors.green.shade500,
              ),
            ),
          ),
        );
        circlePice++;
      } while (circlePice <= codeLength);
    } else {
      if (status == 1) {
        color = Colors.green.shade500;
      }
      if (status == 2) {
        color = Colors.green.shade500;
      }
      for (int i = 1; i <= codeLength; i++) {
        if (i > currentLength) {
          circles.add(SizedBox(
              width: W,
              height: H,
              child: Container(
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(color: color, width: 2.0),
                    color: foregroundColor
                ),
              )));
        } else {
          circles.add(new SizedBox(
              width: W,
              height: H,
              child: new Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(color: color, width: 1.0),
                  color: color,
                ),
              )));
        }
      }
    }

    return new SizedBox.fromSize(
      size: new Size(MediaQuery.of(context).size.width, 30.0),
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.fromSize(
                size: new Size(40.0 * codeLength, H),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: circles,
                )),
          ]),
    );
  }
}

class BgClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height / 1.5);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
