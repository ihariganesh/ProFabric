import 'package:flutter/material.dart';

class MyInventoryScreen extends StatefulWidget {
  const MyInventoryScreen({super.key});

  @override
  State<MyInventoryScreen> createState() => _MyInventoryScreenState();
}

class _MyInventoryScreenState extends State<MyInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            // Header
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101D22).withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Inventory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/list-fabric');
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('List Fabric'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12AEE2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101D22).withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF12AEE2),
                labelColor: const Color(0xFF12AEE2),
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                tabs: const [
                  Tab(text: 'Listed'),
                  Tab(text: 'Unlisted'),
                ],
              ),
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListedTab(),
                  _buildUnlistedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _InventoryCard(
          title: 'Premium Silk Fabric ${index + 1}',
          orderId: 'ORD${1000 + index}',
          totalMeters: '${100 + index * 20}m',
          soldMeters: '${20 + index * 5}m',
          availableMeters: '${80 + index * 15}m',
          pricePerMeter: '₹${500 + index * 50}',
          status: 'Listed',
          imageUrl: 'https://images.unsplash.com/photo-1558769132-cb1aea19e59a?w=400&h=400&fit=crop',
          onEdit: () {},
          onView: () {},
        );
      },
    );
  }

  Widget _buildUnlistedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _InventoryCard(
          title: 'Cotton Blend Fabric ${index + 1}',
          orderId: 'ORD${2000 + index}',
          totalMeters: '${150 + index * 30}m',
          soldMeters: '0m',
          availableMeters: '${150 + index * 30}m',
          pricePerMeter: 'Not listed',
          status: 'Unlisted',
          imageUrl: 'https://images.unsplash.com/photo-1519415943484-9fa1873496d4?w=400&h=400&fit=crop',
          onEdit: () {
            Navigator.pushNamed(context, '/list-fabric');
          },
          onView: () {},
        );
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final String title;
  final String orderId;
  final String totalMeters;
  final String soldMeters;
  final String availableMeters;
  final String pricePerMeter;
  final String status;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const _InventoryCard({
    required this.title,
    required this.orderId,
    required this.totalMeters,
    required this.soldMeters,
    required this.availableMeters,
    required this.pricePerMeter,
    required this.status,
    required this.imageUrl,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final isListed = status == 'Listed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isListed
                                  ? const Color(0xFF12AEE2).withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isListed
                                    ? const Color(0xFF12AEE2)
                                    : Colors.orange,
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isListed
                                    ? const Color(0xFF12AEE2)
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order ID: $orderId',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatChip(
                            label: 'Total',
                            value: totalMeters,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Sold',
                            value: soldMeters,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Available',
                            value: availableMeters,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pricePerMeter,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF12AEE2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: Icon(
                      isListed ? Icons.edit : Icons.add_business,
                      size: 18,
                    ),
                    label: Text(isListed ? 'Edit Listing' : 'List Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12AEE2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
