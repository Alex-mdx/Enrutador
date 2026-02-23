import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';

class SlideGeneral extends StatefulWidget {
  final int id;
  final Widget model;
  final Function()? delete;
  final bool? ifDelete;
  final Function()? pendiente;
  final bool? ifPendiente;
  final Function()? directo;
  final bool? ifDirecto;
  const SlideGeneral(
      {super.key,
      required this.id,
      required this.model,
      this.delete,
      this.ifDelete = true,
      this.pendiente,
      this.ifPendiente = true,
      this.directo,
      this.ifDirecto = true});

  @override
  State<SlideGeneral> createState() => _SlideGeneralState();
}

class _SlideGeneralState extends State<SlideGeneral> {
  double right = 18.sp;
  double left = 18.sp;
  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: ValueKey(widget.id),
        startActionPane: (widget.delete != null || widget.ifDelete!)
            ? ActionPane(motion: ScrollMotion(), children: [
                SlidableAction(
                    spacing: 1.h,
                    onPressed: (context) async => widget.delete!(),
                    backgroundColor: ThemaMain.red,
                    foregroundColor: Colors.white,
                    icon: Icons.cleaning_services,
                    label: 'Eliminar')
              ])
            : null,
        endActionPane: ((widget.directo != null && widget.ifDirecto!) ||
                (widget.pendiente != null && widget.ifPendiente!))
            ? ActionPane(motion: ScrollMotion(), children: [
                if (widget.pendiente != null && widget.ifPendiente!)
                  SlidableAction(
                      spacing: 1.h,
                      onPressed: (context) async => await widget.pendiente!(),
                      backgroundColor: ThemaMain.primary,
                      foregroundColor: ThemaMain.background,
                      icon: Icons.youtube_searched_for,
                      label: 'Pendiente'),
                if (widget.directo != null && widget.ifDirecto!)
                  SlidableAction(
                      spacing: 1.h,
                      onPressed: (context) => widget.directo!(),
                      backgroundColor: ThemaMain.green,
                      foregroundColor: ThemaMain.background,
                      icon: Icons.cloud_done,
                      label: 'Guardar')
              ])
            : null,
        child: Stack(alignment: Alignment.center, children: [
          widget.model,
          if (widget.delete != null && widget.ifDelete!)
            Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.keyboard_arrow_left_rounded,
                    size: left, color: ThemaMain.red)),
          if ((widget.directo != null && widget.ifDirecto!) ||
              (widget.pendiente != null && widget.ifPendiente!))
            Align(
                alignment: Alignment.centerRight,
                child: ((widget.directo != null && widget.ifDirecto!) &&
                        (widget.pendiente != null && widget.ifPendiente!))
                    ? Icon(Icons.keyboard_double_arrow_right,
                        size: right, color: ThemaMain.green)
                    : widget.pendiente != null && widget.ifPendiente!
                        ? Icon(Icons.keyboard_arrow_right,
                            size: right, color: ThemaMain.primary)
                        : Icon(Icons.keyboard_arrow_right_rounded,
                            size: right, color: ThemaMain.green))
        ]));
  }
}
