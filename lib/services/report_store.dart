import 'package:flutter/foundation.dart';

class CitizenReport {
  final String id;
  final String binId;
  final String location;
  final String issueType;
  final String description;
  final String status;
  final DateTime createdAt;

  CitizenReport({
    required this.id,
    required this.binId,
    required this.location,
    required this.issueType,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

class ReportStore extends ChangeNotifier {
  ReportStore._();

  static final ReportStore instance = ReportStore._();

  final List<CitizenReport> _reports = [];

  List<CitizenReport> get reports =>
      List.unmodifiable(_reports);

  void addReport({
    required String binId,
    required String location,
    required String issueType,
    required String description,
  }) {
    final reportNumber =
        (_reports.length + 1).toString().padLeft(3, '0');

    final report = CitizenReport(
      id: 'RPT-$reportNumber',
      binId: binId,
      location: location,
      issueType: issueType,
      description: description,
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    _reports.insert(0, report);

    notifyListeners();
  }

  void clear() {
    _reports.clear();
    notifyListeners();
  }
}