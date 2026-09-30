import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../controllers/fireController/cartera_fire.dart';
import '../models/cartera_model.dart';
import '../models/usuario_model.dart';
import '../utilities/main_provider.dart';
import '../utilities/theme/theme_color.dart';

class CarteraView extends StatefulWidget {
  const CarteraView({super.key});

  @override
  State<CarteraView> createState() => _CarteraViewState();
}

class _CarteraViewState extends State<CarteraView> {
  bool cargando = false;
  List<CarteraModel> pendientes = [];
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

    var result = await CarteraFire.getItemPersonalizado(
        filters: [Filter("empleado_by",isEqualTo: arguments.empleadoId)],
        orderBy: "fecha_actualizado",
        max: 20);
    if (result.isNotEmpty) {
      setState(() => pendientes = result);
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Carteras",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        ),
        body: cargando
            ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                    color: ThemaMain.primary, size: 32.sp))
            : pendientes.isEmpty
                ? Center(
                    child: Text("No hay carteras creadas",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)))
                : Scrollbar(
                    interactive: true,
                    controller: itemScrollController,
                    child: ListView.builder(
                        controller: itemScrollController,
                        itemCount: pendientes.length,
                        itemBuilder: (context, index) => Placeholder())));
  }
}
