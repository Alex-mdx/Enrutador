import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:enrutador/models/geo_names_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ListGeoName extends StatelessWidget {
  final GeoNamesModel model;
  const ListGeoName({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return ListTile(
        onTap: () async {
          provider.mapSeguir = false;
          await provider.animaMap.animateTo(
              duration: Duration(seconds: 1),
              rotation: 0,
              zoom: 15,
              dest: LatLng(double.parse(model.lat), double.parse(model.lng)));
        },
        dense: true,
        minVerticalPadding: 1,
        leading: Icon(Icons.location_on, size: 22.sp, color: ThemaMain.green),
        contentPadding: EdgeInsets.zero,
        title: Text("${model.name}, ${model.adminName1}",
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                backgroundColor: ThemaMain.white)),
        subtitle: Text(
            "${model.toponymName}, ${model.countryName}, ${model.countryCode}",
            style:
                TextStyle(fontSize: 15.sp, backgroundColor: ThemaMain.white)));
  }
}
