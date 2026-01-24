import 'package:enrutador/utilities/permisos.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

class DialogPoliticaUso extends StatefulWidget {
  const DialogPoliticaUso({super.key});

  @override
  State<DialogPoliticaUso> createState() => _DialogPoliticaUsoState();
}

class _DialogPoliticaUsoState extends State<DialogPoliticaUso> {
  final double size = 17.sp;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Permisos.permisosPoliticas();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.sp)),
        child: Container(
            padding: EdgeInsets.all(10.sp),
            constraints: BoxConstraints(
                maxHeight: 85.h),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Política de Uso",
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              const Divider(),
              Flexible(
                  child: Expanded(
                      child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          thickness: 6.sp,
                          radius: Radius.circular(10.sp),
                          child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPermissionSection(
                                        "Ubicación",
                                        "La aplicación enrutador necesita acceso a los permisos de ubicación para navegar en el mapa, recolectar punteos, coordenadas y visualizar la posición del dispositivo.",
                                        Preferences.ubicacion,
                                        Icons.location_on, () async {
                                      var a =
                                          await Permisos.determinePosition();

                                      if (a) {
                                        setState(
                                            () => Preferences.ubicacion = a);
                                        showToast(
                                            "Permisos de ubicación aceptados");
                                      }
                                    }),
                                    _buildPermissionSection(
                                        "Cámara y Galería",
                                        "Necesitamos acceso a la cámara y galería para tomar fotografías de los punteos, escanear documentos u obtener imágenes guardadas.",
                                        Preferences.camara,
                                        Icons.camera_alt, () async {
                                      var a = await Permisos.camera();

                                      if (a) {
                                        setState(() => Preferences.camara = a);
                                        showToast(
                                            "Permisos de cámara aceptados");
                                      }
                                    }),
                                    _buildPermissionSection(
                                        "Contactos y Llamadas",
                                        "Acceso a contactos para obtener información de usuarios, detectar llamadas y localizar coincidencias en la base de datos.",
                                        Preferences.contactos,
                                        Icons.contact_phone, () async {
                                      var a = await Permisos.phone();

                                      if (a) {
                                        setState(
                                            () => Preferences.contactos = a);
                                        showToast(
                                            "Permisos de contactos aceptados");
                                      }
                                    }),
                                    /* _buildPermissionSection(
                                        "Notificaciones",
                                        "Permisos para dar avisos de actualizaciones, alertas de comunidad y extras personalizadas según el uso.",
                                        Preferences.notificaciones,
                                        Icons.notifications_active, () async {
                                      var a = await Permisos.phone();
                                      
                                      if (a){
                                        setState(
                                          () => Preferences.notificaciones = a);
                                        showToast(
                                            "Permisos de notificaciones aceptados");}
                                    }) */
                                  ]))))),
              const Divider(),
              Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () => Navigation.pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ThemaMain.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.sp))),
                      child: Text(
                          "Entendido ${[
                            Preferences.ubicacion,
                            Preferences.camara,
                            Preferences.contactos,
                            kDebugMode ? Preferences.notificaciones : false
                          ].where((element) => element == true).length}/${kDebugMode ? 4 : 3}",
                          style: TextStyle(fontSize: 15.sp))))
            ])));
  }
}

Widget _buildPermissionSection(String title, String desc, bool status,
    IconData icon, VoidCallback onAction) {
  return Padding(
      padding: EdgeInsets.only(bottom: 15.sp, right: 10.sp),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(spacing: 2.w, children: [
          Icon(icon,
              size: 22.sp, color: status ? ThemaMain.green : ThemaMain.red),
          Text(title,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold))
        ]),
        Text(desc,
            style: TextStyle(fontSize: 16.sp, fontStyle: FontStyle.italic)),
        SizedBox(height: 5.sp),
        Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(status ? Icons.check_circle : Icons.add_moderator,
                    size: 16.sp),
                label: Text(status ? "Permitido" : "Activar",
                    style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                    foregroundColor: status ? ThemaMain.green : ThemaMain.red,
                    padding: EdgeInsets.symmetric(horizontal: 2.w))))
      ]));
}
