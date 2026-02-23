import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

import '../card_accout.dart';

class SideButtons extends StatelessWidget {
  const SideButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: ThemaMain.appbar,
        child: Column(children: [
          SizedBox(height: 10.h),
          GestureDetector(
              onTap: () async => await Navigation.pushNamed(route: "contactos"),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Contactos",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.connect_without_contact,
                                size: 22.sp, color: ThemaMain.darkGrey)
                          ])))),
          if (kDebugMode)
            GestureDetector(
                onTap: () async {},
                child: Card(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.w, vertical: 1.h),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Listas",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              Icon(LineIcons.mapMarked,
                                  size: 22.sp, color: ThemaMain.red)
                            ])))),
          GestureDetector(
              onTap: () async => await Navigation.pushNamed(route: "tipos"),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tipos",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.type_specimen,
                                size: 22.sp, color: ThemaMain.primary)
                          ])))),
          GestureDetector(
              onTap: () async => await Navigation.pushNamed(route: "estatus"),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Estatus",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.contact_emergency,
                                size: 22.sp, color: ThemaMain.darkBlue)
                          ])))),
          GestureDetector(
              onTap: () async => await Navigation.pushNamed(route: "navegar"),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Navegar",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(LineIcons.globe,
                                size: 22.sp, color: ThemaMain.green)
                          ])))),
          GestureDetector(
              onTap: () async => await Navigation.pushNamed(route: "roles"),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Roles",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(LineIcons.userTag,
                                size: 22.sp, color: ThemaMain.darkBlue)
                          ])))),
          GestureDetector(
              onTap: () async => await Navigation.pushNamed(route: "lada"),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Lada",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.perm_phone_msg,
                                size: 20.sp, color: ThemaMain.pink)
                          ])))),
          GestureDetector(
              onTap: () async =>
                  await Navigation.pushNamed(route: "regionesMapa"),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Regionar",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(LineIcons.layerGroup,
                                size: 20.sp, color: ThemaMain.primary)
                          ])))),
          GestureDetector(
              onTap: () async => showDialog(
                  context: context,
                  builder: (context) => Dialog(child: CardAccout())),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Perfil",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.person,
                                size: 20.sp, color: ThemaMain.green)
                          ])))),
          GestureDetector(
              onTap: () async => showDialog(
                  context: context,
                  builder: (context) => Dialog(child: CardAccout())),
              child: Card(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Pendientes",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Icon(Icons.youtube_searched_for,
                                size: 20.sp, color: ThemaMain.primary)
                          ]))))
        ]));
  }
}
