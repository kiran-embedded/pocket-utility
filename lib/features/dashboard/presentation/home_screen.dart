import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/tool_registry.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/utils/haptics_engine.dart';
import 'tool_search_delegate.dart';
import 'quick_access_edit_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state_provider.dart';
import 'package:flutter/cupertino.dart';

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
  int _selectedFilter = 0;


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
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
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
                      userName: context.watch<AppStateProvider>().displayName,
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFilters(isDark, primary, textPrimary, textSecondary),
                const SizedBox(height: 18),      // pushes Categories header down
                if (_selectedFilter == 0) ...[
                  _buildSectionHeader('Categories', 'View all', textPrimary, textSecondary, primary, () => widget.onTabSelected(1)),
                  const SizedBox(height: 0),
                  Transform.translate(
                    offset: const Offset(0, -8),
                    child: CategoryGridWidget(isDark: isDark, cardBg: cardBg, cardBorder: cardBorder),
                  ),
                  const SizedBox(height: 4),
                  _buildSectionHeader('Quick Access', 'Edit', textPrimary, textSecondary, primary, () async {
                    await Navigator.push(context, ModernPageRoute(builder: (_) => const QuickAccessEditScreen()));
                    // AppStateProvider reloads on its own via notifyListeners
                  }),
                  const SizedBox(height: 12),     // pushes pills down, away from header
                  QuickAccessWidget(quickAccessTools: context.watch<AppStateProvider>().quickAccessTools, isDark: isDark, cardBg: cardBg, cardBorder: cardBorder),
                  const SizedBox(height: 8),      // safe gap above nav bar
                ] else ...[
                  const SizedBox(height: 16),
                  _buildFilteredToolsView(isDark, cardBg, primary),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color cardBg, Color cardBorder, Color textSecondary) {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: GestureDetector(
          onTap: () {
            HapticsEngine.selectionClick();
            showSearch(context: context, delegate: ToolSearchDelegate());
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4), width: 1.5),
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
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 6 : 0),
            child: GestureDetector(
              onTap: () {
                HapticsEngine.selectionClick();
                setState(() => _selectedFilter = index);
              },
              child: AnimatedContainer(
                duration: 150.ms,
                curve: Curves.easeInOut,
                height: 36,
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
                  border: isSelected || isDark ? null : Border.all(color: primary.withOpacity(0.4), width: 1.2),
                  boxShadow: !isSelected && !isDark ? [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                  ] : [],
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: isSelected ? Colors.white : textSecondary),
                    const SizedBox(width: 3),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          name,
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
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
  Widget _buildFilteredToolsView(bool isDark, Color cardBg, Color primary) {
    List<Map<String, dynamic>> tools = [];
    if (_selectedFilter == 1) {
      tools = ToolRegistry.allTools.where((t) => t['isPopular'] == true).toList();
    } else if (_selectedFilter == 2) {
      final recentList = context.watch<AppStateProvider>().recentTools;
      tools = ToolRegistry.allTools.where((t) => recentList.contains(t['title'])).toList();
    } else if (_selectedFilter == 3) {
      tools = ToolRegistry.allTools.where((t) => t['isFavorite'] == true).toList();
    }

    if (tools.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(child: Text('No tools found', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54))),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        final color = tool['color'] as Color;
        final icon = tool['icon'] as IconData;
        return GestureDetector(
          onTap: () {
            HapticsEngine.selectionClick();
            context.read<AppStateProvider>().addRecentTool(tool['title'] as String);
            Navigator.push(context, CupertinoPageRoute(builder: (_) => tool['screen'] as Widget));
          },
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
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
                child: Center(
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 66,
                child: Text(
                  tool['title'] as String,
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
          ).animate().scale(delay: (index * 20).ms, duration: 250.ms, curve: Curves.easeOutBack),
        );
      },
    );
  }
}
