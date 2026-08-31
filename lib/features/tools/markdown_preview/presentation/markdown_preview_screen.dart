import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/utils/navigation_utils.dart';

class MarkdownPreviewScreen extends StatefulWidget {
  const MarkdownPreviewScreen({super.key});

  @override
  State<MarkdownPreviewScreen> createState() => _MarkdownPreviewScreenState();
}

class _MarkdownPreviewScreenState extends State<MarkdownPreviewScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isPreviewMode = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Editor'), icon: Icon(Icons.edit)),
                ButtonSegment(value: true, label: Text('Preview'), icon: Icon(Icons.visibility)),
              ],
              selected: {_isPreviewMode},
              onSelectionChanged: (set) => setState(() => _isPreviewMode = set.first),
            ),
          ),
          
          Expanded(
            child: _isPreviewMode ? _buildPreview() : _buildEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _inputController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Type markdown here...\n\n# Heading 1\n## Heading 2\n\n* List item 1\n* List item 2\n\n**Bold** and *Italic*',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: MarkdownBody(
        data: _inputController.text.isEmpty ? 'Nothing to preview' : _inputController.text,
        selectable: true,
      ),
    );
  }
}
