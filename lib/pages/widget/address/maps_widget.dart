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
  Future bodyMarker({latitude,longitude})async {
    Uint8List imageData = await getMarker();
    LatLng latlng = LatLng(latitude,longitude);
    marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        draggable: true,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData)
    );
    this.setState(() {});
  }
  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(pin);
    return byteData.buffer.asUint8List();
  }
  _getCurrentLocation() {
    geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((Position position) async {
      dynamic newPosition = position.toJson();
      if(widget.latlong!=null){newPosition = widget.latlong;}
      double lat = double.parse(newPosition[StringConfig.latitude]);
      double lng = double.parse(newPosition[StringConfig.longitude]);
      await bodyMarker(latitude: lat,longitude: lng);
      _currentPosition = {StringConfig.latitude:lat.toString(),StringConfig.longitude:lng.toString()};
      getAddressFromLatLng(lat.toString(),lng.toString());
      if(this.mounted)setState((){});
    }).catchError((e) {
      print(e);
    });
  }
  createMarker(context) {
    if (customIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(configuration, pin).then((icon) {
        setState(() {
          customIcon = icon;
        });
      });
    }
  }
  getAddressFromLatLng(lat, lng) async {
    final scaler = config.ScreenScale(context).scaler;
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(lat, lng);
      Placemark place = p[0];
      String fullAddress = "${place.thoroughfare}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
      _currentPosition = {StringConfig.latitude:lat.toString(),StringConfig.longitude:lng.toString()};
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
                          text:
                              "${place.thoroughfare}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}",
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
    assetImage = AssetImage("assets/img/splash.gif");
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
    createMarker(context);
    return Scaffold(
      appBar: WidgetHelper().appBarWithButton(context, "Pilih lokasi",(){},<Widget>[]),
      body: _currentPosition == null? WidgetHelper().loadingWidget(context): GoogleMap(
        mapType: MapType.normal,
        markers: Set.of((marker != null) ? [marker] : []),
        onTap: (pos) async {
          await bodyMarker(latitude: pos.latitude,longitude: pos.longitude);
          getAddressFromLatLng(pos.latitude, pos.longitude);
          if(this.mounted) setState((){});
        },
        onMapCreated: (GoogleMapController controller) {},
        initialCameraPosition: CameraPosition(
          target: LatLng(double.parse(_currentPosition["latitude"]), double.parse(_currentPosition["longitude"])),
          zoom: 18
        ),
      ),
    );
  }
}
