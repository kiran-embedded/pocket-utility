import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../../../core/utils/navigation_utils.dart';

class LoremIpsumScreen extends StatefulWidget {
  const LoremIpsumScreen({super.key});

  @override
  State<LoremIpsumScreen> createState() => _LoremIpsumScreenState();
}

class _LoremIpsumScreenState extends State<LoremIpsumScreen> {
  int _count = 3;
  bool _isParagraphs = true;
  String _generatedText = '';

  final List<String> _words = [
    'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing', 'elit',
    'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore', 'et', 'dolore',
    'magna', 'aliqua', 'enim', 'ad', 'minim', 'veniam', 'quis', 'nostrud', 'exercitation',
    'ullamco', 'laboris', 'nisi', 'aliquip', 'ex', 'ea', 'commodo', 'consequat', 'duis',
    'aute', 'irure', 'in', 'reprehenderit', 'voluptate', 'velit', 'esse', 'cillum', 'fugiat',
    'nulla', 'pariatur', 'excepteur', 'sint', 'occaecat', 'cupidatat', 'non', 'proident',
    'sunt', 'culpa', 'qui', 'officia', 'deserunt', 'mollit', 'anim', 'id', 'est', 'laborum'
  ];

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final rand = Random();
    List<String> result = [];

    if (_isParagraphs) {
      for (int p = 0; p < _count; p++) {
        List<String> paragraphWords = [];
        // Generate a paragraph of 20 to 50 words
        int numWords = 20 + rand.nextInt(31);
        for (int w = 0; w < numWords; w++) {
          String word = _words[rand.nextInt(_words.length)];
          if (w == 0) {
            word = word[0].toUpperCase() + word.substring(1);
          }
          paragraphWords.add(word);
        }
        result.add('${paragraphWords.join(' ')}.');
      }
      _generatedText = result.join('\n\n');
    } else {
      // Words mode
      List<String> wordsList = [];
      for (int w = 0; w < _count; w++) {
        wordsList.add(_words[rand.nextInt(_words.length)]);
      }
      if (wordsList.isNotEmpty) {
        wordsList[0] = wordsList[0][0].toUpperCase() + wordsList[0].substring(1);
      }
      _generatedText = '${wordsList.join(' ')}.';
    }
    
    setState(() {});
  }

  void _copyToClipboard() {
    if (_generatedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lorem Ipsum Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('Paragraphs'), icon: Icon(Icons.article)),
                ButtonSegment<bool>(value: false, label: Text('Words'), icon: Icon(Icons.text_fields)),
              ],
              selected: {_isParagraphs},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isParagraphs = newSelection.first;
                  _count = _isParagraphs ? 3 : 20; // reset to sensible defaults
                  _generate();
                });
              },
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: primaryColor,
                      thumbColor: primaryColor,
                      overlayColor: primaryColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _count.toDouble(),
                      min: 1,
                      max: _isParagraphs ? 20 : 100,
                      divisions: _isParagraphs ? 19 : 99,
                      label: '$_count',
                      onChanged: (val) {
                        setState(() => _count = val.toInt());
                        _generate();
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '$_count',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.refresh),
                label: const Text('REGENERATE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: SelectableText(
                        _generatedText,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        onPressed: _copyToClipboard,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.copy),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
