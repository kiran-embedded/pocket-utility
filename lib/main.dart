import 'dart:async';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/providers/currency_provider.dart';
import 'core/providers/app_state_provider.dart';
import 'package:flutter/services.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'core/utils/haptics_engine.dart';
import 'features/tools/alarm/presentation/alarm_ring_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HapticsEngine.init();
  await Alarm.init();
  tz.initializeTimeZones();

  // Initial style — will be updated dynamically by MainLayout based on theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const PocketUtilityApp(),
    ),
  );
}

class PocketUtilityApp extends StatefulWidget {
  const PocketUtilityApp({super.key});

  @override
  State<PocketUtilityApp> createState() => _PocketUtilityAppState();
}

class _PocketUtilityAppState extends State<PocketUtilityApp> {
  StreamSubscription<AlarmSettings>? ringSubscription;

  @override
  void initState() {
    super.initState();
    ringSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      if (globalNavigatorKey.currentState != null) {
        globalNavigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => AlarmRingScreen(alarmSettings: alarmSettings),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    ringSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          navigatorKey: globalNavigatorKey,
          title: 'Pocket Utility',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
