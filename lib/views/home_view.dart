import 'dart:async';

import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/map_main.dart';
import 'package:enrutador/views/widgets/map_navigation.dart';
import 'package:enrutador/views/widgets/map_sliding.dart';
import 'package:enrutador/views/widgets/search_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:location/location.dart' as lc;
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:app_links/app_links.dart';

import '../controllers/contacto_controller.dart';
import '../utilities/map_fun.dart';
import '../utilities/uri_fun.dart';
import 'widgets/map_alternative.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
        builder: (context, provider, child) => SliderDrawer(
            key: provider.sliderDrawerKey,
            animationDuration: 350,
            appBar: Placeholder(),
            sliderOpenSize: 30.w,
            isDraggable: false,
            slider: Container(
                color: ThemaMain.appbar,
                child: Column(children: [
                  SizedBox(height: 9.h),
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
                                    Text("Listas",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.format_list_bulleted,
                                        size: 22.sp, color: ThemaMain.red)
                                  ])))),
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
                  Card(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.w, vertical: 1.h),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Estatus",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Icon(Icons.contact_emergency,
                                    size: 22.sp, color: ThemaMain.green)
                              ]))),
                  Card(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.w, vertical: 1.h),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Exportar",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Icon(Icons.send,
                                    size: 20.sp, color: ThemaMain.darkBlue)
                              ])))
                ])),
            child: Scaffold(
                appBar: AppBar(
                    leading: IconButton(
                        onPressed: () =>
                            provider.sliderDrawerKey.currentState?.toggle(),
                        icon: Icon(Icons.menu, size: 20.sp)),
                    title: Text("Enrutador", style: TextStyle(fontSize: 18.sp)),
                    actions: [
                      IconButton(
                          onPressed: () async {
                            await ContactoController.getItems();
                          },
                          icon: Icon(Icons.abc))
                    ],
                    toolbarHeight: 6.h),
                body: Paginado(provider: provider))));
  }
}

class Paginado extends StatefulWidget {
  final MainProvider provider;
  const Paginado({super.key, required this.provider});

  @override
  State<Paginado> createState() => PaginadoState();
}

class PaginadoState extends State<Paginado> {
  lc.Location location = lc.Location();
  final AppLinks appLinks = AppLinks();
  @override
  void initState() {
    super.initState();
    widget.provider.logeo();
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

    location.onLocationChanged.listen((lc.LocationData currentLocation) {
      widget.provider.local = currentLocation;
    });
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    final uri = await appLinks.getInitialLink();
    if (uri != null) _handleUri(uri);

// Escucha de enlaces cálidos (app abierta)
    appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    switch (uri.scheme) {
      case 'com.example.app':
        // Ejemplo: com.example.app://?path=/storage/ejemplo.json
        final filePath = uri.queryParameters['path'];
        if (filePath != null) {
          debugPrint("link: $filePath");
        }
        break;
      case 'geo':
        final filePath = uri.query;
        if (filePath.contains("q=")) {
          showToast("Buscando ubicacion...");
          Future.delayed(
              Duration(seconds: kDebugMode ? 4 : 2),
              () async => await MapFun.getUri(
                  provider: widget.provider, uri: filePath));
        }
        break;
      default:
        UriFun.jsonUri(uri);
        debugPrint("link other: ${uri.data}\n${uri.query}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapMain(),
      Align(alignment: Alignment.bottomRight, child: MapNavigation()),
      Align(alignment: Alignment.bottomLeft, child: MapAlternative()),
      Align(alignment: Alignment.topLeft, child: SearchWidget()),
      MapSliding()
    ]);
  }
}

/* BottomNavigationBarItem _buildBottomNavigationBarItem(
    IconData icon, String label) {
  return BottomNavigationBarItem(icon: Icon(icon, size: 22.sp), label: label);
} */
