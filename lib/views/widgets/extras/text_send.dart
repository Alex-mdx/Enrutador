import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_app.dart';
import '../../../utilities/theme/theme_color.dart';

class TextSend extends StatefulWidget {
  final Function(String)? fun;
  final String? textPlaceholder;
  final bool hideWhenSend;
  const TextSend(
      {super.key, this.textPlaceholder, this.fun, this.hideWhenSend = true});

  @override
  State<TextSend> createState() => _TextSendState();
}

class _TextSendState extends State<TextSend> {
  final controller = TextEditingController();
  bool enviarDirecto = false;

  @override
  void initState() {
    super.initState();
    controller.text = widget.textPlaceholder ?? "";
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        minLines: 1,
        maxLines: 3,
        style: TextStyle(fontSize: 16.sp),
        decoration: InputDecoration(
            hintText: "Agregar nota",
            contentPadding:
                EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: ThemaMain.darkGrey),
                borderRadius: BorderRadius.circular(borderRadius)),
            suffixIcon: enviarDirecto
                ? Stack(alignment: Alignment.center, children: [
                    LoadingAnimationWidget.inkDrop(
                      color: ThemaMain.green,
                      size: 22.sp,
                    ),
                    Icon(Icons.circle, color: ThemaMain.background, size: 28.sp)
                  ])
                : IconButton.filled(
                    iconSize: 20.sp,
                    icon: Icon(Icons.send,
                        color: controller.text.isNotEmpty
                            ? ThemaMain.green
                            : ThemaMain.darkGrey),
                    onPressed: () async {
                      setState(() => enviarDirecto = true);
                      if (widget.fun != null) {
                        await widget.fun!(controller.text);
                      }

                      setState(() => enviarDirecto = false);
                      controller.clear();
                      if (widget.hideWhenSend) {
                        FocusScope.of(context).unfocus();
                      }
                    })));
  }
}
