import 'package:flutter/material.dart';

/// Orders list screen with filter tabs and reporting capability
class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  final List<_Order> _orders = [
    _Order(id: 'FB-9045', product: 'Silk Curtains', vendor: 'Lakshmi Textiles',
        status: 'In Production', progress: 0.6, budget: 85000, color: Colors.blue,
        fabricType: 'Silk', deadline: '28 Feb 2026'),
    _Order(id: 'FB-9038', product: 'Cotton Aprons (Bulk)', vendor: 'Sai Fabrics',
        status: 'Vendor Selected', progress: 0.2, budget: 42000, color: Colors.orange,
        fabricType: 'Cotton', deadline: '15 Mar 2026'),
    _Order(id: 'FB-9021', product: 'Linen Table Runners', vendor: 'Arvind Mills',
        status: 'Design Approved', progress: 0.35, budget: 25000, color: Colors.purple,
        fabricType: 'Linen', deadline: '10 Mar 2026'),
    _Order(id: 'FB-9010', product: 'Polyester Banners', vendor: 'Modern Prints',
        status: 'Quality Check', progress: 0.85, budget: 15000, color: Colors.teal,
        fabricType: 'Polyester', deadline: '20 Feb 2026'),
    _Order(id: 'FB-8990', product: 'Jute Bags', vendor: 'EcoWeave Co',
        status: 'Delivered', progress: 1.0, budget: 32000, color: const Color(0xFF00C853),
        fabricType: 'Jute', deadline: '05 Feb 2026'),
    _Order(id: 'FB-8975', product: 'Velvet Cushion Covers', vendor: 'Royal Fabrics',
        status: 'Delivered', progress: 1.0, budget: 18000, color: const Color(0xFF00C853),
        fabricType: 'Velvet', deadline: '01 Feb 2026'),
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

  List<_Order> get _filteredOrders {
    switch (_tabController.index) {
      case 1: return _orders.where((o) => !['Delivered', 'Cancelled'].contains(o.status)).toList();
      case 2: return _orders.where((o) => o.status == 'Delivered').toList();
      case 3: return _orders.where((o) => o.isReported).toList();
      default: return _orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Orders', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Track and manage all orders', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.white54, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Delivered'), Tab(text: 'Reported')],
      ),
    );
  }

  Widget _buildOrdersList() {
    final orders = _filteredOrders;
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text('No orders found', style: TextStyle(color: Colors.white54, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(_Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: order.color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, '/order-detail', arguments: {'orderId': order.id}),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [order.color.withOpacity(0.3), order.color.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.inventory_2_rounded, color: order.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('#${order.id}', style: TextStyle(color: order.color, fontWeight: FontWeight.bold, fontSize: 12)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: order.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(order.status, style: TextStyle(color: order.color, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(order.product, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('${order.vendor} • ${order.fabricType}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildOrderMeta(Icons.currency_rupee, '₹${order.budget.toInt()}'),
                    const SizedBox(width: 16),
                    _buildOrderMeta(Icons.calendar_today, order.deadline),
                    const Spacer(),
                    if (order.status != 'Delivered')
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
                        color: const Color(0xFF1E2D33),
                        onSelected: (value) {
                          if (value == 'report') _showReportDialog(order);
                          if (value == 'track') Navigator.pushNamed(context, '/order-tracking', arguments: {'orderId': order.id});
                          if (value == 'chat') Navigator.pushNamed(context, '/chat', arguments: {'orderId': order.id, 'recipientName': order.vendor});
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'track', child: Row(children: [Icon(Icons.location_on, color: Colors.white54, size: 18), SizedBox(width: 8), Text('Track Order', style: TextStyle(color: Colors.white))])),
                          const PopupMenuItem(value: 'chat', child: Row(children: [Icon(Icons.chat, color: Colors.white54, size: 18), SizedBox(width: 8), Text('Chat Vendor', style: TextStyle(color: Colors.white))])),
                          const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.flag, color: Colors.red, size: 18), SizedBox(width: 8), Text('Report', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                  ],
                ),
                if (order.progress < 1.0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: order.progress,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(order.color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  void _showReportDialog(_Order order) {
    String? selectedReason;
    final reasons = ['Delayed delivery', 'Poor quality', 'Wrong product', 'Vendor unresponsive', 'Other'];
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Color(0xFF1A2A30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.flag_rounded, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Text('Report Order #${order.id}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Reason', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: reasons.map((r) => ChoiceChip(
                  label: Text(r, style: TextStyle(color: selectedReason == r ? Colors.white : Colors.white70, fontSize: 12)),
                  selected: selectedReason == r,
                  selectedColor: Colors.red.withOpacity(0.3),
                  backgroundColor: Colors.white.withOpacity(0.05),
                  onSelected: (v) => setModalState(() => selectedReason = r),
                )).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Describe the issue...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedReason != null ? () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Report submitted for #${order.id}'), backgroundColor: Colors.red.shade700),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, disabledBackgroundColor: Colors.red.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Order {
  final String id, product, vendor, status, fabricType, deadline;
  final double progress, budget;
  final Color color;
  final bool isReported;
  _Order({required this.id, required this.product, required this.vendor,
    required this.status, required this.progress, required this.budget,
    required this.color, required this.fabricType, required this.deadline,
    this.isReported = false});
}
