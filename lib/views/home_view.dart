import 'dart:async';

import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/views/map_main.dart';
import 'package:enrutador/views/widgets/map_navigation.dart';
import 'package:enrutador/views/widgets/map_sliding.dart';
import 'package:enrutador/views/widgets/search_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:location/location.dart' as lc;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:app_links/app_links.dart';

import '../utilities/map_fun.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Enrutador", style: TextStyle(fontSize: 18.sp)),
            toolbarHeight: 6.h),
        body: Consumer<MainProvider>(
            builder: (context, provider, child) =>
                Paginado(provider: provider)));
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
        if (filePath != null) debugPrint("link: $filePath");
        break;
      case 'geo':
        final filePath = uri.query;
        if (filePath.contains("q=")) {
          Future.delayed(
        Duration(seconds: kDebugMode ?  4:1),() async => await MapFun.getUri(provider: widget.provider, uri: filePath));
          
        }
        break;
      default:
        debugPrint("link: ${uri.query}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapMain(),
      Align(alignment: Alignment.bottomRight, child: MapNavigation()),
      Align(alignment: Alignment.topLeft, child: SearchWidget()),
      MapSliding()
    ]);
  }
}

BottomNavigationBarItem _buildBottomNavigationBarItem(
    IconData icon, String label) {
  return BottomNavigationBarItem(icon: Icon(icon, size: 22.sp), label: label);
}
