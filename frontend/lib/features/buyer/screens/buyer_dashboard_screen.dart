import 'package:flutter/material.dart';
import '../../../core/routing/app_router.dart';

/// Dashboard screen for Buyers
/// Allows buyers to view their orders, create new orders, and track shipments
class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
            _buildAppBar(),
            _buildQuickStats(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveOrdersTab(),
                  _buildBiddingTab(),
                  _buildDeliveredTab(),
                  _buildSavedDesignsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRouter.createOrder),
        backgroundColor: const Color(0xFF00C853),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF00C853),
            child: Text('B',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  'Buyer Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.marketplace),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.pending_actions,
            label: 'Pending',
            value: '5',
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.gavel,
            label: 'Bidding',
            value: '3',
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.local_shipping,
            label: 'In Transit',
            value: '2',
            color: Colors.purple,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.check_circle,
            label: 'Completed',
            value: '18',
            color: const Color(0xFF00C853),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF00C853),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Bidding'),
          Tab(text: 'Delivered'),
          Tab(text: 'Designs'),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    final activeOrders = [
      _MockOrder(
        id: 'FB-8921',
        fabric: 'Cotton Floral Print',
        status: 'In Production',
        statusColor: Colors.blue,
        progress: 0.65,
        quantity: '500 meters',
        eta: '15 Jan 2026',
      ),
      _MockOrder(
        id: 'FB-8918',
        fabric: 'Silk Paisley',
        status: 'Quality Check',
        statusColor: Colors.orange,
        progress: 0.85,
        quantity: '200 meters',
        eta: '10 Jan 2026',
      ),
      _MockOrder(
        id: 'FB-8912',
        fabric: 'Denim Solid',
        status: 'Printing',
        statusColor: Colors.purple,
        progress: 0.45,
        quantity: '1000 meters',
        eta: '25 Jan 2026',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return _buildActiveOrderCard(order);
      },
    );
  }

  Widget _buildActiveOrderCard(_MockOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://picsum.photos/seed/fabric/100/100'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            color: Color(0xFF00C853),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: order.statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: order.statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.fabric,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.quantity} • ETA: ${order.eta}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
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
                      'Progress: ${(order.progress * 100).toInt()}%',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: order.progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(order.statusColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRouter.orderTracking,
                  arguments: {'orderId': order.id},
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00C853),
                  side: const BorderSide(color: Color(0xFF00C853)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Track'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingTab() {
    final biddingOrders = [
      _BiddingOrder(
        id: 'FB-8930',
        fabric: 'Linen Geometric',
        quantity: '800 meters',
        bidCount: 5,
        lowestBid: 28000,
        timeLeft: '2h 30m',
      ),
      _BiddingOrder(
        id: 'FB-8928',
        fabric: 'Cotton Abstract',
        quantity: '300 meters',
        bidCount: 3,
        lowestBid: 12500,
        timeLeft: '5h 15m',
      ),
    ];

    if (biddingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.gavel,
        title: 'No Active Bids',
        subtitle: 'Create a new order to receive bids from vendors',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: biddingOrders.length,
      itemBuilder: (context, index) {
        final order = biddingOrders[index];
        return _buildBiddingCard(order);
      },
    );
  }

  Widget _buildBiddingCard(_BiddingOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      order.timeLeft,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.fabric,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            order.quantity,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBidStat(Icons.people, '${order.bidCount} Bids'),
              const SizedBox(width: 16),
              _buildBidStat(Icons.attach_money, '₹${order.lowestBid}',
                  isHighlight: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.vendorBidding),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                  child: const Text('View Bids'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                  ),
                  child: const Text('Accept Best'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidStat(IconData icon, String text, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlight ? const Color(0xFF00C853) : Colors.white54,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF00C853) : Colors.white54,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveredTab() {
    final deliveredOrders = [
      _MockOrder(
        id: 'FB-8900',
        fabric: 'Velvet Embroidered',
        status: 'Delivered',
        statusColor: const Color(0xFF00C853),
        progress: 1.0,
        quantity: '150 meters',
        eta: '28 Dec 2025',
      ),
      _MockOrder(
        id: 'FB-8885',
        fabric: 'Rayon Printed',
        status: 'Delivered',
        statusColor: const Color(0xFF00C853),
        progress: 1.0,
        quantity: '600 meters',
        eta: '20 Dec 2025',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: deliveredOrders.length,
      itemBuilder: (context, index) {
        final order = deliveredOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://picsum.photos/seed/fabric2/100/100'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.id}',
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      order.fabric,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Delivered on ${order.eta}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.star_border, color: Colors.amber),
                    onPressed: () => _showRatingDialog(),
                  ),
                  const Text(
                    'Rate',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedDesignsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://picsum.photos/seed/design$index/200/200'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.amber, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Design ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${index + 1} days ago',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rate Your Experience',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {},
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Share your feedback...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// Mock data classes
class _MockOrder {
  final String id;
  final String fabric;
  final String status;
  final Color statusColor;
  final double progress;
  final String quantity;
  final String eta;

  _MockOrder({
    required this.id,
    required this.fabric,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.quantity,
    required this.eta,
  });
}

class _BiddingOrder {
  final String id;
  final String fabric;
  final String quantity;
  final int bidCount;
  final int lowestBid;
  final String timeLeft;

  _BiddingOrder({
    required this.id,
    required this.fabric,
    required this.quantity,
    required this.bidCount,
    required this.lowestBid,
    required this.timeLeft,
  });
}
