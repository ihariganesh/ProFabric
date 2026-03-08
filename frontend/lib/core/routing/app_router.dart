import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ai_design/screens/ai_design_screen.dart';
import '../../features/orders/screens/order_tracking_screen.dart';
import '../../features/orders/screens/create_order_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/marketplace/screens/sell_fabric_screen.dart';
import '../../features/inventory/screens/my_inventory_screen.dart';
import '../../features/vendor/screens/vendor_bidding_screen.dart';
import '../../features/textile/screens/textile_dashboard_screen.dart';
import '../../features/vendor/screens/vendor_dashboard_screen.dart';
import '../../features/buyer/screens/buyer_home_screen.dart';
import '../../features/buyer/screens/order_detail_screen.dart';
import '../../features/buyer/screens/ai_vendor_match_screen.dart';
import '../../features/buyer/screens/fabric_request_screen.dart';
import '../../features/buyer/screens/buyer_order_tracking_screen.dart';
import '../../features/payments/screens/payment_screen.dart';
import '../../features/logistics/screens/logistics_dashboard_screen.dart';
import '../../features/buyer/screens/vendor_selection_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/settings/screens/settings_screens.dart';
import '../constants/user_roles.dart';
import '../services/auth_service.dart';

class AppRouter {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String textileDashboard = '/textile-dashboard';
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
  static const String sampleApproval = '/sample-approval';
  static const String chat = '/chat';
  static const String createOrder = '/create-order';
  static const String buyerDashboard = '/buyer-dashboard';
  static const String payment = '/payment';
  static const String logisticsDashboard = '/logistics-dashboard';
  static const String vendorSelection = '/vendor-selection';
  static const String profileSettings = '/profile-settings';
  static const String appSettings = '/app-settings';
  static const String helpSupport = '/help-support';
  static const String about = '/about';
  static const String sellFabric = '/sell-fabric';
  static const String orderDetail = '/order-detail';
  static const String aiVendorMatch = '/ai-vendor-match';
  static const String chatList = '/chat-list';
  static const String fabricRequest = '/fabric-request';
  static const String buyerOrderTracking = '/buyer-order-tracking';

  // Generate Routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case createOrder:
        return MaterialPageRoute(builder: (_) => const CreateOrderScreen());

      case vendorSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => VendorSelectionScreen(
            designId: args?['designId'],
          ),
        );

      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            orderId: args?['orderId'] ?? 'FB-8921',
            recipientName: args?['recipientName'] ?? 'Vendor Hub',
            recipientRole: args?['recipientRole'] ?? 'Hub Orchestrator',
            recipientId: args?['recipientId'],
          ),
        );

      case chatList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatListScreen(
            userRole: args?['role'] ?? 'buyer',
          ),
        );

      case buyerDashboard:
        return MaterialPageRoute(builder: (_) => const BuyerHomeScreen());

      case orderDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            orderId: args?['orderId'] ?? 'FB-0000',
          ),
        );

      case aiVendorMatch:
        return MaterialPageRoute(builder: (_) => const AIVendorMatchScreen());

      case payment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            orderId: args?['orderId'] ?? 'FB-0000',
            totalAmount: (args?['totalAmount'] as num?)?.toDouble() ?? 125000.0,
          ),
        );

      case dashboard:
        // Role-based dashboard routing
        final args = settings.arguments as Map<String, dynamic>?;
        final authService = AuthService();
        final user = authService.currentUser;

        final roleString = args?['role'] as String? ?? 'Buyer';
        final userName =
            args?['userName'] as String? ?? user?.displayName ?? 'User';
        final userEmail = args?['userEmail'] as String? ?? user?.email ?? '';
        final role = UserRole.fromString(roleString);

        return MaterialPageRoute(
          builder: (_) => _buildDashboardForRole(role, userName, userEmail),
        );

      case textileDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        final authService = AuthService();
        final user = authService.currentUser;
        return MaterialPageRoute(
          builder: (_) => TextileDashboardScreen(
            userName: args?['userName'] ?? user?.displayName ?? 'Textile User',
            userEmail: args?['userEmail'] ?? user?.email ?? '',
          ),
        );

      case vendorDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        final authService = AuthService();
        final user = authService.currentUser;
        final roleString = args?['role'] as String? ?? 'FabricSeller';
        return MaterialPageRoute(
          builder: (_) => VendorDashboardScreen(
            userRole: UserRole.fromString(roleString),
            userName: args?['userName'] ?? user?.displayName ?? 'Vendor User',
            userEmail: args?['userEmail'] ?? user?.email ?? '',
          ),
        );

      case logisticsDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        final authService = AuthService();
        final user = authService.currentUser;
        return MaterialPageRoute(
          builder: (_) => LogisticsDashboardScreen(
            userName:
                args?['userName'] ?? user?.displayName ?? 'Logistics User',
            userEmail: args?['userEmail'] ?? user?.email ?? '',
          ),
        );

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

      case sampleApproval:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SampleApprovalScreen(
            orderId: args?['orderId'] ?? 0,
          ),
        );

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

      case profileSettings:
        return MaterialPageRoute(builder: (_) => const ProfileSettingsScreen());

      case appSettings:
        return MaterialPageRoute(builder: (_) => const AppSettingsScreen());

      case helpSupport:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());

      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case sellFabric:
        return MaterialPageRoute(builder: (_) => const SellFabricScreen());

      case fabricRequest:
        return MaterialPageRoute(builder: (_) => const FabricRequestScreen());

      case buyerOrderTracking:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BuyerOrderTrackingScreen(
            orderId: args?['orderId'] ?? 'FB-0000',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  static Widget _buildDashboardForRole(
      UserRole role, String userName, String userEmail) {
    switch (role) {
      case UserRole.buyer:
        return const BuyerHomeScreen();
      case UserRole.textile:
        return TextileDashboardScreen(userName: userName, userEmail: userEmail);
      case UserRole.logistics:
        return LogisticsDashboardScreen(
          userName: userName,
          userEmail: userEmail,
        );
      case UserRole.fabricSeller:
      case UserRole.weaver:
      case UserRole.yarnManufacturer:
      case UserRole.printingUnit:
      case UserRole.stitchingUnit:
        return VendorDashboardScreen(
          userRole: role,
          userName: userName,
          userEmail: userEmail,
        );
      case UserRole.admin:
        return const AdminDashboardScreen();
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
    _checkAuthAndRoute();
  }

  Future<void> _checkAuthAndRoute() async {
    // Brief splash delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) {
      // Not signed in — go to login
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
      return;
    }

    // Signed in — get stored role and route to the correct dashboard
    final storedRole = await authService.getUserRole(user.uid);
    if (!mounted) return;

    final role = (storedRole != null && storedRole != 'supply_partner')
        ? storedRole
        : 'buyer';
    final userName = (user.displayName?.isNotEmpty == true)
        ? user.displayName!
        : (user.email?.split('@').first ?? 'User');
    final userEmail = user.email ?? '';

    if (role == 'buyer') {
      Navigator.of(context).pushReplacementNamed(AppRouter.buyerDashboard);
    } else {
      Navigator.of(context).pushReplacementNamed(
        AppRouter.dashboard,
        arguments: {
          'role': role,
          'userName': userName,
          'userEmail': userEmail,
        },
      );
    }
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

// Admin Dashboard Placeholder
class AdminDashboardPlaceholder extends StatelessWidget {
  const AdminDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1E2D33),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Admin Dashboard',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Coming Soon', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

// Sample Approval Screen
class SampleApprovalScreen extends StatefulWidget {
  final int orderId;
  const SampleApprovalScreen({super.key, required this.orderId});

  @override
  State<SampleApprovalScreen> createState() => _SampleApprovalScreenState();
}

class _SampleApprovalScreenState extends State<SampleApprovalScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isApproving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        title: Text('Sample Approval - Order #${widget.orderId}'),
        backgroundColor: const Color(0xFF1E2D33),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample Images Section
            const Text(
              'Sample Images',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2D33),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image,
                            color: Colors.white54, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Sample ${index + 1}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Sample Details
            const Text(
              'Sample Details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2D33),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Fabric Type', 'Premium Cotton'),
                  _buildDetailRow('Quantity', '5 meters (sample)'),
                  _buildDetailRow('GSM', '180'),
                  _buildDetailRow('Thread Count', '300'),
                  _buildDetailRow('Print Type', 'Digital Print'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notes Section
            const Text(
              'Your Feedback',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add notes about the sample...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF1E2D33),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _isApproving ? null : () => _rejectSample(context),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Reject',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isApproving ? null : () => _approveSample(context),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: _isApproving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Approve',
                            style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6))),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _approveSample(BuildContext context) {
    setState(() => _isApproving = true);
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isApproving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample approved! Production will begin shortly.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _rejectSample(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D33),
        title:
            const Text('Reject Sample?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'A new sample will be produced based on your feedback.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Sample rejected. Textile will produce a new sample.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
