import 'package:enrutador/controllers/usuario_fire.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/views/widgets/extras/card_account_lite.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
    users = await UsuarioFire.getAllItems(limit: 50, index: index - 1);
    setState(() {
      carga = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar:
            AppBar(title: Text('Usuarios', style: TextStyle(fontSize: 18.sp))),
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
            user: user,
            pop: false,
            fun: () async => users =
                await UsuarioFire.getAllItems(limit: 50, index: index - 1)),
        itemComparator: (e1, e2) =>
            (e1.nombre ?? "?").compareTo(e2.nombre ?? "?"),
        itemScrollController: itemScrollController,
        order: StickyGroupedListOrder.ASC);
  }
}
