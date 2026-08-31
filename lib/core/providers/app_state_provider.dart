import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  String _userName = '';
  String _userNickname = '';
  List<String> _recentTools = [];
  List<String> _quickAccessTools = [];
  Set<String> _pinnedTools = {};

  String get userName => _userName;
  String get userNickname => _userNickname;
  String get displayName => _userNickname.isNotEmpty ? _userNickname : (_userName.isNotEmpty ? _userName : 'User');
  List<String> get recentTools => _recentTools;
  List<String> get quickAccessTools => _quickAccessTools;
  Set<String> get pinnedTools => _pinnedTools;

  AppStateProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? 'User';
    _userNickname = prefs.getString('user_nickname') ?? '';
    _recentTools = prefs.getStringList('recent_tools') ?? [];
    _pinnedTools = (prefs.getStringList('pinned_tools') ?? []).toSet();
    
    final savedQuick = prefs.getStringList('quick_access_tools');
    if (savedQuick != null && savedQuick.isNotEmpty) {
      _quickAccessTools = savedQuick;
    } else {
      _quickAccessTools = ['Flashlight', 'Compass', 'QR Scanner', 'Calculator'];
    }
    
    notifyListeners();
  }

  Future<void> updateProfile(String name, String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_nickname', nickname);
    _userName = name;
    _userNickname = nickname;
    notifyListeners();
  }

  Future<void> addRecentTool(String title) async {
    final prefs = await SharedPreferences.getInstance();
    _recentTools.remove(title);
    _recentTools.insert(0, title);
    if (_recentTools.length > 10) _recentTools = _recentTools.sublist(0, 10);
    await prefs.setStringList('recent_tools', _recentTools);
    notifyListeners();
  }

  Future<void> togglePinnedTool(String title) async {
    final prefs = await SharedPreferences.getInstance();
    if (_pinnedTools.contains(title)) {
      _pinnedTools.remove(title);
    } else {
      _pinnedTools.add(title);
    }
    await prefs.setStringList('pinned_tools', _pinnedTools.toList());
    notifyListeners();
  }
  
  Future<void> updateQuickAccess(List<String> newTools) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quick_access_tools', newTools);
    _quickAccessTools = newTools;
    notifyListeners();
  }
}
