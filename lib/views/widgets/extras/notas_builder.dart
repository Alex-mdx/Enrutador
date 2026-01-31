import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

class NotasBuilder extends StatefulWidget {
  const NotasBuilder({super.key});

  @override
  State<NotasBuilder> createState() => _NotasBuilderState();
}

class _NotasBuilderState extends State<NotasBuilder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 6.h,
            title:
                Text("Historial de notas", style: TextStyle(fontSize: 18.sp))),
        body: SafeArea(
            child: Column(children: [
          Center(
              child: LoadingAnimationWidget.stretchedDots(
                  color: ThemaMain.darkBlue, size: 32.sp))
        ])));
  }
}
