import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/custom_text.dart';
import '../themes/app_text_theme.dart';
import '../utils/colors.dart';

enum SpringTypes { defaultSpring, softerSpring, homeNavSpring }

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Set up the spring parameters
            const spring = SpringDescription(
              mass: 1.3,
              stiffness: 300,
              damping: 30,
            );

            // Create a SpringSimulation
            final simulation = SpringSimulation(
              spring,
              0.0,
              1.0,
              0.0,
            );

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    100 * (1 - simulation.x(animation.value)),
                    0.0,
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}

class CustomBottomToTopPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomBottomToTopPageRoute({required this.child})
      : super(
          transitionDuration:
              const Duration(milliseconds: 300), // Adjust duration as needed
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const spring = SpringDescription(
              mass: 1.3,
              stiffness: 300,
              damping: 30,
            );

            final simulation = SpringSimulation(
              spring,
              0.0,
              1.0,
              -animation.value,
            );

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0.0,
                    30 * (1 - simulation.x(animation.value)), // Subtle bounce
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}

class CustomTopToBottomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomTopToBottomPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const spring = SpringDescription(
              mass: 1.3,
              stiffness: 300,
              damping: 30,
            );

            final simulation = SpringSimulation(
              spring,
              0.0,
              1.0,
              -animation.value,
            );

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0.0,
                    -480 *
                        (1 -
                            simulation
                                .x(animation.value)), // Reverse the direction
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: child,
            );
          },
        );
}

class LoadingDotsAnimation extends StatefulWidget {
  const LoadingDotsAnimation(
      {super.key, this.text, this.style, this.width, this.height});

  final String? text;
  final TextStyle? style;
  final double? width;
  final double? height;

  @override
  LoadingDotsAnimationState createState() => LoadingDotsAnimationState();
}

class LoadingDotsAnimationState extends State<LoadingDotsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat();
    _dotAnimation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.text != null ? null : 76.w,
      child: AnimatedBuilder(
        animation: _dotAnimation,
        builder: (context, child) {
          String dots = '.' * (_dotAnimation.value);
          return CustomText(
              baseline: 11.h,
              text: '${widget.text ?? "Loading"}$dots',
              style: widget.style ??
                  AppTextStyle.headerH5(
                    color: AppColors.hintColor,
                    letterSpacing: 0,
                    lineHeight: 1,
                  ));
        },
      ),
    );
  }

  @override
  void dispose() {
    if (mounted) {
      _controller.dispose();
    }

    super.dispose();
  }
}

// Creating the Custom Page Route based on input, including spring animation
Route createCustomPageRoute(
  Widget page, {
  bool fade = false,
  bool slideToLeft = false,
  bool slideToRight = false,
  bool topToBottom = false,
  SpringTypes springType = SpringTypes.defaultSpring, // Default spring type
  Duration duration = const Duration(milliseconds: 520), // Custom duration
  Duration reverseDuration = const Duration(milliseconds: 520),
  bool noSpringAnimation = false,
}) {
  // Define stiffness, damping, and mass based on spring type
  double stiffness;
  double damping;
  double mass = 1.3; // Keeping mass constant in all cases for simplicity

  switch (springType) {
    case SpringTypes.defaultSpring:
      stiffness = 330;
      damping = 30;
      break;
    case SpringTypes.softerSpring:
      stiffness = 330;
      damping = 40;
      break;
    case SpringTypes.homeNavSpring:
      stiffness = 480;
      damping = 38;
      break;
  }

  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Handle slide transitions based on the provided direction
      Offset beginOffset;
      if (slideToLeft) {
        beginOffset = const Offset(1.0, 0.0); // Slide from right to left
      } else if (slideToRight) {
        beginOffset = const Offset(-1.0, 0.0); // Slide from left to right
      } else if (topToBottom) {
        beginOffset = const Offset(0.0, -2.0); // Slide from top to bottom
      } else {
        beginOffset =
            const Offset(0.0, 1.0); // Default slide from bottom to top
      }

      // Apply the custom spring curve based on the user's choice
      var curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: _SpringCurve(
            stiffness: stiffness,
            damping: damping,
            mass: mass), // Apply dynamic spring curve
      );

      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeInOut,
        ),
      );

      if (fade) {
        // Fade Transition
        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      } else if (noSpringAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      }

      return SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      );
    },
    transitionDuration: duration, // Customizable duration
    reverseTransitionDuration: reverseDuration,
  );
}

// Custom Spring Curve class with dynamic stiffness, damping, and mass
class _SpringCurve extends Curve {
  final double stiffness;
  final double damping;
  final double mass;

  const _SpringCurve(
      {required this.stiffness, required this.damping, required this.mass});

  @override
  double transform(double t) {
    // Ensure correct mapping of t = 0.0 to 0.0 and t = 1.0 to 1.0
    if (t == 0.0) return 0.0;
    if (t == 1.0) return 1.0;

    // Calculate natural frequency and damping ratio
    final naturalFreq = sqrt(stiffness / mass);
    final dampingRatio = damping / (2 * sqrt(stiffness * mass));

    // Calculate the spring curve based on underdamped or overdamped motion
    double result;
    if (dampingRatio < 1.0) {
      // Underdamped case
      final dampedFreq = naturalFreq * sqrt(1.0 - dampingRatio * dampingRatio);
      result = exp(-dampingRatio * naturalFreq * t) *
          (cos(dampedFreq * t) +
              (dampingRatio / sqrt(1.0 - dampingRatio * dampingRatio)) *
                  sin(dampedFreq * t));
    } else {
      // Overdamped case
      result = exp(-naturalFreq * t);
    }

    // Normalize the result to ensure it starts at 0.0 and ends at 1.0
    return 1.0 - exp(-6 * t) * result.clamp(0.0, 1.0);
  }
}

class HeroWidget extends StatelessWidget {
  const HeroWidget({
    super.key,
    required this.tag,
    required this.child,
    this.reverseAsFade = false, // Control reverse animation as fade
    this.partialFade = false, // Control partial fade option
    this.pushAsSlide = false, // Control push animation as slide
    this.popAsSlide = false, // Control pop animation as slide
  });

  final String tag;
  final Widget child;
  final bool reverseAsFade;
  final bool partialFade;
  final bool pushAsSlide; // New flag for push slide animation
  final bool popAsSlide; // New flag for pop slide animation

  @override
  Widget build(BuildContext context) {
    return Hero(
      transitionOnUserGestures: true,
      tag: tag,
      child: child,
      placeholderBuilder: (context, heroSize, child) {
        return SizedBox(
          width: heroSize.width,
          height: heroSize.height,
          child: Container(
            color: Colors.transparent,
          ),
        );
      },
      flightShuttleBuilder:
          (flightContext, animation, direction, fromContext, toContext) {
        if (direction == HeroFlightDirection.push) {
          // Forward animation (push)
          if (pushAsSlide) {
            // Slide animation for push
            final slideAnimation = CurvedAnimation(
              parent: animation,
              curve: Cubic(0.175, 0.885, 0.32, 1), // Custom bounce curve
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Slide in from the right
                end: Offset.zero,
              ).animate(slideAnimation),
              child: fromContext.widget,
            );
          } else {
            // Fade animation (default for push)
            final fadeAnimation = CurvedAnimation(
                parent: animation, curve: Cubic(0.175, 0.885, 0.32, 1.27)
                // const Interval(
                //   0.0,
                //   1.0,
                //   curve: Cubic(0.175, 0.885, 0.32, 1.27),
                // ),
                );

            if (partialFade) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent, // Top fade
                        Colors.white, // Middle fully visible
                        Colors.transparent, // Bottom fade
                      ],
                      stops: [0.0, 0.2, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: fromContext.widget,
                ),
              );
            } else {
              return FadeTransition(
                opacity: fadeAnimation,
                child: fromContext.widget,
              );
            }
          }
        } else {
          // Reverse animation (pop)
          if (popAsSlide) {
            // Slide animation for pop
            final slideAnimation = CurvedAnimation(
              parent: animation,
              curve: Cubic(0.175, 0.885, 0.32, 1.27), // Custom bounce curve
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0), // Slide in from the left
                end: Offset.zero,
              ).animate(slideAnimation),
              child: toContext.widget,
            );
          } else if (reverseAsFade) {
            // Fade animation (default for pop)
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 1.0,
                  curve: Cubic(0.68, -0.55, 0.27, 0.8)),
            );

            if (partialFade) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent, // Top fade
                        Colors.white, // Middle fully visible
                        Colors.transparent, // Bottom fade
                      ],
                      stops: [0.0, 0.14, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: toContext.widget,
                ),
              );
            } else {
              return FadeTransition(
                opacity: fadeAnimation,
                child: toContext.widget,
              );
            }
          } else {
            debugPrint('720ssd: reverse');

            var tween = Tween(begin: const Offset(0, 0), end: Offset.zero)
                .chain(CurveTween(
              curve: Cubic(0.175, 0.885, 0.32, 1.4),
            ));

            return SlideTransition(
              position: animation.drive(tween),
              child: toContext.widget,
            );
          }
        }
      },
    );
  }
}

class SpringTransition extends StatefulWidget {
  final Widget child;
  final bool slideToLeft;
  final bool slideToRight;
  final bool topToBottom;
  final bool bottomToTop;
  final bool fade;
  final double stiffness;
  final double damping;
  final double mass;
  final Duration duration;

  const SpringTransition({
    super.key,
    required this.child,
    this.slideToLeft = false,
    this.slideToRight = false,
    this.topToBottom = false,
    this.bottomToTop = true,
    this.fade = false,
    this.stiffness = 300.0,
    this.damping = 30.0,
    this.mass = 1.3,
    this.duration = const Duration(milliseconds: 520),
  });

  @override
  SpringTransitionState createState() => SpringTransitionState();
}

class SpringTransitionState extends State<SpringTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Create a spring description using the user-provided stiffness, damping, and mass
    final spring = SpringDescription(
      mass: widget.mass,
      stiffness: widget.stiffness,
      damping: widget.damping,
    );

    // Define a SpringSimulation for the animation
    final simulation = SpringSimulation(
      spring,
      0.0, // Starting point of animation
      1.0, // End point of animation
      0.0, // Initial velocity
    );

    // Start the spring simulation
    _controller.animateWith(simulation);

    // Determine the starting offset based on the direction
    Offset beginOffset;
    if (widget.slideToLeft) {
      beginOffset = const Offset(1.0, 0.0); // Slide from right to left
    } else if (widget.slideToRight) {
      beginOffset = const Offset(-1.0, 0.0); // Slide from left to right
    } else if (widget.topToBottom) {
      beginOffset = const Offset(0.0, -1.0); // Slide from top to bottom
    } else if (widget.bottomToTop) {
      beginOffset = const Offset(0.0, 1.0); // Slide from bottom to top
    } else {
      beginOffset = Offset.zero; // No slide if none specified
    }

    // Offset animation for sliding transitions
    _offsetAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(_controller);

    // Fade animation for fade transitions
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // Dispose of the animation controller when the widget is removed from the tree
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fade) {
      // Return fade transition if fade is enabled
      return FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      );
    } else {
      // Return slide transition if fade is not enabled
      return SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      );
    }
  }
}

Route createCustomSpringPageRoute(
  Widget page, {
  bool slideToLeft = false,
  bool slideToRight = false,
  bool topToBottom = false,
  bool bottomToTop = true, // Default to bottom to top slide
  bool fade = false,
  double stiffness = 300.0, // Default stiffness
  double damping = 30.0, // Default damping
  double mass = 1.0, // Default mass
  Duration duration =
      const Duration(milliseconds: 520), // Customizable duration
}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SpringTransition(
        slideToLeft: slideToLeft,
        slideToRight: slideToRight,
        topToBottom: topToBottom,
        bottomToTop: bottomToTop,
        fade: fade,
        stiffness: stiffness,
        damping: damping,
        mass: mass,
        duration: duration,
        child: child,
      );
    },
    transitionDuration: duration,
  );
}
