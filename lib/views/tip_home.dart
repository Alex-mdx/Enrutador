import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/fireController/tip_fire.dart';
import 'package:enrutador/models/tip_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/extras/text_send.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import '../models/usuario_model.dart';
import 'widgets/extras/card_tip.dart';

class TipHome extends StatefulWidget {
  const TipHome({super.key});

  @override
  State<TipHome> createState() => _TipHomeState();
}

class _TipHomeState extends State<TipHome> {
  bool find1 = false;
  bool find2 = false;
  bool press = false;
  List<TipModel> tips1 = [];
  List<TipModel> tips2 = [];

  String? tipString;
  bool find3 = false;
  List<TipModel> tips3 = [];

  @override
  void initState() {
    super.initState();
    findTips();
  }

  Future<void> findTips() async {
    try {
      var filter = Filter.and(Filter("uuid", whereIn: Preferences.tipsReaded),
          Filter("estado_tip", isEqualTo: 1));
      var list = await TipFire.getItemPersonalizado(
          filters: [filter], orderBy: "fecha_creacion", descending: false);
      setState(() {
        if (list.isEmpty) {
          Preferences.tipsReaded = [];
        }
        tips1 = list;
        find1 = true;
      });
    } catch (e) {
      setState(() {
        find1 = true;
      });
      showToast(e.toString());
    }
  }

  Future<void> findTips2(UsuarioModel usuario) async {
    try {
      var filter = Filter.and(
          Filter("uuid", whereIn: Preferences.tipsReaded),
          Filter("estado_tip", isEqualTo: 1),
          Filter("empleado_by", isEqualTo: usuario.empleadoId));
      var list = await TipFire.getItemPersonalizado(
          filters: [filter], orderBy: "fecha_creacion", descending: false);
      setState(() {
        tips2 = list;
        find2 = true;
        press = false;
      });
    } catch (e) {
      setState(() {
        find2 = true;
      });
      showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 6.h,
            title: Text("Historial de tips asignados",
                style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton.filledTonal(
                  onPressed: () async => await TipFire.findTips(
                      empleadoId: provider.usuario!.empleadoId!.toString(),
                      estadoTip: true),
                  icon: Icon(LineIcons.syncIcon,
                      size: 18.sp, color: ThemaMain.green))
            ]),
        body: SafeArea(
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: tipString == null || tipString!.isEmpty
                    ? Column(children: [
                        Expanded(
                            child: ListaTipsAsignados(
                                cargando: !find1 && tips1.isEmpty,
                                tips: tips1,
                                onRefresh: findTips)),
                        if ((provider.usuario?.adminTipo == -1) ||
                            (provider.usuario?.adminTipo ?? 0) >= 2)
                          Divider(height: .5.h),
                        if ((provider.usuario?.adminTipo == -1) ||
                            (provider.usuario?.adminTipo ?? 0) >= 2)
                          Expanded(
                              child: ListaTipsCreados(
                                  press: press,
                                  cargando: !find2 && tips2.isEmpty,
                                  tips: tips2,
                                  onCargar: () async {
                                    setState(() {
                                      press = true;
                                    });
                                    await findTips2(provider.usuario!);
                                  },
                                  onRetry: () async {
                                    setState(() {
                                      press = false;
                                    });
                                    await findTips2(provider.usuario!);
                                  },
                                  onRefreshTip: (tip) =>
                                      findTips2(provider.usuario!)))
                      ])
                    : ListaTipsBusqueda(
                        cargando: !find3 && tips3.isEmpty,
                        tips: tips3,
                        tipString: tipString!,
                        onClear: () {
                          setState(() {
                            tipString = "";
                            find3 = false;
                            tips3 = [];
                          });
                        }))),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => Dialog(
                      child: TextSend(
                          label: "Ingresar ID del Tip",
                          hideWhenSend: false,
                          fun: (p0) async {
                            setState(() {
                              find3 = true;
                              tipString = p0.trim();
                            });
                            List<Filter> filters = [
                              Filter.and(Filter("uuid", isEqualTo: p0.trim()),
                                  Filter("estado_tip", isEqualTo: 1))
                            ];
                            List<TipModel> tips =
                                await TipFire.getItemPersonalizado(
                                    filters: filters,
                                    orderBy: "fecha_creacion",
                                    descending: false);
                            if (tips.isEmpty) return;
                            setState(() {
                              tips3 = tips;
                              find3 = false;
                            });
                            Navigation.pop();
                          })));
            },
            child: Icon(Icons.search, color: Colors.white, size: 22.sp)));
  }
}

class ListaTipsAsignados extends StatelessWidget {
  final bool cargando;
  final List<TipModel> tips;
  final VoidCallback onRefresh;

  const ListaTipsAsignados(
      {super.key,
      required this.cargando,
      required this.tips,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Obteniendo asignados", style: TextStyle(fontSize: 18.sp)),
            LoadingAnimationWidget.flickr(
                leftDotColor: ThemaMain.yellow,
                rightDotColor: ThemaMain.green,
                size: 28.sp)
          ]);
    }

    if (tips.isEmpty) {
      return Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            RiveAnimatedIcon(
                riveIcon: RiveIcon.bell,
                color: ThemaMain.yellow,
                height: 32.sp,
                width: 32.sp,
                strokeWidth: 12.sp),
            Text("No hay tips asignados", style: TextStyle(fontSize: 16.sp))
          ]));
    }

    return ListView.builder(
        itemCount: tips.length,
        itemBuilder: (context, index) {
          return CardTip(tip: tips[index], refresh: (p0) => onRefresh());
        });
  }
}

class ListaTipsCreados extends StatelessWidget {
  final bool press;
  final bool cargando;
  final List<TipModel> tips;
  final VoidCallback onCargar;
  final VoidCallback onRetry;
  final Function(TipModel) onRefreshTip;

  const ListaTipsCreados(
      {super.key,
      required this.press,
      required this.cargando,
      required this.tips,
      required this.onCargar,
      required this.onRetry,
      required this.onRefreshTip});

  @override
  Widget build(BuildContext context) {
    if (!press && (cargando && tips.isEmpty)) {
      return ElevatedButton.icon(
          onPressed: onCargar,
          icon: Icon(LineIcons.bellAlt, color: ThemaMain.darkBlue, size: 22.sp),
          label: Text("Ver tips creados por ti",
              style: TextStyle(fontSize: 18.sp)));
    }

    if (cargando && tips.isEmpty) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Obteniendo creados por ti",
                style: TextStyle(fontSize: 18.sp)),
            LoadingAnimationWidget.flickr(
                leftDotColor: ThemaMain.primary,
                rightDotColor: ThemaMain.red,
                size: 28.sp)
          ]);
    }

    if (tips.isEmpty) {
      return Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            RiveAnimatedIcon(
                onTap: onRetry,
                riveIcon: RiveIcon.bell,
                color: ThemaMain.yellow,
                height: 32.sp,
                width: 32.sp,
                strokeWidth: 12.sp),
            Text("No hay tips creados", style: TextStyle(fontSize: 16.sp))
          ]));
    }

    return Stack(alignment: Alignment.topCenter, children: [
      ListView.builder(
          itemCount: tips.length,
          itemBuilder: (context, index) {
            return CardTip(
                tip: tips[index], refresh: (p0) => onRefreshTip(tips[index]));
          }),
      Container(
          padding: EdgeInsets.symmetric(vertical: 2.sp, horizontal: 2.w),
          decoration: BoxDecoration(
              color: ThemaMain.darkBlue,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(borderRadius))),
          child: Text("Tips Creados",
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)))
    ]);
  }
}

class ListaTipsBusqueda extends StatelessWidget {
  final bool cargando;
  final List<TipModel> tips;
  final String tipString;
  final VoidCallback onClear;

  const ListaTipsBusqueda(
      {super.key,
      required this.cargando,
      required this.tips,
      required this.tipString,
      required this.onClear});

  @override
  Widget build(BuildContext context) {
    if (cargando && tips.isEmpty) {
      return Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text("Buscando Tip con: $tipString",
                style: TextStyle(fontSize: 18.sp)),
            LoadingAnimationWidget.flickr(
                leftDotColor: ThemaMain.black,
                rightDotColor: ThemaMain.white,
                size: 28.sp)
          ]));
    }

    if (tips.isEmpty) {
      return Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            RiveAnimatedIcon(
                onTap: onClear,
                riveIcon: RiveIcon.bell,
                color: ThemaMain.yellow,
                height: 32.sp,
                width: 32.sp,
                strokeWidth: 12.sp),
            Text("No se encontraron tips con: $tipString",
                style: TextStyle(fontSize: 16.sp))
          ]));
    }

    return Column(children: [
      Expanded(
          flex: 1,
          child: ElevatedButton.icon(
              onPressed: onClear,
              icon: Icon(Icons.close, color: ThemaMain.red, size: 22.sp),
              label: const Text("Limpiar Busqueda"))),
      Expanded(
          flex: 9,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: tips.length,
              itemBuilder: (context, index) {
                return CardTip(tip: tips[index], refresh: (p0) {});
              }))
    ]);
  }
}
