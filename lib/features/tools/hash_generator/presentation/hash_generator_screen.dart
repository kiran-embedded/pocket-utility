import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../../core/utils/navigation_utils.dart';

class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key});

  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends State<HashGeneratorScreen> {
  final TextEditingController _inputController = TextEditingController();
  
  String _md5 = '';
  String _sha1 = '';
  String _sha256 = '';
  String _sha512 = '';

  void _generateHashes() {
    String input = _inputController.text;
    if (input.isEmpty) {
      setState(() {
        _md5 = ''; _sha1 = ''; _sha256 = ''; _sha512 = '';
      });
      return;
    }

    final bytes = utf8.encode(input);
    setState(() {
      _md5 = md5.convert(bytes).toString();
      _sha1 = sha1.convert(bytes).toString();
      _sha256 = sha256.convert(bytes).toString();
      _sha512 = sha512.convert(bytes).toString();
    });
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hash Generator'),
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
            TextField(
              controller: _inputController,
              onChanged: (_) => _generateHashes(),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Input Text',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    _generateHashes();
                  },
                )
              ),
            ),
            const SizedBox(height: 32),
            
            _buildHashCard('MD5', _md5),
            _buildHashCard('SHA-1', _sha1),
            _buildHashCard('SHA-256', _sha256),
            _buildHashCard('SHA-512', _sha512),
          ],
        ),
      ),
    );
  }

  Widget _buildHashCard(String algorithm, String hash) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(algorithm, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => _copyToClipboard(hash),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            hash.isEmpty ? '...' : hash,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
