import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/navigation_utils.dart';

class UrlEncodeScreen extends StatefulWidget {
  const UrlEncodeScreen({super.key});

  @override
  State<UrlEncodeScreen> createState() => _UrlEncodeScreenState();
}

class _UrlEncodeScreenState extends State<UrlEncodeScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  bool _isEncode = true;

  void _convert() {
    String input = _inputController.text;
    if (input.isEmpty) {
      setState(() => _result = '');
      return;
    }

    try {
      if (_isEncode) {
        _result = Uri.encodeComponent(input);
      } else {
        _result = Uri.decodeComponent(input);
      }
    } catch (e) {
      _result = 'Error parsing URL component';
    }
    setState(() {});
  }

  void _copyResult() {
    if (_result.isNotEmpty && !_result.startsWith('Error')) {
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
        title: const Text('URL Encode/Decode'),
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
                ButtonSegment<bool>(value: true, label: Text('Encode'), icon: Icon(Icons.lock_outline)),
                ButtonSegment<bool>(value: false, label: Text('Decode'), icon: Icon(Icons.lock_open)),
              ],
              selected: {_isEncode},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isEncode = newSelection.first;
                  _convert();
                });
              },
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _inputController,
              onChanged: (_) => _convert(),
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                labelText: _isEncode ? 'Text to Encode' : 'Text to Decode',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    _convert();
                  },
                )
              ),
            ),
            const SizedBox(height: 32),
            
            Container(
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
                    _result.isEmpty ? 'Output will appear here.' : _result, 
                    style: const TextStyle(color: Colors.white, fontSize: 18),
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
