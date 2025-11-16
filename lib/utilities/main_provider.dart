import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/estado_model.dart';
import 'package:enrutador/models/tipos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:location/location.dart' as ld;
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/referencia_model.dart';

class MainProvider with ChangeNotifier implements TickerProvider {
  late AnimatedMapController _animaMap;
  MainProvider() {
    _animaMap = AnimatedMapController(
        vsync: this, duration: Durations.extralong3, curve: Curves.easeInOut);
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

  ReferenciaModelo? _selectReferencia;
  ReferenciaModelo? get selectRefencia => _selectReferencia;
  set selectRefencia(ReferenciaModelo? valor) {
    _selectReferencia = valor;
    notifyListeners();
  }

  TextEditingController _buscar = TextEditingController();
  TextEditingController get buscar => _buscar;
  set buscar(TextEditingController valor) {
    _buscar = valor;
    notifyListeners();
  }

  GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();
  GlobalKey<SliderDrawerState> get sliderDrawerKey => _sliderDrawerKey;
  set sliderDrawerKey(GlobalKey<SliderDrawerState> valor) {
    _sliderDrawerKey = valor;
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

  List<TiposModelo> _tipos = [];
  List<TiposModelo> get tipos => _tipos;
  set tipos(List<TiposModelo> valor) {
    _tipos = valor;
    notifyListeners();
  }

  List<EstadoModel> _estados = [];
  List<EstadoModel> get estados => _estados;
  set estados(List<EstadoModel> valor) {
    _estados = valor;
    notifyListeners();
  }

  bool _mapaReal = false;
  bool get mapaReal => _mapaReal;
  set mapaReal(bool valor) {
    _mapaReal = valor;
    notifyListeners();
  }

  bool _mapSeguir = false;
  bool get mapSeguir => _mapSeguir;
  set mapSeguir(bool valor) {
    _mapSeguir = valor;
    notifyListeners();
  }

  bool _cargaDatos = false;
  bool get cargaDatos => _cargaDatos;
  set cargaDatos(bool valor) {
    _cargaDatos = valor;
    notifyListeners();
  }

  int _cargaLenght = 0;
  int get cargaLenght => _cargaLenght;
  set cargaLenght(int valor) {
    _cargaLenght = valor;
    notifyListeners();
  }

  int _cargaProgress = 0;
  int get cargaProgress => _cargaProgress;
  set cargaProgress(int valor) {
    _cargaProgress = valor;
    notifyListeners();
  }

  bool _shareContacto = false;
  bool get shareContacto => _shareContacto;
  set shareContacto(bool valor) {
    _shareContacto = valor;
    notifyListeners();
  }

  //?Funciones

  Future<void> logeo() async {
    tipos = await TipoController.getItems();
    estados = await EstadoController.getItems();
  }
}
