import 'dart:async';
import 'package:flutter/material.dart';
import '../model/session.dart';
import '../services/location_service.dart';
import '../services/database_service.dart';

class SessionViewModel extends ChangeNotifier {
  Session? _activeSession;
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;

  final _locationService = LocationService();
  final _dbService = DatabaseService();

  Duration get elapsed => _elapsed;
  double get distance => _locationService.totalDistance;
  List<LocationPoint> get locations => _locationService.currentLocations;
  bool get isRunning => _isRunning;

  void startNewSession() {
    _startTime = DateTime.now();
    _elapsed = Duration.zero;
    _locationService.reset();
    _locationService.startTracking(notifyListeners);
    _startTimer();
    _isRunning = true;
    notifyListeners();
  }

  void continueSession(Session session) {
    _activeSession = session;
    _startTime = DateTime.now().subtract(session.elapsedTime);
    _elapsed = session.elapsedTime;
    _locationService.reset();
    _locationService.startTracking(notifyListeners);
    _startTimer();
    _isRunning = true;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    });
  }

  Future<void> endSession() async {
    _timer?.cancel();
    _locationService.stopTracking();
    _isRunning = false;

    final session = Session(
      id: _activeSession?.id,
      startTime: _startTime!,
      endTime: DateTime.now(),
      distance: distance,
      elapsedTime: _elapsed,
      locations: locations,
    );

    if (_activeSession == null) {
      final sessionId = await _dbService.insertSession(session);
      await _dbService.insertLocationPoints(sessionId, locations);
    } else {
      await _dbService.updateSession(session);
      await _dbService.insertLocationPoints(_activeSession!.id!, locations);
    }

    _activeSession = null;
    notifyListeners();
  }

  Future<List<Session>> getAllSessions() async {
    return await _dbService.getAllSessions();
  }
}
