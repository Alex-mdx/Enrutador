import 'package:enrutador/controllers/contacto_fire.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/sliding_cards/tarjeta_contacto_detalle.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DialogComparativa extends StatefulWidget {
  final ContactoModelo entrada;
  const DialogComparativa({super.key, required this.entrada});

  @override
  State<DialogComparativa> createState() => _DialogComparativaState();
}

class _DialogComparativaState extends State<DialogComparativa> {
  late ContactoModelo? salida;
  final controller = PageController();
  bool cargando = true;
  @override
  void initState() {
    super.initState();
    initEntrada();
  }

  Future<void> initEntrada() async {
    try {
      salida = await ContactoFire.getItem(id: widget.entrada.id);
      setState(() {
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SizedBox(
            height: 40.h,
            child: cargando
                ? Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                        color: ThemaMain.primary, size: 30.sp))
                : Column(children: [
                    Expanded(
                        child: PageView(controller: controller, children: [
                      Column(children: [
                        Padding(
                            padding: EdgeInsets.all(8.sp),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.youtube_searched_for,
                                  size: 20.sp, color: ThemaMain.primary),
                              Text('Pendiente a enviar',
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold))
                            ])),
                        Center(
                            child: TarjetaContactoDetalle(
                                compartir: true, contacto: widget.entrada))
                      ]),
                      Column(children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.cloud_upload,
                              size: 20.sp, color: ThemaMain.green),
                          Text("En servidor",
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold))
                        ]),
                        Center(
                            child: salida == null
                                ? Text(
                                    "No existe coincidencia / No se encontro en el servidor")
                                : TarjetaContactoDetalle(
                                    compartir: true, contacto: salida!))
                      ])
                    ])),
                    Divider(),
                    Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: SmoothPageIndicator(
                            controller: controller,
                            count: 2,
                            effect:
                                WormEffect(activeDotColor: ThemaMain.primary),
                            onDotClicked: (index) async =>
                                await controller.animateToPage(index,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeIn)))
                  ])));
  }
}
