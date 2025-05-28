import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CustomSmoothScrollPhysics extends BouncingScrollPhysics {
  final double mass;
  final double stiffness;
  final double damping;
  final double velocityMultiplier;
  final ScrollController scrollController;

  const CustomSmoothScrollPhysics({
    required this.mass,
    required this.stiffness,
    required this.damping,
    this.velocityMultiplier = 0.9, // Adjust for deceleration control
    required this.scrollController,
    super.parent,
  });

  // Method to interpolate the velocity smoothly to zero over a period of time
  double _interpolateToZero(double currentVelocity, double time) {
    const double decelerationTime = 4; // 1.5 seconds to decelerate to zero

    // We calculate the deceleration factor, which reduces the velocity gradually
    double interpolationFactor = (decelerationTime - time) / decelerationTime;
    interpolationFactor =
        interpolationFactor.clamp(0.0, 1.0); // Clamp between 0 and 1

    return currentVelocity * interpolationFactor;
  }

  // Function to smoothly decelerate velocity when within a certain distance from bounds
  double _applySmoothDeceleration(
      double position, double minExtent, double maxExtent, double velocity) {
    const double threshold =
        20.0; // Threshold within which we start decelerating

    // If position is near the min scroll extent, gradually decelerate
    if (position <= minExtent + threshold) {
      final double distanceFromMin =
          (position - minExtent).clamp(0.0, threshold);
      final double decelerationFactor =
          distanceFromMin / threshold; // How close we are to the boundary
      return _interpolateToZero(velocity,
          decelerationFactor); // Gradually interpolate velocity to zero
    }

    // If position is near the max scroll extent, gradually decelerate
    if (position >= maxExtent - threshold) {
      final double distanceFromMax =
          (maxExtent - position).clamp(0.0, threshold);
      final double decelerationFactor =
          distanceFromMax / threshold; // How close we are to the boundary
      return _interpolateToZero(velocity,
          decelerationFactor); // Gradually interpolate velocity to zero
    }

    return velocity; // Otherwise, leave the velocity unchanged for smooth scroll
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // Get decelerated velocity when approaching the bounds
    double deceleratedVelocity = _applySmoothDeceleration(
      position.pixels,
      position.minScrollExtent,
      position.maxScrollExtent,
      velocity,
    );

    // Apply normal bounce-back behavior with smooth deceleration when out of bounds
    if (position.pixels < position.minScrollExtent) {
      // Gently bounce back to minScrollExtent using SpringSimulation
      return ScrollSpringSimulation(
        SpringDescription(
          mass: mass,
          stiffness: stiffness,
          damping: damping,
        ),
        position.pixels,
        position.minScrollExtent, // Target is min scroll extent
        deceleratedVelocity, // Use decelerated velocity for smooth bounce
      );
    }

    if (position.pixels > position.maxScrollExtent) {
      // Gently bounce back to maxScrollExtent using SpringSimulation
      return ScrollSpringSimulation(
        SpringDescription(
          mass: mass,
          stiffness: stiffness,
          damping: damping,
        ),
        position.pixels,
        position.maxScrollExtent, // Target is max scroll extent
        deceleratedVelocity, // Use decelerated velocity for smooth bounce
      );
    }

    // Normal smooth scrolling behavior when within bounds
    if (velocity.abs() >= tolerance.velocity) {
      return ScrollSpringSimulation(
        SpringDescription(
          mass: mass,
          stiffness: stiffness,
          damping: damping,
        ),
        position.pixels,
        velocity < 0 ? position.minScrollExtent : position.maxScrollExtent,
        deceleratedVelocity, // Use decelerated velocity for smooth scrolling
      );
    }

    // Fall back to default physics for minimal velocity
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  bool get allowImplicitScrolling => true;
}

class CustomClampingSpringScrollPhysics extends ScrollPhysics {
  final double mass;
  final double stiffness;
  final double damping;
  final double velocityMultiplier; // New field for increasing velocity

  const CustomClampingSpringScrollPhysics({
    required this.mass,
    required this.stiffness,
    required this.damping,
    this.velocityMultiplier = 1.5, // Default multiplier to increase velocity
    super.parent,
  });

  @override
  CustomClampingSpringScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomClampingSpringScrollPhysics(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
      velocityMultiplier: velocityMultiplier, // Carry the velocity multiplier
      parent: buildParent(ancestor),
    );
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      // Modify the velocity to increase the scroll speed
      final double modifiedVelocity = velocity * velocityMultiplier;

      // Create a spring bounce simulation when the scroll hits the boundary
      return SpringSimulation(
        SpringDescription(
          mass: mass, // Controls the bounce inertia
          stiffness:
              stiffness, // Controls the spring stiffness (bounce strength)
          damping:
              damping, // Controls the spring damping (how quickly it stops bouncing)
        ),
        position.pixels,
        velocity < 0 ? 0.0 : position.maxScrollExtent,
        modifiedVelocity, // Use the modified velocity for faster scroll
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  bool get allowImplicitScrolling => true;
}

// Custom Smooth Scroll Physics
class SmoothScrollPhysics extends ScrollPhysics {
  const SmoothScrollPhysics({super.parent});

  @override
  SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    // Apply custom physics with BouncingScrollPhysics as a parent to allow pulling at the edges
    return SmoothScrollPhysics(parent: BouncingScrollPhysics(parent: ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // Override to create smoother deceleration
    if (velocity.abs() < tolerance.velocity) return null;
    final SpringDescription spring = SpringDescription(
      mass: 4.0, // Adjust mass for smoother inertia
      stiffness: 0.0, // Lower stiffness for a smoother feel
      damping: 4.3, // Damping to reduce over-scrolling
    );
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      0.0,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => true;
}
