import 'package:enrutador/controllers/roles_controller.dart';
import 'package:enrutador/controllers/roles_fire.dart';
import 'package:enrutador/models/roles_model.dart';
import 'package:enrutador/views/dialogs/dialogs_roles.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../utilities/main_provider.dart';
import '../utilities/services/dialog_services.dart';
import '../utilities/share_fun.dart';
import '../utilities/theme/theme_color.dart';
import 'widgets/list_roles_widget.dart';

class RolesView extends StatefulWidget {
  const RolesView({super.key});

  @override
  State<RolesView> createState() => _RolesViewState();
}

class _RolesViewState extends State<RolesView> {
  List<bool> selects = [];
  bool carga = false;
  List<RolesModel> roles = [];
  @override
  void initState() {
    super.initState();
    send();
  }

  Future<void> send() async {
    setState(() {
      carga = false;
    });
    selects = [];
    roles = await RolesController.getAll();
    selects.addAll(roles.map((e) => false).toList());
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async =>
          provider.roles = await RolesController.getAll(),
      child: Scaffold(
          appBar: AppBar(
              title: Text("Roles", style: TextStyle(fontSize: 18.sp)),
              actions: [
                if (roles.isNotEmpty)
                  ElevatedButton.icon(
                      onPressed: () => Dialogs.showMorph(
                          title: "Roles",
                          description:
                              "¿Enviar directamente para que se guarden en la base de datos?",
                          loadingTitle: "Enviando",
                          onAcceptPressed: (context) async {
                            for (var i = 0; i < roles.length; i++) {
                              await RolesFire.send(rol: roles[i]);
                            }
                            showToast("Roles enviados correctamente");
                            await send();
                          }),
                      icon: RiveAnimatedIcon(
                          riveIcon: RiveIcon.reload2,
                          color: ThemaMain.green,
                          height: 22.sp,
                          strokeWidth: 2.w,
                          width: 22.sp),
                      label: Text("Todo", style: TextStyle(fontSize: 14.sp))),
                ElevatedButton.icon(
                    onPressed: () async {
                      var roles = await RolesController.getAll();
                      Dialogs.showMorph(
                          title: "Roles",
                          description:
                              "Estas seguro de enviar los ${roles.length} estado(s)\nEste proceso puede tardar unos segundos dependiendo de el tamaño de los datos obtenidos",
                          loadingTitle: "procesando",
                          onAcceptPressed: (context) async {
                            var archivo = await ShareFun.shareDatas(
                                nombre: "roles", datas: roles);
                            if (archivo.isNotEmpty) {
                              await ShareFun.share(
                                  titulo:
                                      "Este es un contenido compacto de tipos",
                                  mensaje: "objeto de contactos",
                                  files: archivo
                                      .map((e) => XFile(e.path))
                                      .toList());
                            }
                          });
                    },
                    label:
                        Text("Enviar todo", style: TextStyle(fontSize: 14.sp)),
                    icon: Icon(Icons.done_all,
                        color: ThemaMain.primary, size: 20.sp)),
                if (selects.any((element) => element == true))
                  ElevatedButton(
                      onPressed: () async {
                        List<RolesModel> temp = [];
                        for (var i = 0; i < selects.length; i++) {
                          if (selects[i]) {
                            temp.add(roles[i]);
                          }
                        }
                        var archivo = await ShareFun.shareDatas(
                            nombre: "roles", datas: temp);
                        if (archivo.isNotEmpty) {
                          await ShareFun.share(
                              titulo: "Este es un contenido compacto de roles",
                              mensaje: "objeto de contactos",
                              files:
                                  archivo.map((e) => XFile(e.path)).toList());
                        }
                      },
                      child: Text(
                          "Enviar (${selects.where((element) => element == true).length})",
                          style: TextStyle(fontSize: 14.sp)))
              ]),
          body: !carga
              ? Center(
                  child: LoadingAnimationWidget.twoRotatingArc(
                      color: ThemaMain.primary, size: 24.sp))
              : roles.isEmpty
                  ? Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(LineIcons.userTag,
                              size: 24.sp, color: ThemaMain.red),
                          TextButton.icon(onPressed: () async {
                              bool result = false;
                              await Dialogs.showMorph(
                                  title: "Descargar roles",
                                  description:
                                      "Desea descargar los roles de la base de datos?",
                                  loadingTitle: "procesando",
                                  onAcceptPressed: (context) async =>
                                      setState(() {
                                        result = true;
                                      }));
                              if (result) {
                                carga = false;
                                var cont = await RolesFire.getItems();
                                for (var element in cont) {
                                  await RolesController.insert(element);
                                }
                                await send();
                              }}, icon: Icon(Icons.refresh), label: Text("No hay roles creados",style: TextStyle(fontSize: 16.sp)),
                              )
                        ]))
                  : GridView.builder(
                      itemCount: roles.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1.3, crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        return ListRolesWidget(
                            estado: roles[index],
                            fun: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) =>
                                      DialogsRoles(rol: roles[index]));
                              await send();
                            },
                            share: true,
                            selectedVisible: true,
                            selected: selects[index],
                            onSelected: (value) {
                              setState(() {
                                selects[index] = value!;
                              });
                            },
                            dense: false);
                      }),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (context) => DialogsRoles(rol: null));
                await send();
              },
              child: Icon(Icons.add_comment, size: 24.sp))),
    );
  }
}
