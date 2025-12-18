import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/controllers/estado_controller.dart';
import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/pluscode_fun.dart';
import 'package:enrutador/views/dialogs/dialog_send.dart';
import 'package:enrutador/views/dialogs/dialogs_comunicar.dart';
import 'package:enrutador/views/dialogs/dialogs_estado_funcion.dart';
import 'package:enrutador/views/widgets/chip_referencia.dart';
import 'package:enrutador/views/widgets/sliding_cards/tarjeta_contacto_foto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../controllers/contacto_controller.dart';
import '../../../controllers/enrutar_controller.dart';
import '../../../controllers/tipo_controller.dart';
import '../../../models/contacto_model.dart';
import '../../../models/referencia_model.dart';
import '../../../utilities/services/dialog_services.dart';
import '../../../utilities/textos.dart';
import '../../../utilities/theme/theme_color.dart';
import '../../dialogs/dialog_archivo.dart';
import '../../dialogs/dialog_direccion.dart';
import '../../dialogs/dialog_tipos_all.dart';

class TarjetaContactoDetalle extends StatefulWidget {
  final ContactoModelo? contacto;
  final bool compartir;
  const TarjetaContactoDetalle(
      {super.key, required this.contacto, required this.compartir});

  @override
  State<TarjetaContactoDetalle> createState() => _TarjetaContactoDetalleState();
}

class _TarjetaContactoDetalleState extends State<TarjetaContactoDetalle> {
  Future<void> funcion({required ContactoModelo contacto}) async {
    var data =
        await EnrutarController.getItemContacto(contactoId: contacto.id!);

    if (data != null) {
      var newEnrutar = data.copyWith(buscar: contacto);
      await EnrutarController.update(newEnrutar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Card(
        color: ThemaMain.dialogbackground,
        child: AnimatedContainer(
            duration: Durations.medium1,
            height: widget.contacto?.id == null
                ? 0.h
                : widget.compartir
                    ? 29.h
                    : 27.h,
            child: Row(children: [
              Expanded(
                  flex: widget.compartir ? 8 : 4,
                  child: TarjetaContactoFoto(
                      contacto: widget.contacto, compartir: widget.compartir)),
              VerticalDivider(
                  width: widget.compartir ? 1.w : 2.sp,
                  indent: 1.h,
                  endIndent: 1.h),
              Expanded(
                  flex: 12,
                  child: Scrollbar(
                      child: ListView(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!widget.compartir)
                                  TextButton.icon(
                                      onLongPress: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text: widget
                                                    .contacto?.nombreCompleto ??
                                                "Nombre: Sin nombre"));
                                        showToast("Nombre copiado");
                                      },
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                  horizontal: 1.w,
                                                  vertical: 0))),
                                      onPressed: () => showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) => DialogSend(
                                              entradaTexto: widget
                                                  .contacto?.nombreCompleto,
                                              fun: (p0) async {
                                                var newModel = widget.contacto
                                                    ?.copyWith(
                                                        nombreCompleto:
                                                            Textos.normalizar(
                                                                p0 ?? ""));
                                                await ContactoController.update(
                                                    newModel!);
                                                funcion(contacto: newModel);
                                                provider.contacto = newModel;
                                              },
                                              tipoTeclado: TextInputType.name,
                                              fecha: null,
                                              cabeza:
                                                  "Ingresar nombre del contacto")),
                                      label: Text(
                                          widget.contacto?.nombreCompleto ??
                                              "Nombre: Sin nombre",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)))
                                else
                                  Text(
                                      widget.contacto?.nombreCompleto ??
                                          "Nombre: Sin nombre",
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold)),
                                if (!widget.compartir)
                                  TextButton.icon(
                                      onLongPress: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text: widget.contacto?.domicilio ??
                                                "Domicilio: Sin Domicilio"));
                                        showToast("Domicilio copiado");
                                      },
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                  horizontal: 1.w,
                                                  vertical: 0))),
                                      onPressed: () => showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) => DialogDireccion(
                                              word: widget.contacto?.domicilio,
                                              fun: (p0) async {
                                                var newModel = widget.contacto
                                                    ?.copyWith(
                                                        domicilio: p0,
                                                        fechaDomicilio:
                                                            DateTime.now());
                                                await ContactoController.update(
                                                    newModel!);
                                                funcion(contacto: newModel);
                                                provider.contacto = newModel;
                                              },
                                              fecha: widget
                                                  .contacto?.fechaDomicilio)),
                                      label: AutoSizeText(
                                          widget.contacto?.domicilio ??
                                              "Domicilio: Sin Domicilio",
                                          style: TextStyle(fontSize: 16.sp),
                                          minFontSize: 13,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis))
                                else
                                  AutoSizeText(
                                      widget.contacto?.domicilio ??
                                          "Domicilio: Sin Domicilio",
                                      style: TextStyle(fontSize: 16.sp),
                                      minFontSize: 12,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis)
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!widget.compartir)
                                  TextButton.icon(
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                  horizontal: 1.w,
                                                  vertical: 0))),
                                      onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) => DialogTiposAll(
                                              fecha: widget.contacto?.tipoFecha,
                                              selected: (p0) async {
                                                var newModel = widget.contacto
                                                    ?.copyWith(
                                                        tipo: p0.id,
                                                        tipoFecha:
                                                            DateTime.now());
                                                debugPrint(
                                                    "${newModel?.tipo ?? "Sin tipo"}");
                                                await ContactoController.update(
                                                    newModel!);
                                                funcion(contacto: newModel);
                                                provider.contacto = newModel;
                                              })),
                                      label: FutureBuilder(
                                          future: TipoController.getItem(
                                              data:
                                                  widget.contacto?.tipo ?? -1),
                                          builder: (context, data) {
                                            return Text(
                                                "Tipo: ${data.data?.nombre ?? "Ø"}",
                                                style: TextStyle(
                                                    shadows: [Shadow()],
                                                    color: data.data?.color,
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.bold));
                                          }))
                                else
                                  FutureBuilder(
                                      future: TipoController.getItem(
                                          data: widget.contacto?.tipo ?? -1),
                                      builder: (context, data) => Text(
                                          data.data?.nombre ?? "Sin tipo",
                                          style: TextStyle(
                                              color: data.data?.color,
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold))),
                                if (!widget.compartir)
                                  TextButton.icon(
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                  horizontal: 1.w,
                                                  vertical: 0))),
                                      onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              DialogsEstadoFuncion(
                                                  fecha: widget
                                                      .contacto?.estadoFecha,
                                                  contacto: provider.contacto!,
                                                  estatus: (p0) async {
                                                    var newModel = widget
                                                        .contacto
                                                        ?.copyWith(
                                                            estado: p0,
                                                            estadoFecha:
                                                                DateTime.now());
                                                    await ContactoController
                                                        .update(newModel!);
                                                    funcion(contacto: newModel);
                                                    provider.contacto =
                                                        newModel;
                                                  })),
                                      label: FutureBuilder(
                                          future: EstadoController.getItem(
                                              data: widget.contacto?.estado ??
                                                  -1),
                                          builder: (context, data) {
                                            return Text(
                                                "Estado: ${data.data?.nombre ?? "Ø"}",
                                                style: TextStyle(
                                                    color: data.data?.color,
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.bold));
                                          }))
                                else
                                  FutureBuilder(
                                      future: EstadoController.getItem(
                                          data: widget.contacto?.estado ?? -1),
                                      builder: (context, data) => Text(
                                          data.data?.nombre ?? "Sin estado",
                                          style: TextStyle(
                                              color: data.data?.color,
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold)))
                              ]),
                          if (widget.compartir)
                            Text(
                                "PlusCode: ${PlusCodeFun.psCODE(widget.contacto?.latitud ?? 0, widget.contacto?.longitud ?? 0)}",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold)),
                          if (widget.compartir)
                            Text(
                                "W3W: ${widget.contacto?.what3Words ?? "[No Encontrado]"} ",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold)),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!widget.compartir)
                                  ElevatedButton.icon(
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                  vertical: 0,
                                                  horizontal: 1.w))),
                                      iconAlignment: IconAlignment.end,
                                      onLongPress: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text: widget.contacto?.numero
                                                    .toString() ??
                                                "Sin numero"));
                                        showToast("Telefono principal copiado");
                                      },
                                      onPressed: () {
                                        Iterable<PhoneNumber> country;
                                        country = PhoneNumber
                                            .findPotentialPhoneNumbers(
                                                (widget.contacto?.numero ?? "0")
                                                    .toString());
                                        debugPrint(
                                            "${country.toList().map((e) => e).toList()}");
                                        String? lada =
                                            country.firstOrNull?.countryCode;
                                        debugPrint(lada);
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) => DialogSend(
                                                lenght: 10,
                                                lada: lada == null
                                                    ? null
                                                    : "+$lada",
                                                entradaTexto: (widget
                                                            .contacto?.numero ??
                                                        "")
                                                    .toString()
                                                    .replaceFirst("$lada", ""),
                                                fun: (p0) async {
                                                  if (int.tryParse(
                                                          p0.toString()) !=
                                                      null) {
                                                    var newModel = widget
                                                        .contacto
                                                        ?.copyWith(
                                                            numero: int.parse(
                                                                p0.toString()),
                                                            numeroFecha:
                                                                DateTime.now());
                                                    await ContactoController
                                                        .update(newModel!);
                                                    funcion(contacto: newModel);
                                                    provider.contacto =
                                                        newModel;
                                                  } else {
                                                    showToast(
                                                        "Numero ingresado no valido");
                                                  }
                                                },
                                                tipoTeclado:
                                                    TextInputType.phone,
                                                fecha: widget
                                                    .contacto?.numeroFecha,
                                                cabeza:
                                                    "Ingresar numero telefonico del contacto"));
                                      },
                                      label: Text("Telefono\n${PhoneNumber.findPotentialPhoneNumbers((widget.contacto?.numero ?? "0").toString()).firstOrNull?.formatNsn() ?? 0}",
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold)),
                                      icon: PhoneNumber.findPotentialPhoneNumbers((widget.contacto?.numero ?? "0").toString())
                                                  .firstOrNull
                                                  ?.isValid(
                                                      type: PhoneNumberType
                                                          .mobile) ??
                                              false
                                          ? GestureDetector(
                                              onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      DialogsComunicar(number: (widget.contacto?.numero ?? 0).toString())),
                                              child: Stack(alignment: Alignment.center, children: [
                                                Icon(Icons.circle,
                                                    size: 24.sp,
                                                    color: ThemaMain.green),
                                                Icon(LineIcons.tty,
                                                    size: 20.sp,
                                                    color: ThemaMain.second)
                                              ]))
                                          : null)
                                else
                                  Text(
                                      "Telefono\n${PhoneNumber.findPotentialPhoneNumbers((widget.contacto?.numero ?? "0").toString()).firstOrNull?.formatNsn() ?? 0}",
                                      style: TextStyle(fontSize: 14.sp)),
                                if (!widget.compartir)
                                  ElevatedButton.icon(
                                      style: ButtonStyle(
                                          padding: WidgetStatePropertyAll(
                                              EdgeInsets.symmetric(
                                                  vertical: 0,
                                                  horizontal: 1.w))),
                                      iconAlignment: IconAlignment.start,
                                      onLongPress: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text: widget.contacto?.otroNumero
                                                    .toString() ??
                                                "Sin numero"));
                                        showToast(
                                            "Telefono alternativo copiado");
                                      },
                                      onPressed: () {
                                        Iterable<PhoneNumber> country;
                                        country = PhoneNumber
                                            .findPotentialPhoneNumbers(
                                                (widget.contacto?.otroNumero ??
                                                        "0")
                                                    .toString());
                                        debugPrint(
                                            "${country.toList().map((e) => e).toList()}");
                                        String? lada =
                                            country.firstOrNull?.countryCode;
                                        debugPrint(lada);
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) => DialogSend(
                                                lenght: 10,
                                                lada: lada == null
                                                    ? null
                                                    : "+$lada",
                                                entradaTexto: (widget.contacto
                                                            ?.otroNumero ??
                                                        "")
                                                    .toString()
                                                    .replaceFirst("$lada", ""),
                                                fun: (p0) async {
                                                  if (int.tryParse(
                                                          p0.toString()) !=
                                                      null) {
                                                    var newModel = widget
                                                        .contacto
                                                        ?.copyWith(
                                                            otroNumero:
                                                                int.parse(p0
                                                                    .toString()),
                                                            otroNumeroFecha:
                                                                DateTime.now());
                                                    await ContactoController
                                                        .update(newModel!);
                                                    funcion(contacto: newModel);
                                                    provider.contacto =
                                                        newModel;
                                                  } else {
                                                    showToast(
                                                        "Numero ingresado no valido");
                                                  }
                                                },
                                                tipoTeclado:
                                                    TextInputType.phone,
                                                fecha: widget
                                                    .contacto?.otroNumeroFecha,
                                                cabeza:
                                                    "Ingresar numero alternatico del contacto"));
                                      },
                                      label: Text("Otro Tel\n${PhoneNumber.findPotentialPhoneNumbers((widget.contacto?.otroNumero ?? "0").toString()).firstOrNull?.formatNsn() ?? 0}",
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold)),
                                      icon: PhoneNumber.findPotentialPhoneNumbers((widget.contacto?.otroNumero ?? "0").toString())
                                                  .firstOrNull
                                                  ?.isValid(
                                                      type: PhoneNumberType
                                                          .mobile) ??
                                              false
                                          ? GestureDetector(
                                              onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      DialogsComunicar(number: (widget.contacto?.otroNumero ?? 0).toString())),
                                              child: Stack(alignment: Alignment.center, children: [
                                                Icon(Icons.circle,
                                                    size: 24.sp,
                                                    color: ThemaMain.green),
                                                Icon(LineIcons.tty,
                                                    size: 20.sp,
                                                    color: ThemaMain.second)
                                              ]))
                                          : null)
                                else
                                  Text(
                                      "Otro Telefono\n${PhoneNumber.findPotentialPhoneNumbers((widget.contacto?.otroNumero ?? "0").toString()).firstOrNull?.formatNsn() ?? 0}",
                                      style: TextStyle(fontSize: 14.sp))
                              ]),
                          if (!widget.compartir)
                            Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: .5.w,
                                children: [
                                  InkWell(
                                      onTap: () => (provider.selectRefencia ==
                                              null)
                                          ? Dialogs.showMorph(
                                              title: "Ingresar referencia",
                                              description:
                                                  "Seleccione otro contacto para que sea referencia de este mismo",
                                              loadingTitle: "cargando",
                                              onAcceptPressed: (context) async {
                                                provider.selectRefencia =
                                                    ReferenciaModelo(
                                                        id: null,
                                                        idForanea:
                                                            widget.contacto!.id,
                                                        rolId: null,
                                                        contactoIdLat: widget
                                                                .contacto
                                                                ?.latitud ??
                                                            0,
                                                        idRForenea: null,
                                                        contactoIdLng: widget
                                                                .contacto
                                                                ?.longitud ??
                                                            0,
                                                        contactoIdRLat: null,
                                                        contactoIdRLng: null,
                                                        buscar: -1,
                                                        tipoCliente: -1,
                                                        estatus: -1,
                                                        fecha: DateTime.now());
                                              })
                                          : null,
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.person_add,
                                                color: ThemaMain.green,
                                                size: 6.w),
                                            Text("Ref(s):",
                                                style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ])),
                                  Wrap(
                                      runAlignment: WrapAlignment.spaceBetween,
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: .5.w,
                                      runSpacing: 0,
                                      children: [
                                        FutureBuilder(
                                            future:
                                                ReferenciasController.getIdPrin(
                                                    idContacto:
                                                        widget.contacto?.id,
                                                    lat: widget
                                                        .contacto?.latitud,
                                                    lng: widget
                                                        .contacto?.longitud),
                                            builder: (context, snapshot) => Wrap(
                                                runSpacing: 0,
                                                spacing: .5.w,
                                                children: snapshot.data
                                                        ?.map((e) => ChipReferencia(
                                                            ref: e,
                                                            provider: provider,
                                                            latlng: LatLng(
                                                                e.contactoIdRLat ??
                                                                    0,
                                                                e.contactoIdRLng ??
                                                                    0),
                                                            origen: true))
                                                        .toList() ??
                                                    [])),
                                        SizedBox(
                                            height: 3.5.h,
                                            width: .5.w,
                                            child: VerticalDivider())
                                      ]),
                                  FutureBuilder(
                                      future: ReferenciasController.getIdR(
                                          idRContacto: widget.contacto?.id,
                                          lat: widget.contacto?.latitud,
                                          lng: widget.contacto?.longitud),
                                      builder: (context, snapshot) => Wrap(
                                          runSpacing: 0,
                                          spacing: .5.w,
                                          children: snapshot.data
                                                  ?.map((e) => ChipReferencia(
                                                      ref: e,
                                                      provider: provider,
                                                      latlng: LatLng(
                                                          e.contactoIdLat,
                                                          e.contactoIdLng),
                                                      origen: false))
                                                  .toList() ??
                                              []))
                                ]),
                          if (!widget.compartir)
                            TextButton(
                                onPressed: () => showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => DialogSend(
                                        entradaTexto: widget.contacto?.nota,
                                        fun: (p0) async {
                                          var newModel = widget.contacto
                                              ?.copyWith(nota: p0);
                                          await ContactoController.update(
                                              newModel!);
                                          provider.contacto = newModel;
                                        },
                                        tipoTeclado: TextInputType.multiline,
                                        fecha: null,
                                        input: TextInputAction.newline,
                                        cabeza: "Ingresar notas del contacto")),
                                child: AutoSizeText(
                                    "Notas\n${widget.contacto?.nota ?? "Sin notas"}",
                                    style: TextStyle(fontSize: 16.sp),
                                    minFontSize: 13,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis))
                          else
                            AutoSizeText(
                                "Notas\n${widget.contacto?.nota ?? "Sin notas"}",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                                minFontSize: 10,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis),
                          if (!widget.compartir && kDebugMode)
                            ElevatedButton.icon(
                                onPressed: () => showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) => DialogArchivo(
                                        contacto: widget.contacto!)),
                                icon: Icon(Icons.attachment,
                                    size: 20.sp, color: ThemaMain.pink),
                                label: Text("Archivos",
                                    style: TextStyle(fontSize: 16.sp)))
                        ])
                  ])))
            ])));
  }
}
