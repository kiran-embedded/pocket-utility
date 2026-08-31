import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../../core/utils/navigation_utils.dart';

class JsonFormatterScreen extends StatefulWidget {
  const JsonFormatterScreen({super.key});

  @override
  State<JsonFormatterScreen> createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends State<JsonFormatterScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  bool _hasError = false;

  void _formatJson() {
    final input = _inputController.text;
    if (input.trim().isEmpty) {
      setState(() {
        _output = '';
        _hasError = false;
      });
      return;
    }

    try {
      final dynamic parsed = jsonDecode(input);
      final encoder = const JsonEncoder.withIndent('  ');
      setState(() {
        _output = encoder.convert(parsed);
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _output = 'Invalid JSON:\n${e.toString()}';
        _hasError = true;
      });
    }
  }

  void _copyToClipboard() {
    if (_output.isNotEmpty && !_hasError) {
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
        title: const Text('JSON Formatter'),
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
            Expanded(
              flex: 1,
              child: TextField(
                controller: _inputController,
                onChanged: (_) => _formatJson(),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Raw JSON',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _inputController.clear();
                      _formatJson();
                    },
                  )
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hasError ? Colors.red.withOpacity(0.1) : primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _hasError ? Colors.red.withOpacity(0.5) : primaryColor.withOpacity(0.5)),
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: SelectableText(
                        _output.isEmpty ? 'Formatted output will appear here...' : _output,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: _hasError ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    if (!_hasError && _output.isNotEmpty)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.copy, color: primaryColor),
                          onPressed: _copyToClipboard,
                        ),
                      ),
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
