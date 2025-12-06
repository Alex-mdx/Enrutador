import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/permisos.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/map_main.dart';
import 'package:enrutador/views/widgets/map_widget/map_navigation.dart';
import 'package:enrutador/views/widgets/map_widget/map_sliding.dart';
import 'package:enrutador/views/widgets/search/search_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart' as lc;
import 'package:open_location_code/open_location_code.dart';
import 'package:phone_state/phone_state.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:app_links/app_links.dart';
import '../utilities/uri_fun.dart';
import 'widgets/map_widget/map_alternative.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';

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
            animationDuration: 250,
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
                          await Navigation.pushNamed(route: "estatus"),
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
                    title: Text("Enrutador", style: TextStyle(fontSize: 18.sp)),
                    toolbarHeight: 6.h,
                    actions: [
                      OverflowBar(spacing: 1.w, children: [PhoneStateWidget()])
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
                        child: Paginado(provider: provider))))));
  }
}

class PhoneStateWidget extends StatelessWidget {
  const PhoneStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PhoneState>(
        stream: PhoneState.stream,
        builder: (context, snapshot) => AnimatedOpacity(
            opacity:
                snapshot.data?.status == PhoneStateStatus.CALL_INCOMING ? 1 : 0,
            duration: Durations.medium3,
            child: Card(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      AvatarGlow(
                          glowCount: 2,
                          glowColor: ThemaMain.primary,
                          duration: Duration(seconds: 5),
                          glowRadiusFactor: .5.w,
                          startDelay: Duration(seconds: 2),
                          child: RiveAnimatedIcon(
                              riveIcon: RiveIcon.call,
                              strokeWidth: 2.h,
                              height: 4.h,
                              width: 4.h)),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(
                            width: 30.w,
                            child: FutureBuilder(
                                future: ContactoController.buscar(
                                    "${snapshot.data?.number ?? -1}", 2),
                                builder: (context, contacto) => AutoSizeText(
                                    contacto.hasData
                                        ? contacto.data!
                                            .map((e) => e.nombreCompleto)
                                            .toList()
                                            .join(", ")
                                        : "Llamando...\nDesconocido",
                                    maxLines: 2,
                                    minFontSize: 14,
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold))))
                      ])
                    ])))));
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

    location.onLocationChanged.listen((lc.LocationData currentLocation) {
      widget.provider.local = currentLocation;
      if (widget.provider.mapSeguir) {
        widget.provider.animaMap.centerOnPoint(
            LatLng(widget.provider.local?.latitude ?? 0,
                widget.provider.local?.longitude ?? 0),
            duration: Duration(milliseconds: 250));
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
      Align(alignment: Alignment.topLeft, child: SearchWidget()),
      MapSliding()
    ]);
  }
}

/* BottomNavigationBarItem _buildBottomNavigationBarItem(
    IconData icon, String label) {
  return BottomNavigationBarItem(icon: Icon(icon, size: 22.sp), label: label);
} */
