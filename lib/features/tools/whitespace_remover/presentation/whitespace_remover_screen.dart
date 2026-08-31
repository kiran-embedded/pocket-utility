import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/navigation_utils.dart';

class WhitespaceRemoverScreen extends StatefulWidget {
  const WhitespaceRemoverScreen({super.key});

  @override
  State<WhitespaceRemoverScreen> createState() => _WhitespaceRemoverScreenState();
}

class _WhitespaceRemoverScreenState extends State<WhitespaceRemoverScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  
  bool _removeSpaces = true;
  bool _removeNewlines = true;
  bool _removeTabs = true;

  void _processText() {
    String text = _inputController.text;
    if (_removeSpaces) text = text.replaceAll(' ', '');
    if (_removeNewlines) text = text.replaceAll('\n', '').replaceAll('\r', '');
    if (_removeTabs) text = text.replaceAll('\t', '');
    
    setState(() {
      _output = text;
    });
  }

  void _copyResult() {
    if (_output.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _output));
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
        title: const Text('Whitespace Remover'),
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
            Wrap(
              spacing: 16,
              children: [
                FilterChip(
                  label: const Text('Spaces'),
                  selected: _removeSpaces,
                  onSelected: (val) {
                    setState(() => _removeSpaces = val);
                    _processText();
                  },
                ),
                FilterChip(
                  label: const Text('Newlines'),
                  selected: _removeNewlines,
                  onSelected: (val) {
                    setState(() => _removeNewlines = val);
                    _processText();
                  },
                ),
                FilterChip(
                  label: const Text('Tabs'),
                  selected: _removeTabs,
                  onSelected: (val) {
                    setState(() => _removeTabs = val);
                    _processText();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _inputController,
              onChanged: (_) => _processText(),
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Input Text',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 32),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Result', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: _copyResult,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _output.isEmpty ? 'Output will appear here.' : _output, 
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
