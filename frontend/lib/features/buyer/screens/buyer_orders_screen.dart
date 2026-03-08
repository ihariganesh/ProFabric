import 'package:flutter/material.dart';

/// Buyer Orders – filter tabs, search, order cards with tracking & actions.
/// Reworked with new purple/blue color palette.
class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  // ── Orders (loaded from real data source) ────────────────────────────
  final List<_Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_Order> _filtered(int tab) {
    List<_Order> list;
    switch (tab) {
      case 1:
        list = _orders
            .where((o) => o.status != 'Delivered' && o.status != 'Reported')
            .toList();
        break;
      case 2:
        list = _orders.where((o) => o.status == 'Delivered').toList();
        break;
      case 3:
        list = _orders.where((o) => o.status == 'Reported').toList();
        break;
      default:
        list = _orders;
    }
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list
        .where((o) =>
            o.fabric.toLowerCase().contains(q) ||
            o.textile.toLowerCase().contains(q) ||
            o.id.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _searchBar(),
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(4, (i) => _orderList(i)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────
  Widget _header() {
    final active = _orders
        .where((o) => o.status != 'Delivered' && o.status != 'Reported')
        .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Orders',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$active active orders in progress',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13)),
              ],
            ),
          ),
          _iconBtn(Icons.filter_list_rounded, () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white54, size: 20),
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search orders by fabric, textile, ID…',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Tabs ─────────────────────────────────────────────────────────────
  Widget _tabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF6C63FF),
        unselectedLabelColor: Colors.white30,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Active'),
          Tab(text: 'Delivered'),
          Tab(text: 'Reported'),
        ],
      ),
    );
  }

  // ── Order List ──────────────────────────────────────────────────────
  Widget _orderList(int tab) {
    final list = _filtered(tab);
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded,
                color: Colors.white.withValues(alpha: 0.1), size: 56),
            const SizedBox(height: 12),
            Text('No orders found',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: list.length,
      itemBuilder: (_, i) => _orderCard(list[i]),
    );
  }

  // ── Order Card ──────────────────────────────────────────────────────
  Widget _orderCard(_Order o) {
    final isDelivered = o.status == 'Delivered';
    final isReported = o.status == 'Reported';
    final progress = o.stage / 7.0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/buyer-order-tracking',
          arguments: {'orderId': o.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111D22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isReported
                ? const Color(0xFFEF5350).withValues(alpha: 0.25)
                : o.accent.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1 : ID + status badge ──
            Row(
              children: [
                Text('#${o.id}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                _statusBadge(o.status, o.accent),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 2 : Fabric & Textile ──
            Text(o.fabric,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.factory_rounded,
                    color: o.accent.withValues(alpha: 0.6), size: 14),
                const SizedBox(width: 6),
                Text(o.textile,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(o.fabricType,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Row 3 : Progress bar ──
            if (!isDelivered && !isReported) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation(o.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(progress * 100).toInt()}%',
                      style: TextStyle(
                          color: o.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ── Row 4 : Budget + ETA + Actions ──
            Row(
              children: [
                _infoChip(Icons.currency_rupee_rounded,
                    '₹${(o.budget / 1000).toStringAsFixed(0)}K'),
                const SizedBox(width: 8),
                _infoChip(Icons.schedule_rounded, o.eta),
                const Spacer(),
                if (!isDelivered && !isReported) ...[
                  _actionChip('Track', Icons.route_rounded, o.accent, () {
                    Navigator.pushNamed(context, '/buyer-order-tracking',
                        arguments: {'orderId': o.id});
                  }),
                  const SizedBox(width: 6),
                  _actionChip(
                      'Chat', Icons.forum_rounded, const Color(0xFF3F8CFF), () {
                    Navigator.pushNamed(context, '/chat', arguments: {
                      'orderId': o.id,
                      'recipientName': o.textile,
                    });
                  }),
                ],
                if (isReported)
                  _actionChip('Review', Icons.rate_review_rounded,
                      const Color(0xFFEF5350), () {}),
                if (isDelivered)
                  _actionChip('Reorder', Icons.replay_rounded,
                      const Color(0xFF00C896), () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white24, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _actionChip(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Data Model ───────────────────────────────────────────────────────
class _Order {
  final String id, fabric, textile, status, fabricType, deadline, eta;
  final int stage; // 1-7
  final double budget;
  final Color accent;

  _Order({
    required this.id,
    required this.fabric,
    required this.textile,
    required this.status,
    required this.stage,
    required this.budget,
    required this.accent,
    required this.fabricType,
    required this.deadline,
    required this.eta,
  });
}
