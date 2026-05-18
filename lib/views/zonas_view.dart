import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ZonasView extends StatefulWidget {
  const ZonasView({super.key});

  @override
  State<ZonasView> createState() => _ZonasViewState();
}

class _ZonasViewState extends State<ZonasView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Zonas",style: TextStyle(fontSize: 18.sp))
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(child: Center(child: Text("Zonas"))),
        ));
  }
}