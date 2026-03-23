import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../../utilities/theme/theme_color.dart';

class PaginadorGroupedWidget extends StatefulWidget {
  final int max;
  final int length;
  final int maxLenght;
  final Function(int) send;
  final GroupedItemScrollController? itemScrollController;
  const PaginadorGroupedWidget(
      {super.key,
      required this.max,
      required this.length,
      this.maxLenght = 100,
      required this.send,
      required this.itemScrollController});

  @override
  State<PaginadorGroupedWidget> createState() => _PaginadorGroupedWidgetState();
}

class _PaginadorGroupedWidgetState extends State<PaginadorGroupedWidget> {
  int index = 1;
  @override
  Widget build(BuildContext context) {
    var max = (((widget.length >= widget.maxLenght
                              ? (widget.max)
                              : widget.length) ==
                          0
                      ? 1
                      : (widget.length >= widget.maxLenght
                          ? (widget.max)
                          : index * widget.maxLenght)) /
                  widget.maxLenght)
              .ceil();
          return Column(children: [
            Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.itemScrollController != null)
                    IconButton.filledTonal(
                        iconSize: 19.sp,
                        onPressed: () async =>
                            await widget.itemScrollController!.scrollTo(
                                index: 0,
                                duration: Duration(seconds: 1),
                                curve: Curves.easeInOut),
                        icon: Icon(LineIcons.arrowCircleUp,
                            color: ThemaMain.primary)),
                  IconButton.filledTonal(
                      iconSize: 19.sp,
                      onPressed: () async {
                        if (index != 1) {
                          index = 1;
                          debugPrint("$index");
                          await widget.send(index);
                        } else {
                          showToast("Este es el inicio de la pagina");
                        }
                      },
                      icon: Icon(LineIcons.angleDoubleLeft,
                          color: ThemaMain.green)),
                  IconButton.filledTonal(
                      iconSize: 19.sp,
                      onPressed: () async {
                        if (index != 1) {
                          if (index > 1) {
                            index--;
                          }
                          debugPrint("$index");
                          await widget.send(index);
                        } else {
                          showToast("Este es el inicio de la pagina");
                        }
                      },
                      icon: Icon(LineIcons.angleLeft, color: ThemaMain.green)),
                  Text("$index - $max",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  IconButton.filledTonal(
                      iconSize: 19.sp,
                      onPressed: () async {
                        if (index != max) {
                          if (index < max) {
                            index++;
                          }
                          debugPrint("$index");
                          await widget.send(index);
                        } else {
                          showToast("Esta es la ultima pagina");
                        }
                      },
                      icon: Icon(LineIcons.angleRight, color: ThemaMain.green)),
                  IconButton.filledTonal(
                      iconSize: 19.sp,
                      onPressed: () async {
                        if (index != max) {
                          index = max;
                          debugPrint("$index");
                          await widget.send(index);
                        } else {
                          showToast("Esta es la ultima pagina");
                        }
                      },
                      icon: Icon(LineIcons.angleDoubleRight,
                          color: ThemaMain.green)),
                  if (widget.itemScrollController != null)
                    IconButton.filledTonal(
                        iconSize: 19.sp,
                        onPressed: () async =>
                            await widget.itemScrollController!.scrollTo(
                                index: widget.length - 1,
                                duration: Duration(seconds: 1),
                                curve: Curves.easeInOut),
                        icon: Icon(LineIcons.arrowCircleDown,
                            color: ThemaMain.primary))
                ]),
            LinearProgressIndicator(
                color: ThemaMain.primary,
                value: (index == 0 ? 1 : index / max),
                minHeight: .7.h)
          ]);
  }
}
