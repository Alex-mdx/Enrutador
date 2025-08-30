import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class DialogDireccion extends StatefulWidget {
  final DateTime? fecha;
  final String? word;
  final Function(String?) fun;
  const DialogDireccion(
      {super.key, required this.fecha, required this.fun, required this.word});

  @override
  State<DialogDireccion> createState() => _DialogDireccionState();
}

class _DialogDireccionState extends State<DialogDireccion> {
  TextEditingController calle = TextEditingController();
  TextEditingController nint = TextEditingController();
  TextEditingController next = TextEditingController();

  TextEditingController cruz1 = TextEditingController();
  TextEditingController cruz2 = TextEditingController();
  TextEditingController colonia = TextEditingController();
  TextEditingController postal = TextEditingController();
  @override
  void initState() {
    super.initState();
    calle = TextEditingController(
        text: Textos.obtenerEntre(
            palabra: widget.word ?? "", palabra1: "C. ", palabra2: ","));
    nint = TextEditingController(
        text: Textos.obtenerEntre(
            palabra: widget.word ?? "", palabra1: "int: ", palabra2: " y"));
    next = TextEditingController(
        text: Textos.obtenerEntre(
            palabra: widget.word ?? "", palabra1: "ext: ", palabra2: ","));
    cruz1 = TextEditingController(
        text: Textos.obtenerEntre(
            palabra: widget.word ?? "",
            palabra1: " entre cruz. 1: ",
            palabra2: " x"));
    cruz2 = TextEditingController(
        text: Textos.obtenerEntre(
            palabra: widget.word ?? "", palabra1: " cruz. 2: ", palabra2: ","));
    colonia = TextEditingController(
        text: Textos.obtenerEntre(
            palabra: widget.word ?? "", palabra1: "Colonia: ", palabra2: ","));
    postal = TextEditingController(
        text: Textos.obtenerEntre(
            palabra: widget.word ?? "", palabra1: "CP: ", palabra2: "."));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text("Ingresar Domicilio",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
      Divider(),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(children: [
            if (widget.fecha != null)
              Text(
                  "Ultima modificacion: ${Textos.fechaYMDHMS(fecha: widget.fecha!)}",
                  style:
                      TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic)),
            Wrap(
                runSpacing: .5.h,
                alignment: WrapAlignment.spaceAround,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(
                        width: 25.w,
                        child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: calle,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecoration(
                                labelText: "Calle",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h)))),
                    Text(", "),
                    SizedBox(
                        width: 24.w,
                        child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: nint,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecoration(
                                labelText: "Num. Interior",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h)))),
                    Text(" y "),
                    SizedBox(
                        width: 24.w,
                        child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: next,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecoration(
                                labelText: "Num. Exterior",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h))))
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Entre: "),
                    SizedBox(
                        width: 25.w,
                        child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: cruz1,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecoration(
                                labelText: "Cruz. 1",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h)))),
                    Text(" x "),
                    SizedBox(
                        width: 25.w,
                        child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: cruz2,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecoration(
                                labelText: "Cruz. 2",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h))))
                  ]),
                  SizedBox(
                      width: 35.w,
                      child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: colonia,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.streetAddress,
                          decoration: InputDecoration(
                              labelText: "Colonia",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 1.h)))),
                  SizedBox(
                      width: 35.w,
                      child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: postal,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: "Codigo Postal",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 1.h))))
                ]),
            Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton.icon(
                  icon: Icon(Icons.close, size: 22.sp, color: ThemaMain.red),
                  onPressed: () => Navigation.pop(),
                  label: Text("Cerrar", style: TextStyle(fontSize: 16.sp))),
              ElevatedButton.icon(
                  icon: Icon(LineIcons.userCheck,
                      size: 22.sp, color: ThemaMain.green),
                  onPressed: () async {
                    await widget.fun(
                        "C. ${calle.text}, int: ${nint.text} y ext: ${next.text}, entre cruz. 1: ${cruz1.text} x cruz. 2: ${cruz2.text}, Colonia: ${colonia.text}, CP: ${postal.text}.");
                    Navigation.pop();
                  },
                  label: Text("Aceptar", style: TextStyle(fontSize: 16.sp)))
            ])
          ]))
    ]));
  }
}
