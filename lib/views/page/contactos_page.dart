import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/views/widgets/sliding_cards/slide_general.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../controllers/contacto_controller.dart';
import '../../controllers/contacto_fire.dart';
import '../../controllers/nota_controller.dart';
import '../../controllers/referencias_controller.dart';
import '../../models/contacto_model.dart';
import '../../utilities/services/dialog_services.dart';
import '../../utilities/textos.dart';
import '../../utilities/theme/theme_app.dart';
import '../../utilities/theme/theme_color.dart';
import '../widgets/card_contacto_widget.dart';

class ContactosPage extends StatefulWidget {
  final List<ContactoModelo> contactos;
  final bool carga;
  final Function() send;
  const ContactosPage({super.key, required this.contactos, required this.carga, required this.send});

  @override
  State<ContactosPage> createState() => _ContactosPageState();
}

class _ContactosPageState extends State<ContactosPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return !widget.carga
        ? Center(
            child: LoadingAnimationWidget.twoRotatingArc(
                color: ThemaMain.primary, size: 24.sp))
        : widget.contactos.isEmpty
            ? Center(
                child: Text("No se encontraron contactos pendientes a enviar",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)))
            : Scrollbar(
                child: StickyGroupedListView<ContactoModelo, String>(
                    floatingHeader: true,
                    elements: widget.contactos,
                    itemComparator: (a, b) => a.id!.compareTo(b.id!),
                    groupBy: (element) => element.modificado != null
                        ? Textos.fechaYMD(fecha: element.modificado!)
                        : "Sin fecha",
                    groupSeparatorBuilder: (element) => Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 2.w),
                        decoration: BoxDecoration(
                            color: ThemaMain.darkBlue,
                            borderRadius: BorderRadius.circular(borderRadius)),
                        child: Text(
                            element.modificado != null
                                ? Textos.fechaYMD(fecha: element.modificado!)
                                : "Sin fecha",
                            style: TextStyle(
                                fontSize: 16.sp,
                                color: ThemaMain.second,
                                fontWeight: FontWeight.bold))),
                    itemBuilder: (context, contacto) =>
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          SlideGeneral(
                              id: contacto.id!,
                              delete: () async {
                                await Dialogs.showMorph(
                                    title: "Eliminar envio",
                                    description:
                                        "¿Desea quitar este cambio de los pendientes?\nTodos los cambios se mantendran de manera local",
                                    loadingTitle: "Eliminando",
                                    onAcceptPressed: (context) async {
                                      var data =
                                          contacto.copyWith(pendiente: 0);
                                      await ContactoController.update(data);
                                      await widget.send();
                                    });
                              },
                              pendiente: () async {
                                var referencia =
                                    await ReferenciasController.getIdPrin(
                                        idContacto: contacto.id!,
                                        lat: contacto.latitud,
                                        lng: contacto.longitud,
                                        status: 1);

                                var notas = await NotasController.getContactoId(
                                    contacto.id!,
                                    pendiente: 1);
                                await Dialogs.showMorph(
                                    title: "Pendiente",
                                    description:
                                        "¿Desea enviar este contacto para que sea revisado?\nEstas enviando ${referencia.length} referencias y ${notas.length} notas ligadas a este contacto",
                                    loadingTitle: "Enviando",
                                    onAcceptPressed: (contexto) {});
                              },
                              directo: () {
                                Dialogs.showMorph(
                                    title: "Sincronizar",
                                    description:
                                        "¿Desea guardar este contacto con sus cambios de manera directa? ",
                                    loadingTitle: "Guardando",
                                    onAcceptPressed: (contexto) async {
                                      var data = contacto.copyWith(
                                          pendiente: 0,
                                          aceptadoEmpleado: provider
                                              .usuario?.empleadoId
                                              ?.toString());
                                      var result = await ContactoFire.send(
                                          contacto: data);
                                      if (result) {
                                        await ContactoController.update(data);
                                        await widget.send();
                                        showToast("Contacto enviado");
                                      } else {
                                        showToast("Error al enviar datos");
                                      }
                                    });
                              },
                              model: CardContactoWidget(
                                  compartir: false,
                                  entrada: "",
                                  funContact: (p0) {},
                                  selectedVisible: false,
                                  onSelected: (p0) {},
                                  contacto: contacto)),
                        ])));
  }
}
