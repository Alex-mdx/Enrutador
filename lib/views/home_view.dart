import 'dart:async';
import 'package:enrutador/controllers/fireController/tip_fire.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/permisos.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/map_main.dart';
import 'package:enrutador/views/widgets/map_widget/map_navigation.dart';
import 'package:enrutador/views/widgets/map_widget/map_sliding.dart';
import 'package:enrutador/views/widgets/search/search_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';
import 'package:app_links/app_links.dart';
import '../utilities/uri_fun.dart';
import 'dialogs/dialog_download.dart';
import 'widgets/extras/side_buttons.dart';
import 'widgets/map_widget/map_alternative.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
        builder: (context, provider, child) => SliderDrawer(
            key: _sliderDrawerKey,
            animationDuration: 300,
            appBar: Placeholder(),
            sliderOpenSize: 35.w,
            isDraggable: false,
            slider: SideButtons(),
            child: Scaffold(
                appBar: AppBar(
                    leading: IconButton(
                        onPressed: () => setState(() {
                              _sliderDrawerKey.currentState?.toggle();
                            }),
                        icon: Icon(Icons.menu,
                            color: ThemaMain.darkBlue, size: 20.sp)),
                    toolbarHeight: 6.h,
                    title: Text(
                        "Enrutador${kDebugMode ? provider.internet : ""}",
                        style: TextStyle(fontSize: 18.sp)),
                    actions: [
                      IconButton.filled(
                          iconSize: 20.sp,
                          onPressed: () async =>
                              await Navigation.pushNamed(route: "tipHome"),
                          icon: Icon(
                              Preferences.tipsReaded.isNotEmpty
                                  ? Icons.notifications_active
                                  : Icons.notifications,
                              color: Preferences.tipsReaded.isNotEmpty
                                  ? ThemaMain.yellow
                                  : ThemaMain.dialogbackground)),
                      IconButton.filledTonal(
                          iconSize: 20.sp,
                          onPressed: () => showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => DialogDownload()),
                          icon: RiveAnimatedIcon(
                              riveIcon: RiveIcon.upload,
                              strokeWidth: 20.sp,
                              enableAbsorbPointer: true,
                              color: ThemaMain.green,
                              width: 20.sp,
                              height: 20.sp)),
                      /* FutureBuilder(
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
                                              : ThemaMain.primary)))) */
                    ]),
                body: IgnorePointer(
                    ignoring:
                        _sliderDrawerKey.currentState?.isDrawerOpen ?? false,
                    child: AnimatedOpacity(
                        duration: Durations.short4,
                        opacity: (_sliderDrawerKey.currentState?.isDrawerOpen ??
                                false)
                            ? .2
                            : 1,
                        child: PopScope(
                            canPop: false,
                            onPopInvokedWithResult: (didPop, result) async {
                              await Dialogs.showMorph(
                                  title: "Salir",
                                  description: "¿Desea salir de la aplicación?",
                                  loadingTitle: "Cerrando aplicacion",
                                  onAcceptPressed: (context) async =>
                                      await SystemNavigator.pop());
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
  Timer? _notificationTimer;
  @override
  void initState() {
    super.initState();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      bool isConnected = false;
      for (var result in results) {
        if ((result == ConnectivityResult.mobile ||
                result == ConnectivityResult.other) &&
            Preferences.redMobile) {
          isConnected = true;
        } else if (result == ConnectivityResult.wifi && Preferences.redWifi) {
          isConnected = true;
        }
      }
      widget.provider.internet = isConnected;
    });
    widget.provider.logeo();
    Permisos.determinePosition();
    Permisos.phone();

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      widget.provider.local = position;
      if (widget.provider.mapSeguir) {
        widget.provider.animaMap.centerOnPoint(
            LatLng(widget.provider.local?.latitude ?? 0,
                widget.provider.local?.longitude ?? 0),
            duration: Duration(milliseconds: 10));
      }
    });
    initDeepLinks();
    if (_notificationTimer != null && _notificationTimer!.isActive) {
      _notificationTimer!.cancel();
      _notificationTimer = null;
    } else {
      _notificationTimer = Timer.periodic(const Duration(minutes: kDebugMode ? 1 : 5),
          (timer) async {
        if (widget.provider.internet) {
          await TipFire.findTips(
              empleadoId: widget.provider.usuario!.empleadoId!.toString(),
              abierto: false);
        }
      });
    }
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
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
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
