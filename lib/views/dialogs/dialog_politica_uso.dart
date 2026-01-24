import 'package:enrutador/utilities/permisos.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

class DialogPoliticaUso extends StatefulWidget {
  const DialogPoliticaUso({super.key});

  @override
  State<DialogPoliticaUso> createState() => _DialogPoliticaUsoState();
}

class _DialogPoliticaUsoState extends State<DialogPoliticaUso> {
  @override
  void initState() {
    super.initState();
    Permisos.permisosPoliticas();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Politica de Uso",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(children: [
            Text(
                "La aplicacion enrutador, necesita acceso a los permisos de ubicacion del dispositivo para poder navegar en el mapa, recolectar informacion de punteos, coordenadas y visualizar la ubicacion del dispositivo para poder ofrecer la mejor experiencia posible",
                style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic)),
            ElevatedButton.icon(
                onPressed: () async {
                  var a = await Permisos.determinePosition();

                  setState(() {
                    Preferences.ubicacion = a;
                  });
                  if (a) {
                    showToast("Permisos de ubicacion aceptados");
                  }
                },
                label: Text("Aceptar", style: TextStyle(fontSize: 15.sp)),
                icon: Icon(
                    Preferences.ubicacion
                        ? Icons.location_on
                        : Icons.location_disabled,
                    size: 20.sp,
                    color: Preferences.ubicacion
                        ? ThemaMain.green
                        : ThemaMain.red)),
            Text(
                "La aplicacion enrutador, necesita acceso a los permisos de camara y galeria para poder tomar fotografias de los punteos y guardarlas, escanear documentos y/o obtenerla dentro de la galeria del dispositivo",
                style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic)),
            ElevatedButton.icon(
                onPressed: () async {
                  var a = await Permisos.camera();

                  setState(() {
                    Preferences.camara = a;
                  });
                  if (a) {
                    showToast("Permisos de camara aceptados");
                  }
                },
                label: Text("Aceptar", style: TextStyle(fontSize: 15.sp)),
                icon: Icon(
                    Preferences.camara ? Icons.camera_alt : Icons.camera_alt,
                    size: 20.sp,
                    color:
                        Preferences.camara ? ThemaMain.green : ThemaMain.red)),

            ///Text("La aplicacion enrutador, necesita acceso a los permisos de notificaciones para poder enviar notificaciones push a los usuarios",style: TextStyle(fontSize: 16.sp)),
            Text(
                "La aplicacion enrutador, necesita acceso a los contactos para obtener informacion de los usuarios, asi como detectar llamadas y localizar a los usuarios que coincidan con el numero de telefono guardado en la base de datos",
                style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic)),
            ElevatedButton.icon(
                onPressed: () async {
                  var a = await Permisos.phone();

                  setState(() {
                    Preferences.contactos = a;
                  });
                  if (a) {
                    showToast("Permisos de contactos aceptados");
                  }
                },
                label: Text("Aceptar", style: TextStyle(fontSize: 15.sp)),
                icon: Icon(
                    Preferences.contactos
                        ? Icons.contact_phone
                        : Icons.contact_emergency,
                    size: 20.sp,
                    color: Preferences.contactos
                        ? ThemaMain.green
                        : ThemaMain.red)),
                        Text(
                "La aplicacion enrutador, necesita acceso a permisos de notificaciones para dar avisos de actualizaciones y extras personalizadas segun el uso.",
                style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic)),
            ElevatedButton.icon(
                onPressed: () async {
                  var a = await Permisos.phone();

                  setState(() {
                    Preferences.contactos = a;
                  });
                  if (a) {
                    showToast("Permisos de contactos aceptados");
                  }
                },
                label: Text("Aceptar", style: TextStyle(fontSize: 15.sp)),
                icon: Icon(
                    Preferences.notificaciones
                        ? Icons.push
                        : Icons.contact_emergency,
                    size: 20.sp,
                    color: Preferences.contactos
                        ? ThemaMain.green
                        : ThemaMain.red))
          ]))
    ]));
  }
}
