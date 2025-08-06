import 'dart:async';


import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/views/map_main.dart';
import 'package:enrutador/views/widgets/map_navigation.dart';
import 'package:enrutador/views/widgets/map_sliding.dart';
import 'package:enrutador/views/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:location/location.dart' as lc;
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sizer/sizer.dart';

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
  var recibir = ReceiveSharingIntent;
  lc.Location location = lc.Location();
  String? _sharedJsonPath;
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
    _listenForSharedFiles();
  }

  void _listenForSharedFiles() {
    // Para Android/iOS cuando la app está abierta
    ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isNotEmpty && files.first.path.endsWith('.json')) {
        setState(() {
          _sharedJsonPath = files.first.path;
        });
        _processJsonFile(_sharedJsonPath!);
      }
    });

    // Para Android/iOS cuando la app está cerrada/inactiva
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty && files.first.path.endsWith('.json')) {
        setState(() {
          _sharedJsonPath = files.first.path;
        });
        _processJsonFile(_sharedJsonPath!);
      }
    });
  }

  void _processJsonFile(String path) {
    print("Archivo JSON recibido: $path");
    // Aquí lees el archivo y lo procesas
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
