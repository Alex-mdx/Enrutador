import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/fireController/nota_fire.dart';
import 'package:enrutador/controllers/nota_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/card_nota.dart';
import 'package:enrutador/views/widgets/extras/text_send.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../../utilities/textos.dart';

class NotasBuilder extends StatefulWidget {
  const NotasBuilder({super.key});

  @override
  State<NotasBuilder> createState() => _NotasBuilderState();
}

class _NotasBuilderState extends State<NotasBuilder> {
  List<NotaModel> notas = [];
  bool loading = false;
  ContactoModelo? contacto;
  UsuarioModel? user;

  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();

  Timer? timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ModalRoute.of(context)?.settings.arguments as List;
      contacto = data[0];
      user = data[1];
      _loadData();
    });
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (Preferences.enviarDirectoNotas) {
        await sendNotas();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    notas = await NotasController.getContactoId(contacto!.id!);
    setState(() => loading = false);

    // Esperamos un momento para que el ListView termine de construirse
    Future.delayed(const Duration(milliseconds: 100), () {
      if (itemScrollController.isAttached && notas.isNotEmpty) {
        itemScrollController.jumpTo(index: notas.length - 1);
      }
    });
  }

  Future<void> sendNotas() async {
    if (contacto == null || user == null) return;
    final data = await NotasController.getContactoId(contacto!.id!,
        pendiente: 1, empleadoId: user!.empleadoId);
    var filtro = Filter.and(
        Filter("id", isEqualTo: contacto!.id),
        Filter("contacto_id", isEqualTo: contacto!.id),
        Filter("empleado_id", isEqualTo: user!.empleadoId));
    await NotaFire.getItemPersonalizado(id: null, filters: [filtro]);
    showToast("test ${data.length}");
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 6.h,
            title: Text(
                "Historial de notas\n${contacto?.nombreCompleto ?? "Sin nombre"}",
                style: TextStyle(fontSize: 18.sp)),
            actions: [
              Card(
                  elevation: 0,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Switch.adaptive(
                          padding: EdgeInsets.zero,
                          thumbIcon: WidgetStatePropertyAll(Icon(Icons.cloud,
                              color: ThemaMain.background, size: 15.sp)),
                          inactiveThumbColor: ThemaMain.yellow,
                          activeThumbColor: ThemaMain.green,
                          value: Preferences.enviarDirectoNotas,
                          onChanged: (value) {
                            setState(() => Preferences.enviarDirectoNotas =
                                !Preferences.enviarDirectoNotas);
                            if (Preferences.enviarDirectoNotas) {
                              showToast(
                                  "Las notas se enviarán directamente al servidor cuando se agreguen");
                            }
                            debugPrint("Enviar directo: ${value}");
                          })))
            ]),
        body: SafeArea(
            child: Column(children: [
          if (loading && notas.isEmpty)
            Expanded(
                child: Center(
                    child: LoadingAnimationWidget.stretchedDots(
                        color: ThemaMain.darkBlue, size: 30.sp)))
          else if (notas.isNotEmpty)
            Expanded(
                child: Scrollbar(
                    child: StickyGroupedListView(
                        itemScrollController: itemScrollController,
                        elements: notas,
                        itemComparator: (a, b) => a.creado.compareTo(b.creado),
                        floatingHeader: true,
                        groupBy: (NotaModel e) =>
                            Textos.fechaYMD(fecha: e.creado),
                        groupSeparatorBuilder: (element) => Card(
                            elevation: 0,
                            color: ThemaMain.darkBlue,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.w, vertical: 0),
                                child: Text(
                                    Textos.fechaYMD(fecha: element.creado),
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: ThemaMain.background)))),
                        itemBuilder: (context, element) => CardNota(
                            element: element,
                            eliminado: element.pendiente == 1,
                            onDelete: () async {
                              bool? permite = false;
                              if (element.pendiente != 1) {
                                await Dialogs.showMorph(
                                    title: "Eliminar nota",
                                    description:
                                        "¿Estas seguro de eliminar la nota desde el servidor?",
                                    loadingTitle: "Eliminando nota",
                                    onAcceptPressed: () async {
                                      permite = true;
                                    });
                              }

                              var response = element.pendiente == 1
                                  ? true
                                  : permite == true
                                      ? await NotaFire.delete(nota: element)
                                      : false;

                              if (response) {
                                await NotasController.deleteItem(element.id!);
                                setState(() => notas.remove(element));
                                showToast("Nota eliminada");
                              }
                            }))))
          else
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                  Icon(Icons.note_alt, size: 30.sp, color: ThemaMain.darkGrey),
                  Text("No hay notas", style: TextStyle(fontSize: 16.sp))
                ])),
          Padding(
              padding: EdgeInsets.all(10.sp),
              child: TextSend(fun: (p0) async {
                if (p0.isEmpty) {
                  showToast("La nota no puede estar vacia");
                  return;
                }
                var tempNota = NotaModel(
                    id: null,
                    contactoId: contacto!.id!,
                    descripcion: p0,
                    empleadoId: provider.usuario!.empleadoId!,
                    pendiente: 1,
                    fijado: 0,
                    creado: DateTime.now());
                log("tempNota ${tempNota.toJson()}");
                await NotasController.insert(tempNota);
                setState(() => notas.add(tempNota));

                // Esperamos un momento para que el nuevo elemento se renderice
                Future.delayed(const Duration(milliseconds: 100), () async {
                  if (itemScrollController.isAttached && notas.isNotEmpty) {
                    await itemScrollController.scrollTo(
                        index: notas.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  }
                });
              }))
        ])));
  }
}
