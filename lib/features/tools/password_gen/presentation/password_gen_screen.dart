import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../../../core/utils/navigation_utils.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';

class PasswordGenScreen extends StatefulWidget {
  const PasswordGenScreen({super.key});

  @override
  State<PasswordGenScreen> createState() => _PasswordGenScreenState();
}

class _PasswordGenScreenState extends State<PasswordGenScreen> {
  double _length = 16;
  bool _useUpper = true;
  bool _useLower = true;
  bool _useNumbers = true;
  bool _useSymbols = true;
  
  String _password = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    if (!_useUpper && !_useLower && !_useNumbers && !_useSymbols) {
      setState(() => _password = 'Select at least one option');
      return;
    }

    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    String chars = '';
    if (_useUpper) chars += upper;
    if (_useLower) chars += lower;
    if (_useNumbers) chars += numbers;
    if (_useSymbols) chars += symbols;

    final rand = Random.secure();
    String newPass = List.generate(_length.toInt(), (index) => chars[rand.nextInt(chars.length)]).join();
    
    setState(() => _password = newPass);
  }

  void _copyToClipboard() {
    if (_password.isNotEmpty && _password != 'Select at least one option') {
      Clipboard.setData(ClipboardData(text: _password));
      HapticsEngine.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
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
                children: [
                  SelectableText(
                    _password,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _generatePassword();
                            HapticsEngine.selectionClick();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('REGENERATE'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: primaryColor,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          padding: const EdgeInsets.all(12),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            _buildOptionRow('Length', '${_length.toInt()}'),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: primaryColor,
                thumbColor: primaryColor,
                overlayColor: primaryColor.withOpacity(0.2),
              ),
              child: Slider(
                value: _length,
                min: 4,
                max: 64,
                divisions: 60,
                onChanged: (val) {
                  setState(() => _length = val);
                  _generatePassword();
                },
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSwitch('Uppercase (A-Z)', _useUpper, (val) {
              setState(() => _useUpper = val);
              _generatePassword();
            }),
            _buildSwitch('Lowercase (a-z)', _useLower, (val) {
              setState(() => _useLower = val);
              _generatePassword();
            }),
            _buildSwitch('Numbers (0-9)', _useNumbers, (val) {
              setState(() => _useNumbers = val);
              _generatePassword();
            }),
            _buildSwitch('Symbols (!@#\$)', _useSymbols, (val) {
              setState(() => _useSymbols = val);
              _generatePassword();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).primaryColor,
    );
  }
}
