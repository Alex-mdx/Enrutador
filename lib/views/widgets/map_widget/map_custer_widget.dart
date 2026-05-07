import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ClusterMarkerWidget extends StatelessWidget {
  final int count;

  const ClusterMarkerWidget({super.key, required this.count});

  Color _colorForCount(int count) {
    switch (count) {
      case < 5:
        return ThemaMain.primary;
      case < 50:
        return ThemaMain.green;
      case < 150:
        return ThemaMain.yellow;
      case < 300:
        return ThemaMain.red;
      case < 500:
        return ThemaMain.pink;
      default:
        return ThemaMain.darkBlue;
    }
  }

  double _sizeForCount(int count) {
    if (count < 10) return 40;
    if (count < 50) return 50;
    return 60;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForCount(count);
    final size = _sizeForCount(count);

    // RepaintBoundary evita re-renders innecesarios del cluster
    return RepaintBoundary(
        child: SizedBox(
            width: size,
            height: size,
            child: Stack(alignment: Alignment.center, children: [
              // Halo exterior semi-transparente
              Container(
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      shape: BoxShape.circle)),
              // Círculo principal
              Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1)
                      ]),
                  child: Center(
                      child: Text(count > 999 ? '999+' : '$count',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp))))
            ])));
  }
}
