import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/utils/tool_registry.dart';
import '../../../../core/utils/navigation_utils.dart';

class RecentToolsWidget extends StatelessWidget {
  final List<String> recentToolsList;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;

  const RecentToolsWidget({
    super.key,
    required this.recentToolsList,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    if (recentToolsList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text('No recently used tools yet.', style: TextStyle(color: textSecondary)),
        ),
      );
    }

    return Column(
      children: recentToolsList.map((toolName) {
        final toolInfo = ToolRegistry.getTool(toolName);
        if (toolInfo == null) return const SizedBox.shrink();

        final icon = toolInfo['icon'] as IconData;
        final color = toolInfo['color'] as Color;

        return GestureDetector(
          onTap: () {
            HapticsEngine.selectionClick();
            NavigationUtils.openTool(context, toolName, toolInfo['screen'] as Widget);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scaleXY(begin: 1.0, end: 1.1, duration: 1800.ms, curve: Curves.easeInOut),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(toolName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textPrimary)),
                      const SizedBox(height: 4),
                      Text('Recently used', style: TextStyle(fontSize: 12, color: textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textSecondary.withOpacity(0.5))
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .moveX(begin: 0, end: 4, duration: 1000.ms, curve: Curves.easeInOut),
              ],
            ),
          ).animate().fade(delay: (200 + recentToolsList.indexOf(toolName) * 75).ms, duration: 400.ms).slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),
        );
      }).toList(),
    );
  }
}
