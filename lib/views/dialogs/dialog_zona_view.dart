import 'package:enrutador/controllers/zonas_controller.dart';
import 'package:enrutador/models/zona_model.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/list_zona_widget.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DialogZonaView extends StatefulWidget {
  final List<int> zonas;
  final Function(List<ZonasModel>) fun;
  const DialogZonaView({super.key, required this.fun, required this.zonas});

  @override
  State<DialogZonaView> createState() => _DialogZonaViewState();
}

class _DialogZonaViewState extends State<DialogZonaView> {
  List<ZonasModel> selectedZonas = [];

  @override
  void initState() {
    getdata();
    super.initState();
  }

  getdata() async {
    List<ZonasModel> temp = [];
    for (var item in widget.zonas) {
      var ides = await ZonasController.getId(item);
      if (ides != null) {
        temp.add(ides);
      }
    }
    setState(() {
      selectedZonas = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
          title: Text("Filtro de Zonas", style: TextStyle(fontSize: 16.sp)),
          actions: [
            ElevatedButton.icon(
                style: ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 1.w))),
                onPressed: () => setState(() {
                      Preferences.zonasDibujar = !Preferences.zonasDibujar;
                    }),
                icon: Icon(Icons.map_outlined,
                    size: 20.sp,
                    color: Preferences.zonasDibujar
                        ? ThemaMain.green
                        : ThemaMain.red),
                label: Text("Dibujar",
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)))
          ]),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Text("Seleccione zonas para filtrar",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            Container(
                constraints: BoxConstraints(maxHeight: 60.h),
                child: FutureBuilder(
                    future: ZonasController.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              ZonasModel zona = snapshot.data![index];
                              return ListZonaWidget(
                                  zona: zona,
                                  fun: () {},
                                  selectedVisible: true,
                                  selected: selectedZonas
                                      .where((e) => e.id == zona.id)
                                      .isNotEmpty,
                                  onSelected: (p0) {
                                    if (selectedZonas
                                        .where((e) => e.id == zona.id)
                                        .isNotEmpty) {
                                      setState(() {
                                        selectedZonas.removeWhere(
                                            (e) => e.id == zona.id);
                                      });
                                    } else {
                                      setState(() {
                                        selectedZonas.add(zona);
                                      });
                                    }
                                  });
                            });
                      } else if (!snapshot.hasData &&
                          (snapshot.data?.isEmpty ?? false)) {
                        return Center(
                            child: Text(
                          "No hay datos",
                          style: TextStyle(fontSize: 15.sp),
                        ));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    })),
            ElevatedButton(
                onPressed: () {
                  widget.fun(selectedZonas);
                },
                child: Text("Aplicar", style: TextStyle(fontSize: 15.sp)))
          ]))
    ]));
  }
}
