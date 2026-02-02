import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ai_design/screens/ai_design_screen.dart';
import '../../features/orders/screens/order_tracking_screen.dart';
import '../../features/orders/screens/create_order_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/inventory/screens/my_inventory_screen.dart';
import '../../features/vendor/screens/vendor_bidding_screen.dart';
import '../../features/textile/screens/textile_dashboard_screen.dart';
import '../../features/vendor/screens/vendor_dashboard_screen.dart';
import '../../features/buyer/screens/buyer_dashboard_screen.dart';
import '../../features/payments/screens/payment_screen.dart';
import '../../features/logistics/screens/logistics_dashboard_screen.dart';
import '../constants/user_roles.dart';

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

      case buyerDashboard:
        return MaterialPageRoute(builder: (_) => const BuyerDashboardScreen());

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
        final roleString = args?['role'] as String? ?? 'Buyer';
        final userName = args?['userName'] as String? ?? 'User';
        final userEmail = args?['userEmail'] as String? ?? '';
        final role = UserRole.fromString(roleString);

        return MaterialPageRoute(
          builder: (_) => _buildDashboardForRole(role, userName, userEmail),
        );

      case textileDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TextileDashboardScreen(
            userName: args?['userName'] ?? 'Textile User',
            userEmail: args?['userEmail'] ?? '',
          ),
        );

      case vendorDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        final roleString = args?['role'] as String? ?? 'FabricSeller';
        return MaterialPageRoute(
          builder: (_) => VendorDashboardScreen(
            userRole: UserRole.fromString(roleString),
            userName: args?['userName'] ?? 'Vendor User',
            userEmail: args?['userEmail'] ?? '',
          ),
        );

      case logisticsDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LogisticsDashboardScreen(
            userName: args?['userName'] ?? 'Logistics User',
            userEmail: args?['userEmail'] ?? '',
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

      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            orderId: args?['orderId'],
            recipientId: args?['recipientId'],
            recipientName: args?['recipientName'] ?? 'Chat',
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
        return const BuyerDashboardScreen();
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
        return const AdminDashboardPlaceholder();
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

// Chat Screen
class ChatScreen extends StatefulWidget {
  final int? orderId;
  final int? recipientId;
  final String recipientName;

  const ChatScreen({
    super.key,
    this.orderId,
    this.recipientId,
    required this.recipientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi, I have a question about the order',
      'isMe': true,
      'time': '10:30 AM'
    },
    {'text': 'Sure, how can I help you?', 'isMe': false, 'time': '10:31 AM'},
    {
      'text': 'What is the expected delivery date?',
      'isMe': true,
      'time': '10:32 AM'
    },
    {
      'text': 'The order will be delivered by Feb 15th',
      'isMe': false,
      'time': '10:33 AM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2D33),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF12AEE2),
              child: Text(
                widget.recipientName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.recipientName,
                    style: const TextStyle(fontSize: 16)),
                if (widget.orderId != null)
                  Text(
                    'Order #${widget.orderId}',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(
                  message['text'] as String,
                  message['isMe'] as bool,
                  message['time'] as String,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D33),
              border:
                  Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white54),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF12AEE2)),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      setState(() {
                        _messages.add({
                          'text': _messageController.text,
                          'isMe': true,
                          'time': 'Now',
                        });
                        _messageController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF12AEE2) : const Color(0xFF1E2D33),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              time,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
