import 'package:flutter/material.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/animations/animation_modules.dart';
import 'emoji_hand_shader.dart';

class HomeHeaderWidget extends StatelessWidget {
  final String userName;
  final String timeGreeting;
  final bool isDark;
  final Color primary;

  const HomeHeaderWidget({
    super.key,
    required this.userName,
    required this.timeGreeting,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Text — left side
          Positioned(
            left: 0,
            top: 20,
            right: 210, // Keep text away from image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeGreeting,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : const Color(0xFF636675),
                  ),
                ).applyPremiumFade(delay: 50),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF8B3DFF),
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const EmojiHandShader(size: 28),
                  ],
                ).applyPremiumFade(delay: 80),
                const SizedBox(height: 12),
                Text(
                  'A fresh start to\nachieve your goals today ✨',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white54 : const Color(0xFF7A7D8F),
                  ),
                ).applyPremiumFade(delay: 120),
              ],
            ),
          ),
          
          // Tea image — increased size by 20%
          Positioned(
            right: -88,
            top: -108,
            child: Image.asset(
              'assets/images/tea_book.png',
              width: 440,
              height: 440,
              fit: BoxFit.contain,
            ).applyPremiumFade(delay: 150),
          ),
        ],
      ),
    );
  }
}
