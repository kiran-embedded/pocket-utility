import 'package:flutter/material.dart';
import '../../../../core/utils/navigation_utils.dart';

class WordCounterScreen extends StatefulWidget {
  const WordCounterScreen({super.key});

  @override
  State<WordCounterScreen> createState() => _WordCounterScreenState();
}

class _WordCounterScreenState extends State<WordCounterScreen> {
  final TextEditingController _inputController = TextEditingController();
  
  int _charCount = 0;
  int _charNoSpaceCount = 0;
  int _wordCount = 0;
  int _sentenceCount = 0;
  int _lineCount = 0;

  void _analyzeText() {
    String text = _inputController.text;
    
    _charCount = text.length;
    _charNoSpaceCount = text.replaceAll(RegExp(r'\s+'), '').length;
    
    if (text.trim().isEmpty) {
      _wordCount = 0;
      _sentenceCount = 0;
      _lineCount = 0;
    } else {
      _wordCount = text.trim().split(RegExp(r'\s+')).length;
      _sentenceCount = text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty).length;
      _lineCount = text.split('\n').length;
    }
    
    setState(() {});
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
        title: const Text('Word Counter'),
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
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBlock('WORDS', _wordCount),
                      _buildStatBlock('CHARS', _charCount),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.white24),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBlock('SENTENCES', _sentenceCount, small: true),
                      _buildStatBlock('LINES', _lineCount, small: true),
                      _buildStatBlock('NO SPACES', _charNoSpaceCount, small: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _inputController,
              onChanged: (_) => _analyzeText(),
              maxLines: 15,
              minLines: 10,
              decoration: InputDecoration(
                labelText: 'Enter text here',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    _analyzeText();
                  },
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBlock(String label, int value, {bool small = false}) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(color: Colors.white, fontSize: small ? 24 : 48, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: small ? 10 : 12, letterSpacing: 1),
        ),
      ],
    );
  }
}
