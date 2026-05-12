import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
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
                obtenerKeysContacto().map((e) => _buildItem(key: e)).toList())
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
                padding: EdgeInsets.all(6.sp),
                child: Text(key.toUpperCase(),
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.bold)))));
  }
}
