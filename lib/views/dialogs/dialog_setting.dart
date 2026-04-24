import 'package:enrutador/models/contacto_model.dart';
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
        what3Words: '',
        nota: '');

    return dummy
        .toJson()
        .keys
        .where((element) =>
            !element.toLowerCase().contains("fecha") &&
            !element.toLowerCase().contains("empleado"))
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
            runSpacing: 0,
            spacing: .1.w,
            children: obtenerKeysContacto()
                .map(
                    (e) => _buildItem(key: e, icon: Icons.add_ic_call_outlined))
                .toList())
      ])
    ]));
  }

  Widget _buildItem({required String key, required IconData icon}) {
    return Card(
        child: Padding(
      padding: EdgeInsets.all(8.sp),
      child: Text(key.replaceAll("_", " ").toUpperCase(),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
    ));
  }
}
