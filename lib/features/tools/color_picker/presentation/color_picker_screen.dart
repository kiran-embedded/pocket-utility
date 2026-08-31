import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  double _red = 107;
  double _green = 78;
  double _blue = 230;
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _checkHaptics();
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _triggerHaptic() {
    if (_hasHapticFeedback) {
      HapticsEngine.selectionClick();
    }
  }

  Color get _currentColor => Color.fromRGBO(_red.toInt(), _green.toInt(), _blue.toInt(), 1.0);

  String get _hexCode => '#${_currentColor.value.toRadixString(16).substring(2).toUpperCase()}';
  
  String get _rgbCode => 'RGB(${_red.toInt()}, ${_green.toInt()}, ${_blue.toInt()})';
  
  String get _hslCode {
    HSLColor hsl = HSLColor.fromColor(_currentColor);
    return 'HSL(${hsl.hue.toStringAsFixed(0)}, ${(hsl.saturation * 100).toStringAsFixed(0)}%, ${(hsl.lightness * 100).toStringAsFixed(0)}%)';
  }

  void _copyToClipboard(String text) {
    _triggerHaptic();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$text copied to clipboard'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Color Picker', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Color Preview Box
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _hexCode,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _currentColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ).animate().fade().scale(curve: Curves.easeOutBack, duration: 400.ms),
            
            const SizedBox(height: 32),
            
            // Color Codes Cards
            _buildCodeCard('HEX', _hexCode, cardColor, textColor, subTextColor).animate().fade(delay: 100.ms).slideY(begin: 0.2),
            const SizedBox(height: 16),
            _buildCodeCard('RGB', _rgbCode, cardColor, textColor, subTextColor).animate().fade(delay: 150.ms).slideY(begin: 0.2),
            const SizedBox(height: 16),
            _buildCodeCard('HSL', _hslCode, cardColor, textColor, subTextColor).animate().fade(delay: 200.ms).slideY(begin: 0.2),
            
            const SizedBox(height: 40),
            
            // RGB Sliders
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Adjust RGB values', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildSlider('Red', _red, Colors.redAccent, textColor, (val) {
                    setState(() => _red = val);
                  }),
                  _buildSlider('Green', _green, Colors.green, textColor, (val) {
                    setState(() => _green = val);
                  }),
                  _buildSlider('Blue', _blue, Colors.blue, textColor, (val) {
                    setState(() => _blue = val);
                  }),
                ],
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeCard(String label, String code, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(code, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF6B4EE6)),
            onPressed: () => _copyToClipboard(code),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, Color activeColor, Color textColor, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            activeColor: activeColor,
            inactiveColor: activeColor.withOpacity(0.2),
            onChanged: (val) {
              if (val.toInt() % 10 == 0) _triggerHaptic();
              onChanged(val);
            },
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(value.toInt().toString(), style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
