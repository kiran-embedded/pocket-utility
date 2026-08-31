import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/navigation_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClipboardManagerScreen extends StatefulWidget {
  const ClipboardManagerScreen({super.key});

  @override
  State<ClipboardManagerScreen> createState() => _ClipboardManagerScreenState();
}

class _ClipboardManagerScreenState extends State<ClipboardManagerScreen> {
  List<String> _history = [];
  Set<int> _pinned = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _readCurrentClipboard();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final pinnedList = prefs.getStringList('clipboard_pinned') ?? [];
    setState(() {
      _history = prefs.getStringList('clipboard_history') ?? [];
      _pinned = pinnedList.map(int.parse).toSet();
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('clipboard_history', _history);
    await prefs.setStringList('clipboard_pinned', _pinned.map((e) => e.toString()).toList());
  }

  Future<void> _readCurrentClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      final text = data.text!;
      if (!_history.contains(text)) {
        setState(() {
          _history.insert(0, text);
          if (_history.length > 100) _history.removeLast();
        });
      } else {
        setState(() {
          _history.remove(text);
          _history.insert(0, text);
        });
      }
      _save();
    }
  }

  void _copy(String text) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
    );
  }

  void _delete(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _pinned.remove(index);
      _history.removeAt(index);
    });
    _save();
  }

  void _togglePin(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_pinned.contains(index)) {
        _pinned.remove(index);
      } else {
        _pinned.add(index);
      }
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = Theme.of(context).cardColor;
    final primary = Theme.of(context).primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF121212);
    final textSecondary = isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100;

    // Sort: pinned first
    final filtered = _history
        .asMap()
        .entries
        .where((e) => e.value.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    filtered.sort((a, b) {
      final aPin = _pinned.contains(a.key) ? 0 : 1;
      final bPin = _pinned.contains(b.key) ? 0 : 1;
      return aPin - bPin;
    });

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Clipboard', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primary),
            onPressed: () {
              HapticFeedback.selectionClick();
              _readCurrentClipboard();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _history.clear();
                _pinned.clear();
              });
              _save();
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: textPrimary),
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search clipboard…',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.search, color: primary),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ).animate().slideY(begin: -0.2).fade(),
          ),

          // Item count badge
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_history.length} saved', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.content_paste_off, size: 72, color: textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('Nothing here yet', style: TextStyle(color: textSecondary, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text('Copy some text to add it here', style: TextStyle(color: textSecondary.withOpacity(0.5), fontSize: 13)),
                      ],
                    ),
                  ).animate().fade()
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final entry = filtered[i];
                      final realIndex = entry.key;
                      final text = entry.value;
                      final isPinned = _pinned.contains(realIndex);

                      final wordCount = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
                      final charCount = text.length;

                      return Dismissible(
                        key: Key('clip_$realIndex$text'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _delete(realIndex),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isPinned ? primary.withOpacity(0.5) : borderColor,
                              width: isPinned ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isPinned ? primary.withOpacity(0.08) : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => _copy(text),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isPinned)
                                      Row(
                                        children: [
                                          Icon(Icons.push_pin, size: 12, color: primary),
                                          const SizedBox(width: 4),
                                          Text('Pinned', style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    if (isPinned) const SizedBox(height: 6),
                                    Text(
                                      text,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: textPrimary, fontSize: 15, height: 1.45),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        // Word + char badges
                                        _badge('$wordCount words', isDark, textSecondary),
                                        const SizedBox(width: 8),
                                        _badge('$charCount chars', isDark, textSecondary),
                                        const Spacer(),
                                        // Pin
                                        _iconBtn(
                                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                          isPinned ? primary : textSecondary,
                                          () => _togglePin(realIndex),
                                        ),
                                        const SizedBox(width: 4),
                                        // Copy
                                        _iconBtn(Icons.copy_rounded, primary, () => _copy(text)),
                                        const SizedBox(width: 4),
                                        // Delete
                                        _iconBtn(Icons.delete_outline, Colors.redAccent, () => _delete(realIndex)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().fade(delay: (i * 40).ms).slideX(begin: 0.08);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, bool isDark, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: textSecondary)),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 20),
    );
  }
}
