import 'package:enrutador/utilities/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../utilities/theme/theme_app.dart';
import '../../../utilities/theme/theme_color.dart';
import '../sliding_cards/tarjeta_contacto.dart';
import '../sliding_cards/tarjeta_seleccion.dart';

class MapSliding extends StatefulWidget {
  const MapSliding({super.key});

  @override
  State<MapSliding> createState() => _MapSlidingState();
}

class _MapSlidingState extends State<MapSliding> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        provider.slide.close();
      },
      child: SlidingUpPanel(
          isDraggable: true,
          backdropEnabled: true,
          renderPanelSheet: false,
          backdropTapClosesPanel: true,
          defaultPanelState: PanelState.CLOSED,
          minHeight: provider.selectRefencia != null
              ? 6.h
              : provider.cargaDatos
                  ? 4.h
                  : 0,
          maxHeight: 45.h,
          controller: provider.slide,
          panel: Column(
              mainAxisAlignment: provider.slide.isAttached
                  ? provider.slide.isPanelClosed
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end
                  : MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(children: [
                  Container(
                      decoration: BoxDecoration(
                          color: ThemaMain.background,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(borderRadius))),
                      width: 100.w,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        if (provider.cargaDatos)
                          Column(children: [
                            Text("Cargando datos"),
                            LinearProgressIndicator(
                                minHeight: 1.h,
                                value: (provider.cargaProgress == 0)
                                    ? null
                                    : (provider.cargaProgress /
                                        provider.cargaLenght),
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                backgroundColor: ThemaMain.dialogbackground,
                                color: ThemaMain.primary)
                          ]),
                        if (provider.selectRefencia != null) TarjetaSeleccion(),
                        TarjetaContacto()
                      ])),
                  if (!provider.cargaDatos)
                    Align(
                        child: Icon(Icons.drag_handle_rounded,
                            size: 20.sp, color: ThemaMain.darkBlue))
                ])
              ])),
    );
  }
}
