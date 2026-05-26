import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class DialogMapLite extends StatefulWidget {
  final List<LatLng> latlongPrev;
  final Function(List<LatLng>?) onPress;
  const DialogMapLite(
      {super.key, required this.latlongPrev, required this.onPress});

  @override
  State<DialogMapLite> createState() => _DialogMapLiteState();
}

class _DialogMapLiteState extends State<DialogMapLite> {
  late List<LatLng> latLongs;
  LatLng? currentPoint;
  @override
  void initState() {
    latLongs = widget.latlongPrev;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(title: Text("Ubicación", style: TextStyle(fontSize: 16.sp))),
      SizedBox(
          height: 50.h,
          child: FlutterMap(
              options: MapOptions(
                  initialCameraFit: latLongs.isNotEmpty
                      ? CameraFit.coordinates(
                          coordinates: latLongs,
                          maxZoom: 18,
                          minZoom: 10,
                          padding: EdgeInsets.all(15.sp))
                      : null,
                  onTap: (tapPosition, point) => MapFun.touch(
                      provider: provider,
                      lat: point.latitude,
                      lng: point.longitude),
                  keepAlive: true,
                  initialZoom: 16,
                  minZoom: 10,
                  maxZoom: 20,
                  initialCenter: latLongs.isNotEmpty
                      ? latLongs.first
                      : LatLng(provider.local?.latitude ?? 0,
                          provider.local?.longitude ?? 0)),
              children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.enrutador'),
                PolylineLayer(polylines: [
                  if (latLongs.isNotEmpty)
                    Polyline(
                        points: [
                          ...latLongs,
                          if (latLongs.length >= 3) latLongs.first
                        ],
                        color: ThemaMain.primary,
                        strokeWidth: 7.sp,
                        borderColor: ThemaMain.darkBlue)
                ]),
                AnimatedMarkerLayer(
                    markers: latLongs
                        .map((e) => AnimatedMarker(
                            point: e,
                            builder: (context, animation) => InkWell(
                                onTap: () {
                                  setState(() {
                                    currentPoint = e;
                                  });
                                },
                                child: Icon(Icons.circle,
                                    size: currentPoint == e ? 17.sp : 15.sp,
                                    color: currentPoint == e
                                        ? ThemaMain.green
                                        : ThemaMain.darkBlue))))
                        .toList()),
                if (provider.marker != null)
                  AnimatedMarkerLayer(
                      alignment: Alignment.center, markers: [provider.marker!]),
              ])),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        if (provider.marker != null)
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  latLongs.add(provider.marker!.point);
                  provider.marker = null;
                });
              },
              icon: Icon(Icons.add, size: 18.sp, color: ThemaMain.green),
              label: Text("Agregar", style: TextStyle(fontSize: 15.sp))),
        if (currentPoint != null)
          ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  latLongs.remove(currentPoint);
                  currentPoint = null;
                });
              },
              icon: Icon(Icons.remove, size: 18.sp, color: ThemaMain.red),
              label: Text("Remover", style: TextStyle(fontSize: 15.sp))),
        ElevatedButton.icon(
            onPressed: () {
              widget.onPress(latLongs);
              Navigator.pop(context);
            },
            icon: Icon(Icons.check, size: 20.sp, color: ThemaMain.primary),
            label: Text("Ingresar",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)))
      ])
    ]));
  }
}
