import 'package:flutter/material.dart';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../../../../core/animations/animation_modules.dart';
import '../../../../core/utils/haptics_engine.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  Timer? _timer;
  DateTime _localNow = DateTime.now();
  
  // By default add some popular cities if empty, but we'll start with just Local and a few others
  final List<String> _pinnedLocations = [
    'Local Time', // special case
    'America/New_York',
    'Europe/London',
    'Asia/Tokyo',
    'Australia/Sydney',
    'Asia/Dubai'
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _localNow = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showAddCitySheet() {
    HapticsEngine.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _CitySearchSheet();
      },
    ).then((selectedLocation) {
      if (selectedLocation != null && !_pinnedLocations.contains(selectedLocation)) {
        setState(() {
          _pinnedLocations.add(selectedLocation);
        });
        HapticsEngine.heavyImpact();
      }
    });
  }

  void _removeLocation(int index) {
    if (_pinnedLocations[index] == 'Local Time') return; // Cannot remove local time
    HapticsEngine.selectionClick();
    setState(() {
      _pinnedLocations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF8B5CF6); // Lavender theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddCitySheet,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: _pinnedLocations.length,
        itemBuilder: (context, index) {
          final locationName = _pinnedLocations[index];
          
          DateTime timeToShow;
          bool isLocal = locationName == 'Local Time';
          String displayName = locationName;
          
          if (isLocal) {
            timeToShow = _localNow;
          } else {
            try {
              final location = tz.getLocation(locationName);
              timeToShow = tz.TZDateTime.from(_localNow, location);
              displayName = locationName.split('/').last.replaceAll('_', ' ');
            } catch (e) {
              timeToShow = _localNow;
              displayName = "Unknown";
            }
          }
          
          final isNight = timeToShow.hour < 6 || timeToShow.hour > 18;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Dismissible(
              key: Key(locationName),
              direction: isLocal ? DismissDirection.none : DismissDirection.endToStart,
              onDismissed: (_) => _removeLocation(index),
              background: Container(
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(24)),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isNight ? const Color(0xFF1C1C22) : (isDark ? const Color(0xFF2A2A35) : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primary.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: isNight ? Colors.black26 : Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLocal ? 'Local Time' : displayName,
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: isNight ? Colors.white : (isDark ? Colors.white : Colors.black87)
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMM d').format(timeToShow),
                          style: TextStyle(
                            fontSize: 13,
                            color: isNight ? Colors.white54 : (isDark ? Colors.white54 : Colors.black54)
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          DateFormat('h:mm').format(timeToShow),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: isNight ? Colors.white : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('a').format(timeToShow),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).applyStaggeredSlide(index: index),
          );
        },
      ),
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  const _CitySearchSheet();

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allLocations = [];
  List<String> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _allLocations = tz.timeZoneDatabase.locations.keys.toList();
    _allLocations.sort();
    _filteredLocations = _allLocations;
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _allLocations;
      } else {
        _filteredLocations = _allLocations
            .where((loc) => loc.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF8B5CF6);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _filterLocations,
                  decoration: InputDecoration(
                    hintText: 'Search city or country...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = _filteredLocations[index];
                    final parts = location.split('/');
                    final city = parts.last.replaceAll('_', ' ');
                    final region = parts.length > 1 ? parts.first : '';
                    
                    return ListTile(
                      leading: Icon(Icons.location_city, color: primary.withOpacity(0.7)),
                      title: Text(city, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: region.isNotEmpty ? Text(region) : null,
                      onTap: () {
                        Navigator.pop(context, location);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
