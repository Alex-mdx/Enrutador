import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MapAlternative extends StatefulWidget {
  const MapAlternative({super.key});

  @override
  State<MapAlternative> createState() => _MapAlternativeState();
}

class _MapAlternativeState extends State<MapAlternative> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.only(right: 2.w, bottom: 4.h),
        child: Column(spacing: .5.h, mainAxisSize: MainAxisSize.min, children: [
          IconButton.filledTonal(
              iconSize: 24.sp,
              onPressed: () async {
                provider.mapaReal = !provider.mapaReal;
              },
              icon: Icon(Icons.map, color: ThemaMain.primary))
        ]));
  }
}
