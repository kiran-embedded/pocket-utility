import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  String? _scannedCode;
  bool _hasHapticFeedback = true;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
  }
  
  Future<void> _checkHaptics() async {
    bool hasVib = true;
    setState(() {
      _hasHapticFeedback = hasVib ?? false;
    });
  }

  void _triggerHaptic() {
    if (_hasHapticFeedback) {
      HapticsEngine.heavyImpact(); // Light haptic tap
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanning = false;
        _triggerHaptic(); // Vibrate when a new code is scanned
        setState(() {
          _scannedCode = barcode.rawValue;
        });
        
        // Show result bottom sheet
        _showResultSheet(barcode.rawValue!);
        break;
      }
    }
  }

  void _showResultSheet(String result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan Result', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
              ),
              child: SelectableText(result, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.copy, 'Copy', () {
                  _triggerHaptic();
                  Clipboard.setData(ClipboardData(text: result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                  Navigator.pop(context);
                }),
                _buildActionButton(Icons.open_in_browser, 'Open', () {
                  _triggerHaptic();
                  // TODO: Implement URL launcher if URL
                  Navigator.pop(context);
                }),
                _buildActionButton(Icons.share, 'Share', () {
                  _triggerHaptic();
                  // TODO: Implement Share
                  Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).whenComplete(() {
      // Reset after closing sheet so user can scan again
      setState(() {
        _scannedCode = null;
        _isScanning = true;
      });
    });
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Theme.of(context).primaryColor : null,
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
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              _triggerHaptic();
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Overlay to create the scanner cutout effect
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Stack(
                children: [
                  // Corner accents could go here
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame to scan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
