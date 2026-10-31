import 'package:map_launcher/map_launcher.dart';

abstract final class DemoMapModel {
  static const maps = <MapApp>[
    MapApp.google,
    MapApp.apple,
    MapApp.waze,
    MapApp.googleGo,
    MapApp.petal,
    MapApp.osmand,
    MapApp.osmandplus
  ];
}
