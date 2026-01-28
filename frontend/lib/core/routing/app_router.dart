import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ai_design/screens/ai_design_screen.dart';
import '../../features/orders/screens/order_tracking_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/inventory/screens/my_inventory_screen.dart';
import '../../features/vendor/screens/vendor_bidding_screen.dart';

class AppRouter {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String aiDesign = '/ai-design';
  static const String orderDetails = '/order-details';
  static const String orderTracking = '/order-tracking';
  static const String notifications = '/notifications';
  static const String vendorDashboard = '/vendor-dashboard';
  static const String checkout = '/checkout';
  static const String marketplace = '/marketplace';
  static const String myInventory = '/my-inventory';
  static const String listFabric = '/list-fabric';
  static const String fabricDetails = '/fabric-details';
  static const String vendorBidding = '/vendor-bidding';

  // Generate Routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case aiDesign:
        return MaterialPageRoute(builder: (_) => const AIDesignScreen());

      case orderTracking:
        return MaterialPageRoute(builder: (_) => const OrderTrackingScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketplaceScreen());

      case myInventory:
        return MaterialPageRoute(builder: (_) => const MyInventoryScreen());

      case vendorBidding:
        return MaterialPageRoute(builder: (_) => const VendorBiddingScreen());

      case listFabric:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('List Fabric Screen - Coming Soon')),
          ),
        );

      case fabricDetails:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Fabric Details Screen - Coming Soon')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}

// Placeholder screens
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF12AEE2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.polyline_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FabricFlow',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
