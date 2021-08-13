import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/widget_helper.dart';


// ignore: must_be_immutable
class FormProfileWidget extends StatefulWidget {
  dynamic user;
  VoidCallback onChanged;
  Function(dynamic data) onSubmited;
  FormProfileWidget({Key key, this.user, this.onChanged,this.onSubmited}) : super(key: key);
  @override
  _FormProfileWidgetState createState() => _FormProfileWidgetState();
}

class _FormProfileWidgetState extends State<FormProfileWidget> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();

  String tgl="";

  @override
  Widget build(BuildContext context) {
    return WidgetHelper().myRipple(
      callback: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                title: WidgetHelper().titleQ(context, "Ubah data diri", icon: UiIcons.user_1,),
                children: <Widget>[
                  Form(
                    key: _profileSettingsFormKey,
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          style: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(
                              hintText: 'John Doe',
                              labelText: 'Full Name'
                          ),
                          initialValue: widget.user[StringConfig.nama],
                          validator: (input) => input.trim().length < 3 ? 'Not a valid full name' : null,
                          onSaved: (input) => widget.user[StringConfig.nama] = input,
                          onChanged: (input)=>widget.user[StringConfig.nama] = input,
                        ),
                        new TextFormField(
                          style: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color),
                          keyboardType: TextInputType.emailAddress,
                          decoration: getInputDecoration(hintText: 'johndo@gmail.com', labelText: 'Email Address'),
                          initialValue: widget.user[StringConfig.email],
                          validator: (input) => !input.contains('@') ? 'Not a valid email' : null,
                          onSaved: (input) => widget.user[StringConfig.email] = input,
                          onChanged: (input)=>widget.user[StringConfig.email] = input,
                        ),
                        FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return DropdownButtonFormField<String>(
                              decoration: getInputDecoration(hintText: '0', labelText: 'Jenis kelamin'),
                              hint: config.MyFont.subtitle(context: context,text: "Pilih"),
                              value: widget.user[StringConfig.jenis_kelamin],
                              onChanged: (input) {
                                setState(() {
                                  widget.user[StringConfig.jenis_kelamin] = input;
                                  widget.onChanged();
                                });
                              },
                              onSaved: (input) => widget.user[StringConfig.jenis_kelamin] = input,
                              items: [
                                new DropdownMenuItem(value: "1", child: config.MyFont.subtitle(context: context,text: "Pria")),
                                new DropdownMenuItem(value: "0", child: config.MyFont.subtitle(context: context,text: "Wanita")),
                              ],
                            );
                          },
                        ),
                        FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return DateTimeField(
                              style: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color),
                              decoration: getInputDecoration(hintText: '1996-12-31', labelText: 'Birth Date'),
                              format: new DateFormat('yyyy-MM-dd'),
                              initialValue: new DateFormat("yyyy-MM-dd").parse(widget.user[StringConfig.tgl_ultah]),
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));

                              },
                              onSaved:(input){
                                setState(() {
                                  widget.user[StringConfig.tgl_ultah] = input;
                                  widget.onChanged();
                                });
                              },
                              onChanged: (input){
                                if(input!=null){
                                  this.setState(() {
                                    tgl=input.toString();
                                  });
                                }
                              },


                            );
                          },

                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Kembali'),
                      ),
                      MaterialButton(
                        onPressed: (){
                          // var cel = new DateFormat("yyyy-MM-dd").parse(tgl);
                          if(tgl!=""){
                            DateTime tempDate = new DateFormat("yyyy-MM-dd").parse(tgl);
                            this.setState(() {
                              widget.user[StringConfig.tgl_ultah] =  "$tempDate".substring(0,10);
                            });
                          }
                          widget.onSubmited(widget.user);
                        },
                        child: Text(
                          'Simpan',
                          style: TextStyle(color: Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                  SizedBox(height: 10),
                ],
              );
            });
      },
      child: config.MyFont.subtitle(context: context,text:"Ubah",fontSize: 9,color: config.Colors.mainColors)
    );
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      labelStyle: config.MyFont.fieldStyle(context: context,color: Theme.of(context).textTheme.headline1.color),
    );
  }

}
