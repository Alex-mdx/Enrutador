import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../utilities/theme/theme_app.dart';

class RegionesMapa extends StatefulWidget {
  const RegionesMapa({super.key});

  @override
  State<RegionesMapa> createState() => _RegionesMapaState();
}

class _RegionesMapaState extends State<RegionesMapa> {
  // Future para obtener todos los stores
  Future<List<({String storeName, int tiles, double sizeMB})>>
      _getStores() async {
    try {
      final storesAvailable = await FMTCRoot.stats.storesAvailable;

      List<({String storeName, int tiles, double sizeMB})> storesList = [];

      for (var store in storesAvailable) {
        final stats = await FMTCStore(store.storeName).stats.all;
        storesList.add((
          storeName: store.storeName,
          tiles: stats.length,
          sizeMB: stats.size / (1024 * 1024)
        ));
      }

      return storesList;
    } catch (e) {
      debugPrint('Error al obtener stores: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text('Regiones de Mapas', style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton.filledTonal(
                  onPressed: () => Dialogs.showMorph(
                      title: "Descargar Zonas",
                      description:
                          "¿Deseas descargar zonas de mapa para usarlo sin conexión?",
                      loadingTitle: "Descargando Zonas",
                      onAcceptPressed: (context) {
                        provider.descargarZona = true;
                        Navigation.pop();
                      }),
                  icon: Icon(LineIcons.fileDownload,
                      size: 22.sp, color: Colors.green))
            ]),
        body: FutureBuilder(
            future: _getStores(),
            builder: (context, snapshot) {
              // Estado de error
              if (snapshot.hasError) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.error_outline, size: 60, color: ThemaMain.red),
                      SizedBox(height: 2.h),
                      Text('Error al cargar mapas',
                          style: TextStyle(
                              color: ThemaMain.red,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 1.h),
                      Text('${snapshot.error}',
                          style: TextStyle(
                              color: ThemaMain.white.withAlpha(128),
                              fontSize: 12.sp),
                          textAlign: TextAlign.center)
                    ]));
              }

              final stores = snapshot.data ?? [];

              // Estado vacío
              if (stores.isEmpty) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(LineIcons.map,
                          size: 80, color: ThemaMain.white.withAlpha(128)),
                      SizedBox(height: 2.h),
                      Text('No hay mapas descargados',
                          style: TextStyle(
                              color: ThemaMain.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 1.h),
                      Text('Presiona el botón de descarga para agregar mapas',
                          style: TextStyle(
                              color: ThemaMain.white.withAlpha(128),
                              fontSize: 13.sp),
                          textAlign: TextAlign.center)
                    ]));
              }

              // Lista de stores
              return ListView.builder(
                  padding: EdgeInsets.all(2.w),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];

                    return ListTile(
                        tileColor: ThemaMain.darkBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                        leading: Icon(LineIcons.thLarge,
                            color: ThemaMain.primary, size: 28.sp),
                        title: Text(store.storeName,
                            style: TextStyle(
                                color: ThemaMain.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.grid_on,
                                    size: 16.sp,
                                    color: ThemaMain.white.withAlpha(128)),
                                Text(' ${store.tiles} tiles',
                                    style: TextStyle(
                                        color: ThemaMain.white.withAlpha(128),
                                        fontSize: 14.sp)),
                                SizedBox(width: 3.w),
                                Icon(Icons.storage,
                                    size: 16.sp,
                                    color: ThemaMain.white.withAlpha(128)),
                                Text(' ${store.sizeMB.toStringAsFixed(2)} MB',
                                    style: TextStyle(
                                        color: ThemaMain.white.withAlpha(128),
                                        fontSize: 14.sp))
                              ])
                            ]),
                        trailing: IconButton(
                            onPressed: () async => await Dialogs.showMorph(
                                title: "Eliminar Mapa",
                                description:
                                    "¿Estás seguro de eliminar el mapa '${store.storeName}'? Esta acción no se puede deshacer.",
                                loadingTitle: "Eliminar",
                                onAcceptPressed: (context) async {
                                  try {
                                    await FMTCStore(store.storeName)
                                        .manage
                                        .delete();
                                    setState(() {});
                                    showToast("Mapa Eliminado");
                                  } catch (e) {
                                    showToast("error: $e");
                                  }
                                }),
                            icon: Icon(Icons.delete_outline,
                                color: ThemaMain.red, size: 22.sp)));
                  });
            }));
  }
}
