import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AnimationModules on Widget {
  /// A premium, smooth fade in with a slight upward drift
  Widget applyPremiumFade({int delay = 0, int duration = 400}) {
    return this
        .animate(delay: delay.ms)
        .fade(duration: duration.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.1, end: 0, duration: duration.ms, curve: Curves.easeOutCubic);
  }

  /// A staggered horizontal slide in, great for lists or menu items
  Widget applyStaggeredSlide({int index = 0, int baseDelay = 50, int duration = 300, double slideDistance = 0.2}) {
    return this
        .animate(delay: (index * baseDelay).ms)
        .fade(duration: duration.ms)
        .slideX(begin: slideDistance, end: 0, duration: duration.ms, curve: Curves.easeOutCubic);
  }

  /// A subtle scale pop, perfect for buttons, icons, or badges
  Widget applyMicroPop({int delay = 0, int duration = 300}) {
    return this
        .animate(delay: delay.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: duration.ms,
          curve: Curves.easeOutBack,
        )
        .fade(duration: (duration * 0.8).toInt().ms);
  }

  /// Shimmer effect, great for loading states or premium highlights
  Widget applyShimmer({int delay = 0, int duration = 1500, Color? color}) {
    return this
        .animate(onPlay: (controller) => controller.repeat(), delay: delay.ms)
        .shimmer(
          duration: duration.ms,
          color: color ?? Colors.white.withOpacity(0.3),
        );
  }

  /// Subtle shake effect for error states
  Widget applyErrorShake() {
    return this.animate().shake(
      duration: 300.ms,
      hz: 4,
      curve: Curves.easeInOut,
    );
  }
}
