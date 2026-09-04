import 'package:flutter/foundation.dart';
import '../models/bin.dart';

class BinStore extends ChangeNotifier {
  BinStore._();

  static final BinStore instance = BinStore._();

  final Map<String, Bin> _bins = {};

  List<Bin> get bins => _bins.values.toList();

  void updateFromSocket(dynamic data) {
    if (data is! Map) return;

    try {
      final bin = Bin.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (bin.id.isEmpty) return;

      _bins[bin.id] = bin;

      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing SmartBin data: $e');
    }
  }

  void clear() {
    _bins.clear();
    notifyListeners();
  }
}