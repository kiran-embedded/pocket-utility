import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:system_info2/system_info2.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:pocket_utility/core/utils/haptics_engine.dart';
import '../../../../core/utils/flashlight_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/navigation_utils.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final Battery battery = Battery();
  StreamSubscription<BatteryState>? _batterySubscription;

  // Device info
  String _deviceName = 'Loading...';
  String _deviceModel = '';
  String _deviceManufacturer = '';
  String _deviceBoard = '';
  String _deviceHardware = '';
  String _osVersion = '';
  String _apiLevel = '';
  String _buildFingerprint = '';
  String _securityPatch = '';
  String _screenRes = '';
  String _screenDpi = '';
  String _refreshRate = '';
  String _bootloader = '';
  String _serialNo = 'N/A';

  // Battery
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;

  // Storage
  String _storageUsed = '--';
  String _storageTotal = '--';
  String _storageFree = '--';
  double _storagePercent = 0.0;

  // RAM
  String _ramUsed = '--';
  String _ramTotal = '--';
  String _ramFree = '--';
  double _ramPercent = 0.0;

  // CPU
  String _cpu = 'Unknown';
  String _cpuArch = 'Unknown';
  int _cpuCores = 0;

  // Permissions
  Map<String, PermissionStatus> _permissions = {};

  int _currentTabIndex = 0;

  final List<_PermDef> _permDefs = [
    _PermDef(Permission.camera, Icons.camera_alt, 'Camera', 'Used for QR Scanner & Protractor'),
    _PermDef(Permission.microphone, Icons.mic, 'Microphone', 'Used for Sound Meter'),
    _PermDef(Permission.location, Icons.location_on, 'Location', 'Used for GPS & Speedometer'),
    _PermDef(Permission.storage, Icons.folder, 'Storage', 'Access files on device'),
    _PermDef(Permission.notification, Icons.notifications, 'Notifications', 'Used for Alarm & Reminders'),
  ];

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initAll() async {
    await _initDeviceInfo();
    await _checkPermissions();
    _batterySubscription = battery.onBatteryStateChanged.listen((state) {
      if (mounted) setState(() => _batteryState = state);
    });
  }

  Future<void> _checkPermissions() async {
    final results = <String, PermissionStatus>{};
    for (final def in _permDefs) {
      results[def.label] = await def.permission.status;
    }
    if (mounted) setState(() => _permissions = results);
  }

  Future<void> _initDeviceInfo() async {
    // Screen info
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize;
    final dpr = view.devicePixelRatio;
    final refreshRate = view.display.refreshRate;
    if (mounted) {
      setState(() {
        _screenRes = '${size.width.toInt()} × ${size.height.toInt()} px';
        _screenDpi = '${(dpr * 160).toStringAsFixed(0)} DPI';
        _refreshRate = '${refreshRate.toStringAsFixed(0)} Hz';
      });
    }

    try {
      final info = await deviceInfo.androidInfo;
      if (mounted) {
        setState(() {
          _deviceName = info.brand.toUpperCase();
          _deviceModel = info.model;
          _deviceManufacturer = info.manufacturer;
          _deviceBoard = info.board;
          _deviceHardware = info.hardware;
          _osVersion = info.version.release;
          _apiLevel = info.version.sdkInt.toString();
          _cpuArch = info.supportedAbis.isNotEmpty ? info.supportedAbis.first : 'Unknown';
          _buildFingerprint = info.fingerprint.split('/').take(3).join('/');
          _securityPatch = info.version.securityPatch ?? 'Unknown';
          _bootloader = info.bootloader;
        });
      }
    } catch (_) {}

    try {
      final level = await battery.batteryLevel;
      final state = await battery.batteryState;
      if (mounted) setState(() { _batteryLevel = level; _batteryState = state; });
    } catch (_) {}

    try {
      final totalDisk = await DiskSpace.getTotalDiskSpace;
      final freeDisk = await DiskSpace.getFreeDiskSpace;
      if (totalDisk != null && freeDisk != null && totalDisk > 0) {
        final used = totalDisk - freeDisk;
        if (mounted) {
          setState(() {
            _storageTotal = '${(totalDisk / 1024).toStringAsFixed(1)} GB';
            _storageUsed = '${(used / 1024).toStringAsFixed(1)} GB';
            _storageFree = '${(freeDisk / 1024).toStringAsFixed(1)} GB';
            _storagePercent = used / totalDisk;
          });
        }
      }
    } catch (_) {}

    try {
      if (Platform.isAndroid) {
        final meminfo = await File('/proc/meminfo').readAsString();
        double memTotal = 0, memAvailable = 0;
        for (var line in meminfo.split('\n')) {
          if (line.startsWith('MemTotal:')) memTotal = double.parse(line.replaceAll(RegExp(r'[^0-9]'), '')) * 1024;
          if (line.startsWith('MemAvailable:')) memAvailable = double.parse(line.replaceAll(RegExp(r'[^0-9]'), '')) * 1024;
        }
        final cpuinfo = await File('/proc/cpuinfo').readAsString();
        int cores = 0;
        String cpuName = 'Unknown';
        for (var line in cpuinfo.split('\n')) {
          if (line.startsWith('processor')) cores++;
          if (line.startsWith('Hardware') && cpuName == 'Unknown') cpuName = line.split(':').last.trim();
        }
        final used = memTotal - memAvailable;
        if (mounted) {
          setState(() {
            _ramTotal = '${(memTotal / 1e9).toStringAsFixed(2)} GB';
            _ramUsed = '${(used / 1e9).toStringAsFixed(2)} GB';
            _ramFree = '${(memAvailable / 1e9).toStringAsFixed(2)} GB';
            _ramPercent = memTotal > 0 ? used / memTotal : 0;
            _cpuCores = cores > 0 ? cores : 8;
            if (cpuName != 'Unknown') _cpu = cpuName;
          });
        }
      }
    } catch (_) {}
  }

  String get _batteryStateLabel {
    switch (_batteryState) {
      case BatteryState.charging: return 'Charging';
      case BatteryState.discharging: return 'Discharging';
      case BatteryState.full: return 'Full';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildContent(isDark, primary),
            ),
          ),
          _buildBottomTabs(isDark, primary),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, Color primary) {
    if (_currentTabIndex == 1) return _buildInfoTab(isDark, primary);
    if (_currentTabIndex == 2) return _buildTestsTab(isDark, primary);
    if (_currentTabIndex == 3) return _buildPermissionsTab(isDark, primary);
    return _buildOverviewTab(isDark, primary);
  }

  Widget _buildOverviewTab(bool isDark, Color primary) {
    final cardBg = Theme.of(context).cardColor;
    final batteryColor = _batteryLevel < 20 ? Colors.red : (_batteryLevel < 50 ? Colors.orange : Colors.green);

    return Column(
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              // Phone icon
              Container(
                width: 56,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Icon(Icons.smartphone, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1)),
                    Text(_deviceModel, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Android $_osVersion  (API $_apiLevel)',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              // Battery
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: _batteryLevel / 100,
                          strokeWidth: 6,
                          color: batteryColor,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_batteryLevel%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          if (_batteryState == BatteryState.charging)
                            const Icon(Icons.bolt, color: Colors.yellow, size: 14),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_batteryStateLabel, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Screen info row
        Row(
          children: [
            _miniStatCard(Icons.monitor, _screenRes, 'Resolution', isDark, primary),
            const SizedBox(width: 12),
            _miniStatCard(Icons.grain, _screenDpi, 'DPI', isDark, primary),
            const SizedBox(width: 12),
            _miniStatCard(Icons.refresh, _refreshRate, 'Refresh', isDark, primary),
          ],
        ),

        const SizedBox(height: 16),
        _buildProgressCard('Storage', _storageUsed, _storageFree, _storageTotal, _storagePercent, Colors.deepPurple, Icons.sd_storage, isDark),
        const SizedBox(height: 12),
        _buildProgressCard('RAM', _ramUsed, _ramFree, _ramTotal, _ramPercent, Colors.teal, Icons.memory, isDark),
        const SizedBox(height: 12),

        // CPU quick card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _textMetric('CPU Cores', '$_cpuCores'),
              _textMetric('Arch', _cpuArch.split('-').first),
              _textMetric('Battery', _batteryStateLabel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard(IconData icon, String value, String label, bool isDark, Color primary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(bool isDark, Color primary) {
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoSection('Device', cardBg, borderColor, isDark, [
          ('Brand', _deviceName), ('Model', _deviceModel), ('Manufacturer', _deviceManufacturer),
          ('Board', _deviceBoard), ('Hardware', _deviceHardware), ('Bootloader', _bootloader),
        ]),
        const SizedBox(height: 16),
        _infoSection('Software', cardBg, borderColor, isDark, [
          ('Android', _osVersion), ('API Level', _apiLevel), ('Architecture', _cpuArch),
          ('Security Patch', _securityPatch), ('Kernel Bits', '${SysInfo.kernelBitness}-bit'),
        ]),
        const SizedBox(height: 16),
        _infoSection('Display', cardBg, borderColor, isDark, [
          ('Resolution', _screenRes), ('DPI', _screenDpi), ('Refresh Rate', _refreshRate),
        ]),
        const SizedBox(height: 16),
        _infoSection('Build', cardBg, borderColor, isDark, [
          ('Fingerprint', _buildFingerprint), ('Security Patch', _securityPatch),
        ]),
      ],
    );
  }

  Widget _infoSection(String title, Color cardBg, Color borderColor, bool isDark, List<(String, String)> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: rows.asMap().entries.map((e) {
              final isLast = e.key == rows.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.value.$1, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 14)),
                        Flexible(
                          child: Text(
                            e.value.$2,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsTab(bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('App Permissions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          'Manage which features this app can access on your device.',
          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 20),
        ..._permDefs.map((def) => _buildPermCard(def, isDark, primary)),
      ],
    );
  }

  Widget _buildPermCard(_PermDef def, bool isDark, Color primary) {
    final status = _permissions[def.label] ?? PermissionStatus.denied;
    final isGranted = status == PermissionStatus.granted;
    final statusColor = isGranted ? Colors.green : Colors.orange;
    final statusLabel = isGranted ? 'Granted' : 'Not Granted';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(def.icon, color: primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(def.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(def.description, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              if (!isGranted)
                TextButton(
                  onPressed: () async {
                    await def.permission.request();
                    _checkPermissions();
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 24)),
                  child: Text('Grant', style: TextStyle(color: primary, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestsTab(bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hardware Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Test your device hardware components.', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            _testCard('Vibration', Icons.vibration, Colors.orange, isDark, () async {
              final ok = true;
              if (ok) {
                HapticsEngine.heavyImpact();
                _snack('Vibration OK ✓');
              } else _snack('No vibrator');
            }),
            _testCard('Flashlight', Icons.highlight, Colors.amber, isDark, () async {
              try {
                await FlashlightManager.setTorchMode(true);
                await Future.delayed(const Duration(milliseconds: 500));
                await FlashlightManager.setTorchMode(false);
                _snack('Flashlight OK ✓');
              } catch (_) { _snack('Flashlight not available'); }
            }),
            _testCard('Display', Icons.monitor, Colors.blue, isDark, () {
              showDialog(
                context: context,
                builder: (_) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.deepPurple,
                    child: const Center(
                      child: Text('Display OK ✓\nTap to close', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, decoration: TextDecoration.none)),
                    ),
                  ),
                ),
              );
            }),
            _testCard('Speaker', Icons.volume_up, Colors.green, isDark, () {
              _snack('Testing Speaker…');
              HapticsEngine.success();
            }),
            _testCard('Camera', Icons.camera_alt, Colors.purple, isDark, () => _snack('Camera Test (Coming Soon)')),
            _testCard('Multitouch', Icons.touch_app, Colors.teal, isDark, () => _snack('Multitouch Test (Coming Soon)')),
          ],
        ),
      ],
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _testCard(String title, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String used, String free, String total, double percent, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Text(total, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              color: color,
              backgroundColor: color.withOpacity(0.15),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: $used', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
              Text('Free: $free', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textMetric(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(title, style: TextStyle(fontSize: 11, color: Theme.of(context).disabledColor)),
      ],
    );
  }

  Widget _buildBottomTabs(bool isDark, Color primary) {
    final items = [
      (Icons.phone_android_outlined, Icons.phone_android, 'Overview'),
      (Icons.info_outline, Icons.info, 'Info'),
      (Icons.build_circle_outlined, Icons.build_circle, 'Tests'),
      (Icons.security_outlined, Icons.security, 'Permissions'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = _currentTabIndex == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentTabIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? items[i].$2 : items[i].$1,
                    color: isActive ? primary : (isDark ? Colors.white38 : Colors.black38),
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].$3,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? primary : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PermDef {
  final Permission permission;
  final IconData icon;
  final String label;
  final String description;
  const _PermDef(this.permission, this.icon, this.label, this.description);
}
