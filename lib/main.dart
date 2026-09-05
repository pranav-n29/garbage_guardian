import 'package:flutter/material.dart';
import 'app/app.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiService.instance.initialize();

  runApp(const GarbageGuardianApp());
}