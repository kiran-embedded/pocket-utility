import 'package:flutter/services.dart';

class FlashlightManager {
  static const MethodChannel _channel = MethodChannel('com.kiranembedded.pocketutility/flashlight');
  
  static int _maxLevel = 1;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      _maxLevel = await _channel.invokeMethod('getMaxLevel') ?? 1;
      _initialized = true;
    } catch (e) {
      print('Error initializing FlashlightManager: $e');
    }
  }

  static bool get isDimmingSupported => _maxLevel > 1;
  static int get maxLevel => _maxLevel;

  static Future<void> setTorchMode(bool enabled) async {
    try {
      await _channel.invokeMethod('setTorchMode', {'enabled': enabled});
    } catch (e) {
      print('Error setting torch mode: $e');
    }
  }

  /// Sets the brightness of the flashlight.
  /// [percentage] is a value between 0.0 and 1.0.
  static Future<void> setBrightness(double percentage) async {
    try {
      if (percentage <= 0) {
        await setTorchMode(false);
        return;
      }

      if (_maxLevel > 1) {
        int level = (percentage * _maxLevel).round();
        if (level < 1) level = 1;
        if (level > _maxLevel) level = _maxLevel;
        await _channel.invokeMethod('setTorchLevel', {'level': level});
      } else {
        // Fallback for devices that don't support dimming
        await setTorchMode(true);
      }
    } catch (e) {
      print('Error setting torch level: $e');
    }
  }

  static Future<void> turnOff() async {
    await setTorchMode(false);
  }
}
