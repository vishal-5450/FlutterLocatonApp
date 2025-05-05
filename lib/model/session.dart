class Session {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance; // in meters
  final Duration elapsedTime;
  final List<LocationPoint> locations;

  Session({
    this.id,
    required this.startTime,
    this.endTime,
    required this.distance,
    required this.elapsedTime,
    required this.locations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'distance': distance,
      'elapsedTime': elapsedTime.inSeconds,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map, List<LocationPoint> locations) {
    return Session(
      id: map['id'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      distance: map['distance'],
      elapsedTime: Duration(seconds: map['elapsedTime']),
      locations: locations,
    );
  }
}

class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap(int sessionId) {
    return {
      'sessionId': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
