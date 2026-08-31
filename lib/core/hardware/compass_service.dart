import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class CompassService {
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;
  
  final _headingController = StreamController<double>.broadcast();
  final _locationController = StreamController<Position>.broadcast();
  final _accuracyController = StreamController<double>.broadcast();

  Stream<double> get headingStream => _headingController.stream;
  Stream<Position> get locationStream => _locationController.stream;
  Stream<double> get accuracyStream => _accuracyController.stream;

  CompassService() {
    _initLocation();
  }

  void startCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _headingController.add(event.heading!);
      }
      if (event.accuracy != null) {
        _accuracyController.add(event.accuracy!);
      }
    });
  }

  void stopCompass() {
    _compassSubscription?.cancel();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get initial position
    try {
      Position position = await Geolocator.getCurrentPosition();
      _locationController.add(position);
    } catch (e) {
      // Handle error
    }

    // Listen for updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _locationController.add(position);
    });
  }

  void dispose() {
    _compassSubscription?.cancel();
    _positionSubscription?.cancel();
    _headingController.close();
    _locationController.close();
    _accuracyController.close();
  }
}
