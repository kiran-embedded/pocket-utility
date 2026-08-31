import 'package:flutter/material.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../../core/utils/tool_registry.dart';
import '../../../core/utils/haptics_engine.dart';
import '../../dashboard/presentation/tool_search_delegate.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_state_provider.dart';

class ToolsGridScreen extends StatefulWidget {
  const ToolsGridScreen({super.key});

  @override
  State<ToolsGridScreen> createState() => _ToolsGridScreenState();
}

class _ToolsGridScreenState extends State<ToolsGridScreen> {
  final List<String> _filters = ['All', 'Pinned', 'Popular', 'Recent', 'Favorite'];
  int _selectedIndex = 0;

  void _togglePin(String title) {
    HapticsEngine.heavyImpact();
    context.read<AppStateProvider>().togglePinnedTool(title);
  }

  final List<Map<String, dynamic>> _allTools = ToolRegistry.allTools;

  List<Map<String, dynamic>> _getToolsForFilter(String filter, AppStateProvider appState) {
    List<Map<String, dynamic>> list;
    if (filter == 'All') {
      list = List.from(_allTools);
    } else if (filter == 'Pinned') {
      list = _allTools.where((t) => appState.pinnedTools.contains(t['title'])).toList();
    } else if (filter == 'Recent') {
      list = _allTools.where((t) => appState.recentTools.contains(t['title'])).toList();
      list.sort((a, b) => appState.recentTools.indexOf(a['title']).compareTo(appState.recentTools.indexOf(b['title'])));
    } else if (filter == 'Popular') {
      list = _allTools.where((t) => t['isPopular'] == true).toList();
    } else if (filter == 'Favorite') {
      list = _allTools.where((t) => t['isFavorite'] == true).toList();
    } else {
      list = List.from(_allTools);
    }
    
    if (filter == 'All') {
      list.sort((a, b) {
        final aPin = appState.pinnedTools.contains(a['title']) ? 0 : 1;
        final bPin = appState.pinnedTools.contains(b['title']) ? 0 : 1;
        return aPin.compareTo(bPin);
      });
    }
    return list;
  }

  Widget _buildFilterPills(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final selected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticsEngine.selectionClick();
                setState(() => _selectedIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 4, right: index == _filters.length - 1 ? 0 : 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? primary : primary.withOpacity(0.35),
                    width: selected ? 0 : 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final currentFilter = _filters[_selectedIndex];
    final tools = _getToolsForFilter(currentFilter, appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              HapticsEngine.selectionClick();
              showSearch(context: context, delegate: ToolSearchDelegate());
            }
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildFilterPills(context),
        ),
      ),
      body: tools.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No tools here yet', style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16).copyWith(bottom: 120),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return _buildToolItem(context, tool['title'], tool['icon'], tool['color'], () {
                  HapticsEngine.selectionClick();
                  NavigationUtils.openTool(context, tool['title'], tool['screen']);
                }, () => _togglePin(tool['title']), appState);
              },
            ),
    );
  }

  Widget _buildToolItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, VoidCallback onLongPress, AppStateProvider appState) {
    final isPinned = appState.pinnedTools.contains(title);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPinned ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.4),
                      width: isPinned ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 28),
                  ),
                ),
                if (isPinned)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.push_pin, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
