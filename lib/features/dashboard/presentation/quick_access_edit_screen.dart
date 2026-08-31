import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../core/constants/app_tools.dart';

class QuickAccessEditScreen extends StatefulWidget {
  const QuickAccessEditScreen({super.key});

  @override
  State<QuickAccessEditScreen> createState() => _QuickAccessEditScreenState();
}

class _QuickAccessEditScreenState extends State<QuickAccessEditScreen> {
  List<String> _selectedTools = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTools();
  }

  Future<void> _loadSavedTools() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('quick_access_tools');
    if (mounted) {
      setState(() {
        if (saved != null && saved.isNotEmpty) {
          _selectedTools = List<String>.from(saved);
        } else {
          // Default selection if none saved
          _selectedTools = ['Compass', 'Flashlight', 'Level', 'QR Scanner'];
        }
        _isLoading = false;
      });
    }
  }

  void _triggerHaptic() {
    HapticsEngine.selectionClick();
  }

  void _toggleSelection(String title) {
    _triggerHaptic();
    setState(() {
      if (_selectedTools.contains(title)) {
        _selectedTools.remove(title);
      } else {
        if (_selectedTools.length < 4) {
          _selectedTools.add(title);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only select up to 4 quick access tools.')),
          );
        }
      }
    });
  }

  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quick_access_tools', _selectedTools);
    if (mounted) {
      Navigator.pop(context, true); // true indicates changes were made
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quick Access'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _selectedTools.isNotEmpty ? _saveSelection : null,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Select up to 4 tools to pin to your home screen (${_selectedTools.length}/4)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: AppTools.allTools.length,
              itemBuilder: (context, index) {
                final tool = AppTools.allTools[index];
                final isSelected = _selectedTools.contains(tool.title);
                
                return ListTile(
                  leading: Icon(tool.icon, color: tool.color),
                  title: Text(tool.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (val) => _toggleSelection(tool.title),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  onTap: () => _toggleSelection(tool.title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
