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
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      id: json['deviceId']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Location unavailable',
      fillLevel: (json['fillPercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Unknown',

      // Backend has NOT provided coordinates yet.
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,

      lastUpdated:
          DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ??
              DateTime.now(),

      uptime: (json['uptime'] as num?)?.toInt() ?? 0,
      online: json['online'] == true,
    );
  }
}