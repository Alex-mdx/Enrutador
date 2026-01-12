import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_app.dart';
import '../card_phone.dart';

class MapNavigation extends StatefulWidget {
  const MapNavigation({super.key});

  @override
  State<MapNavigation> createState() => _MapNavigationState();
}

class _MapNavigationState extends State<MapNavigation> {
  bool container = false;
  bool followFix = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return AnimatedPadding(
        padding: EdgeInsets.only(
            right: 2.w,
            bottom: provider.selectRefencia != null
                ? 6.h
                : provider.cargaDatos
                    ? 4.h
                    : 2.h),
        duration: Duration(seconds: 1),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: .5.h,
            mainAxisSize: MainAxisSize.min,
            children: [
              PhoneStateWidget(),
              if (provider.descargarZona)
                Column(spacing: .2.h, children: [
                  IconButton.filled(
                      onPressed: () {
                        if (provider.zona.isEmpty) {
                          Dialogs.showMorph(
                              title: "Cancelar proceso",
                              description:
                                  "Se cancelara el proceso de descarga de la zona",
                              loadingTitle: "Cancelar",
                              onAcceptPressed: (context) {
                                provider.descargarZona = false;
                              });
                        } else {
                          provider.zona.clear();
                        }
                      },
                      icon: Icon(Icons.cancel,
                          color: provider.zona.isEmpty
                              ? ThemaMain.red
                              : ThemaMain.pink,
                          size: 24.sp)),
                  if (provider.marker?.point != null)
                    Container(
                        decoration: BoxDecoration(
                            color: ThemaMain.darkBlue,
                            borderRadius: BorderRadius.circular(borderRadius)),
                        child: Column(children: [
                          Text("${provider.zona.length}/4",
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: ThemaMain.background)),
                          Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 0,
                              children: [
                                IconButton(
                                    iconSize: 22.sp,
                                    onPressed: () => (provider.zona.length < 4)
                                        ? provider.zona
                                            .add(provider.marker!.point)
                                        : showToast(
                                            "Se han marcado los 4 puntos permitidos"),
                                    icon: Icon(Icons.add_circle,
                                        color: ThemaMain.green)),
                                IconButton(
                                    iconSize: 22.sp,
                                    onPressed: () => provider.zona.removeLast(),
                                    icon: Icon(Icons.exposure_minus_1,
                                        color: ThemaMain.yellow))
                              ])
                        ])),
                  if (provider.zona.length == 4)
                    IconButton.filled(
                        onPressed: () async {
                          bool descargar = false;
                          CameraFit camara = CameraFit.coordinates(
                              coordinates: provider.zona,
                              maxZoom: 18,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 10.h));
                          await provider.animaMap
                              .animatedFitCamera(cameraFit: camara);

                          // Mostrar diálogo de confirmación
                          await Dialogs.showMorph(
                              title: "Descargar zona",
                              description:
                                  "Se va a descargar la zona remarcada para usar el mapa sin conexión",
                              loadingTitle: "Aceptar",
                              onAcceptPressed: (context) {
                                descargar = true;
                              });

                          if (descargar) {
                            // Iniciar descarga con parámetros personalizables
                            _iniciarDescargaRegion(context, provider,
                                minZoom: 8,
                                maxZoom: 18,
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                storeName: 'OSM');
                          }
                        },
                        icon: Icon(Icons.save_rounded,
                            size: 26.sp, color: ThemaMain.background))
                ]),
              if (provider.contacto != null)
                IconButton.filled(
                    iconSize: 24.sp,
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(ThemaMain.primary)),
                    onPressed: () async {
                      provider.mapSeguir = false;
                      container = !container;
                      if (container) {
                        CameraFit camara = CameraFit.bounds(
                            maxZoom: 19,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            bounds: LatLngBounds(
                                LatLng(provider.local?.latitude ?? -1,
                                    provider.local?.longitude ?? -1),
                                LatLng(provider.contacto!.latitud,
                                    provider.contacto!.longitud)));
                        await provider.animaMap
                            .animatedFitCamera(cameraFit: camara);
                      } else {
                        await provider.animaMap.centerOnPoint(
                            LatLng(provider.contacto!.latitud,
                                provider.contacto!.longitud),
                            zoom: 18);
                      }
                    },
                    icon: Icon(
                        container
                            ? Icons.border_outer_rounded
                            : Icons.border_inner_rounded,
                        color: ThemaMain.white)),
              IconButton.filled(
                  iconSize: 26.sp,
                  onPressed: () async {
                    if (provider.mapSeguir) {
                      setState(() {
                        followFix = true;
                      });

                      if (followFix) {
                        await provider.animaMap.centerOnPoint(
                            LatLng(provider.local!.latitude,
                                provider.local!.longitude),
                            zoom: 18);
                      }
                    } else {
                      followFix = false;
                      
                      provider.animaMap.animatedRotateReset();
                      await provider.animaMap.centerOnPoint(LatLng(
                          provider.local!.latitude, provider.local!.longitude));
                      provider.mapSeguir = true;
                    }
                  },
                  icon: Icon(
                      provider.mapSeguir
                          ? followFix
                              ? Icons.my_location_rounded
                              : Icons.location_searching_rounded
                          : Icons.location_disabled_rounded,
                      color: ThemaMain.white))
            ]));
  }

  // Método para iniciar la descarga de la región
  // Parámetros:
  // - context: BuildContext para mostrar diálogos
  // - provider: MainProvider con la zona a descargar
  // - minZoom: Nivel de zoom mínimo (por defecto 8)
  // - maxZoom: Nivel de zoom máximo (por defecto 18)
  // - urlTemplate: URL del proveedor de tiles
  // - storeName: Nombre del store donde se guardarán los tiles
  void _iniciarDescargaRegion(BuildContext context, MainProvider provider,
      {int minZoom = 8,
      int maxZoom = 18,
      required String urlTemplate,
      required String storeName}) async {
    try {
      // Verificar si el store existe, si no, crearlo
      final storeExists = await FMTCStore(storeName).manage.ready;

      if (!storeExists) {
        // Crear el store si no existe
        await FMTCStore(storeName).manage.create();
        showToast('Store "$storeName" creado exitosamente');
      }

      // Crear la región a descargar
      final region = CustomPolygonRegion(provider.zona);
      final downloadableRegion = region.toDownloadable(
          minZoom: minZoom,
          maxZoom: maxZoom,
          options: TileLayer(
              urlTemplate: urlTemplate,
              userAgentPackageName: 'com.example.enrutador'));

      // Iniciar la descarga en foreground usando el store especificado
      final (:downloadProgress, :tileEvents) = FMTCStore(storeName)
          .download
          .startForeground(region: downloadableRegion);

      // Mostrar diálogo con progreso
      if (context.mounted) {
        await _mostrarDialogoProgreso(
            context, downloadProgress, tileEvents, provider, storeName);
      }
    } catch (e) {
      // Manejar errores
      if (context.mounted) {
        showToast('Error al iniciar descarga: $e');
      }
      debugPrint('Error en _iniciarDescargaRegion: $e');
    }
  }

  // Método para mostrar el diálogo de progreso
  Future<void> _mostrarDialogoProgreso(
      BuildContext context,
      Stream<DownloadProgress> downloadProgress,
      Stream<TileEvent> tileEvents,
      MainProvider provider,
      String storeName) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StreamBuilder<DownloadProgress>(
              stream: downloadProgress,
              builder: (context, snapshot) {
                final progress = snapshot.data;

                // Calcular porcentaje y tiles usando las propiedades correctas
                final int totalTiles = progress?.maxTilesCount ?? 0;
                final int tilesDescargados = progress?.attemptedTilesCount ?? 0;
                final int tilesExitosos = progress?.flushedTilesCount ?? 0;
                final double porcentaje = progress?.percentageProgress ?? 0;
                final int tilesFaltantes = progress?.remainingTilesCount ?? 0;
                final int tilesFallidos = progress?.failedTilesCount ?? 0;

                // Verificar si la descarga ha terminado
                final bool descargaCompleta =
                    tilesFaltantes == 0 && totalTiles > 0;

                if (descargaCompleta) {
                  // Cerrar el diálogo automáticamente cuando termine
                  Future.delayed(Duration(milliseconds: 500), () {
                    if (dialogContext.mounted) {
                      provider.descargarZona = false;
                      provider.zona.clear();
                      showToast(
                          "Descarga completada: $tilesExitosos tiles descargados",
                          duration: Duration(seconds: 3));
                      Navigation.pop();
                    }
                  });
                }

                return AlertDialog(
                    backgroundColor: ThemaMain.darkBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius)),
                    title: Text('Descargando Mapa',
                        style: TextStyle(
                            color: ThemaMain.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold)),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      // Indicador de progreso circular
                      SizedBox(
                          height: 100,
                          width: 100,
                          child: Stack(alignment: Alignment.center, children: [
                            CircularProgressIndicator(
                                value: totalTiles > 0
                                    ? tilesDescargados / totalTiles
                                    : null,
                                strokeWidth: 8,
                                backgroundColor:
                                    ThemaMain.background.withAlpha(128),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    descargaCompleta
                                        ? ThemaMain.green
                                        : ThemaMain.primary)),
                            Text('${porcentaje.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    color: ThemaMain.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold))
                          ])),
                      SizedBox(height: 2.h),

                      // Información de tiles
                      Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                              color: ThemaMain.background.withAlpha(90),
                              borderRadius:
                                  BorderRadius.circular(borderRadius / 2)),
                          child: Column(children: [
                            _buildInfoRow('Tiles descargados:',
                                '$tilesDescargados / $totalTiles'),
                            SizedBox(height: 1.h),
                            _buildInfoRow(
                                'Tiles restantes:', '$tilesFaltantes'),
                            if (tilesFallidos > 0) ...[
                              SizedBox(height: 1.h),
                              _buildInfoRow('Tiles fallidos:', '$tilesFallidos',
                                  color: ThemaMain.red)
                            ]
                          ]))
                    ]),
                    actions: [
                      if (!descargaCompleta)
                        TextButton(
                            onPressed: () {
                              // Cancelar la descarga usando el store correcto
                              FMTCStore(storeName).download.cancel();
                              Navigator.of(dialogContext).pop();
                              provider.descargarZona = false;
                              provider.zona.clear();
                              showToast('Descarga cancelada');
                            },
                            child: Text('Cancelar',
                                style: TextStyle(
                                    color: ThemaMain.red, fontSize: 14.sp)))
                    ]);
              });
        });
  }

  // Widget helper para mostrar filas de información
  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              color: ThemaMain.white.withAlpha(178), fontSize: 12.sp)),
      Text(value,
          style: TextStyle(
              color: color ?? ThemaMain.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold))
    ]);
  }
}
