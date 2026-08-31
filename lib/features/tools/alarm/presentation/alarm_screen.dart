import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/utils/navigation_utils.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<AlarmSettings> alarms = [];
  Map<String, List<int>> repeatingAlarms = {}; // alarmId -> list of weekdays (1=Mon..7=Sun)

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final fetchedAlarms = await Alarm.getAlarms();
    final prefs = await SharedPreferences.getInstance();
    final repeatingData = prefs.getString('repeating_alarms');
    if (repeatingData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(repeatingData);
        repeatingAlarms = decoded.map((k, v) => MapEntry(k, List<int>.from(v)));
      } catch (e) {
        debugPrint('Error parsing repeating alarms: $e');
      }
    }

    setState(() {
      alarms = fetchedAlarms;
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? -1 : 1);
    });
  }

  Future<void> _saveRepeating() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('repeating_alarms', jsonEncode(repeatingAlarms));
  }

  Future<void> _addAlarm() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && mounted) {
      // Ask for repeat days
      final List<int>? selectedDays = await _showRepeatDaysDialog();
      if (selectedDays == null) return;

      DateTime now = DateTime.now();
      DateTime dt = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

      // Adjust if time passed today
      if (dt.isBefore(now)) {
        dt = dt.add(const Duration(days: 1));
      }

      // If repeating is set, find the first day that matches
      if (selectedDays.isNotEmpty) {
        int safety = 0;
        while (!selectedDays.contains(dt.weekday) && safety < 8) {
          dt = dt.add(const Duration(days: 1));
          safety++;
        }
      }

      final id = DateTime.now().millisecondsSinceEpoch % 10000;
      final alarmSettings = AlarmSettings(
        id: id,
        dateTime: dt,
        assetAudioPath: 'assets/audio/alarm.ogg',
        loopAudio: true,
        vibrate: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.8),
        notificationSettings: const NotificationSettings(
          title: 'Pocket Utility Alarm',
          body: 'Your alarm is ringing!',
          stopButton: 'Stop',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
      
      if (selectedDays.isNotEmpty) {
        repeatingAlarms[id.toString()] = selectedDays;
        await _saveRepeating();
      }

      HapticsEngine.heavyImpact();
      _loadAlarms();
    }
  }

  Future<List<int>?> _showRepeatDaysDialog() async {
    List<int> selected = [];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return showModalBottomSheet<List<int>>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Repeat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(7, (index) {
                      final dayInt = index + 1; // 1 to 7
                      final isSelected = selected.contains(dayInt);
                      return ChoiceChip(
                        label: Text(days[index]),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() {
                            if (val) selected.add(dayInt);
                            else selected.remove(dayInt);
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              if (selected.length == 7) selected.clear();
                              else selected = [1, 2, 3, 4, 5, 6, 7];
                            });
                          },
                          child: Text(selected.length == 7 ? 'Clear All' : 'Everyday'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, selected),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAlarm(int id) async {
    await Alarm.stop(id);
    repeatingAlarms.remove(id.toString());
    await _saveRepeating();
    HapticsEngine.heavyImpact();
    _loadAlarms();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $amPm';
  }

  String _getRepeatText(int alarmId, DateTime dt) {
    final days = repeatingAlarms[alarmId.toString()];
    if (days == null || days.isEmpty) {
      final isTomorrow = dt.day != DateTime.now().day;
      return isTomorrow ? 'Tomorrow' : 'Today';
    }
    if (days.length == 7) return 'Everyday';
    if (days.length == 5 && days.contains(1) && days.contains(2) && days.contains(3) && days.contains(4) && days.contains(5)) return 'Weekdays';
    if (days.length == 2 && days.contains(6) && days.contains(7)) return 'Weekends';
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    days.sort();
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Alarm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off, size: 100, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 24),
                  const Text('No Alarms Scheduled', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24.0).copyWith(bottom: 100),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                final repeatText = _getRepeatText(alarm.id, alarm.dateTime);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor.withOpacity(0.8), primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTime(alarm.dateTime),
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.repeat, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                repeatText,
                                style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
                        onPressed: () => _deleteAlarm(alarm.id),
                      ),
                    ],
                  ),
                );
              },
            ),
            
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAlarm,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add Alarm', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
