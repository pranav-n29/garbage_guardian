class Bin {
  final String id;
  final String location;
  final double fillLevel;
  final String status;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;

  const Bin({
    required this.id,
    required this.location,
    required this.fillLevel,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['binId'] ?? '',
      location: json['location'] ?? '',
      fillLevel: (json['fillLevel'] ?? 0).toDouble(),
      status: json['status'] ?? 'Unknown',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      lastUpdated: DateTime.tryParse(
            json['lastUpdated'] ?? '',
          ) ??
          DateTime.now(),
    );
  }
}