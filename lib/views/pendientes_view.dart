import 'package:enrutador/controllers/pendiente_fire.dart';
import 'package:enrutador/models/pendiente_model.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../utilities/theme/theme_color.dart';
import 'widgets/extras/card_pendientes.dart';

class PendientesView extends StatefulWidget {
  const PendientesView({super.key});

  @override
  State<PendientesView> createState() => _PendientesViewState();
}

class _PendientesViewState extends State<PendientesView> {
  bool cargando = false;
  List<PendienteModel> pendientes = [];
  late UsuarioModel arguments;

  final ScrollController itemScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      arguments = ModalRoute.of(context)!.settings.arguments as UsuarioModel;
      _cargarPendientes();
    });
  }

  Future<void> _cargarPendientes() async {
    setState(() => cargando = true);

    if (Preferences.propiosPendientes) {
      pendientes = await PendienteFire.getItems(
          table: "empleado_id", query: "${arguments.empleadoId}", limit: 50);
    } else {
      pendientes = await PendienteFire.getAllItems(limit: 50);
    }
    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text("Pendientes",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            actions: [
              Card(
                  elevation: 0,
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 0),
                      child: Row(spacing: 1.w, children: [
                        Text("Todos",
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        if ((provider.usuario?.adminTipo ?? 0) >= 3)
                          Switch.adaptive(
                              applyCupertinoTheme: true,
                              padding: EdgeInsets.zero,
                              thumbIcon: WidgetStatePropertyAll(Icon(
                                  Preferences.propiosPendientes
                                      ? LineIcons.user
                                      : LineIcons.users,
                                  color: ThemaMain.background,
                                  size: 16.sp)),
                              inactiveThumbColor: ThemaMain.darkBlue,
                              activeThumbColor: ThemaMain.primary,
                              value: Preferences.propiosPendientes,
                              onChanged: (value) async {
                                setState(() => Preferences.propiosPendientes =
                                    !Preferences.propiosPendientes);
                                if (Preferences.propiosPendientes) {
                                  var nuevos = await PendienteFire.getItems(
                                      table: "empleado_id",
                                      query: "${arguments.empleadoId}",
                                      limit: 50);
                                  setState(() => pendientes = nuevos);
                                } else {
                                  var nuevos = await PendienteFire.getAllItems(
                                      limit: 50);
                                  setState(() => pendientes = nuevos);
                                }
                              }),
                        Text("Mios",
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.bold))
                      ])))
            ]),
        body: cargando
            ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: ThemaMain.primary, size: 32.sp))
            : Scrollbar(
                interactive: true,
                controller: itemScrollController,
                child: ListView.builder(
                    controller: itemScrollController,
                    itemCount: pendientes.length,
                    itemBuilder: (context, index) {
                      return CardPendientes(
                          pendientes: pendientes[index],
                          fun: () => _cargarPendientes());
                })));
  }
}
