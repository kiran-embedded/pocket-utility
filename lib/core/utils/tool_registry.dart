import 'package:flutter/material.dart';
import '../../features/tools/currency_converter/presentation/currency_converter_screen.dart';


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
import '../../features/tools/password_gen/presentation/password_gen_screen.dart';
import '../../features/tools/hash_generator/presentation/hash_generator_screen.dart';
import '../../features/tools/base64/presentation/base64_screen.dart';
import '../../features/tools/lorem_ipsum/presentation/lorem_ipsum_screen.dart';
import '../../features/tools/url_encode/presentation/url_encode_screen.dart';
import '../../features/tools/word_counter/presentation/word_counter_screen.dart';
import '../../features/tools/whitespace_remover/presentation/whitespace_remover_screen.dart';
import '../../features/tools/markdown_preview/presentation/markdown_preview_screen.dart';
import '../../features/tools/uuid_generator/presentation/uuid_generator_screen.dart';
import '../../features/tools/json_formatter/presentation/json_formatter_screen.dart';
import '../../features/tools/dice_roller/presentation/dice_roller_screen.dart';
import '../../features/tools/coin_flipper/presentation/coin_flipper_screen.dart';
import '../../features/tools/bmi_calculator/presentation/bmi_calculator_screen.dart';
import '../../features/tools/age_calculator/presentation/age_calculator_screen.dart';
import '../../features/tools/discount_calculator/presentation/discount_calculator_screen.dart';
import '../../features/tools/tip_calculator/presentation/tip_calculator_screen.dart';
import '../../features/tools/loan_calculator/presentation/loan_calculator_screen.dart';
import '../../features/tools/unit_price/presentation/unit_price_screen.dart';
import '../../features/tools/color_palette/presentation/color_palette_screen.dart';
import '../../features/tools/alarm/presentation/alarm_screen.dart';
import '../../features/tools/world_clock/presentation/world_clock_screen.dart';
import '../../features/tools/pomodoro/presentation/pomodoro_screen.dart';
import '../../features/tools/pedometer/presentation/pedometer_screen.dart';
import '../../features/tools/morse_code/presentation/morse_code_screen.dart';
import '../../features/tools/text_repeater/presentation/text_repeater_screen.dart';
import '../../features/tools/ascii_converter/presentation/ascii_converter_screen.dart';
import '../../features/tools/binary_converter/presentation/binary_converter_screen.dart';
import '../../features/tools/hex_converter/presentation/hex_converter_screen.dart';
import '../../features/tools/clipboard/presentation/clipboard_manager_screen.dart';
import '../../features/tools/color_picker/presentation/color_picker_screen.dart';

class ToolRegistry {
  static final List<Map<String, dynamic>> allTools = [
    {'title': 'Password Gen', 'icon': Icons.password, 'color': Colors.orange, 'screen': const PasswordGenScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Hash Generator', 'icon': Icons.security, 'color': Colors.blueGrey, 'screen': const HashGeneratorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Base64', 'icon': Icons.code, 'color': Colors.deepPurple, 'screen': const Base64Screen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Lorem Ipsum', 'icon': Icons.text_fields, 'color': Colors.blue, 'screen': const LoremIpsumScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'URL Encoder', 'icon': Icons.link, 'color': Colors.green, 'screen': const UrlEncodeScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Word Counter', 'icon': Icons.calculate, 'color': Colors.indigo, 'screen': const WordCounterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Whitespace Remover', 'icon': Icons.format_clear, 'color': Colors.redAccent, 'screen': const WhitespaceRemoverScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Markdown', 'icon': Icons.text_format, 'color': Colors.grey, 'screen': const MarkdownPreviewScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'UUID Generator', 'icon': Icons.fingerprint, 'color': Colors.purpleAccent, 'screen': const UuidGeneratorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'JSON Formatter', 'icon': Icons.data_object, 'color': Colors.yellow[800]!, 'screen': const JsonFormatterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Dice Roller', 'icon': Icons.casino, 'color': Colors.redAccent, 'screen': const DiceRollerScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Coin Flipper', 'icon': Icons.monetization_on, 'color': Colors.amber, 'screen': const CoinFlipperScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'BMI Calculator', 'icon': Icons.accessibility, 'color': Colors.teal, 'screen': const BmiCalculatorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Age Calculator', 'icon': Icons.cake, 'color': Colors.pinkAccent, 'screen': const AgeCalculatorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Discount Calculator', 'icon': Icons.local_offer, 'color': Colors.green, 'screen': const DiscountCalculatorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Tip Calculator', 'icon': Icons.receipt, 'color': Colors.blueGrey, 'screen': const TipCalculatorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Loan Calculator', 'icon': Icons.account_balance, 'color': Colors.indigo, 'screen': const LoanCalculatorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Unit Price', 'icon': Icons.shopping_cart, 'color': Colors.deepOrange, 'screen': const UnitPriceScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Color Palette', 'icon': Icons.palette, 'color': Colors.pink, 'screen': const ColorPaletteScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Alarm', 'icon': Icons.alarm, 'color': Colors.redAccent, 'screen': const AlarmScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'World Clock', 'icon': Icons.public, 'color': Colors.blue, 'screen': const WorldClockScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Pomodoro', 'icon': Icons.timer, 'color': Colors.red, 'screen': const PomodoroScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'Pedometer', 'icon': Icons.directions_walk, 'color': Colors.green, 'screen': const PedometerScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Morse Code', 'icon': Icons.more_horiz, 'color': Colors.black, 'screen': const MorseCodeScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Text Repeater', 'icon': Icons.repeat, 'color': Colors.deepPurple, 'screen': const TextRepeaterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'ASCII Converter', 'icon': Icons.font_download, 'color': Colors.indigo, 'screen': const AsciiConverterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Binary Converter', 'icon': Icons.code, 'color': Colors.blueGrey, 'screen': const BinaryConverterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Hex Converter', 'icon': Icons.data_array, 'color': Colors.grey, 'screen': const HexConverterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Compass', 'icon': Icons.explore, 'color': Colors.blue, 'screen': const CompassScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'Flashlight', 'icon': Icons.highlight, 'color': Colors.yellow[700]!, 'screen': const FlashlightScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'Sensors', 'icon': Icons.sensors, 'color': Colors.green, 'screen': const SensorsScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Level', 'icon': Icons.horizontal_rule, 'color': Colors.purple, 'screen': const LevelScreen(), 'isPopular': true, 'isFavorite': false},
    {'title': 'Sound Meter', 'icon': Icons.graphic_eq, 'color': Colors.greenAccent, 'screen': const SoundMeterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Random Picker', 'icon': Icons.casino, 'color': Colors.amber, 'screen': const RandomPickerScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Counter', 'icon': Icons.plus_one, 'color': Colors.cyan, 'screen': const CounterScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Stopwatch', 'icon': Icons.timer, 'color': Colors.blueAccent, 'screen': const StopwatchScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'Speedometer', 'icon': Icons.speed, 'color': Colors.indigoAccent, 'screen': const SpeedometerScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Unit Converter', 'icon': Icons.swap_horiz, 'color': Colors.deepPurple, 'screen': const ConverterScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'Currency Converter', 'icon': Icons.monetization_on_outlined, 'color': const Color(0xFF8B5CF6), 'screen': const CurrencyConverterScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'GPS & Altitude', 'icon': Icons.satellite_alt, 'color': Colors.lightBlue, 'screen': const GpsScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Timer', 'icon': Icons.hourglass_empty, 'color': Colors.red, 'screen': const TimerScreen(), 'isPopular': true, 'isFavorite': false},
    {'title': 'Emergency', 'icon': Icons.warning, 'color': Colors.red, 'screen': const EmergencyScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Ruler', 'icon': Icons.straighten, 'color': Colors.orange, 'screen': const RulerScreen(), 'isPopular': true, 'isFavorite': false},
    {'title': 'Protractor', 'icon': Icons.pie_chart, 'color': Colors.teal, 'screen': const ProtractorScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Text to Speech', 'icon': Icons.record_voice_over, 'color': Colors.pinkAccent, 'screen': const TtsScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'QR Scanner', 'icon': Icons.qr_code_scanner, 'color': Colors.purpleAccent, 'screen': const QrScannerScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'Magnifier', 'icon': Icons.search, 'color': Colors.blue, 'screen': const MagnifierScreen(), 'isPopular': false, 'isFavorite': false},
    {'title': 'Calculator', 'icon': Icons.calculate, 'color': Colors.indigo, 'screen': const CalculatorScreen(), 'isPopular': true, 'isFavorite': true},
    {'title': 'Clipboard', 'icon': Icons.content_paste, 'color': Colors.deepOrange, 'screen': const ClipboardManagerScreen(), 'isPopular': true, 'isFavorite': false},
    {'title': 'Color Picker', 'icon': Icons.color_lens, 'color': Colors.pink, 'screen': const ColorPickerScreen(), 'isPopular': false, 'isFavorite': true},
  ];

  static Map<String, dynamic>? getTool(String title) {
    try {
      return allTools.firstWhere((t) => t['title'] == title);
    } catch (e) {
      return null;
    }
  }
}
