import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void launch(
    {required BuildContext context,
    required Widget widget,
    PageTransitionType animationType = PageTransitionType.scale}) {
  Navigator.push(
    context,
    PageTransition(
      alignment: Alignment.center,
      type: animationType,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      child: widget,
    ),
  );
}

void returnToWidget(
    {required BuildContext context,
    required Widget widget,
    PageTransitionType animationType = PageTransitionType.scale}) {
  Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        alignment: Alignment.center,
        type: animationType,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
        child: widget,
      ),
      (route) => false);
}
