import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:miski_shop/config/app_config.dart' as config;
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/config/ui_icons.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miski_shop/pages/component/address/address_component.dart';
import 'package:miski_shop/pages/widget/address/modal_form_address_widget.dart';
import 'package:miski_shop/provider/address_provider.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MapsWidget extends StatefulWidget {
  final dynamic latlong;
  final Function(dynamic address) callback;
  const MapsWidget({Key key, this.callback,this.latlong}) : super(key: key);

  @override
  _MapsWidgetState createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  BitmapDescriptor customIcon;
  Set<Marker> markers;
  String pin = '${StringConfig.localAssets}bb.png';
  StreamSubscription _locationSubscription;
  AssetImage assetImage;
  @override
  void initState() {
    super.initState();
    final map = Provider.of<AddressProvider>(context, listen: false);
    map.getCurrentLocation(widget.latlong);
    map.checkingGps();
  }
  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final map = Provider.of<AddressProvider>(context);

    final scaler = config.ScreenScale(context).scaler;
    return Scaffold(
      bottomNavigationBar: map.isActiveGps&&map.addressFromLatLong!=null?Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: scaler.getPadding(1, 2),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WidgetHelper().titleQ(context, "alamat anda",icon: UiIcons.information, fontSize: 9),
                      WidgetHelper().myRipple(
                          callback: () async {

                            // dynamic dataAddress= {
                            //   StringConfig.latitude:map.addressFromLatLong[StringConfig.latitude],
                            //   StringConfig.longitude:map.addressFromLatLong[StringConfig.longitude],
                            //   StringConfig.fullAddress:map.addressFromLatLong[StringConfig.fullAddress],
                            // };

                            widget.callback({});
                            // Navigator.of(context).pop();
                          },
                          child: config.MyFont.subtitle(context: context,text: "konfirmasi",color: config.Colors.mainColors)
                      )
                    ],
                  ),
                  Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: Image.asset(pin, height: scaler.getHeight(2)),
                    title: config.MyFont.subtitle(context: context,text: map.addressFromLatLong[StringConfig.fullAddress],fontWeight: FontWeight.normal),
                  ),
                ],
              )),
        ],
      ):SizedBox(),
      appBar: WidgetHelper().appBarWithButton(context, "Lokasi instant kurir",(){},<Widget>[],param:"default"),
      body:!map.isActiveGps?Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal:50),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 250,
                width: 250,
                child: Image.asset('${StringConfig.localAssets}nogps.png'),
              ),
              SizedBox(height: 20),
              config.MyFont.subtitle(context: context,text:"anda harus mengaktifkan gps untuk mendapatkan lokasi",textAlign: TextAlign.center),
              SizedBox(
                height:40,
              ),
              RaisedButton(
                onPressed: ()async{
                  map.checkingGps();
                  map.getCurrentLocation(widget.latlong);
              },
                child: config.MyFont.subtitle(context: context,text:"coba lagi",textAlign: TextAlign.center),
              )
            ],
          ),
        ),
      ):map.addressFromLatLong == null ? WidgetHelper().loadingWidget(context): GoogleMap(
        mapType: MapType.normal,
        markers: Set.of((map.marker != null) ? [map.marker] : []),
        onTap: (pos) async {
          await map.createMarker(latitude: pos.latitude,longitude: pos.longitude);
          await map.getAddressFromLatLng(pos.latitude, pos.longitude);
        },
        onMapCreated: (GoogleMapController controller) {},
        initialCameraPosition: CameraPosition(
          target: LatLng(map.addressFromLatLong[StringConfig.latitude], map.addressFromLatLong[StringConfig.longitude]),
          zoom: 18
        ),
      ),
    );
  }
}
