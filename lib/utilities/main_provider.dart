import 'package:enrutador/models/contacto_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:location/location.dart' as ld;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MainProvider with ChangeNotifier implements TickerProvider {
  late AnimatedMapController _animaMap;
  MainProvider() {
    _animaMap = AnimatedMapController(
        vsync: this,
        duration: Durations.extralong2,
        curve: Curves.easeInOut);
  }
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);

  AnimatedMapController get animaMap => _animaMap;
  set animaMap(AnimatedMapController valor) {
    animaMap = valor;
    notifyListeners();
  }


  bool _internet = false;
  bool get internet => _internet;
  set internet(bool valor) {
    _internet = valor;
    notifyListeners();
  }

  TextEditingController _buscar = TextEditingController();
  TextEditingController get buscar => _buscar;
  set buscar(TextEditingController valor) {
    _buscar = valor;
    notifyListeners();
  }

  ld.LocationData? _local;
  ld.LocationData? get local => _local;
  set local(ld.LocationData? valor) {
    _local = valor;
    notifyListeners();
  }

  PanelController _slide = PanelController();
  PanelController get slide => _slide;
  set slide(PanelController valor) {
    _slide = valor;
    notifyListeners();
  }

  ContactoModelo? _contacto;
  ContactoModelo? get contacto => _contacto;
  set contacto(ContactoModelo? valor) {
    _contacto = valor;
    notifyListeners();
  }

  List<AnimatedMarker> _marker = [];
  List<AnimatedMarker> get marker => _marker;
  set marker(List<AnimatedMarker> valor) {
    _marker = valor;
    notifyListeners();
  }

  String? _jsonPath;
  String? get jsonPath => _jsonPath;
  set jsonPath(String? valor) {
    _jsonPath = valor;
    notifyListeners();
  }

  //?Funciones
}
