import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends ChangeNotifier {
  Position? _position;
  Position? _startPosition;
  double _distance = 0.0;
  String? _time;
  bool _permissionGranted = true;
  late Stopwatch _stopwatch;

  Position? get position => _position;
  String? get time => _time;
  double get distance => _distance;
  bool get permissionGranted => _permissionGranted;
  String get elapsedTimeFormatted {
    final duration = _stopwatch.elapsed;
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  LocationViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    _stopwatch = Stopwatch()..start();
    await _checkPermissions();
    if (_permissionGranted) {
      _getLocation();
      Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    }
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    _permissionGranted =
        permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    notifyListeners();
  }

  void requestPermission() async {
    await _checkPermissions();
    if (_permissionGranted) {
      _getLocation();
    }
  }

  void _getLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position pos) {
      if (_startPosition == null) {
        _startPosition = pos;
      } else {
        _distance += Geolocator.distanceBetween(
          _position?.latitude ?? pos.latitude,
          _position?.longitude ?? pos.longitude,
          pos.latitude,
          pos.longitude,
        );
      }
      _position = pos;
      notifyListeners();
    });
  }

  void _updateTime() {
    _time = DateTime.now().toLocal().toString();
    notifyListeners();
  }
}