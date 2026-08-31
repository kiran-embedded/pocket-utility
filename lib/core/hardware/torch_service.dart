import 'dart:async';
import 'package:torch_light/torch_light.dart';

class TorchService {
  bool _isTorchAvailable = false;
  bool _isOn = false;
  Timer? _blinkTimer;

  bool get isOn => _isOn;
  bool get isAvailable => _isTorchAvailable;

  TorchService() {
    _initTorch();
  }

  Future<void> _initTorch() async {
    try {
      _isTorchAvailable = await TorchLight.isTorchAvailable();
    } catch (e) {
      _isTorchAvailable = false;
    }
  }

  Future<void> toggle(bool state) async {
    if (!_isTorchAvailable) return;
    try {
      if (state) {
        await TorchLight.enableTorch();
        _isOn = true;
      } else {
        await TorchLight.disableTorch();
        _isOn = false;
      }
    } catch (e) {
      // Handle error
    }
  }

  void startStrobe(int intervalMs) {
    stopBlinking();
    _blinkTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      toggle(!_isOn);
    });
  }

  void stopBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
    toggle(false);
  }

  void dispose() {
    stopBlinking();
  }
}
