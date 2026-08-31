import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({super.key, required this.alarmSettings});

  void _snooze(BuildContext context) {
    HapticsEngine.heavyImpact();
    final now = DateTime.now();
    Alarm.set(
      alarmSettings: alarmSettings.copyWith(
        id: alarmSettings.id,
        dateTime: DateTime(now.year, now.month, now.day, now.hour, now.minute).add(const Duration(minutes: 10)),
      ),
    ).then((_) {
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _stop(BuildContext context) async {
    HapticsEngine.heavyImpact();
    await Alarm.stop(alarmSettings.id);

    // Check if alarm should repeat
    final prefs = await SharedPreferences.getInstance();
    final repeatingData = prefs.getString('repeating_alarms');
    if (repeatingData != null) {
      try {
        final Map<String, dynamic> repeatingAlarms = jsonDecode(repeatingData);
        final alarmIdStr = alarmSettings.id.toString();
        if (repeatingAlarms.containsKey(alarmIdStr)) {
          final List<int> days = List<int>.from(repeatingAlarms[alarmIdStr]);
          if (days.isNotEmpty) {
            // Find next matching day
            DateTime nextTime = alarmSettings.dateTime.add(const Duration(days: 1));
            // weekDay is 1-7 (Mon-Sun).
            int safety = 0;
            while (!days.contains(nextTime.weekday) && safety < 8) {
              nextTime = nextTime.add(const Duration(days: 1));
              safety++;
            }
            
            final nextSettings = alarmSettings.copyWith(
              id: alarmSettings.id,
              dateTime: nextTime,
            );
            await Alarm.set(alarmSettings: nextSettings);
          }
        }
      } catch (e) {
        debugPrint('Error parsing repeating alarms: $e');
      }
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Icon(Icons.alarm, color: Colors.white, size: 100)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 600.ms, curve: Curves.easeInOutSine)
                    .shimmer(duration: 2.seconds, color: Colors.blueAccent.withOpacity(0.5)),
                const SizedBox(height: 32),
                const Text(
                  'Alarm Ringing',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                Text(
                  alarmSettings.notificationSettings.body,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _snooze(context),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('SNOOZE\n10m', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _stop(context),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 4),
                      ],
                    ),
                    child: const Center(
                      child: Text('STOP', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
