import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../dashboard/presentation/main_layout.dart';

class PermissionsOnboardingScreen extends StatefulWidget {
  const PermissionsOnboardingScreen({super.key});

  @override
  State<PermissionsOnboardingScreen> createState() => _PermissionsOnboardingScreenState();
}

class _PermissionsOnboardingScreenState extends State<PermissionsOnboardingScreen> {
  final List<Map<String, dynamic>> _permissions = [
    {
      'title': 'Camera',
      'icon': Icons.camera_alt,
      'description': 'Required for QR Scanner, Magnifier, and Flashlight.',
      'permission': Permission.camera,
      'status': false,
    },
    {
      'title': 'Location',
      'icon': Icons.location_on,
      'description': 'Required for GPS, Altitude, Speedometer, and Compass.',
      'permission': Permission.locationWhenInUse,
      'status': false,
    },
    {
      'title': 'Microphone',
      'icon': Icons.mic,
      'description': 'Required for Sound Meter.',
      'permission': Permission.microphone,
      'status': false,
    },
    {
      'title': 'Sensors',
      'icon': Icons.sensors,
      'description': 'Required for Compass, Level, and Sensors data.',
      'permission': Permission.sensors,
      'status': false,
    },
  ];

  Future<void> _requestPermission(int index) async {
    final hasVib = true;
    if (hasVib == true) HapticsEngine.selectionClick();
    
    final perm = _permissions[index]['permission'] as Permission;
    final status = await perm.request();
    
    setState(() {
      _permissions[index]['status'] = status.isGranted;
    });
  }

  Future<void> _finishOnboarding() async {
    final hasVib = true;
    if (hasVib == true) HapticsEngine.selectionClick();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        ModernPageRoute(builder: (_) => const MainLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Unlock Full Potential",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Pocket Utility needs a few permissions to power its tools. We only use these when you activate the specific tool.",
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: ListView.separated(
                  itemCount: _permissions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _permissions[index];
                    final isGranted = item['status'] as bool;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isGranted ? Colors.green.withOpacity(0.5) : Theme.of(context).dividerColor.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item['icon'] as IconData, color: Theme.of(context).primaryColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(item['description'] as String, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          isGranted 
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : ElevatedButton(
                                onPressed: () => _requestPermission(index),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: const Text('Allow'),
                              ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finishOnboarding,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Finish Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
