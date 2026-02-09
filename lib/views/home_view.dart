import 'dart:async';
import 'package:enrutador/controllers/nota_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/permisos.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/map_main.dart';
import 'package:enrutador/views/widgets/card_accout.dart';
import 'package:enrutador/views/widgets/map_widget/map_navigation.dart';
import 'package:enrutador/views/widgets/map_widget/map_sliding.dart';
import 'package:enrutador/views/widgets/search/search_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:app_links/app_links.dart';
import '../controllers/contacto_controller.dart';
import '../models/nota_model.dart';
import '../utilities/uri_fun.dart';
import 'widgets/map_widget/map_alternative.dart';
import 'package:badges/badges.dart' as bd;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool out = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
        builder: (context, provider, child) => SliderDrawer(
            key: provider.sliderDrawerKey,
            animationDuration: 300,
            appBar: Placeholder(),
            sliderOpenSize: 34.w,
            isDraggable: false,
            slider: Container(
                color: ThemaMain.appbar,
                child: Column(children: [
                  SizedBox(height: 10.h),
                  GestureDetector(
                      onTap: () async =>
                          await Navigation.pushNamed(route: "contactos"),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Contactos",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.connect_without_contact,
                                        size: 22.sp, color: ThemaMain.darkGrey)
                                  ])))),
                  if (kDebugMode)
                    GestureDetector(
                        onTap: () async {},
                        child: Card(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.w, vertical: 1.h),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Listas",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Icon(LineIcons.mapMarked,
                                          size: 22.sp, color: ThemaMain.red)
                                    ])))),
                  GestureDetector(
                      onTap: () async =>
                          await Navigation.pushNamed(route: "tipos"),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Tipos",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.type_specimen,
                                        size: 22.sp, color: ThemaMain.primary)
                                  ])))),
                  GestureDetector(
                      onTap: () async =>
                          await Navigation.pushNamed(route: "estatus"),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Estatus",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.contact_emergency,
                                        size: 22.sp, color: ThemaMain.darkBlue)
                                  ])))),
                  GestureDetector(
                      onTap: () async =>
                          await Navigation.pushNamed(route: "navegar"),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Navegar",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(LineIcons.globe,
                                        size: 22.sp, color: ThemaMain.green)
                                  ])))),
                  GestureDetector(
                      onTap: () async =>
                          await Navigation.pushNamed(route: "roles"),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Roles",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(LineIcons.userTag,
                                        size: 22.sp, color: ThemaMain.darkBlue)
                                  ])))),
                  GestureDetector(
                      onTap: () async =>
                          await Navigation.pushNamed(route: "lada"),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Lada",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.perm_phone_msg,
                                        size: 20.sp, color: ThemaMain.pink)
                                  ])))),
                  GestureDetector(
                      onTap: () async =>
                          await Navigation.pushNamed(route: "regionesMapa"),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Regionar",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(LineIcons.layerGroup,
                                        size: 20.sp, color: ThemaMain.primary)
                                  ])))),
                  GestureDetector(
                      onTap: () async => showDialog(
                          context: context,
                          builder: (context) => Dialog(child: CardAccout())),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Perfil",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.person,
                                        size: 20.sp, color: ThemaMain.green)
                                  ]))))
                ])),
            child: Scaffold(
                appBar: AppBar(
                    leading: IconButton(
                        onPressed: () => setState(() {
                              provider.sliderDrawerKey.currentState?.toggle();
                            }),
                        icon: Icon(Icons.menu,
                            color: ThemaMain.darkBlue, size: 20.sp)),
                    toolbarHeight: 6.h,
                    title: Text("Enrutador", style: TextStyle(fontSize: 18.sp)),
                    actions: [
                      if (kDebugMode)
                        IconButton(
                            onPressed: () async {
                              var notado =
                                  await ContactoController.getPersonalizado(
                                      query: "nota IS NOT NULL AND nota != ''",
                                      columns: [
                                    "id",
                                    "nota",
                                    "latitud",
                                    "longitud"
                                  ]);
                              for (var i = 0; i < notado.length; i++) {
                                NotaModel nota = NotaModel(
                                    contactoId: notado[i].id!,
                                    descripcion: notado[i].nota!,
                                    empleadoId: provider.usuario!.empleadoId!,
                                    pendiente: 1,
                                    creado: DateTime.now());
                                await NotasController.insert(nota);
                              }
                            },
                            icon: Icon(Icons.add, color: ThemaMain.darkBlue)),
                      FutureBuilder(
                          future: ContactoController.getCountPendiente(),
                          builder: (context, snapshot) => bd.Badge(
                              showBadge: snapshot.hasData || snapshot.data == 1,
                              badgeStyle:
                                  bd.BadgeStyle(badgeColor: ThemaMain.red),
                              badgeAnimation: bd.BadgeAnimation.slide(),
                              position: bd.BadgePosition.topStart(),
                              badgeContent: Text(snapshot.data.toString(),
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold)),
                              child: IconButton.filledTonal(
                                  iconSize: 22.sp,
                                  onPressed: () async =>
                                      await Navigation.pushNamed(
                                          route: "pendientes"),
                                  icon: Icon(LineIcons.alternateCloudUpload,
                                      color:
                                          snapshot.hasData || snapshot.data == 1
                                              ? ThemaMain.red
                                              : ThemaMain.primary))))
                    ]),
                body: IgnorePointer(
                    ignoring:
                        provider.sliderDrawerKey.currentState?.isDrawerOpen ??
                            false,
                    child: AnimatedOpacity(
                        duration: Durations.medium1,
                        opacity: (provider.sliderDrawerKey.currentState
                                    ?.isDrawerOpen ??
                                false)
                            ? .25
                            : 1,
                        child: PopScope(
                            canPop: false,
                            onPopInvokedWithResult: (didPop, result) async {
                              await Dialogs.showMorph(
                                  title: "Salir",
                                  description: "¿Desea salir de la aplicación?",
                                  loadingTitle: "Cerrando aplicacion",
                                  onAcceptPressed: (context) async {
                                    await SystemNavigator.pop();
                                  });
                            },
                            child: Paginado(provider: provider)))))));
  }
}

class Paginado extends StatefulWidget {
  final MainProvider provider;
  const Paginado({super.key, required this.provider});

  @override
  State<Paginado> createState() => PaginadoState();
}

class PaginadoState extends State<Paginado> {
  final LocationSettings locationSettings = Permisos.location();
  final AppLinks appLinks = AppLinks();
  @override
  void initState() {
    super.initState();
    widget.provider.logeo();
    Permisos.determinePosition();
    Permisos.phone();
    InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          widget.provider.internet = true;
          break;
        case InternetStatus.disconnected:
          widget.provider.internet = false;
          break;
      }
    });

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      widget.provider.local = position;
      if (widget.provider.mapSeguir) {
        widget.provider.animaMap.centerOnPoint(
            LatLng(widget.provider.local?.latitude ?? 0,
                widget.provider.local?.longitude ?? 0),
            duration: Duration(milliseconds: 50));
      }
    });
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    final uriString = await appLinks.getInitialLinkString();
    if (uriString != null) _handleString(uriString);

// Escucha de enlaces cálidos (app abierta)
    appLinks.stringLinkStream.listen(_handleString);
  }

  void _handleString(String url) {
    UriFun.readContentUriSafe(url, widget.provider);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapMain(),
      Align(alignment: Alignment.bottomRight, child: MapNavigation()),
      Align(alignment: Alignment.bottomLeft, child: MapAlternative()),
      if (!widget.provider.descargarZona)
        Align(alignment: Alignment.topLeft, child: SearchWidget()),
      MapSliding()
    ]);
  }
}

/* BottomNavigationBarItem _buildBottomNavigationBarItem(
    IconData icon, String label) {
  return BottomNavigationBarItem(icon: Icon(icon, size: 22.sp), label: label);
} */
