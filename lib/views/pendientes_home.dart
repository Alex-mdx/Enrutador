import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/models/referencia_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/page/contactos_page.dart';
import 'package:enrutador/views/page/referencias_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../controllers/contacto_controller.dart';
import '../controllers/nota_controller.dart';
import '../models/contacto_model.dart';
import 'widgets/extras/list_referencia_agrupada.dart';

class PendientesHome extends StatefulWidget {
  const PendientesHome({super.key});

  @override
  State<PendientesHome> createState() => _PendientesHomeState();
}

class _PendientesHomeState extends State<PendientesHome> {
  int _tabIndex = 1;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  late PageController pageController;

  bool carga = false;
  List<ContactoModelo> contactos = [];
  List<NotaModel> notas = [];
  List<ReferenciaModelo> referencias = [];
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
    send();
  }

  Future<void> send() async {
    setState(() {
      carga = false;
    });
    contactos = await ContactoController.getPendientes();
    notas = await NotasController.getAll(
        pendiente: 1, long: 100, order: "creado DESC");
    referencias = await ReferenciasController.getItems(
        estatus: -1, long: 50, order: "fecha DESC");
    setState(() {
      carga = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text("Mis Pendientes", style: TextStyle(fontSize: 18.sp)),
            toolbarHeight: 6.h,
            actions: []),
        extendBody: true,
        bottomNavigationBar: CircleNavBar(
            activeIcons: [
              Icon(Icons.person_add_alt_1,
                  color: ThemaMain.darkBlue, size: 4.h),
              Icon(Icons.contacts, color: ThemaMain.darkBlue, size: 4.h),
              Icon(Icons.note, color: ThemaMain.darkBlue, size: 4.h)
            ],
            inactiveIcons: [
              Text("Referencias",
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              Text("Contactos",
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              Text("Notas",
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold))
            ],
            onTap: (v) async {
              await pageController.animateToPage(v,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
              tabIndex = v;
            },
            color: ThemaMain.primary,
            circleColor: ThemaMain.dialogbackground,
            height: 6.h,
            circleWidth: 6.h,
            activeIndex: tabIndex,
            cornerRadius:
                BorderRadius.vertical(top: Radius.circular(borderRadius)),
            shadowColor: ThemaMain.darkBlue,
            circleShadowColor: ThemaMain.primary,
            elevation: 5),
        body: PageView(
            controller: pageController,
            onPageChanged: (v) {
              tabIndex = v;
            },
            children: [
              ReferenciasPage(
                  referencias: referencias, carga: carga, send: send),
              ContactosPage(contactos: contactos, carga: carga, send: send),
              Placeholder()
            ]));
  }
}
