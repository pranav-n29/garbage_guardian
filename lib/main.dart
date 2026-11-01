
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/api_service.dart';
import 'services/bin_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiService.instance.initialize();

  // Start the app immediately; load saved bin locations in the background.
  runApp(const GarbageGuardianApp());

  BinStore.instance.loadSavedLocations();
}
