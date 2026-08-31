import os
import re

def replace_in_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for target, replacement in replacements:
        if target not in content:
            print(f"Failed to find target in {filepath}:\n{target[:100]}")
            return False
        content = content.replace(target, replacement)
        
    with open(filepath, 'w') as f:
        f.write(content)
    return True

# 1. home_header_widget.dart
header_path = '/home/kirancybergrid/Documents/all in one tool/lib/features/dashboard/presentation/widgets/home_header_widget.dart'
header_target = """class HomeHeaderWidget extends StatelessWidget {
  final String userName;
  final String timeGreeting;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;

  const HomeHeaderWidget({
    super.key,
    required this.userName,
    required this.timeGreeting,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
  });"""

with open(header_path, 'r') as f:
    header_content = f.read()

header_content = """import 'package:flutter/material.dart';
import '../../../../core/utils/haptics_engine.dart';
import '../../../../core/animations/animation_modules.dart';
import 'emoji_hand_shader.dart';

class HomeHeaderWidget extends StatelessWidget {
  final String userName;
  final String timeGreeting;
  final bool isDark;
  final Color primary;

  const HomeHeaderWidget({
    super.key,
    required this.userName,
    required this.timeGreeting,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Text — left side
          Positioned(
            left: 0,
            top: 20,
            right: 170, // Keep text away from image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeGreeting,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : const Color(0xFF636675),
                  ),
                ).applyPremiumFade(delay: 50),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF8B3DFF),
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const EmojiHandShader(size: 28),
                  ],
                ).applyPremiumFade(delay: 80),
                const SizedBox(height: 12),
                Text(
                  'A fresh start to\\nachieve your goals today ✨',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white54 : const Color(0xFF7A7D8F),
                  ),
                ).applyPremiumFade(delay: 120),
              ],
            ),
          ),
          
          // Tea image — overlaps right side heavily, 30% width visual presence
          Positioned(
            right: -24, // Overlap edge
            top: -10,
            child: Image.asset(
              'assets/images/tea_book.png',
              width: 230,
              height: 230,
              fit: BoxFit.contain,
            ).applyPremiumFade(delay: 150),
          ),
        ],
      ),
    );
  }
}
"""
with open(header_path, 'w') as f:
    f.write(header_content)


# 2. category_grid_widget.dart
cat_path = '/home/kirancybergrid/Documents/all in one tool/lib/features/dashboard/presentation/widgets/category_grid_widget.dart'
cat_target = """      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),"""
cat_rep = """      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.1,
      ),"""

cat_target2 = """            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(iconData, color: color, size: 18),
                  ).animate().scale(delay: (200 + index * 50).ms, duration: 300.ms, curve: Curves.easeOutBack),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titleText,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: isDark ? Colors.white : const Color(0xFF121212),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitleText,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),"""
cat_rep2 = """            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cardBorder),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(iconData, color: color, size: 20),
                  ).animate().scale(delay: (200 + index * 50).ms, duration: 300.ms, curve: Curves.easeOutBack),
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
            ),"""
replace_in_file(cat_path, [(cat_target, cat_rep), (cat_target2, cat_rep2)])

# 3. home_screen.dart
home_path = '/home/kirancybergrid/Documents/all in one tool/lib/features/dashboard/presentation/home_screen.dart'
with open(home_path, 'r') as f:
    home_content = f.read()

home_content_new = """import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/tool_registry.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/utils/haptics_engine.dart';
import 'tool_search_delegate.dart';
import 'category_detail_screen.dart';
import 'quick_access_edit_screen.dart';

import 'widgets/home_header_widget.dart';
import 'widgets/category_grid_widget.dart';
import 'widgets/quick_access_widget.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabSelected;
  const HomeScreen({super.key, required this.onTabSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  List<String> _quickAccessTools = ['Flashlight', 'Compass', 'QR Scanner', 'Calculator'];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    final nickname = prefs.getString('user_nickname');
    final savedTools = prefs.getStringList('quick_access_tools');
    
    if (mounted) {
      setState(() {
        _userName = (nickname != null && nickname.isNotEmpty) ? nickname : name;
        if (savedTools != null && savedTools.isNotEmpty) {
          _quickAccessTools = savedTools;
        }
      });
    }
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF121212);
    final textSecondary = isDark ? const Color(0xFFA19CC5) : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF111111) : Colors.white;
    final cardBorder = isDark ? Colors.white.withOpacity(0.07) : Colors.transparent;

    final scaffoldBg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: scaffoldBg,
            elevation: 0,
            systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (!isDark)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEBE3FF), Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 24,
                    right: 0,
                    child: HomeHeaderWidget(
                      userName: _userName,
                      timeGreeting: _getTimeBasedGreeting(),
                      isDark: isDark,
                      primary: primary,
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: _buildSearchBar(isDark, cardBg, cardBorder, textSecondary),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFilters(isDark, primary, textPrimary, textSecondary),
                const SizedBox(height: 24),
                
                if (_selectedFilter == 0) ...[
                  _buildSectionHeader('Categories', 'View all', textPrimary, textSecondary, primary, () => widget.onTabSelected(1)),
                  const SizedBox(height: 16),
                  CategoryGridWidget(isDark: isDark, cardBg: cardBg, cardBorder: cardBorder),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Quick Access', 'Edit', textPrimary, textSecondary, primary, () async {
                    final result = await Navigator.push(context, ModernPageRoute(builder: (_) => const QuickAccessEditScreen()));
                    if (result == true) _loadData();
                  }),
                  const SizedBox(height: 16),
                  QuickAccessWidget(quickAccessTools: _quickAccessTools, isDark: isDark, cardBg: cardBg, cardBorder: cardBorder),
                ] else ...[
                  const SizedBox(height: 40),
                  Center(child: Text('Coming soon...', style: TextStyle(color: textSecondary))),
                ],
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color cardBg, Color cardBorder, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          HapticsEngine.selectionClick();
          showSearch(context: context, delegate: ToolSearchDelegate());
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: cardBorder, width: 1),
            boxShadow: [
              if (!isDark) BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: textSecondary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Search tools...',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark, Color primary, Color textPrimary, Color textSecondary) {
    final filters = [
      {'name': 'All', 'icon': Icons.grid_view_rounded},
      {'name': 'Popular', 'icon': Icons.local_fire_department_rounded},
      {'name': 'Recent', 'icon': Icons.access_time_rounded},
      {'name': 'Favorites', 'icon': Icons.favorite_border_rounded},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(filters.length, (index) {
        final isSelected = _selectedFilter == index;
        final icon = filters[index]['icon'] as IconData;
        final name = filters[index]['name'] as String;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticsEngine.selectionClick();
                setState(() => _selectedFilter = index);
              },
              child: AnimatedContainer(
                duration: 250.ms,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF8B3DFF), Color(0xFF5E2BFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.07) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected || isDark ? null : Border.all(color: Colors.grey.shade100),
                  boxShadow: !isSelected && !isDark ? [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                  ] : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: isSelected ? Colors.white : textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      name,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    ).animate().fade(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildSectionHeader(String title, String action, Color textPrimary, Color textSecondary, Color primary, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
        ),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: () {
              HapticsEngine.selectionClick();
              onAction();
            },
            child: Text(
              action,
              textScaler: TextScaler.noScaling,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF8B3DFF)),
            ),
          ),
      ],
    );
  }
}
"""
with open(home_path, 'w') as f:
    f.write(home_content_new)

print("Done")
