
import 'package:flutter/material.dart';

class RouteTransitions {
  static Widget slideDown(context, animation, secondaryAnimation, child) {
    var begin = const Offset(0.0, -0.1);
    var end = Offset.zero;
    var tween = Tween(begin: begin, end: end);
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  static Widget slideUp(context, animation, secondaryAnimation, child) {
    var offsetAnimation = animation.drive(
      Tween(begin: const Offset(0.0, 0.8), end: Offset.zero));

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  static Widget slideLeft(context, animation, secondaryAnimation, child) {
    var begin = const Offset(1.0, 0.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end);
    var curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }

  static Widget scale(context, animation, secondaryAnimation, child) {
    var scaledAnimation = animation.drive(Tween(begin: 0.3, end: 1.0));
    var offsetAnimation = animation.drive(
      Tween(begin: const Offset(0.0, 0.1), end: Offset.zero),
    );

    return ScaleTransition(
      scale: scaledAnimation,
      child: SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  static Widget fade(context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
