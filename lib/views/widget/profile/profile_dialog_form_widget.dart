import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:netindo_shop/helper/user_helper.dart';

class ProfileDialogFormWidget extends StatefulWidget {
  VoidCallback onChanged;

  ProfileDialogFormWidget({Key key, this.onChanged}) : super(key: key);
  @override
  _ProfileDialogFormWidgetState createState() => _ProfileDialogFormWidgetState();
}

class _ProfileDialogFormWidgetState extends State<ProfileDialogFormWidget> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  String name='',email='',gender='',birthDate='';
  final userHelper = UserHelper();
  Future loadData()async{
    final var_foto = await userHelper.getDataUser('foto');
    final var_nama = await userHelper.getDataUser('nama');
    final var_email = await userHelper.getDataUser('email');
    final var_gender = await userHelper.getDataUser('jenis_kelamin');
    final var_birthDate = await userHelper.getDataUser('tgl_ultah');
    setState(() {
      name = var_nama;
      email = var_email;
      gender = var_gender;
      birthDate = var_birthDate;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                title: Row(
                  children: <Widget>[
                    Icon(AntDesign.user),
                    SizedBox(width: 10),
                    Text(
                      'Profile Settings',
                      style: Theme.of(context).textTheme.body2,
                    )
                  ],
                ),
                children: <Widget>[
                  Form(
                    key: _profileSettingsFormKey,
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(hintText: 'John Doe', labelText: 'Full Name'),
                          initialValue: name,
                          validator: (input) => input.trim().length < 3 ? 'Not a valid full name' : null,
                          onSaved: (input) => name = input,
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: getInputDecoration(hintText: 'johndo@gmail.com', labelText: 'Email Address'),
                          initialValue: email,
                          validator: (input) => !input.contains('@') ? 'Not a valid email' : null,
                          onSaved: (input) => email = input,
                        ),
                        FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return DropdownButtonFormField<String>(
                              decoration: getInputDecoration(hintText: 'Pria', labelText: 'Jenis Kelamin'),
                              hint: Text("Select Device"),
                              value: gender,
                              onChanged: (input) {
                                setState(() {
                                  gender = input;
                                  widget.onChanged();
                                });
                              },
                              onSaved: (input) => gender = input,
                              items: [
                                new DropdownMenuItem(value: 'Wanita', child: Text('Wanita')),
                                new DropdownMenuItem(value: 'Pria', child: Text('Pria')),
                              ],
                            );
                          },
                        ),
                        FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return DateTimeField(
                              decoration: getInputDecoration(hintText: '1996-12-31', labelText: 'Birth Date'),
                              format: new DateFormat('yyyy-MM-dd'),
                              initialValue: DateFormat.yMd().parse(birthDate),
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                              },
                              onSaved: (input) => setState(() {
                                birthDate = input.toString();
                                widget.onChanged();
                              }),
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
                        child: Text('Cancel'),
                      ),
                      MaterialButton(
                        onPressed: _submit,
                        child: Text(
                          'Save',
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
      child: Text(
        "Edit",
        style: Theme.of(context).textTheme.body1,
      ),
    );
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.body1.merge(
        TextStyle(color: Theme.of(context).focusColor),
      ),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      hasFloatingPlaceholder: true,
      labelStyle: Theme.of(context).textTheme.body1.merge(
        TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  void _submit() {
    if (_profileSettingsFormKey.currentState.validate()) {
      _profileSettingsFormKey.currentState.save();
      Navigator.pop(context);
    }
  }
}
