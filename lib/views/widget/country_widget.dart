import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netindo_shop/config/site_config.dart';

class CountryWidget extends StatelessWidget {
  const CountryWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[100],
      ),
      child: CountryCodePicker(
        textStyle: TextStyle(color: SiteConfig().secondColor),
        initialSelection: 'ID',
        showCountryOnly: true,
        alignLeft: false,
      ),
    );
  }
}