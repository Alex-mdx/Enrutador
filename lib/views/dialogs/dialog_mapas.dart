import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/views/widgets/list_maps_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sizer/sizer.dart';

class DialogMapas extends StatelessWidget {
  final String words;
  final LatLng coordenadas;
  const DialogMapas({super.key, required this.words,required this.coordenadas});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Seleccione algun mapa",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      FutureBuilder(
          future: MapLauncher.installedMaps,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.isEmpty
                  ? Center(
                      child: Text(
                          "No tienes ninguna aplicacion de navegacion disponible",
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold)))
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        AvailableMap mapas = snapshot.data![index];
                        return Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: ListMapsWidget(
                                mapas: mapas,
                                latitud: coordenadas.latitude,
                                longitud: coordenadas.longitude,word: words,
                                launch: (p0) async {
                                  Navigation.pop();
                                }));
                      });
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("Error: ${snapshot.error}",
                      style: TextStyle(fontSize: 14.sp)));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          })
    ]));
  }
}
