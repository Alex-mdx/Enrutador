import 'package:flutter/material.dart';

import 'navigation_services.dart';

class MorphDialog extends StatefulWidget {
  const MorphDialog({
    super.key,
    required this.title,
    required this.description,
    required this.cancelText,
    required this.acceptText,
    required this.onAcceptPressed,
    required this.loadingTitle,
    required this.loadingDescription,
  });

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
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Text(!isAccepted ? widget.title : widget.loadingTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold))),
              Padding(
                  padding:
                      const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Text(
                      !isAccepted
                          ? widget.description
                          : widget.loadingDescription,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center)),
              if (!isAccepted) const Divider(height: 1),
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
                        const VerticalDivider(width: 1),
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
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()))
            ])));
  }

  void _switchState() {
    isAccepted = !isAccepted;
    setState(() {});
  }
}
