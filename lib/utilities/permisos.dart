import 'package:location/location.dart' as lc;

class Permisos {
  static Future<bool> ubicacion() async {
    lc.Location location = lc.Location();

    bool serviceEnabled;
    lc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == lc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != lc.PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }
}
