import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/usuario_model.dart';
import '../../../utilities/theme/theme_app.dart';

class CardChildren extends StatefulWidget {
  final UsuarioModel e;
  final double width;
  final Function() onTap;
  final double fontSize;
  final Color? card;
  final double elevation;
  const CardChildren({super.key, required this.e, required this.width, required this.onTap, required this.fontSize, required this.card, required this.elevation});

  @override
  State<CardChildren> createState() => _CardChildrenState();
}

class _CardChildrenState extends State<CardChildren> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.width,
        child: Tooltip(
            message: widget.e.nombre ?? '',
            child: InkWell(
                onTap: () => widget.onTap(),
                borderRadius: BorderRadius.circular(borderRadius),
                child: Card(
                    elevation: widget.elevation,
                    color: widget.card,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: .5.w, vertical: .2.h),
                        child: Text(widget.e.nombre!,
                            style: TextStyle(fontSize: widget.fontSize),
                            overflow: TextOverflow.ellipsis))))));
  }
}