import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:geolocator/geolocator.dart';
import '../model/session.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<Position>? _positionStream;
  final List<LocationPoint> _locations = [];
  int _initialStepCount = 0;
  int _currentStepCount = 0;
  double _distancePerStep = 0.762; // average step length in meters
  Position? _lastKnownPosition;

  List<LocationPoint> get currentLocations => _locations;
  double get totalDistance => (_currentStepCount - _initialStepCount) * _distancePerStep;
  int get totalSteps => _currentStepCount - _initialStepCount;

  Position? get lastKnownPosition => _lastKnownPosition;

  void startTracking(Function() onLocationUpdated) async {
    // Start step tracking
    _stepCountStream = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (_initialStepCount == 0) {
          _initialStepCount = event.steps;
        }
        _currentStepCount = event.steps;
        onLocationUpdated();
      },
      onError: (error) {
        print('Step Count Error: $error');
      },
      cancelOnError: true,
    );

    // Start location tracking
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      _lastKnownPosition = position;
      _locations.add(LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      ));
      onLocationUpdated();
    });
  }

  void stopTracking() {
    _stepCountStream?.cancel();
    _stepCountStream = null;
    _positionStream?.cancel();
    _positionStream = null;
  }

  void reset() {
    _locations.clear();
    _initialStepCount = 0;
    _currentStepCount = 0;
    _lastKnownPosition = null;
  }
}
