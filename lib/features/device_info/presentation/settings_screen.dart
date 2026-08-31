import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/providers/app_state_provider.dart';
import 'package:flutter/cupertino.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>();
      setState(() {
        _nameCtrl.text = appState.userName;
        _nicknameCtrl.text = appState.userNickname;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final appState = context.read<AppStateProvider>();
    await appState.updateProfile(_nameCtrl.text.trim(), _nicknameCtrl.text.trim());
    HapticFeedback.mediumImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.themeMode == ThemeMode.dark;
    final primary = Theme.of(context).primaryColor;
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDarkNow ? Colors.white54 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text('PROFILE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1.2)),
            ),
            _buildSettingsGroup(
              context,
              isDarkNow,
              children: [
                _buildSettingsRow(
                  context,
                  isDarkNow,
                  title: context.watch<AppStateProvider>().displayName.isNotEmpty 
                      ? context.watch<AppStateProvider>().displayName 
                      : 'Set Your Name',
                  icon: Icons.person_outline,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Edit', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(width: 4),
                      Icon(Icons.edit, size: 14, color: primary),
                    ],
                  ),
                  onTap: () => _showNameEditor(context, primary),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text('APPEARANCE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1.2)),
            ),
            _buildSettingsGroup(
              context,
              isDarkNow,
              children: [
                _buildSettingsRow(
                  context,
                  isDarkNow,
                  title: 'Dark Mode',
                  icon: Icons.dark_mode_outlined,
                  trailing: CupertinoSwitch(
                    value: isDark,
                    activeColor: primary,
                    onChanged: (val) {
                      HapticFeedback.mediumImpact();
                      themeController.toggleTheme(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text('ABOUT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textSecondary, letterSpacing: 1.2)),
            ),
            _buildSettingsGroup(
              context,
              isDarkNow,
              children: [
                _buildSettingsRow(
                  context,
                  isDarkNow,
                  title: 'Pocket Utility PRO',
                  icon: Icons.verified_outlined,
                  trailing: Text('Version 1.0.0', style: TextStyle(color: textSecondary, fontSize: 14)),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    showAboutDialog(
                      context: context,
                      applicationName: 'Pocket Utility PRO',
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(Icons.build_circle, size: 64, color: primary),
                      children: const [Text('All Essential Tools.\n100% Offline. Always with you.')],
                    );
                  },
                ),
                _buildDivider(isDarkNow),
                _buildSettingsRow(
                  context,
                  isDarkNow,
                  title: 'Help Center',
                  icon: Icons.help_outline,
                  trailing: Icon(CupertinoIcons.chevron_right, color: textSecondary, size: 18),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const HelpCenterScreen()));
                  },
                ),
                _buildDivider(isDarkNow),
                _buildSettingsRow(
                  context,
                  isDarkNow,
                  title: 'Developer',
                  icon: Icons.code_rounded,
                  trailing: Icon(Icons.open_in_new, color: textSecondary, size: 16),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    launchUrl(Uri.parse('https://github.com/kiran-embedded'), mode: LaunchMode.externalApplication);
                  },
                ),
                _buildDivider(isDarkNow),
                _buildSettingsRow(
                  context,
                  isDarkNow,
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  trailing: Icon(CupertinoIcons.chevron_right, color: textSecondary, size: 18),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNameEditor(BuildContext context, Color primary) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      backgroundColor: Theme.of(context).cardColor,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nicknameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nickname (shown in greeting)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _saveName();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsGroup(BuildContext context, bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          if (!isDark) BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    bool isDark, {
    required String title,
    required IconData icon,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final primary = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
