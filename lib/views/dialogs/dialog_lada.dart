import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:sizer/sizer.dart';

class DialogLada extends StatelessWidget {
  final Function(String?) ladaGet;
  const DialogLada({super.key, required this.ladaGet});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Seleccione un lada telefonico", style: TextStyle(fontSize: 16.sp)),
      FutureBuilder(
          future: getAllSupportedRegions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                  child: Scrollbar(
                      thickness: 2.w,
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data!.values.toList()[index];
                            return ListTile(
                                dense: true,
                                onTap: () {
                                  ladaGet("+${data.phoneCode}");
                                  Navigation.pop();
                                },
                                leading: Text("+${data.phoneCode}",
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold)),
                                title: Text(
                                    "${data.countryName} - ${data.countryCode}",
                                    style: TextStyle(fontSize: 15.sp)),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 1.w, vertical: 0));
                          })));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}",
                  style: TextStyle(fontSize: 14.sp));
            } else {
              return CircularProgressIndicator();
            }
          })
    ]));
  }
}
