import 'package:flutter/material.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/services/auth_service.dart';

/// Textile Orchestrator Dashboard
///
/// The Textile role is the central coordinator who:
/// - Receives orders from Buyers
/// - Assigns sub-orders to FabricSellers, PrintingUnits, StitchingUnits
/// - Monitors the entire production pipeline
/// - Ensures timely delivery
class TextileDashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const TextileDashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<TextileDashboardScreen> createState() => _TextileDashboardScreenState();
}

class _TextileDashboardScreenState extends State<TextileDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPendingOrdersTab(),
                  _buildActiveProductionTab(),
                  _buildVendorNetworkTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: UserRole.textile.themeColor,
        onPressed: () {
          _showQuickActions(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final authService = AuthService();
    final user = authService.currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UserRole.textile.themeColor.withOpacity(0.3),
            const Color(0xFF101D22),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: user?.photoURL != null 
                ? NetworkImage(user!.photoURL!) 
                : null,
            backgroundColor: UserRole.textile.themeColor,
            child: user?.photoURL == null 
                ? Icon(UserRole.textile.icon, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: UserRole.textile.themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        UserRole.textile.displayName,
                        style: TextStyle(
                          color: UserRole.textile.themeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to messages
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard(
            'Pending Orders',
            '12',
            Icons.hourglass_empty,
            Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'In Production',
            '8',
            Icons.precision_manufacturing,
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Ready to Ship',
            '5',
            Icons.local_shipping,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: UserRole.textile.themeColor,
        labelColor: UserRole.textile.themeColor,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'Pending Orders'),
          Tab(text: 'Production'),
          Tab(text: 'Vendor Network'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildOrderCard(
          orderId: 'ORD-${1001 + index}',
          buyerName: 'Buyer ${index + 1}',
          fabricType: ['Cotton', 'Silk', 'Polyester', 'Wool', 'Linen'][index],
          quantity: (100 + index * 50),
          status: 'Awaiting Acceptance',
          deadline: '${15 + index} days',
        );
      },
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String buyerName,
    required String fabricType,
    required int quantity,
    required String status,
    required String deadline,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.person, buyerName),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.texture, fabricType),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.square_foot, '$quantity m'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_outlined,
                      color: Colors.white.withOpacity(0.5), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: $deadline',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      _showOrderDetails(context, orderId);
                    },
                    child: const Text('View Details'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _showAcceptOrderDialog(context, orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UserRole.textile.themeColor,
                    ),
                    child: const Text('Accept',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveProductionTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildProductionCard(index);
      },
    );
  }

  Widget _buildProductionCard(int index) {
    final stages = [
      {'name': 'Fabric Sourcing', 'status': 'Complete', 'color': Colors.green},
      {'name': 'Printing', 'status': 'In Progress', 'color': Colors.blue},
      {'name': 'Stitching', 'status': 'Pending', 'color': Colors.grey},
      {'name': 'Quality Check', 'status': 'Pending', 'color': Colors.grey},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORD-${2001 + index}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '40% Complete',
                style: TextStyle(
                  color: UserRole.textile.themeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.4,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor:
                AlwaysStoppedAnimation<Color>(UserRole.textile.themeColor),
          ),
          const SizedBox(height: 16),
          ...stages.map((stage) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: (stage['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        stage['status'] == 'Complete'
                            ? Icons.check
                            : stage['status'] == 'In Progress'
                                ? Icons.autorenew
                                : Icons.hourglass_empty,
                        color: stage['color'] as Color,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stage['name'] as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (stage['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stage['status'] as String,
                        style: TextStyle(
                          color: stage['color'] as Color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildVendorNetworkTab() {
    final vendors = [
      {'role': UserRole.fabricSeller, 'count': 12, 'active': 8},
      {'role': UserRole.printingUnit, 'count': 6, 'active': 4},
      {'role': UserRole.stitchingUnit, 'count': 8, 'active': 5},
      {'role': UserRole.logistics, 'count': 4, 'active': 3},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...vendors.map((vendor) {
          final role = vendor['role'] as UserRole;
          final count = vendor['count'] as int;
          final active = vendor['active'] as int;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D33),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: role.themeColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: role.themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(role.icon, color: role.themeColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$active active of $count total',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: role.themeColor),
                  onPressed: () {
                    // Add new vendor
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D33),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Chart Coming Soon',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Key Metrics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard('Orders Completed', '156', '+12%', true),
              const SizedBox(width: 12),
              _buildMetricCard('Avg. Delivery Time', '18 days', '-8%', true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricCard('Revenue', '₹12.4L', '+24%', true),
              const SizedBox(width: 12),
              _buildMetricCard('Customer Rating', '4.8', '+0.2', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, String change, bool positive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2D33),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  positive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: positive ? Colors.green : Colors.red,
                  size: 14,
                ),
                Text(
                  change,
                  style: TextStyle(
                    color: positive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: UserRole.textile.themeColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Vendors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2D33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickAction(Icons.add_shopping_cart, 'Create Order', () {}),
              _buildQuickAction(Icons.person_add, 'Add Vendor', () {}),
              _buildQuickAction(Icons.assignment, 'Assign Sub-Order', () {}),
              _buildQuickAction(Icons.chat, 'Message Buyer', () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: UserRole.textile.themeColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: UserRole.textile.themeColor),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showOrderDetails(BuildContext context, String orderId) {
    // Navigate to order details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing $orderId details')),
    );
  }

  void _showAcceptOrderDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2D33),
          title: const Text(
            'Accept Order',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Accept $orderId and start orchestrating production?',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Proposed Cost (₹)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: UserRole.textile.themeColor),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Estimated Days',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: UserRole.textile.themeColor),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '$orderId accepted! You are now the orchestrator.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: UserRole.textile.themeColor,
              ),
              child: const Text('Accept Order',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
