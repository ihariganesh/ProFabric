import 'package:flutter/material.dart';
import '../../../core/constants/user_roles.dart';

/// Generic Vendor Dashboard
///
/// Used by all production vendors:
/// - FabricSeller: Fabric inventory & dispatch
/// - PrintingUnit: Printing jobs queue
/// - StitchingUnit: Stitching jobs queue
/// - Logistics: Shipment tracking
/// - Weaver: Weaving orders
/// - YarnManufacturer: Yarn production
class VendorDashboardScreen extends StatefulWidget {
  final UserRole userRole;
  final String userName;
  final String userEmail;

  const VendorDashboardScreen({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            _buildStatsRow(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveJobsTab(),
                  _buildPendingJobsTab(),
                  _buildCompletedJobsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.userRole.themeColor.withOpacity(0.3),
            const Color(0xFF101D22),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.userRole.themeColor,
                width: 2,
              ),
            ),
            child: Icon(
              widget.userRole.icon,
              color: widget.userRole.themeColor,
            ),
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
                        color: widget.userRole.themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.userRole.displayName,
                        style: TextStyle(
                          color: widget.userRole.themeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const Text(
                      '4.8',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _showMenuOptions(context),
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
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard(
            'Active',
            '5',
            Icons.play_circle_outline,
            Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Pending',
            '3',
            Icons.hourglass_empty,
            Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Today\'s Earnings',
            '₹12.5K',
            Icons.currency_rupee,
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
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
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
        indicatorColor: widget.userRole.themeColor,
        labelColor: widget.userRole.themeColor,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Pending'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildActiveJobsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildJobCard(
          subOrderId: 'SO-${3001 + index}',
          parentOrderId: 'ORD-${2001 + index}',
          textileOrchestratorName: 'Textile Partner ${index + 1}',
          taskDescription: _getTaskDescription(index),
          deadline: '${3 + index} days',
          status: 'In Progress',
          progress: 0.3 + (index * 0.15),
        );
      },
    );
  }

  Widget _buildPendingJobsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildPendingJobCard(
          subOrderId: 'SO-${4001 + index}',
          parentOrderId: 'ORD-${3001 + index}',
          textileOrchestratorName: 'Textile Partner ${index + 4}',
          taskDescription: _getTaskDescription(index),
          offeredPrice: 25000 + (index * 5000),
          deadline: '${10 + index * 2} days',
        );
      },
    );
  }

  Widget _buildCompletedJobsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildCompletedJobCard(
          subOrderId: 'SO-${1001 + index}',
          parentOrderId: 'ORD-${1001 + index}',
          taskDescription: _getTaskDescription(index % 5),
          completedDate: '${index + 1} days ago',
          earnings: 18000 + (index * 2500),
          rating: 4.5 + (index % 5) * 0.1,
        );
      },
    );
  }

  String _getTaskDescription(int index) {
    switch (widget.userRole) {
      case UserRole.fabricSeller:
        return [
          'Cotton 40s - 200m',
          'Silk Pure - 100m',
          'Polyester Blend - 500m',
          'Linen Natural - 150m',
          'Wool Fine - 80m'
        ][index % 5];
      case UserRole.printingUnit:
        return [
          'Block Print',
          'Digital Print',
          'Screen Print',
          'Rotary Print',
          'Heat Transfer'
        ][index % 5];
      case UserRole.stitchingUnit:
        return [
          'Shirts - 500 pcs',
          'Pants - 300 pcs',
          'Dresses - 200 pcs',
          'Jackets - 150 pcs',
          'Blouses - 400 pcs'
        ][index % 5];
      case UserRole.logistics:
        return [
          'Mumbai → Delhi',
          'Surat → Bangalore',
          'Ahmedabad → Chennai',
          'Jaipur → Kolkata',
          'Pune → Hyderabad'
        ][index % 5];
      default:
        return 'Task ${index + 1}';
    }
  }

  Widget _buildJobCard({
    required String subOrderId,
    required String parentOrderId,
    required String textileOrchestratorName,
    required String taskDescription,
    required String deadline,
    required String status,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.userRole.themeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subOrderId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    parentOrderId,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(widget.userRole.icon,
                    color: widget.userRole.themeColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    taskDescription,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.business,
                  color: Colors.white.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text(
                textileOrchestratorName,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
              const Spacer(),
              const Icon(Icons.timer_outlined, color: Colors.orange, size: 14),
              const SizedBox(width: 4),
              Text(
                deadline,
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress: ${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.userRole.themeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  _showUpdateProgressDialog(context, subOrderId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.userRole.themeColor,
                ),
                child:
                    const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingJobCard({
    required String subOrderId,
    required String parentOrderId,
    required String textileOrchestratorName,
    required String taskDescription,
    required int offeredPrice,
    required String deadline,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subOrderId,
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
                child: const Text(
                  'New Request',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            taskDescription,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.business, textileOrchestratorName),
              const Spacer(),
              _buildInfoChip(Icons.timer_outlined, deadline),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Offered Price:',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '₹${(offeredPrice / 1000).toStringAsFixed(1)}K',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showNegotiateDialog(context, subOrderId, offeredPrice);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.userRole.themeColor),
                  ),
                  child: Text(
                    'Negotiate',
                    style: TextStyle(color: widget.userRole.themeColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _acceptJob(context, subOrderId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Accept',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedJobCard({
    required String subOrderId,
    required String parentOrderId,
    required String taskDescription,
    required String completedDate,
    required int earnings,
    required double rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.check, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subOrderId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  taskDescription,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  completedDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(earnings / 1000).toStringAsFixed(1)}K',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.amber, fontSize: 12),
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
        selectedItemColor: widget.userRole.themeColor,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(_getInventoryIcon()),
            label: _getInventoryLabel(),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  IconData _getInventoryIcon() {
    switch (widget.userRole) {
      case UserRole.logistics:
        return Icons.local_shipping;
      case UserRole.fabricSeller:
        return Icons.inventory_2;
      default:
        return Icons.settings;
    }
  }

  String _getInventoryLabel() {
    switch (widget.userRole) {
      case UserRole.logistics:
        return 'Routes';
      case UserRole.fabricSeller:
        return 'Inventory';
      default:
        return 'Capacity';
    }
  }

  void _showUpdateProgressDialog(BuildContext context, String subOrderId) {
    showDialog(
      context: context,
      builder: (context) {
        double progress = 0.5;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2D33),
              title: const Text(
                'Update Progress',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subOrderId,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: widget.userRole.themeColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: progress,
                    onChanged: (value) {
                      setState(() {
                        progress = value;
                      });
                    },
                    activeColor: widget.userRole.themeColor,
                  ),
                  const SizedBox(height: 16),
                  if (progress >= 1.0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Mark as Complete',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
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
                        content: Text(progress >= 1.0
                            ? '$subOrderId marked as complete!'
                            : 'Progress updated to ${(progress * 100).toInt()}%'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMenuOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2D33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuOption(
              icon: Icons.person_outline,
              title: 'Profile Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile-settings');
              },
            ),
            _buildMenuOption(
              icon: Icons.settings_outlined,
              title: 'App Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/app-settings');
              },
            ),
            _buildMenuOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help-support');
              },
            ),
            _buildMenuOption(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            const Divider(color: Colors.white12, height: 32),
            _buildMenuOption(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }

  void _showNegotiateDialog(
      BuildContext context, String subOrderId, int currentPrice) {
    final controller = TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2D33),
          title: const Text(
            'Negotiate Price',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current offer: ₹${(currentPrice / 1000).toStringAsFixed(1)}K',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Your Counter Offer (₹)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: widget.userRole.themeColor),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Message (optional)',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: widget.userRole.themeColor),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
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
                  const SnackBar(
                    content: Text('Counter offer sent!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.userRole.themeColor,
              ),
              child: const Text('Send Offer',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _acceptJob(BuildContext context, String subOrderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2D33),
          title: const Text(
            'Accept Job?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Accept $subOrderId and start working on it?',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
                  const SnackBar(
                    content: Text('Job accepted! Check Active tab.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child:
                  const Text('Accept', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
