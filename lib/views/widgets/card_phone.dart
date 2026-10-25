import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/number_fun.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:phone_state/phone_state.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/contacto_controller.dart';
import '../../utilities/main_provider.dart';

class PhoneStateWidget extends StatelessWidget {
  const PhoneStateWidget({super.key});

  /// Normaliza el numero entrante y busca el contacto con multiples estrategias
  /// para cubrir variaciones de formato (codigo de pais, lada, guiones, espacios).
  static Future<List<ContactoModelo>> _buscarContacto(
      String? rawNumber) async {
    if (rawNumber == null || rawNumber.isEmpty) return [];

    // 1. Extraer solo digitos del numero entrante
    final soloDigitos = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (soloDigitos.isEmpty) return [];

    // 2. Intentar con el numero formateado por NumberFun (metodo original)
    final formateado =
        NumberFun.formatNumber(rawNumber).replaceAll(RegExp(r'\D'), '');

    // 3. Preparar variantes de busqueda (de mas especifica a menos)
    final variantes = <String>{};

    // Numero completo en digitos puros
    if (soloDigitos.length >= 7) variantes.add(soloDigitos);

    // Numero formateado por la libreria (sin espacios ni caracteres especiales)
    if (formateado.length >= 7 && formateado != soloDigitos) {
      variantes.add(formateado);
    }

    // Ultimos 10 digitos (numero nacional mexicano estandar)
    if (soloDigitos.length > 10) {
      variantes.add(soloDigitos.substring(soloDigitos.length - 10));
    }

    // Ultimos 7 digitos (numero local sin lada)
    if (soloDigitos.length > 7) {
      variantes.add(soloDigitos.substring(soloDigitos.length - 7));
    }

    // 4. Buscar con cada variante hasta encontrar resultados
    for (final variante in variantes) {
      final resultados = await ContactoController.buscar(variante, 2);
      if (resultados.isNotEmpty) return resultados;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return StreamBuilder<PhoneState>(
        stream: PhoneState.stream,
        builder: (context, snapshot) => snapshot.data?.status ==
                PhoneStateStatus.CALL_INCOMING
            ? AnimatedOpacity(
                opacity: snapshot.data?.status == PhoneStateStatus.CALL_INCOMING
                    ? 1
                    : 0,
                duration: Durations.medium3,
                child: FutureBuilder<List<ContactoModelo>>(
                    future: _buscarContacto(snapshot.data?.number),
                    builder: (context, contacto) => InkWell(
                        borderRadius: BorderRadius.circular(borderRadius),
                        onTap: () async {
                          if (contacto.hasData && contacto.data!.isNotEmpty) {
                            await provider.animaMap.centerOnPoint(
                                LatLng(contacto.data!.firstOrNull!.latitud,
                                    contacto.data!.firstOrNull!.longitud),
                                zoom: 18);
                          }
                        },
                        child: Card(
                            elevation: 2,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1.w),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle,
                                                color: ThemaMain.green,
                                                size: 28.sp),
                                            RiveAnimatedIcon(
                                                riveIcon: RiveIcon.call,
                                                strokeWidth: 2.h,
                                                height: 4.h,
                                                width: 4.h),
                                          ]),
                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                                width: 30.w,
                                                child: AutoSizeText(
                                                    contacto.hasData
                                                        ? contacto.data!
                                                                .map((e) => e
                                                                    .nombreCompleto)
                                                                .toList()
                                                                .firstOrNull ??
                                                            "Llamando...\nDesconocido"
                                                        : "Llamando...\nDesconocido",
                                                    maxLines: 2,
                                                    minFontSize: 14,
                                                    textAlign: TextAlign.end,
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold)))
                                          ])
                                    ]))))))
            : SizedBox());
  }
}

