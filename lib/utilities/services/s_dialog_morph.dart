import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'navigation_services.dart';

class MorphDialog extends StatefulWidget {
  const MorphDialog(
      {super.key,
      required this.title,
      required this.description,
      required this.cancelText,
      required this.acceptText,
      required this.onAcceptPressed,
      required this.loadingTitle,
      required this.loadingDescription});

  final String title, description, loadingTitle, loadingDescription;
  final Text cancelText, acceptText;
  final Function(BuildContext)? onAcceptPressed;

  @override
  State<MorphDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<MorphDialog>
    with SingleTickerProviderStateMixin {
  late bool isAccepted = false;
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        lowerBound: 0.7,
        vsync: this,
        duration: const Duration(milliseconds: 100));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ScaleTransition(
        scale: scaleAnimation,
        child: Dialog(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                  child: Text(!isAccepted ? widget.title : widget.loadingTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold))),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
                  child: Text(
                      !isAccepted
                          ? widget.description
                          : widget.loadingDescription,
                      style: TextStyle(fontSize: 18.sp),
                      textAlign: TextAlign.center)),
              if (!isAccepted) Divider(height: 1.sp),
              !isAccepted
                  ? SizedBox(
                      height: size.height * 0.075,
                      child: Row(children: [
                        Expanded(
                            child: InkWell(
                                splashFactory: InkSparkle
                                    .constantTurbulenceSeedSplashFactory,
                                highlightColor: Colors.grey[255],
                                onTap: () => Navigation.pop(),
                                child: Center(child: widget.cancelText))),
                        VerticalDivider(width: 1.sp),
                        Expanded(
                            child: InkWell(
                                splashFactory: InkSparkle
                                    .constantTurbulenceSeedSplashFactory,
                                highlightColor: Colors.grey[255],
                                onTap: () {
                                  _switchState();
                                  widget.onAcceptPressed?.call(context);
                                },
                                child: Center(child: widget.acceptText)))
                      ]))
                  : Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.sp),
                      child: Center(child: CircularProgressIndicator()))
            ])));
  }

  void _switchState() {
    isAccepted = !isAccepted;
    setState(() {});
  }
}
