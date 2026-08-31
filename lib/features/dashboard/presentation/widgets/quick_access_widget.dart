import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/utils/tool_registry.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../core/animations/animation_modules.dart';

class QuickAccessWidget extends StatelessWidget {
  final List<String> quickAccessTools;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;

  const QuickAccessWidget({
    super.key,
    required this.quickAccessTools,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: quickAccessTools.map((toolName) {
        final toolInfo = ToolRegistry.getTool(toolName);
        final color = toolInfo != null ? (toolInfo['color'] as Color) : const Color(0xFF6B4EE6);
        final icon = toolInfo != null ? (toolInfo['icon'] as IconData) : Icons.build;
        
        return GestureDetector(
          onTap: () {
            HapticsEngine.mediumImpact();
            if (toolInfo != null) {
              NavigationUtils.openTool(context, toolName, toolInfo['screen'] as Widget);
            }
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    if (!isDark) BoxShadow(
                      color: Colors.black.withOpacity(0.025),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 66,
                child: Text(
                  toolName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ).applyStaggeredSlide(index: quickAccessTools.indexOf(toolName), baseDelay: 75),
        );
      }).toList(),
    );
  }
}
