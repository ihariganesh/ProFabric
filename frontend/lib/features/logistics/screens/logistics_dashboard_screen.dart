import 'package:flutter/material.dart';

/// Logistics Dashboard for shipment management
/// 
/// Features:
/// - Active shipments map view
/// - Shipment list with status
/// - Route optimization
/// - Delivery scheduling
class LogisticsDashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const LogisticsDashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<LogisticsDashboardScreen> createState() =>
      _LogisticsDashboardScreenState();
}

class _LogisticsDashboardScreenState extends State<LogisticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavIndex = 0;

  final List<_Shipment> _shipments = [
    _Shipment(
      id: 'SHP-9821',
      orderId: 'FB-8921',
      origin: 'Mill X, Surat',
      destination: 'Chennai Warehouse',
      status: ShipmentStatus.inTransit,
      progress: 0.65,
      eta: 'Oct 28, 2:30 PM',
      distance: '1,240 km',
      items: 'Egyptian Cotton - 500m',
      vehicleNumber: 'TN-45-AB-1234',
      driverName: 'Rajesh Kumar',
      driverPhone: '+91 98765 43210',
    ),
    _Shipment(
      id: 'SHP-9820',
      orderId: 'FB-8920',
      origin: 'Print Unit, Ahmedabad',
      destination: 'Mumbai Port',
      status: ShipmentStatus.loading,
      progress: 0.15,
      eta: 'Oct 29, 10:00 AM',
      distance: '524 km',
      items: 'Printed Silk - 200m',
      vehicleNumber: 'GJ-01-XY-5678',
      driverName: 'Amit Patel',
      driverPhone: '+91 87654 32109',
    ),
    _Shipment(
      id: 'SHP-9819',
      orderId: 'FB-8918',
      origin: 'Stitch Unit, Tirupur',
      destination: 'Bangalore Hub',
      status: ShipmentStatus.delivered,
      progress: 1.0,
      eta: 'Delivered Oct 25',
      distance: '380 km',
      items: 'Finished Garments - 50 pcs',
      vehicleNumber: 'TN-33-CD-9012',
      driverName: 'Venu Gopal',
      driverPhone: '+91 76543 21098',
    ),
    _Shipment(
      id: 'SHP-9818',
      orderId: 'FB-8917',
      origin: 'Yarn Factory, Coimbatore',
      destination: 'Weaving Unit, Salem',
      status: ShipmentStatus.pending,
      progress: 0.0,
      eta: 'Scheduled Oct 30',
      distance: '160 km',
      items: 'Cotton Yarn - 100kg',
      vehicleNumber: 'Pending Assignment',
      driverName: 'Not Assigned',
      driverPhone: '',
    ),
  ];

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
            _buildStatsRow(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllShipmentsTab(),
                  _buildInTransitTab(),
                  _buildPendingTab(),
                  _buildDeliveredTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOptimizeRoutesDialog(),
        backgroundColor: const Color(0xFF12AEE2),
        icon: const Icon(Icons.route, color: Colors.white),
        label: const Text(
          'Optimize Routes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.3),
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
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: const Icon(Icons.local_shipping, color: Colors.orange),
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
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'LOGISTICS',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const Text(
                      '4.9',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
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
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
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
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            onPressed: () => _showMapView(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final inTransit =
        _shipments.where((s) => s.status == ShipmentStatus.inTransit).length;
    final pending =
        _shipments.where((s) => s.status == ShipmentStatus.pending).length;
    final delivered =
        _shipments.where((s) => s.status == ShipmentStatus.delivered).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatCard(
            'In Transit',
            inTransit.toString(),
            Icons.local_shipping,
            const Color(0xFF12AEE2),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Pending',
            pending.toString(),
            Icons.schedule,
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Delivered',
            delivered.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Total',
            _shipments.length.toString(),
            Icons.inventory_2,
            Colors.purple,
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
                color: color.withOpacity(0.8),
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
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF12AEE2),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF12AEE2),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'In Transit'),
          Tab(text: 'Pending'),
          Tab(text: 'Delivered'),
        ],
      ),
    );
  }

  Widget _buildAllShipmentsTab() {
    return _buildShipmentList(_shipments);
  }

  Widget _buildInTransitTab() {
    final filtered = _shipments
        .where((s) =>
            s.status == ShipmentStatus.inTransit ||
            s.status == ShipmentStatus.loading)
        .toList();
    return _buildShipmentList(filtered);
  }

  Widget _buildPendingTab() {
    final filtered =
        _shipments.where((s) => s.status == ShipmentStatus.pending).toList();
    return _buildShipmentList(filtered);
  }

  Widget _buildDeliveredTab() {
    final filtered =
        _shipments.where((s) => s.status == ShipmentStatus.delivered).toList();
    return _buildShipmentList(filtered);
  }

  Widget _buildShipmentList(List<_Shipment> shipments) {
    if (shipments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No shipments found',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shipments.length,
      itemBuilder: (context, index) {
        return _buildShipmentCard(shipments[index]);
      },
    );
  }

  Widget _buildShipmentCard(_Shipment shipment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF192D33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: shipment.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  shipment.id,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: shipment.statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shipment.statusText,
                    style: TextStyle(
                      color: shipment.statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 30,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipment.origin,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            shipment.destination,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          shipment.distance,
                          style: const TextStyle(
                            color: Color(0xFF12AEE2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          shipment.eta,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress
                if (shipment.status != ShipmentStatus.pending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${(shipment.progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: shipment.progress,
                                backgroundColor: Colors.grey.withOpacity(0.3),
                                color: shipment.statusColor,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                // Items
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF12AEE2),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shipment.items,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        shipment.orderId,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone,
                    label: 'Call Driver',
                    onTap: () {},
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.map,
                    label: 'Track',
                    onTap: () =>
                        Navigator.pushNamed(context, '/order-tracking'),
                    color: const Color(0xFF12AEE2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit,
                    label: 'Update',
                    onTap: () => _showUpdateStatusDialog(shipment),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF192D33),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/notifications');
              break;
            case 2:
              Navigator.pushNamed(context, '/chat', arguments: {
                'recipientName': 'Support',
              });
              break;
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF12AEE2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showMapView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101D22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.map, color: Color(0xFF12AEE2)),
                  SizedBox(width: 8),
                  Text(
                    'Live Shipment Map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF192D33),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 80,
                        color: Color(0xFF12AEE2),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Interactive Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Live tracking of all active shipments',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptimizeRoutesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF192D33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF12AEE2)),
            SizedBox(width: 8),
            Text(
              'AI Route Optimization',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12AEE2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.route,
                    color: Color(0xFF12AEE2),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Optimize all pending routes?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI will analyze traffic, weather, and delivery windows to find optimal routes.',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildOptimizationOption(
              'Fastest Routes',
              'Minimize delivery time',
              Icons.speed,
              true,
            ),
            const SizedBox(height: 8),
            _buildOptimizationOption(
              'Cost Efficient',
              'Minimize fuel consumption',
              Icons.attach_money,
              false,
            ),
            const SizedBox(height: 8),
            _buildOptimizationOption(
              'Balanced',
              'Optimal time & cost',
              Icons.balance,
              false,
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
                  content: Text('Optimizing routes...'),
                  backgroundColor: Color(0xFF12AEE2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF12AEE2),
            ),
            child: const Text('Optimize'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationOption(
    String title,
    String subtitle,
    IconData icon,
    bool selected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            selected ? const Color(0xFF12AEE2).withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? const Color(0xFF12AEE2)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: selected ? const Color(0xFF12AEE2) : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? const Color(0xFF12AEE2) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF12AEE2),
            ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(_Shipment shipment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF192D33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.update, color: Color(0xFF12AEE2)),
                const SizedBox(width: 8),
                Text(
                  'Update ${shipment.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusOption('Loading', Icons.download, Colors.orange),
            _buildStatusOption(
                'In Transit', Icons.local_shipping, const Color(0xFF12AEE2)),
            _buildStatusOption(
                'At Checkpoint', Icons.flag, Colors.purple),
            _buildStatusOption(
                'Out for Delivery', Icons.delivery_dining, Colors.blue),
            _buildStatusOption('Delivered', Icons.check_circle, Colors.green),
            _buildStatusOption('Delayed', Icons.warning, Colors.red),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to: $label'),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
enum ShipmentStatus { pending, loading, inTransit, delivered }

class _Shipment {
  final String id;
  final String orderId;
  final String origin;
  final String destination;
  final ShipmentStatus status;
  final double progress;
  final String eta;
  final String distance;
  final String items;
  final String vehicleNumber;
  final String driverName;
  final String driverPhone;

  _Shipment({
    required this.id,
    required this.orderId,
    required this.origin,
    required this.destination,
    required this.status,
    required this.progress,
    required this.eta,
    required this.distance,
    required this.items,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverPhone,
  });

  Color get statusColor {
    switch (status) {
      case ShipmentStatus.pending:
        return Colors.grey;
      case ShipmentStatus.loading:
        return Colors.orange;
      case ShipmentStatus.inTransit:
        return const Color(0xFF12AEE2);
      case ShipmentStatus.delivered:
        return Colors.green;
    }
  }

  String get statusText {
    switch (status) {
      case ShipmentStatus.pending:
        return 'PENDING';
      case ShipmentStatus.loading:
        return 'LOADING';
      case ShipmentStatus.inTransit:
        return 'IN TRANSIT';
      case ShipmentStatus.delivered:
        return 'DELIVERED';
    }
  }
}
