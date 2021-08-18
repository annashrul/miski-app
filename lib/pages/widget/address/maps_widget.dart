import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:netindo_shop/config/app_config.dart' as config;
import 'package:netindo_shop/config/string_config.dart';
import 'package:netindo_shop/config/ui_icons.dart';
import 'package:netindo_shop/helper/function_helper.dart';
import 'package:netindo_shop/helper/widget_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:netindo_shop/provider/handle_http.dart';
import 'package:http/http.dart' as http;

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
  Marker marker;
  String pin = '${StringConfig.localAssets}bb.png';
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  dynamic _currentPosition;
  StreamSubscription _locationSubscription;
  String currentAddress = "";
  bool activegps=true;
  Future bodyMarker({latitude,longitude})async {
    LatLng latlng = LatLng(latitude,longitude);
    marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        draggable: true,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
    );
    this.setState(() {});
  }

  _getCurrentLocation() async {


    if (!(await Geolocator().isLocationServiceEnabled())){
      activegps=false;
    }
    else{
      geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
        dynamic newPosition = position.toJson();
        if(widget.latlong!=null){newPosition = widget.latlong;}
        double lat = newPosition[StringConfig.latitude];
        double lng = newPosition[StringConfig.longitude];
        await bodyMarker(latitude: lat,longitude: lng);
        _currentPosition = {StringConfig.latitude:lat,StringConfig.longitude:lng};
        getAddressFromLatLng(lat,lng);
        if(this.mounted)setState((){});
      }).catchError((e) {
        print(e);
      });
    }

  }

  getAddressFromLatLng(lat, lng) async {
    final scaler = config.ScreenScale(context).scaler;
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(lat, lng);
      Placemark place = p[0];
      String fullAddress = "${place.thoroughfare}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
      _currentPosition = {StringConfig.latitude:lat,StringConfig.longitude:lng};
      WidgetHelper().myModal(
        context,
        Column(
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
                            dynamic dataAddress= {
                              StringConfig.latitude:lat.toString(),
                              StringConfig.longitude:lng.toString(),
                              StringConfig.fullAddress:fullAddress.toString(),
                            };
                            print("############################ $dataAddress ###########################");
                            Navigator.of(context).pop();
                            widget.callback(dataAddress);
                          },
                          child: config.MyFont.subtitle(
                            context: context,
                            text: "konfirmasi",
                            color: config.Colors.mainColors,
                          )
                        )
                      ],
                    ),
                    Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Image.asset(pin, height: scaler.getHeight(2)),
                      title: config.MyFont.subtitle(
                          context: context,
                          text: "${place.thoroughfare}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}",
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                )),
          ],
        )
      );
      if (this.mounted) {
        this.setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  AssetImage assetImage;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    markers = Set.from([]);
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
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Lokasi instant kurir",(){},<Widget>[],param:"default"),
      body:!activegps?Container(
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
              RaisedButton(onPressed: ()async{
                if (!(await Geolocator().isLocationServiceEnabled())){
                  setState(() {
                    activegps=false;
                  });
                }else{
                  setState(() {
                    activegps=true;
                  });
                  _getCurrentLocation();
                }
              },
                child: config.MyFont.subtitle(context: context,text:"coba lagi",textAlign: TextAlign.center),
              )
            ],
          ),
        ),
      ):_currentPosition == null ? WidgetHelper().loadingWidget(context): GoogleMap(
        mapType: MapType.normal,
        markers: Set.of((marker != null) ? [marker] : []),
        onTap: (pos) async {
          print("${pos.latitude} ${pos.longitude}");
          await bodyMarker(latitude: pos.latitude,longitude: pos.longitude);
          getAddressFromLatLng(pos.latitude, pos.longitude);
          if(this.mounted) setState((){});
        },
        onMapCreated: (GoogleMapController controller) {},
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition["latitude"], _currentPosition["longitude"]),
          zoom: 18
        ),
      ),
    );
  }
}
