import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';

class MagnifierScreen extends StatefulWidget {
  const MagnifierScreen({super.key});

  @override
  State<MagnifierScreen> createState() => _MagnifierScreenState();
}

class _MagnifierScreenState extends State<MagnifierScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  double _zoomLevel = 0.5; // 0.0 is 1x, 0.5 is 4x, 1.0 is 8x approx mapping
  int _activeZoomFactor = 4;
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
  }
  
  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) {
      setState(() {
        _hasHapticFeedback = hasVib ?? false;
      });
    }
  }

  void _triggerHaptic() {
    if (_hasHapticFeedback) {
      HapticsEngine.selectionClick();
    }
  }

  void _setZoomFactor(int factor) {
    _triggerHaptic();
    setState(() {
      _activeZoomFactor = factor;
      if (factor == 2) _zoomLevel = 0.25;
      else if (factor == 4) _zoomLevel = 0.5;
      else if (factor == 8) _zoomLevel = 1.0;
    });
    cameraController.setZoomScale(_zoomLevel);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Magnifier', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? const Color(0xFF6B4EE6) : Colors.white,
            ),
            onPressed: () {
              _triggerHaptic();
              cameraController.toggleTorch();
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {}, 
          ),
          
          // Magnifier UI Overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Zoom Slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.remove, color: Colors.white, size: 24),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 2,
                            activeTrackColor: const Color(0xFF6B4EE6),
                            inactiveTrackColor: Colors.white38,
                            thumbColor: Colors.white,
                            overlayColor: const Color(0xFF6B4EE6).withOpacity(0.1),
                          ),
                          child: Slider(
                            value: _zoomLevel,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              setState(() {
                                _zoomLevel = value;
                                if (value < 0.3) _activeZoomFactor = 2;
                                else if (value < 0.7) _activeZoomFactor = 4;
                                else _activeZoomFactor = 8;
                              });
                              cameraController.setZoomScale(value);
                              if ((value * 100).round() % 20 == 0) {
                                _triggerHaptic();
                              }
                            },
                          ),
                        ),
                      ),
                      const Icon(Icons.add, color: Colors.white, size: 24),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Zoom Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildZoomButton(2),
                    const SizedBox(width: 24),
                    _buildZoomButton(4),
                    const SizedBox(width: 24),
                    _buildZoomButton(8),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton(int factor) {
    bool isSelected = _activeZoomFactor == factor;
    return GestureDetector(
      onTap: () => _setZoomFactor(factor),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF6B4EE6) : Colors.white,
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6B4EE6).withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
            )
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '${factor}x',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
