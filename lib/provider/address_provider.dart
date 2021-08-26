

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:miski_shop/config/string_config.dart';
import 'package:miski_shop/helper/function_helper.dart';
import 'package:miski_shop/helper/user_helper.dart';
import 'package:miski_shop/helper/widget_helper.dart';
import 'package:miski_shop/model/address/detail_address_model.dart';
import 'package:miski_shop/model/address/list_address_model.dart';
import 'package:miski_shop/model/general_model.dart';
import 'package:miski_shop/provider/handle_http.dart';
import 'package:miski_shop/provider/user_provider.dart';
import 'package:provider/provider.dart';

class AddressProvider with ChangeNotifier{
  dynamic addressFromLatLong;
  bool isActiveGps=true,isError=false,isLoading=true;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Marker marker;
  DetailAddressModel detail;
  ListAddressModel listAddressModel;
  dynamic listByIndex;
  TextEditingController titleController = new TextEditingController();
  TextEditingController receiverController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController provinceController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController districtController = new TextEditingController();
  TextEditingController mainAddressController = new TextEditingController();
  FocusNode titleFocus,receiverFocus,phoneFocus,provinceFocus,cityFocus,districtFocus,mainAddressFocus = new FocusNode();
  String provCode="",cityCode="",districtCode="";
  int idxProv = 0,idxCity = 0,idxDistrict = 0;
  Future create(BuildContext context,Function(String res) callback)async{
    WidgetHelper().loadingDialog(context);
    final data = await bodyStore();
    var res = await HandleHttp().postProvider("member_alamat", data, context: context);
    if (res != null) {
      Navigator.pop(context);
      Navigator.pop(context);
      await FunctionHelper().rmPinPoint();
      callback("berhasil");
    }
  }
  Future readList(BuildContext context)async{
    print("============================= READ ADDRESS $listAddressModel ============================");
    if(listAddressModel==null)isLoading=true;
    final idUser = await UserHelper().getDataUser("id_user");
    final res = await HandleHttp().getProvider("member_alamat?page=1&id_member=$idUser", listAddressModelFromJson,context: context);
    listAddressModel = ListAddressModel.fromJson(res.toJson());
    isLoading=false;
    notifyListeners();
  }
  Future update(BuildContext context,Function(String res) callback,id) async {
    WidgetHelper().loadingDialog(context);
    final data = await bodyStore();
    data.remove("id_member");
    var res = await HandleHttp().putProvider("member_alamat/$id", data, context: context);
    if (res != null) {
      Navigator.pop(context);
      Navigator.pop(context);
      await FunctionHelper().rmPinPoint();
      callback('berhasil');
    }
  }
  Future delete(BuildContext context,id)async{
    WidgetHelper().loadingDialog(context);
    var res = await HandleHttp().deleteProvider("member_alamat/$id", generalFromJson,context: context);
    if(res!=null){
      readList(context);
      Navigator.of(context).pop();
      notifyListeners();
    }
  }
  Future readDetail(BuildContext context,id)async{
    if(detail==null)isLoading=true;
    final res = await HandleHttp().getProvider("member_alamat/$id", detailAddressModelFromJson,context: context);
    if(res!=null){
      detail = DetailAddressModel.fromJson(res.toJson());
      if(detail.result.pinpoint!='-'){
        getAddressFromLatLng(double.parse(detail.result.pinpoint.split(",")[0]), double.parse(detail.result.pinpoint.split(",")[1]));
      }
      final getDetail = detail.result;
      titleController =  TextEditingController(text: getDetail.title);
      receiverController =  TextEditingController(text: getDetail.penerima);
      phoneController =  TextEditingController(text: getDetail.noHp);
      provinceController =  TextEditingController(text: getDetail.provinsi);
      cityController =  TextEditingController(text: getDetail.kota);
      districtController =  TextEditingController(text: getDetail.kecamatan);
      mainAddressController =  TextEditingController(text: getDetail.mainAddress);
      provCode = getDetail.kdProv;
      cityCode = getDetail.kdKota;
      districtCode = getDetail.kdKec;
    }
    else{
      isError=true;
    }
    isLoading=false;
    notifyListeners();
  }
  readByIndex(int index){
    listByIndex = listAddressModel.result.data[index].toJson();
    notifyListeners();

  }
  checkingGps()async{
    if (!(await Geolocator().isLocationServiceEnabled()))isActiveGps=false;
    else isActiveGps=true;
    notifyListeners();
  }
  getAddressFromLatLng(lat, lng) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(lat, lng);
      Placemark place = p[0];
      addressFromLatLong={
        StringConfig.fullAddress:"${place.thoroughfare}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}",
        StringConfig.latitude:lat,
        StringConfig.longitude:lng
      };
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
  getCurrentLocation(dynamic latlong) async {
    geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      dynamic newPosition = position.toJson();
      if(latlong!=null)newPosition=latlong;
      double lat = newPosition[StringConfig.latitude];
      double lng = newPosition[StringConfig.longitude];
      await createMarker(longitude: lng,latitude: lat);
      await getAddressFromLatLng(lat,lng);
      notifyListeners();
    }).catchError((e) {
      print(e);
    });
  }
  Future createMarker({latitude,longitude})async {
    LatLng latlng = LatLng(latitude,longitude);
    marker = Marker(
      markerId: MarkerId("home"),
      position: latlng,
      draggable: true,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5, 0.5),
    );
    notifyListeners();
  }
  resetField(BuildContext context){
    final user = Provider.of<UserProvider>(context, listen: false);
    titleController = TextEditingController(text: "");
    receiverController= TextEditingController(text: user.dataUser[StringConfig.nama]);
    phoneController= TextEditingController(text: user.dataUser[StringConfig.tlp]);
    provinceController = TextEditingController(text: "");
    cityController = TextEditingController(text: "");
    districtController = TextEditingController(text: "");
    mainAddressController = TextEditingController(text: "");
    provCode="";
    cityCode="";
    districtCode="";
    idxProv = 0;
    idxCity = 0;
    idxDistrict = 0;
    // addressFromLatLong=null;
    notifyListeners();
  }
  msgBox(BuildContext context,desc){
    WidgetHelper().showFloatingFlushbar(context, "failed", desc);
  }
  Future validate(BuildContext context,String id,Function(String res) callback) async {
    if (titleController.text == '') {
      msgBox(context, "title alamat tidak boleh kosong");
    } else if (receiverController.text == '') {
      msgBox(context, "penerima tidak boleh kosong");
    } else if (phoneController.text == '') {
      msgBox(context, "no telepon tidak boleh kosong");
    } else if (provinceController.text == '') {
      msgBox(context, "provinsi tidak boleh kosong");
    } else if (cityController.text == '') {
      msgBox(context, "kota tidak boleh kosong");
    } else if (districtController.text == '') {
      msgBox(context, "kecamatan tidak boleh kosong");
    } else if (mainAddressController.text == '') {
      msgBox(context, "catatan tidak boleh kosong");
    }
    else if(addressFromLatLong==null){
      msgBox(context, "silahkan pilih lokasi pick up");
    }
    else {
      if(id==""){
        await create(context, (res)=>callback(res));
      }
      else{
        await update(context, (res) => callback(res), id);
      }
    }
    notifyListeners();
  }
  Future<Map<String,Object>> bodyStore()async{
    final idMember = await UserHelper().getDataUser(StringConfig.id_user);
    return {
      "id_member": "$idMember",
      "title": "${titleController.text}",
      "penerima": "${receiverController.text}",
      "main_address":mainAddressController.text,
      "kd_prov": "$provCode",
      "kd_kota": "$cityCode",
      "kd_kec": "$districtCode",
      "no_hp": "${phoneController.text}",
      "pinpoint":addressFromLatLong!=null?"${addressFromLatLong[StringConfig.latitude]},${addressFromLatLong[StringConfig.longitude]}":"-"
    };
  }

  setAddressFromLatLong(input){
    print("provider $addressFromLatLong");
    print("provider $input");
    addressFromLatLong = input;
    notifyListeners();
  }

}