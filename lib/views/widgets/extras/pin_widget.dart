import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

class PinWidget extends StatefulWidget {
  final int lenght;
  final String pin;
  final Function(String)? onChanged;
  final Function(String) onCompleted;
  final bool error;
  final TextEditingController? textController;
  const PinWidget(
      {super.key,
      this.lenght = 4,
      required this.pin,
      this.onChanged,
      this.textController,
      this.error = false,
      required this.onCompleted});

  @override
  State<PinWidget> createState() => _PinWidgetState();
}

class _PinWidgetState extends State<PinWidget> {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
        width: 56,
        height: 56,
        textStyle: TextStyle(
            fontSize: 20,
            color: ThemaMain.darkBlue,
            fontWeight: FontWeight.w600),
        decoration: BoxDecoration(
            border: Border.all(color: ThemaMain.background),
            borderRadius: BorderRadius.circular(20)));

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
        color: ThemaMain.darkGrey,
        border: Border.all(color: ThemaMain.primary),
        borderRadius: BorderRadius.circular(8));

    final submittedPinTheme = defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration
            ?.copyWith(color: ThemaMain.dialogbackground));

    return Pinput(
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        closeKeyboardWhenCompleted: true,
        controller: widget.textController,
        validator: (s) {
          return widget.error
              ? s == widget.pin
                  ? null
                  : 'Pin is incorrect'
              : null;
        },
        keyboardType:
            TextInputType.numberWithOptions(decimal: false, signed: false),
        length: widget.lenght,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        onCompleted: (pin) => widget.onCompleted(pin),
        onChanged: widget.onChanged == null
            ? (value) {}
            : (value) => widget.onChanged!(value));
  }
}
