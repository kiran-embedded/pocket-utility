import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../category_detail_screen.dart';
import '../../../../core/utils/tool_registry.dart';

class CategoryGridWidget extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;

  const CategoryGridWidget({
    super.key,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
  });

  int _countTools(List<String> titles) {
    return ToolRegistry.allTools.where((t) => titles.contains(t['title'])).length;
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Measurement', 'icon': Icons.straighten, 'color': const Color(0xFF2D78FF),
        'tools': ['Ruler', 'Protractor', 'Unit Converter', 'Level', 'Sound Meter']},
      {'title': 'Utilities', 'icon': Icons.build, 'color': const Color(0xFFF5B000),
        'tools': ['Flashlight', 'Magnifier', 'QR Scanner', 'Text to Speech', 'Calculator', 'Stopwatch', 'Timer', 'Counter', 'Random Picker']},
      {'title': 'Calculation', 'icon': Icons.calculate, 'color': const Color(0xFF6B4EE6),
        'tools': ['Calculator', 'Unit Converter']},
      {'title': 'Daily Life', 'icon': Icons.coffee, 'color': const Color(0xFF2EBD59),
        'tools': ['Flashlight', 'Timer', 'Stopwatch', 'Counter', 'Random Picker', 'QR Scanner']},
      {'title': 'Sensors', 'icon': Icons.sensors, 'color': const Color(0xFFE94B7C),
        'tools': ['Sensors', 'Sound Meter', 'Level', 'Compass', 'GPS & Altitude', 'Speedometer']},
      {'title': 'Device', 'icon': Icons.phone_android, 'color': const Color(0xFF4DB6AC),
        'tools': ['Sensors', 'GPS & Altitude']},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final color = cat['color'] as Color;
        final titleText = cat['title'] as String;
        final toolTitles = cat['tools'] as List<String>;
        final count = _countTools(toolTitles);
        final subtitleText = '$count Tool${count != 1 ? 's' : ''}';
        final iconData = cat['icon'] as IconData;

        return _CategoryPill(
          cat: cat,
          index: index,
          isDark: isDark,
          cardBg: cardBg,
        );
      },
    );
  }
}

class _CategoryPill extends StatefulWidget {
  final Map<String, dynamic> cat;
  final int index;
  final bool isDark;
  final Color cardBg;
  const _CategoryPill({required this.cat, required this.index, required this.isDark, required this.cardBg});

  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _pressed = false;

  void _openCategory(BuildContext context) {
    HapticsEngine.selectionClick();
    final color = widget.cat['color'] as Color;
    final titleText = widget.cat['title'] as String;
    final iconData = widget.cat['icon'] as IconData;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => CategoryDetailScreen(
        categoryName: titleText,
        categoryColor: color,
        categoryIcon: iconData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.cat['color'] as Color;
    final titleText = widget.cat['title'] as String;
    final toolTitles = widget.cat['tools'] as List<String>;
    final count = ToolRegistry.allTools.where((t) => toolTitles.contains(t['title'])).length;
    final subtitleText = '$count Tool${count != 1 ? 's' : ''}';
    final iconData = widget.cat['icon'] as IconData;
    final isDark = widget.isDark;
    final cardBg = widget.cardBg;
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _openCategory(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withOpacity(0.4), width: 1.5),
            boxShadow: [
              if (!isDark) BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: color, size: 22),
              ).animate().scale(delay: (200 + widget.index * 50).ms, duration: 300.ms, curve: Curves.easeOutBack),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF121212),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white30 : Colors.black26, size: 20),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: (150 + widget.index * 50).ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
