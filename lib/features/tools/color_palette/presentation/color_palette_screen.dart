import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';

class ColorPaletteScreen extends StatefulWidget {
  const ColorPaletteScreen({super.key});

  @override
  State<ColorPaletteScreen> createState() => _ColorPaletteScreenState();
}

class _ColorPaletteScreenState extends State<ColorPaletteScreen> {
  final List<Map<String, dynamic>> _palettes = [
    {'name': 'Material Red', 'color': Colors.red},
    {'name': 'Material Pink', 'color': Colors.pink},
    {'name': 'Material Purple', 'color': Colors.purple},
    {'name': 'Material Deep Purple', 'color': Colors.deepPurple},
    {'name': 'Material Indigo', 'color': Colors.indigo},
    {'name': 'Material Blue', 'color': Colors.blue},
    {'name': 'Material Light Blue', 'color': Colors.lightBlue},
    {'name': 'Material Cyan', 'color': Colors.cyan},
    {'name': 'Material Teal', 'color': Colors.teal},
    {'name': 'Material Green', 'color': Colors.green},
    {'name': 'Material Light Green', 'color': Colors.lightGreen},
    {'name': 'Material Lime', 'color': Colors.lime},
    {'name': 'Material Yellow', 'color': Colors.yellow},
    {'name': 'Material Amber', 'color': Colors.amber},
    {'name': 'Material Orange', 'color': Colors.orange},
    {'name': 'Material Deep Orange', 'color': Colors.deepOrange},
    {'name': 'Material Brown', 'color': Colors.brown},
    {'name': 'Material Blue Grey', 'color': Colors.blueGrey},
  ];

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _copyColor(Color color, String name) {
    final hex = _colorToHex(color);
    Clipboard.setData(ClipboardData(text: hex));
    HapticsEngine.heavyImpact(); // Haptic feedback
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(width: 24, height: 24, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text('$hex copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Palette'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _palettes.length,
        itemBuilder: (context, index) {
          final palette = _palettes[index];
          final MaterialColor baseColor = palette['color'];
          
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () => _copyColor(baseColor.shade500, palette['name']),
                    child: Container(
                      color: baseColor.shade500,
                      child: Center(
                        child: Text(
                          _colorToHex(baseColor.shade500),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _copyColor(baseColor.shade300, palette['name']),
                          child: Container(color: baseColor.shade300),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _copyColor(baseColor.shade700, palette['name']),
                          child: Container(color: baseColor.shade700),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _copyColor(baseColor.shade900, palette['name']),
                          child: Container(color: baseColor.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Text(
                    palette['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
