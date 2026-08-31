import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/navigation_utils.dart';

class BinaryConverterScreen extends StatefulWidget {
  const BinaryConverterScreen({super.key});

  @override
  State<BinaryConverterScreen> createState() => _BinaryConverterScreenState();
}

class _BinaryConverterScreenState extends State<BinaryConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  bool _isTextToBinary = true;

  void _convert() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() => _result = '');
      return;
    }

    try {
      if (_isTextToBinary) {
        _result = input.codeUnits.map((e) => e.toRadixString(2).padLeft(8, '0')).join(' ');
      } else {
        String cleanInput = input.replaceAll(',', ' ');
        List<String> binChars = [];
        if (cleanInput.contains(' ')) {
          binChars = cleanInput.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
        } else {
          for (int i = 0; i < cleanInput.length; i += 8) {
            if (i + 8 <= cleanInput.length) {
              binChars.add(cleanInput.substring(i, i + 8));
            } else {
              binChars.add(cleanInput.substring(i));
            }
          }
        }
        _result = String.fromCharCodes(binChars.map((e) => int.parse(e, radix: 2)));
      }
    } catch (e) {
      _result = 'Error: Invalid input format.';
    }
    setState(() {});
  }

  void _copyResult() {
    if (_result.isNotEmpty && !_result.startsWith('Error:')) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result copied to clipboard')),
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
        title: const Text('Binary Converter'),
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
                  label: Text('Text to Binary'),
                  icon: Icon(Icons.text_fields),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Binary to Text'),
                  icon: Icon(Icons.data_object),
                ),
              ],
              selected: {_isTextToBinary},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isTextToBinary = newSelection.first;
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
                labelText: _isTextToBinary ? 'Enter Text' : 'Enter Binary',
                hintText: _isTextToBinary ? 'e.g., Hello' : 'e.g., 01001000 01100101',
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
              maxLines: 8,
              minLines: 3,
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
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: _copyResult,
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _result.isEmpty ? 'Output will appear here.' : _result, 
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
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
