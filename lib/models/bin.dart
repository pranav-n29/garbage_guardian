
class Bin {
  final String id;
  final String location;
  final double fillLevel;
  final String status;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final int uptime;
  final bool online;
  final double distance;

  const Bin({
    required this.id,
    required this.location,
    required this.fillLevel,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.uptime,
    required this.online,
    required this.distance,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['deviceId']?.toString() ??
          json['id']?.toString() ??
          '',
      location: json['location']?.toString() ??
          'Location unavailable',

      fillLevel: _toDouble(
        json['fillPercentage'] ?? json['fillLevel'],
      ),

      status: json['status']?.toString() ?? 'UNKNOWN',

      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),

      lastUpdated: DateTime.tryParse(
            json['lastUpdated']?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),

      uptime: _toInt(json['uptime']),
      online: json['online'] == true,
      distance: _toDouble(json['distance']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // LOCATION

  bool get hasLocation {
    return latitude != 0 &&
        longitude != 0 &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  // SENSOR DATA

  bool get hasSensorData {
    return lastUpdated.millisecondsSinceEpoch > 0 ||
        status.toUpperCase() != 'UNKNOWN' ||
        fillLevel > 0 ||
        uptime > 0 ||
        online;
  }

  bool get isFull => fillLevel >= 80;

  bool get isNearlyFull => fillLevel >= 60;

  bool get needsCollection {
    return hasSensorData &&
        (isFull || status.toUpperCase() == 'FULL');
  }

  String get displayFillLevel {
    if (!hasSensorData) return '--';
    return '${fillLevel.round()}%';
  }

  String get displayStatus {
    if (!hasSensorData) return 'Awaiting Sensor Data';

    if (needsCollection) return 'Needs Collection';

    if (isNearlyFull) return 'Nearly Full';

    return 'Normal';
  }

  String get displayLastUpdated {
    if (!hasSensorData) return 'No sensor data received';

    return 'Updated ${lastUpdated.toLocal()}';
  }
}
