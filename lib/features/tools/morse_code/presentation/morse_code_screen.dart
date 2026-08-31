import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class MorseCodeScreen extends StatefulWidget {
  const MorseCodeScreen({super.key});

  @override
  State<MorseCodeScreen> createState() => _MorseCodeScreenState();
}

class _MorseCodeScreenState extends State<MorseCodeScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  bool _isTextToMorse = true;

  static const Map<String, String> _textToMorse = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.',
    'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..',
    'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.',
    'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-',
    'Y': '-.--', 'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
    '3': '...--', '4': '....-', '5': '.....', '6': '-....', '7': '--...',
    '8': '---..', '9': '----.', ' ': '/'
  };

  static final Map<String, String> _morseToText = 
      _textToMorse.map((key, value) => MapEntry(value, key));

  void _convert() {
    final input = _inputController.text.toUpperCase();
    if (input.isEmpty) {
      setState(() => _result = '');
      return;
    }

    if (_isTextToMorse) {
      List<String> morseChars = [];
      for (int i = 0; i < input.length; i++) {
        final char = input[i];
        if (_textToMorse.containsKey(char)) {
          morseChars.add(_textToMorse[char]!);
        }
      }
      _result = morseChars.join(' ');
    } else {
      List<String> words = input.split('/');
      List<String> decodedWords = [];
      for (String word in words) {
        List<String> chars = word.trim().split(' ');
        String decodedWord = '';
        for (String char in chars) {
          if (char.isNotEmpty && _morseToText.containsKey(char)) {
            decodedWord += _morseToText[char]!;
          }
        }
        decodedWords.add(decodedWord);
      }
      _result = decodedWords.join(' ');
    }
    setState(() {});
  }

  Future<void> _playVibration() async {
    if (_result.isEmpty || !_isTextToMorse) return;
    
    bool hasVibrator = true;
    if (hasVibrator != true) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vibration not supported on this device')),
        );
      }
      return;
    }

    List<int> pattern = [];
    // Start with 0 wait
    pattern.add(0);

    for (int i = 0; i < _result.length; i++) {
      String char = _result[i];
      if (char == '.') {
        pattern.add(100); // Dot duration
        pattern.add(100); // Pause
      } else if (char == '-') {
        pattern.add(300); // Dash duration
        pattern.add(100); // Pause
      } else if (char == ' ') {
        pattern.add(0);
        pattern.add(300); // Pause between letters
      } else if (char == '/') {
        pattern.add(0);
        pattern.add(700); // Pause between words
      }
    }
    
    if (pattern.length > 1) {
      HapticsEngine.success();
    }
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morse Code'),
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
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Text to Morse'),
                  icon: Icon(Icons.text_fields),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Morse to Text'),
                  icon: Icon(Icons.more_horiz),
                ),
              ],
              selected: {_isTextToMorse},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isTextToMorse = newSelection.first;
                  _result = ''; 
                  _convert();
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _inputController,
              onChanged: (_) => _convert(),
              decoration: InputDecoration(
                labelText: _isTextToMorse ? 'Enter Text' : 'Enter Morse Code',
                hintText: _isTextToMorse ? 'e.g., SOS' : 'e.g., ... --- ...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.edit_note),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    _convert();
                  },
                )
              ),
              maxLines: 5,
              minLines: 2,
            ),
            if (!_isTextToMorse) ...[
               const SizedBox(height: 12),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                   ElevatedButton(onPressed: () { _inputController.text += '.'; _convert(); }, child: const Text('• Dot', style: TextStyle(fontSize: 18))),
                   ElevatedButton(onPressed: () { _inputController.text += '-'; _convert(); }, child: const Text('— Dash', style: TextStyle(fontSize: 18))),
                   ElevatedButton(onPressed: () { _inputController.text += ' '; _convert(); }, child: const Text('Space')),
                   ElevatedButton(onPressed: () { _inputController.text += ' / '; _convert(); }, child: const Text('/ Word')),
                 ],
               )
            ],
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Result', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Row(
                        children: [
                          if (_isTextToMorse)
                            IconButton(
                              icon: const Icon(Icons.vibration, color: Colors.white),
                              onPressed: _playVibration,
                              tooltip: 'Play Vibration',
                            ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white),
                            onPressed: _copyResult,
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _result.isEmpty ? 'Output will appear here.' : _result, 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
