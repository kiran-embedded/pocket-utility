import 'package:flutter/material.dart';
import '../../../../core/animations/animation_modules.dart';

class EmojiHandShader extends StatelessWidget {
  final double size;

  const EmojiHandShader({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF8B5CF6), // Dark Violet
          Color(0xFFD946EF), // Fuchsia / Neon Pink
          Color(0xFF6366F1), // Indigo
        ],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcATop,
      child: Text(
        '👋',
        style: TextStyle(
          fontSize: size,
          height: 1.0, // Prevent clipping
        ),
      ),
    ).applyMicroPop(delay: 200, duration: 600);
  }
}
