import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/controllers/roles_controller.dart';
import 'package:enrutador/models/roles_model.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/list_roles_widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import '../../models/referencia_model.dart';

class DialogReferencia extends StatefulWidget {
  final ReferenciaModelo? referencia;
  final bool origen;
  const DialogReferencia({super.key, this.referencia, required this.origen});

  @override
  State<DialogReferencia> createState() => _DialogReferenciaState();
}

class _DialogReferenciaState extends State<DialogReferencia> {
  bool press = false;
  List<RolesModel> items = [];
  final SingleSelectController<RolesModel> controller =
      SingleSelectController<RolesModel>(null);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      press = true;
    });
    items = await RolesController.getAll(long: 10);
    if (widget.referencia?.rolId != null) {
      var roles = await RolesController.getId(widget.referencia!.rolId!);
      controller.value = roles;
    }
    setState(() {
      press = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Configuración de la referencia", style: TextStyle(fontSize: 16.sp)),
      if (widget.referencia?.rolId != null)
        FutureBuilder(
            future: RolesController.getId(widget.referencia!.rolId!),
            builder: (context, snapshot) {
              return Text(
                  widget.origen
                      ? "Esta referencia es ${snapshot.data?.nombre} del contacto"
                      : "Este contacto es ${snapshot.data?.nombre} del contacto que referencia",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold));
            }),
      ElevatedButton.icon(
          onPressed: () async => Dialogs.showMorph(
              title: "Eliminar referencia",
              description:
                  "¿Estas seguro de eliminar esta referencia?\nAl hacerlo romperas el enlace entre el contacto y la referencia",
              loadingTitle: "Eliminando",
              onAcceptPressed: (context) async {
                setState(() {
                  press = true;
                });
                await ReferenciasController.deleteItem(
                    id: widget.referencia!.id);
                Navigation.pop();
                setState(() {
                  press = false;
                });
              }),
          icon: Icon(Icons.delete, color: ThemaMain.red, size: 20.sp),
          label: Text("Eliminar", style: TextStyle(fontSize: 16.sp))),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            CustomDropdown<RolesModel>.searchRequest(
                futureRequest: (String query) =>
                    RolesController.getBuscar(query),
                hintText: 'Rol de referencia',
                searchRequestLoadingIndicator: LoadingAnimationWidget.flickr(
                    leftDotColor: ThemaMain.green,
                    rightDotColor: ThemaMain.red,
                    size: 20.sp),
                enabled: !press,
                overlayHeight: 44.h,
                decoration: CustomDropdownDecoration(
                    closedSuffixIcon: controller.value != null
                        ? IconButton(
                            onPressed: () {
                              controller.value = null;
                            },
                            icon: Icon(Icons.close,
                                color: ThemaMain.red, size: 20.sp))
                        : null),
                excludeSelected: true,
                searchHintText: "Buscar Rol",
                noResultFoundText: "No se encontraron resultados",
                headerBuilder: (context, selectedItem, enabled) =>
                    ListRolesWidget(
                        estado: selectedItem,
                        fun: () {},
                        share: false,
                        selectedVisible: false,
                        selected: true,
                        onSelected: (value) {},
                        dense: true),
                itemsListPadding: EdgeInsets.all(0),
                listItemPadding: EdgeInsets.all(0),
                closedHeaderPadding: EdgeInsets.all(0),
                listItemBuilder: (context, item, isSelected, onItemSelect) =>
                    ListRolesWidget(
                        estado: item,
                        fun: () {
                          controller.value = item;
                        },
                        share: false,
                        selectedVisible: false,
                        selected: isSelected,
                        onSelected: (value) {},
                        dense: true),
                items: items,
                controller: controller,
                onChanged: (value) {
                  if (value != null) {
                    controller.value = value;
                  }
                }),
            Text("Este buscador solo mostrara los ultimos 10 roles creados",
                style: TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic)),
          ])),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor:
                    press ? WidgetStatePropertyAll(ThemaMain.grey) : null),
            onPressed: () => (!press) ? Navigation.pop() : null,
            icon: Icon(Icons.cancel, color: ThemaMain.red, size: 20.sp),
            label: Text("Cancelar", style: TextStyle(fontSize: 16.sp))),
        ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor:
                    press ? WidgetStatePropertyAll(ThemaMain.grey) : null),
            onPressed: () async {
              setState(() {
                press = true;
              });
              var temp = widget.referencia
                  ?.copyWith(rolId: controller.value?.id ?? -1);
              await ReferenciasController.update(temp!);
              setState(() {
                press = false;
              });
              Navigation.pop();
            },
            icon: press
                ? CircularProgressIndicator.adaptive(padding: EdgeInsets.all(0))
                : Icon(Icons.save, color: ThemaMain.green, size: 20.sp),
            label: Text("Guardar", style: TextStyle(fontSize: 16.sp)))
      ])
    ]));
  }
}
