import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool press = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.sp),
      child: AnimatedContainer(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(4, 4), // Posición de la sombra (x, y)
              ),
            ],
          ),
          width: press ? 95.w : 28.sp,
          duration: Durations.medium3,
          child: press
              ? TextFormField(
                  style: TextStyle(fontSize: 18.sp),
                  decoration: InputDecoration(
                      fillColor: ThemaMain.second,
                      prefixIcon: IconButton(
                          iconSize: 20.sp,
                          onPressed: () => setState(() {
                                press = !press;
                              }),
                          icon: Icon(Icons.arrow_back, color: ThemaMain.red)),
                      label: Text("Nombre | 3 palabras | Telefono",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16.sp, color: ThemaMain.darkGrey)),
                      suffixIcon: IconButton(
                          iconSize: 20.sp,
                          onPressed: () {},
                          icon: Icon(Icons.search, color: ThemaMain.green)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h)))
              : IconButton.filled(
                  iconSize: 24.sp,
                  onPressed: () => setState(() {
                        press = !press;
                      }),
                  icon: Icon(Icons.search, color: ThemaMain.green))),
    );
  }
}
