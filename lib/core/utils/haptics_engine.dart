import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'dart:io' show Platform;

class HapticsEngine {
  static bool _initialized = false;
  static const MethodChannel _hapticsChannel = MethodChannel('com.kiranembedded.pocketutility/haptics');

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  static Future<void> _invokeNativeHaptic(String method) async {
    if (Platform.isAndroid) {
      try {
        await _hapticsChannel.invokeMethod(method);
      } catch (e) {
        // Fallback
        HapticFeedback.lightImpact();
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Light click for simple selections or navigation (e.g. tabs, simple buttons, calculator key press)
  static void selectionClick() {
    _invokeNativeHaptic('vibrateClick');
  }

  /// Medium impact for standard buttons, tool cards
  static void mediumImpact() {
    _invokeNativeHaptic('vibrateDoubleClick');
  }

  /// Heavy impact for clear buttons, warnings, or major actions (e.g. flashlight switch)
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Success or complete action
  static void success() {
    if (!_initialized) return;
    _invokeNativeHaptic('vibrateDoubleClick');
    Future.delayed(const Duration(milliseconds: 100), () => _invokeNativeHaptic('vibrateClick'));
  }

  /// Extremely light haptic for sliders / continuous scrolling elements / compass moving
  static void sliderSelection() {
    _invokeNativeHaptic('vibrateTick');
  }
}
