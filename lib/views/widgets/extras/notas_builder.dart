import 'package:enrutador/controllers/nota_controller.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/card_nota.dart';
import 'package:enrutador/views/widgets/extras/text_send.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  int? contactoId;

  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      contactoId = ModalRoute.of(context)?.settings.arguments as int;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    notas = await NotasController.getContactoId(contactoId!);
    setState(() => loading = false);
    if (itemScrollController.isAttached) {
      await itemScrollController.scrollTo(
          index: notas.length - 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 6.h,
            title:
                Text("Historial de notas", style: TextStyle(fontSize: 18.sp)),
            actions: [
              Card(
                  elevation: 0,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Row(spacing: 1.w, children: [
                        Switch.adaptive(
                            padding: EdgeInsets.zero,
                            thumbIcon: WidgetStatePropertyAll(Icon(Icons.cloud,
                                color: ThemaMain.background, size: 16.sp)),
                            inactiveThumbColor: ThemaMain.yellow,
                            activeThumbColor: ThemaMain.green,
                            value: Preferences.enviarDirectoNotas,
                            onChanged: (value) {
                              setState(() => Preferences.enviarDirectoNotas =
                                  !Preferences.enviarDirectoNotas);
                              debugPrint("Enviar directo: ${value}");
                            }),
                        Text("Enviar directo",
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.bold))
                      ])))
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
                                      color: ThemaMain.background)),
                            )),
                        itemBuilder: (context, element) =>
                            CardNota(element: element))))
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
                var tempNota = NotaModel(
                    contactoId: contactoId!,
                    descripcion: p0,
                    empleadoId: provider.usuario!.empleadoId!,
                    pendiente: 1,
                    creado: DateTime.now());
                await NotasController.insert(tempNota);
                setState(() => notas.add(tempNota));
                await itemScrollController.scrollTo(
                    index: notas.length - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              }))
        ])));
  }
}
