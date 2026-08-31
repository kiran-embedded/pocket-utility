import '../../../core/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../core/constants/app_tools.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  List<ToolData> _getToolsForCategory(String category) {
    switch (category) {
      case 'Navigation':
        return AppTools.allTools.where((t) => ['Compass', 'GPS & Altitude', 'Speedometer'].contains(t.title)).toList();
      case 'Sensors':
        return AppTools.allTools.where((t) => ['Sensors', 'Sound Meter', 'Level'].contains(t.title)).toList();
      case 'Tools':
      case 'Utilities':
        return AppTools.allTools.where((t) => ['Flashlight', 'Magnifier', 'QR Scanner', 'Text to Speech', 'Calculator', 'Stopwatch', 'Timer', 'Counter', 'Random Picker'].contains(t.title)).toList();
      case 'Emergency':
        return AppTools.allTools.where((t) => ['Emergency', 'Flashlight'].contains(t.title)).toList();
      case 'Measurement':
        return AppTools.allTools.where((t) => ['Ruler', 'Protractor', 'Unit Converter', 'Level', 'Sound Meter'].contains(t.title)).toList();
      case 'Calculation':
        return AppTools.allTools.where((t) => ['Calculator', 'Tip Calculator', 'Unit Price', 'Percentage'].contains(t.title)).toList();
      case 'Daily Life':
        return AppTools.allTools.where((t) => ['Flashlight', 'Timer', 'Stopwatch', 'Counter', 'Random Picker', 'QR Scanner', 'Notes', 'Clipboard'].contains(t.title)).toList();
      case 'Health':
        return AppTools.allTools.where((t) => ['Sound Meter', 'Magnifier', 'Level'].contains(t.title)).toList();
      case 'Device':
        return AppTools.allTools.where((t) => ['Sensors', 'GPS & Altitude'].contains(t.title)).toList();
      default:
        return AppTools.allTools;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tools = _getToolsForCategory(categoryName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final sheetBg = isDark ? const Color(0xFF0F0F0F) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F5FF);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: primary.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: categoryColor.withOpacity(0.3), width: 1),
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0D0D0D),
                          ),
                        ),
                        Text(
                          '${tools.length} tools available',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 18, color: isDark ? Colors.white54 : Colors.black45),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.1, duration: 250.ms),
              ),
              Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
              // Tools Grid
              Expanded(
                child: tools.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.construction_rounded, size: 48, color: categoryColor.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('No tools in this category', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: tools.length,
                        itemBuilder: (context, index) {
                          final tool = tools[index];
                          return _buildToolItem(context, tool, index, isDark, cardBg, primary);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolItem(BuildContext context, ToolData tool, int index, bool isDark, Color cardBg, Color primary) {
    return GestureDetector(
      onTap: () {
        HapticsEngine.selectionClick();
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 50), () {
          NavigationUtils.openTool(context, tool.title, tool.screen);
        });
      },
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(tool.icon, color: tool.color, size: 28),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            tool.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ).animate().scale(
        delay: (index * 35).ms,
        duration: 280.ms,
        curve: Curves.easeOutBack,
        begin: const Offset(0.7, 0.7),
      ).fadeIn(delay: (index * 35).ms, duration: 200.ms),
    );
  }
}
