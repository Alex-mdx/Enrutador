import 'package:enrutador/models/what_3_words_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/utilities/w3w_fun.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ListW3w extends StatefulWidget {
  final What3WordsModel w3w;
  const ListW3w({super.key, required this.w3w});

  @override
  State<ListW3w> createState() => _ListW3wState();
}

class _ListW3wState extends State<ListW3w> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        await W3wFun.wordtocoor(widget.w3w.words);
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      dense: true,
      leading: Stack(alignment: Alignment.center, children: [
        Icon(Icons.circle, size: 24.sp, color: ThemaMain.red),
        Text("///", style: TextStyle(fontSize: 16.sp, color: ThemaMain.second)),
      ]),
      title: Text("///${widget.w3w.words}",
          style: TextStyle(
              backgroundColor: ThemaMain.second,
              fontSize: 16.sp,
              color: ThemaMain.darkBlue)),
      subtitle: Text("${widget.w3w.nearestPlace}, ${widget.w3w.country}",
          style: TextStyle(
              backgroundColor: ThemaMain.second,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: ThemaMain.darkBlue)),
    );
  }
}
