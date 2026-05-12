import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:badges/badges.dart' as bd;
import '../../../controllers/contacto_controller.dart';
import '../../dialogs/dialog_setting.dart';
import '../card_accout.dart';

class SideButtons extends StatelessWidget {
  const SideButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Container(
        color: ThemaMain.appbar,
        child: Column(children: [
          SizedBox(height: 10.h),
          GestureDetector(
              onTap: () async => await Navigation.pushNamed(route: "contactos"),
              child: FutureBuilder(
                  future: ContactoController.getCountPendiente(),
                  builder: (context, snapshot) => bd.Badge(
                      showBadge: snapshot.hasData || snapshot.data == 1,
                      badgeStyle: bd.BadgeStyle(badgeColor: ThemaMain.red),
                      badgeAnimation: bd.BadgeAnimation.slide(),
                      position: bd.BadgePosition.topEnd(top: -10, end: 0),
                      badgeContent: Text(snapshot.data.toString(),
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Contactos",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.connect_without_contact,
                                        size: 22.sp, color: ThemaMain.darkGrey)
                                  ])))))),
          if (kDebugMode)
            cards(context, () async {}, "Zonas", LineIcons.mapMarked,
                ThemaMain.red),
          cards(context, () async => await Navigation.pushNamed(route: "tipos"),
              "Tipos", Icons.type_specimen, ThemaMain.primary),
          cards(
              context,
              () async => await Navigation.pushNamed(route: "estatus"),
              "Estatus",
              Icons.contact_emergency,
              ThemaMain.darkBlue),
          cards(
              context,
              () async => await Navigation.pushNamed(route: "navegar"),
              "Navegar",
              LineIcons.globe,
              ThemaMain.green),
          cards(context, () async => await Navigation.pushNamed(route: "roles"),
              "Roles", LineIcons.userTag, ThemaMain.darkBlue),
          cards(context, () async => await Navigation.pushNamed(route: "lada"),
              "Lada", Icons.perm_phone_msg, ThemaMain.pink),
          cards(
              context,
              () async => await Navigation.pushNamed(route: "regionesMapa"),
              "Regionar",
              LineIcons.layerGroup,
              ThemaMain.primary),
          cards(
              context,
              () async => showDialog(
                  context: context,
                  builder: (context) => Dialog(child: CardAccout())),
              "Perfil",
              Icons.person,
              ThemaMain.green),
          cards(
              context,
              () async => Navigation.pushNamed(
                  route: "pendientesView", arguments: provider.usuario),
              "Pendientes",
              Icons.youtube_searched_for,
              ThemaMain.primary),
          if ((provider.usuario?.adminTipo ?? 0) >= 4 ||
              (provider.usuario?.adminTipo ?? 0) <= -1)
            cards(context, () async => Navigation.pushNamed(route: "users"),
                "Usuarios", LineIcons.users, ThemaMain.darkBlue),
          cards(
              context,
              () async => showDialog(
                  context: context, builder: (context) => DialogSetting()),
              "Configuración",
              Icons.settings,
              ThemaMain.darkGrey)
        ]));
  }

  Widget cards(BuildContext context, Function() function, String text,
      IconData icon, Color colorIcon) {
    return GestureDetector(
        onTap: () async => function(),
        child: Card(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: .5.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 3,
                          child: AutoSizeText(text,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold))),
                      Expanded(child: Icon(icon, size: 22.sp, color: colorIcon))
                    ]))));
  }
}
