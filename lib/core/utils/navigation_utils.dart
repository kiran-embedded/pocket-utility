import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/device_info/presentation/settings_screen.dart';
import '../../features/device_info/presentation/help_center_screen.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state_provider.dart';

class NavigationUtils {
  static Future<void> openTool(BuildContext context, String toolName, Widget screen) async {
    if (context.mounted) {
      context.read<AppStateProvider>().addRecentTool(toolName);
      Navigator.push(context, ModernPageRoute(builder: (_) => screen));
    }
  }

  static void showGlobalMoreOptions(BuildContext context) {
    HapticsEngine.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings, color: Colors.blue),
                  ),
                  title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CupertinoPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.help_outline, color: Colors.green),
                  ),
                  title: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, CupertinoPageRoute(builder: (_) => const HelpCenterScreen()));
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, color: Colors.purple),
                  ),
                  title: const Text('Share App', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share('Check out Pocket Utility PRO! An all-in-one premium toolkit. Download it now!');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.orange),
                  ),
                  title: const Text('About Pocket Utility PRO', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: 'Pocket Utility PRO',
                      applicationVersion: '2.1.0',
                      applicationIcon: const Icon(Icons.build_circle, size: 48, color: Colors.blue),
                      children: const [
                        Text('A premium utility toolkit designed with an advanced UX engine and completely native features.'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ModernPageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  ModernPageRoute({required this.builder, super.settings});

  @override
  Color? get barrierColor => null;
  @override
  String? get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // Ultra-premium Apple iOS-like lateral slide with parallax and shadow
    final drive = CurvedAnimation(parent: animation, curve: const Cubic(0.2, 0.9, 0.1, 1.0), reverseCurve: Curves.easeOutQuad);
    final secondaryDrive = CurvedAnimation(parent: secondaryAnimation, curve: const Cubic(0.2, 0.9, 0.1, 1.0));

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(drive),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(-5, 0),
            )
          ],
        ),
        child: child,
      ),
    );
  }
}
