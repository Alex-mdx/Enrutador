import 'package:enrutador/controllers/pendiente_fire.dart';
import 'package:enrutador/models/pendiente_model.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

import '../utilities/theme/theme_color.dart';
import 'widgets/extras/card_pendientes.dart';

class PendientesView extends StatefulWidget {
  const PendientesView({super.key});

  @override
  State<PendientesView> createState() => _PendientesViewState();
}

class _PendientesViewState extends State<PendientesView> {
  bool propios = true;
  bool cargando = false;
  List<PendienteModel> pendientes = [];
  late UsuarioModel arguments;

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

    pendientes = await PendienteFire.getItems(
        table: "empleado_id", query: "${arguments.empleadoId}", limit: 50);
    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
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
                        Switch.adaptive(
                            applyCupertinoTheme: true,
                            padding: EdgeInsets.zero,
                            thumbIcon: WidgetStatePropertyAll(Icon(
                                propios ? LineIcons.user : LineIcons.users,
                                color: ThemaMain.background,
                                size: 16.sp)),
                            inactiveThumbColor: ThemaMain.darkBlue,
                            activeThumbColor: ThemaMain.primary,
                            value: propios,
                            onChanged: (value) {
                              setState(() => propios = !propios);
                              debugPrint("Enviar directo: ${propios}");
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
            : ListView.builder(
                itemCount: pendientes.length,
                itemBuilder: (context, index) {
                  return CardPendientes(
                      pendientes: pendientes[index]);
                }));
  }
}
