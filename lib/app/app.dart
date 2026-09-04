import 'package:flutter/material.dart';
import '../services/bin_store.dart';
import '../core/theme/app_theme.dart';
import '../services/socket_service.dart';
import 'routes.dart';

class GarbageGuardianApp extends StatefulWidget {
  const GarbageGuardianApp({super.key});

  @override
  State<GarbageGuardianApp> createState() =>
      _GarbageGuardianAppState();
}

class _GarbageGuardianAppState
    extends State<GarbageGuardianApp> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();

    _socketService.connect(
     onSmartBinData: (data) {
  BinStore.instance.updateFromSocket(data);
},
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

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