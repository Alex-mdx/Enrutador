import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';

class SlideGeneral extends StatefulWidget {
  final int id;
  final Widget model;
  final Function() delete;
  final Function() pendiente;
  final Function() directo;
  const SlideGeneral({
    super.key,
    required this.id,
    required this.model,
    required this.delete,
    required this.pendiente,
    required this.directo,
  });

  @override
  State<SlideGeneral> createState() => _SlideGeneralState();
}

class _SlideGeneralState extends State<SlideGeneral> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: ValueKey(widget.id),
        startActionPane: ActionPane(motion: ScrollMotion(), children: [
          SlidableAction(
              spacing: 1.h,
              onPressed: (context) async => widget.delete(),
              backgroundColor: ThemaMain.red,
              foregroundColor: Colors.white,
              icon: Icons.cleaning_services,
              label: 'Eliminar')
        ]),
        endActionPane: ActionPane(motion: ScrollMotion(), children: [
          SlidableAction(
              spacing: 1.h,
              onPressed: (context) async => await widget.pendiente(),
              backgroundColor: ThemaMain.primary,
              foregroundColor: ThemaMain.background,
              icon: Icons.youtube_searched_for,
              label: 'Pendiente'),
          SlidableAction(
              spacing: 1.h,
              onPressed: (context) => widget.directo(),
              backgroundColor: ThemaMain.green,
              foregroundColor: ThemaMain.background,
              icon: Icons.cloud_done,
              label: 'Guardar')
        ]),
        child: Stack(alignment: Alignment.center, children: [
          widget.model,
          Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.keyboard_arrow_left_rounded,
                  size: 19.sp, color: ThemaMain.red)),
          Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.keyboard_double_arrow_right_rounded,
                  size: 19.sp, color: ThemaMain.green))
        ]));
  }
}
