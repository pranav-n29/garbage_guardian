import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/bins/bin_details_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/reports/report_issues_screen.dart';
import '../screens/reports/my_reports_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/awareness/awareness_screen.dart';
import '../screens/profile/profile_screen.dart';



class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String binDetails = '/bin-details';
  static const String map = '/map';
  static const String reportIssue = '/report-issue';
  static const String myReports = '/my-reports';
  static const String notifications = '/notifications';
  static const String awareness = '/awareness';
  static const String profile = '/profile';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case binDetails:
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => const BinDetailsScreen(),
  );

      case map:
        return MaterialPageRoute(
          builder: (_) => const MapScreen(),
        );

      case reportIssue:
        return MaterialPageRoute(
          builder: (_) => const ReportIssuesScreen(),
        );

      case myReports:
        return MaterialPageRoute(
          builder: (_) => const MyReportsScreen(),
        );

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      case awareness:
        return MaterialPageRoute(
          builder: (_) => const AwarenessScreen(),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

    default:
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(
        title: const Text('Route Error'),
      ),
      body: Center(
        child: Text(
          'Unknown route: ${settings.name}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
    }
  }
}
