import 'package:enrutador/models/geo_postal_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ListGeoPostal extends StatelessWidget {
  final GeoPostalModel model;
  const ListGeoPostal({super.key, required this.model});

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
              dest: LatLng(model.lat,model.lng));
        },
        dense: true,
        minVerticalPadding: 1,
        leading: Icon(LineIcons.mapSigns, size: 22.sp, color: ThemaMain.yellow),
        contentPadding: EdgeInsets.zero,
        title: Text("${model.adminName2}, ${model.adminName1}, ${model.postalCode}",
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                backgroundColor: ThemaMain.white)),
        subtitle: Text(
            "${model.placeName}, ${model.iso31662}, ${model.countryCode}",
            style:
                TextStyle(fontSize: 15.sp, backgroundColor: ThemaMain.white)));
  }
}
