import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

class RegionesMapa extends StatefulWidget {
  const RegionesMapa({super.key});

  @override
  State<RegionesMapa> createState() => _RegionesMapaState();
}

class _RegionesMapaState extends State<RegionesMapa> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text('Regiones de Mapas', style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton.filledTonal(
                  onPressed: () => Dialogs.showMorph(
                      title: "Descargar Zonas",
                      description:
                          "¿Deseas descargar zonas de mapa para usarlo sin conexión?",
                      loadingTitle: "Descargando Zonas",
                      onAcceptPressed: (context) {
                        provider.descargarZona = true;
                        Navigation.pop();
                      }),
                  icon: Icon(LineIcons.fileDownload,
                      size: 22.sp, color: Colors.green))
            ]),
        body: Center(child: Text('Regiones de Mapas')));
  }
}
