import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class DialogSetting extends StatefulWidget {
  const DialogSetting({super.key});

  @override
  State<DialogSetting> createState() => _DialogSettingState();
}

class _DialogSettingState extends State<DialogSetting> {
  List<String> obtenerKeysContacto() {
    // Creamos una instancia con valores mínimos para obtener la estructura
    final dummy = ContactoModelo(
        nombreCompleto: '',
        latitud: 0,
        longitud: 0,
        domicilio: '',
        zonas: [],
        fechaDomicilio: DateTime.now(),
        numero: 0,
        numeroFecha: DateTime.now(),
        otroNumero: 0,
        otroNumeroFecha: DateTime.now(),
        agendar: DateTime.now(),
        tipo: 0,
        tipoFecha: DateTime.now(),
        estado: 0,
        estadoFecha: DateTime.now(),
        foto: '',
        fotoFecha: DateTime.now(),
        fotoReferencia: '',
        fotoReferenciaFecha: DateTime.now(),
        what3Words: '');

    return dummy
        .toJson()
        .keys
        .where((element) =>
            !element.toLowerCase().contains("fecha") &&
            !element.toLowerCase().contains("empleado") &&
            !element.toLowerCase().contains("nota") &&
            !element.toLowerCase().contains("zonas"))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(title: Text("Configuración", style: TextStyle(fontSize: 18.sp))),
      Column(children: [
        Text("Compartir", style: TextStyle(fontSize: 16.sp)),
        Wrap(
            alignment: WrapAlignment.spaceAround,
            runSpacing: 0,
            spacing: .1.w,
            children:
                obtenerKeysContacto().map((e) => _buildItem(key: e)).toList()),
        Padding(
            padding: EdgeInsets.all(8.sp),
            child: CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius)),
                tileColor: ThemaMain.second,
                title: Text("No mostrar vacios",
                    style: TextStyle(fontSize: 13.sp)),
                subtitle: Text(
                    "Si se selecciono un campo, pero este no tiene contenido ingresado, no se mostrará en el texto compartido",
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.bold)),
                value: Preferences.removeVacios,
                onChanged: (value) => setState(() {
                      Preferences.removeVacios = value!;
                    }))),
        const Divider(),
        Text("Zoom", style: TextStyle(fontSize: 16.sp)),
        Text(
            "Cantidad mínima de zoom permitida antes de que los marcadores se muestren como circulos.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp)),
        Slider(
            value: Preferences.zoomMark.toDouble(),
            showValueIndicator: ShowValueIndicator.onDrag,
            divisions: 12,
            label: Preferences.zoomMark.toString(),
            min: 10,
            max: 16,
            onChanged: (value) {
              setState(() {
                Preferences.zoomMark = value;
              });
            }),
        const Divider(),
        Text("Numero de contactos encontrados",
            style: TextStyle(fontSize: 16.sp)),
        Text(
            "Cantidad máxima de contactos que se mostrarán en pantalla al realizar una búsqueda.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp)),
        InputQty.int(
            maxVal: 8,
            onQtyChanged: (val) => setState(() {
                  Preferences.contactosMax = val;
                }),
            initVal: Preferences.contactosMax,
            minVal: 4,
            qtyFormProps: QtyFormProps(
                enableTyping: false,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            decoration: QtyDecorationProps(
                plusBtn: Icon(LineIcons.plusCircle, size: 22.sp),
                minusBtn: Icon(LineIcons.minusCircle, size: 22.sp),
                fillColor: ThemaMain.background,
                isDense: true,
                isBordered: false),
            steps: 1),
        const Divider(),
        Text("Preferencias de red", style: TextStyle(fontSize: 16.sp)),
        Text(
            "Subida automática de datos según el tipo de conexión a internet disponible.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp)),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8.sp),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                      showCheckmark: false,
                      avatar: Icon(Icons.network_cell,
                          color: Preferences.redMobile
                              ? ThemaMain.primary
                              : ThemaMain.grey),
                      label: Text("Mobile", style: TextStyle(fontSize: 14.sp)),
                      selected: Preferences.redMobile,
                      onSelected: (bool selected) => setState(() {
                            Preferences.redMobile = selected;
                          })),
                  ChoiceChip(
                      showCheckmark: false,
                      avatar: Icon(Icons.wifi,
                          color: Preferences.redWifi
                              ? ThemaMain.green
                              : ThemaMain.grey),
                      label: Text("Wi-Fi", style: TextStyle(fontSize: 14.sp)),
                      selected: Preferences.redWifi,
                      onSelected: (bool selected) => setState(() {
                            Preferences.redWifi = selected;
                          }))
                ]))
      ])
    ]));
  }

  Widget _buildItem({required String key}) {
    return InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () {
          setState(() {
            if (Preferences.shareText.where((e) => e == key).isNotEmpty) {
              Preferences.shareText = Preferences.shareText..remove(key);
            } else {
              Preferences.shareText = Preferences.shareText..add(key);
            }
          });
        },
        child: Card(
            color: Preferences.shareText.where((e) => e == key).isNotEmpty
                ? ThemaMain.primary
                : null,
            elevation:
                Preferences.shareText.where((e) => e == key).isNotEmpty ? 3 : 0,
            child: Padding(
                padding: EdgeInsets.all(4.sp),
                child: Text(key.toUpperCase(),
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.bold)))));
  }
}
