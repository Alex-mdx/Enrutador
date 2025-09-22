import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/tipos_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/views/widgets/list_tipo_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_color.dart';

class RowFiltro extends StatefulWidget {
  const RowFiltro({super.key});

  @override
  State<RowFiltro> createState() => _RowFiltroState();
}

class _RowFiltroState extends State<RowFiltro> {
  DateTime first = DateTime.now().subtract(Duration(days: 365 * 2));
  DateTime last = DateTime.now().add(Duration(days: 365 * 2));

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(spacing: .5.w, children: [
          chips(
              icono: Icons.type_specimen,
              cabeza: Preferences.tipos.isEmpty
                  ? "Tipo"
                  : Preferences.tipos
                      .map((e) => provider.tipos
                          .firstWhereOrNull((ti) => ti.id == int.tryParse(e))
                          ?.nombre)
                      .join(", "),
              fun: () => showDialog(
                  context: context,
                  builder: (context) => Dialog(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        Text("Seleccione tipos para filtrar",
                            style: TextStyle(fontSize: 16.sp)),
                        FutureBuilder(
                            future: TipoController.getItems(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      TiposModelo tipo = snapshot.data![index];
                                      return ListTipoWidget(
                                          tipo: tipo,
                                          fun: () {},
                                          share: false,
                                          selectedVisible: true,
                                          selected: Preferences.tipos
                                              .contains(tipo.id.toString()),
                                          onSelected: (p0) {
                                            var temp = Preferences.tipos
                                                .map((e) => int.parse(e))
                                                .toList();
                                            if (temp.contains(tipo.id)) {
                                              temp.remove(tipo.id);
                                            } else {
                                              temp.add(tipo.id!);
                                            }
                                            Preferences.tipos = temp
                                                .map((e) => e.toString())
                                                .toList();
                                            Navigation.pop();
                                          });
                                    });
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}",
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontStyle: FontStyle.italic));
                              } else {
                                return Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: CircularProgressIndicator());
                              }
                            })
                      ]))),
              colorprincipal: ThemaMain.primary,
              condicion: Preferences.tipos.isNotEmpty,
              delete: () => setState(() {
                    Preferences.tipos = [];
                  })),
          chips(
              icono: Icons.contact_emergency,
              cabeza: Preferences.status.isEmpty
                  ? "Estatus"
                  : Preferences.status.join(","),
              fun: () {},
              colorprincipal: ThemaMain.darkBlue,
              condicion: Preferences.status.isNotEmpty,
              delete: () => setState(() {
                    Preferences.status = [];
                  })),
          chips(
              icono: LineIcons.mapMarked,
              cabeza: Preferences.zonas.isEmpty
                  ? "Zona"
                  : Preferences.zonas.join(","),
              fun: () {},
              colorprincipal: ThemaMain.pink,
              condicion: Preferences.zonas.isNotEmpty,
              delete: () => setState(() {
                    Preferences.zonas = [];
                  }))
        ]));
  }

  Widget chips(
      {required IconData icono,
      required String cabeza,
      required Function() fun,
      required Color colorprincipal,
      required bool condicion,
      required Function() delete}) {
    return GestureDetector(
        onTap: fun,
        child: Chip(
            avatar: Icon(icono,
                size: 17.sp,
                color: condicion ? colorprincipal : ThemaMain.darkGrey),
            padding: EdgeInsets.all(0),
            label: Text(cabeza,
                style: TextStyle(
                    fontSize: condicion ? 12.sp : 13.sp,
                    fontWeight:
                        condicion ? FontWeight.bold : FontWeight.normal)),
            onDeleted: delete,
            labelPadding: EdgeInsets.all(0),
            deleteIcon: condicion
                ? Icon(Icons.close, size: 18.sp, color: ThemaMain.red)
                : SizedBox()));
  }
}
