import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/card_contacto_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool press = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.all(10.sp),
        child: Column(children: [
          AnimatedContainer(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(4, 4))
                  ]),
              width: press ? 95.w : 28.sp,
              duration: Durations.medium3,
              child: press
                  ? Column(children: [
                      TextFormField(
                          controller: provider.buscar,
                          onChanged: (value) => setState(() {
                                provider.buscar.text = value;
                              }),
                          style: TextStyle(fontSize: 18.sp),
                          decoration: InputDecoration(
                              fillColor: ThemaMain.second,
                              prefixIcon: IconButton(
                                  iconSize: 20.sp,
                                  onPressed: () {
                                    setState(() {
                                      press = !press;
                                    });
                                    if (!press) {
                                      provider.buscar.clear();
                                    }
                                  },
                                  icon: Icon(Icons.arrow_back,
                                      color: ThemaMain.red)),
                              label: Text(
                                  "Nombre | PlusCode | Telefono(s)${kDebugMode ? " | What3Word" : ""}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16.sp,
                                      color: ThemaMain.darkGrey)),
                              suffixIcon: IconButton.filledTonal(
                                  iconSize: 22.sp,
                                  onPressed: () {},
                                  icon: Icon(Icons.youtube_searched_for,
                                      color: ThemaMain.green)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 1.h))),
                      if (provider.buscar.text != "")
                        FutureBuilder(
                            future: ContactoController.buscar(
                                provider.buscar.text, 6),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                    constraints:
                                        BoxConstraints(maxHeight: 40.h),
                                    child: Scrollbar(
                                        child: ListView.builder(
                                            itemCount: snapshot.data!.length,
                                            shrinkWrap: true,
                                            padding: EdgeInsets.all(0),
                                            itemBuilder: (context, index) {
                                              final contacto =
                                                  snapshot.data![index];
                                              return CardContactoWidget(
                                                  contacto: contacto,
                                                  funContact: (p0) async {
                                                    provider.animaMap
                                                        .centerOnPoint(
                                                            LatLng(
                                                                contacto
                                                                    .latitud,
                                                                contacto
                                                                    .longitud),
                                                            zoom: 18);
                                                    provider.contacto =
                                                        await ContactoController
                                                            .getItem(
                                                                lat: contacto
                                                                    .latitud,
                                                                lng: contacto
                                                                    .longitud);
                                                    provider.buscar.clear();
                                                    press = false;
                                                    await provider.slide.open();
                                                  },
                                                  compartir: false,
                                                  selectedVisible: false,
                                                  selected: null,
                                                  onSelected: (p0) {});
                                            })));
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              } else {
                                return LinearProgressIndicator();
                              }
                            }),
                    ])
                  : IconButton.filled(
                      iconSize: 24.sp,
                      onPressed: () => setState(() {
                            press = !press;
                          }),
                      icon: Icon(Icons.search, color: ThemaMain.green))),
        ]));
  }
}
