import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/navigation_utils.dart';

class TextRepeaterScreen extends StatefulWidget {
  const TextRepeaterScreen({super.key});

  @override
  State<TextRepeaterScreen> createState() => _TextRepeaterScreenState();
}

class _TextRepeaterScreenState extends State<TextRepeaterScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _countController = TextEditingController(text: '5');
  String _result = '';
  bool _addNewLine = false;

  void _generate() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() => _result = '');
      return;
    }

    final count = int.tryParse(_countController.text) ?? 0;
    if (count <= 0) {
      setState(() => _result = 'Error: Enter a valid repeat count greater than 0.');
      return;
    }
    if (count > 100000) {
      setState(() => _result = 'Error: Count too high (Max 100000).');
      return;
    }

    _result = List.generate(count, (index) => input).join(_addNewLine ? '\n' : ' ');
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
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Repeater'),
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
            TextField(
              controller: _inputController,
              onChanged: (_) => _generate(),
              decoration: InputDecoration(
                labelText: 'Text to repeat',
                hintText: 'e.g., Hello',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.text_fields),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    _generate();
                  },
                )
              ),
              maxLines: 4,
              minLines: 1,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _countController,
                    onChanged: (_) => _generate(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Repeat count',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      prefixIcon: const Icon(Icons.repeat),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(child: Text('Add New Line')),
                        Switch(
                          value: _addNewLine,
                          onChanged: (val) {
                            setState(() {
                              _addNewLine = val;
                              _generate();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
