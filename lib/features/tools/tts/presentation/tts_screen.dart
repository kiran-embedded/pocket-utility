import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  
  bool _isPlaying = false;
  double _volume = 0.8;
  double _pitch = 1.0;
  double _rate = 0.5;
  
  bool _hasHapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    _checkHaptics();
  }

  Future<void> _checkHaptics() async {
    bool hasVib = true;
    if (mounted) setState(() => _hasHapticFeedback = hasVib ?? false);
  }

  void _triggerHaptic({bool light = true}) {
    if (_hasHapticFeedback) {
      HapticsEngine.selectionClick();
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setVolume(_volume);
    await flutterTts.setSpeechRate(_rate);
    await flutterTts.setPitch(_pitch);

    flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isPlaying = true);
    });
    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _speak() async {
    _triggerHaptic(light: false);
    if (_textController.text.isNotEmpty) {
      await flutterTts.speak(_textController.text);
    }
  }

  Future<void> _stop() async {
    _triggerHaptic(light: false);
    await flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Speech'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3D Text Area
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                  ),
                ],
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 2),
              ),
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontSize: 18, height: 1.5),
                decoration: const InputDecoration(
                  hintText: 'Enter text to synthesize...',
                  border: InputBorder.none,
                ),
              ),
            ).animate().slideY(begin: -0.1).fade(),
            
            const SizedBox(height: 32),
            
            // Giant Play/Stop Button
            Center(
              child: GestureDetector(
                onTap: _isPlaying ? _stop : _speak,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: _isPlaying ? Colors.redAccent : Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying ? Colors.redAccent : Theme.of(context).primaryColor).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 40),
            
            // 3D Sliders
            _buildSliderCard('Volume', Icons.volume_up, _volume, (val) {
              setState(() {
                _volume = val;
                flutterTts.setVolume(_volume);
              });
            }).animate().slideX(begin: -0.1, delay: 150.ms).fade(),
            
            const SizedBox(height: 16),
            
            _buildSliderCard('Pitch', Icons.multitrack_audio, _pitch, (val) {
              setState(() {
                _pitch = val;
                flutterTts.setPitch(_pitch);
              });
            }, max: 2.0).animate().slideX(begin: -0.1, delay: 200.ms).fade(),
            
            const SizedBox(height: 16),
            
            _buildSliderCard('Speed', Icons.speed, _rate, (val) {
              setState(() {
                _rate = val;
                flutterTts.setSpeechRate(_rate);
              });
            }, max: 1.5).animate().slideX(begin: -0.1, delay: 250.ms).fade(),
            
            const SizedBox(height: 40),
            
            // 3D Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton('Clear', Icons.clear, Colors.grey, () {
                    _triggerHaptic(light: false);
                    _textController.clear();
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton('Save', Icons.save_alt, Colors.green, () {
                    _triggerHaptic(light: false);
                    // TODO: Implement save
                  }),
                ),
              ],
            ).animate().slideY(begin: 0.1, delay: 300.ms).fade(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard(String label, IconData icon, double value, ValueChanged<double> onChanged, {double max = 1.0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: max,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    onChanged: (val) {
                      onChanged(val);
                      if ((val * 100).round() % 10 == 0) _triggerHaptic();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
          ],
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
