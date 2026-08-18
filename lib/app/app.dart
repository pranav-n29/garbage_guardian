import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'routes.dart';

class GarbageGuardianApp extends StatelessWidget {
  const GarbageGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Garbage Guardian',

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.splash,

      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}