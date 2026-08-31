import 'package:flutter/material.dart';
import '../../features/tools/compass/presentation/compass_screen.dart';
import '../../features/tools/flashlight/presentation/flashlight_screen.dart';
import '../../features/tools/sensors/presentation/sensors_screen.dart';
import '../../features/tools/level/presentation/level_screen.dart';
import '../../features/emergency/presentation/emergency_screen.dart';
import '../../features/tools/scanner/presentation/qr_scanner_screen.dart';
import '../../features/tools/magnifier/presentation/magnifier_screen.dart';
import '../../features/tools/sound_meter/presentation/sound_meter_screen.dart';
import '../../features/tools/calculator/presentation/calculator_screen.dart';
import '../../features/tools/stopwatch/presentation/stopwatch_screen.dart';
import '../../features/tools/timer/presentation/timer_screen.dart';
import '../../features/tools/tts/presentation/tts_screen.dart';
import '../../features/tools/counter/presentation/counter_screen.dart';
import '../../features/tools/random/presentation/random_picker_screen.dart';
import '../../features/tools/converter/presentation/converter_screen.dart';
import '../../features/tools/ruler/presentation/ruler_screen.dart';
import '../../features/tools/protractor/presentation/protractor_screen.dart';
import '../../features/tools/speedometer/presentation/speedometer_screen.dart';
import '../../features/tools/gps/presentation/gps_screen.dart';

class ToolData {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;
  final bool isPopular;
  final bool isFavorite;

  const ToolData({
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
    this.isPopular = false,
    this.isFavorite = false,
  });
}

class AppTools {
  static final List<ToolData> allTools = [
    ToolData(title: 'Compass', icon: Icons.explore, color: Colors.blue, screen: const CompassScreen(), isPopular: true, isFavorite: true),
    ToolData(title: 'Flashlight', icon: Icons.highlight, color: Colors.yellow[700]!, screen: const FlashlightScreen(), isPopular: true, isFavorite: true),
    ToolData(title: 'Sensors', icon: Icons.sensors, color: Colors.green, screen: const SensorsScreen()),
    ToolData(title: 'Level', icon: Icons.horizontal_rule, color: Colors.purple, screen: const LevelScreen(), isPopular: true),
    ToolData(title: 'Sound Meter', icon: Icons.graphic_eq, color: Colors.greenAccent, screen: const SoundMeterScreen()),
    ToolData(title: 'Random Picker', icon: Icons.casino, color: Colors.amber, screen: const RandomPickerScreen()),
    ToolData(title: 'Counter', icon: Icons.plus_one, color: Colors.cyan, screen: const CounterScreen()),
    ToolData(title: 'Stopwatch', icon: Icons.timer, color: Colors.blueAccent, screen: const StopwatchScreen(), isPopular: true, isFavorite: true),
    ToolData(title: 'Speedometer', icon: Icons.speed, color: Colors.indigoAccent, screen: const SpeedometerScreen()),
    ToolData(title: 'Unit Converter', icon: Icons.swap_horiz, color: Colors.deepPurple, screen: const ConverterScreen(), isPopular: true, isFavorite: true),
    ToolData(title: 'GPS & Altitude', icon: Icons.satellite_alt, color: Colors.lightBlue, screen: const GpsScreen()),
    ToolData(title: 'Timer', icon: Icons.hourglass_empty, color: Colors.red, screen: const TimerScreen(), isPopular: true),
    ToolData(title: 'Emergency', icon: Icons.warning, color: Colors.red, screen: const EmergencyScreen()),
    ToolData(title: 'Ruler', icon: Icons.straighten, color: Colors.orange, screen: const RulerScreen(), isPopular: true),
    ToolData(title: 'Protractor', icon: Icons.pie_chart, color: Colors.teal, screen: const ProtractorScreen()),
    ToolData(title: 'Text to Speech', icon: Icons.record_voice_over, color: Colors.pinkAccent, screen: const TtsScreen()),
    ToolData(title: 'QR Scanner', icon: Icons.qr_code_scanner, color: Colors.purpleAccent, screen: const QrScannerScreen(), isPopular: true, isFavorite: true),
    ToolData(title: 'Magnifier', icon: Icons.search, color: Colors.blue, screen: const MagnifierScreen()),
    ToolData(title: 'Calculator', icon: Icons.calculate, color: Colors.indigo, screen: const CalculatorScreen(), isPopular: true, isFavorite: true),
  ];
}
