import 'package:enrutador/controllers/usuario_fire.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/views/widgets/extras/card_account_lite.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../utilities/theme/theme_color.dart';
import 'widgets/extras/paginador_widget.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  bool carga = false;
  int index = 1;
  int max = 1;
  List<UsuarioModel> users = [];
  final GroupedItemScrollController itemScrollController =
      GroupedItemScrollController();
  @override
  void initState() {
    super.initState();
    send(1);
  }

  Future<void> send(int idx) async {
    max = await UsuarioFire.countAll();
    setState(() {
      carga = false;
    });
    index = idx;
    users = await UsuarioFire.getAllItems(limit: 20, index: index - 1);
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text('Usuarios', style: TextStyle(fontSize: 18.sp)),
            actions: [
              if ((provider.usuario?.adminTipo ?? 0) == 5 ||
                  (provider.usuario?.adminTipo ?? 0) == -1)
                IconButton(
                    onPressed: () async {
                      var max = (await UsuarioFire.getAllItems(
                              limit: 1, index: 0, orden: "id", decender: true))
                          .firstOrNull;
                      debugPrint("Max: ${max?.id ?? 0}");
                      var newUser = UsuarioModel(
                          id: (max?.id ?? 0) + 1,
                          uuid: null,
                          nombre: null,
                          contactoId: null,
                          empleadoId: null,
                          adminTipo: 0,
                          status: 0,
                          foto: null,
                          children: [],
                          creacion: DateTime.now());
                      showDialog(
                          context: context,
                          builder: (context) => Dialog(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    CardAccountLite(
                                        user: newUser,
                                        pop: false,
                                        fun: (p0) async {
                                          if (p0 != null) {
                                            setState(() {
                                              newUser = p0;
                                            });
                                          }
                                        },
                                        local: true),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton.icon(
                                              onPressed: () => Navigation.pop(),
                                              icon: Icon(Icons.cancel_rounded,
                                                  size: 22.sp,
                                                  color: ThemaMain.red),
                                              label: Text("Cancelar",
                                                  style: TextStyle(
                                                      fontSize: 16.sp))),
                                          TextButton.icon(
                                              onPressed: () async {
                                                var result =
                                                    await UsuarioFire.sendItem(
                                                        data: newUser);
                                                showToast(result
                                                    ? "Se creo el usuario de manera exitosa"
                                                    : "No se pudo crear el usuario");
                                                if (result) {
                                                  await send(index);
                                                  Navigation.pop();
                                                }
                                              },
                                              icon: Icon(Icons.cloud_upload,
                                                  size: 22.sp,
                                                  color: ThemaMain.green),
                                              label: Text("Guardar",
                                                  style: TextStyle(
                                                      fontSize: 16.sp)))
                                        ])
                                  ])));
                    },
                    icon: Icon(Icons.person_add,
                        size: 22.sp, color: ThemaMain.background))
            ]),
        body: Column(children: [
          Expanded(
              flex: 10,
              child: !carga
                  ? Center(
                      child: LoadingAnimationWidget.twoRotatingArc(
                          color: ThemaMain.primary, size: 24.sp))
                  : users.isEmpty
                      ? Center(
                          child: Text("No se encontraron usuarios disponibles",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold)))
                      : Scrollbar(child: stick(provider))),
          PaginadorGroupedWidget(
              max: max,
              length: users.length,
              send: (index) async => await send(index),
              itemScrollController: itemScrollController)
        ]));
  }

  StickyGroupedListView<UsuarioModel, String?> stick(MainProvider provider) {
    return StickyGroupedListView<UsuarioModel, String?>(
        shrinkWrap: true,
        elements: users,
        groupBy: (element) => element.nombre?.substring(0, 1),
        groupSeparatorBuilder: (element) => Text(
            (element.nombre ?? "?").substring(0, 1),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16.sp,
                backgroundColor: ThemaMain.darkBlue,
                color: ThemaMain.dialogbackground,
                fontWeight: FontWeight.bold)),
        itemBuilder: (context, user) => CardAccountLite(
            user: user, pop: false, fun: (p0) async => send(index)),
        itemComparator: (e1, e2) =>
            (e1.nombre ?? "?").compareTo(e2.nombre ?? "?"),
        itemScrollController: itemScrollController,
        order: StickyGroupedListOrder.ASC);
  }
}
