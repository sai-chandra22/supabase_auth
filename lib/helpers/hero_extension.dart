import 'package:flutter/material.dart';

extension HeroText on Text {
  Widget hero(Object tag) {
    return Hero(
      flightShuttleBuilder: (_,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext) {
        // Create a curved animation for bounce effect
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.bounceInOut, // Apply bounce curve
        );

        return AnimatedBuilder(
          animation: curvedAnimation,
          child: this,
          builder: (_, child) {
            return DefaultTextStyle.merge(
              child: child!,
              style: TextStyle.lerp(
                  ((fromHeroContext.widget as Hero).child as Text).style,
                  ((toHeroContext.widget as Hero).child as Text).style,
                  flightDirection == HeroFlightDirection.pop
                      ? 1 - curvedAnimation.value
                      : curvedAnimation.value * 0.9),
            );
          },
        );
      },
      tag: tag,
      transitionOnUserGestures: true,
      child: this,
    );
  }
}
