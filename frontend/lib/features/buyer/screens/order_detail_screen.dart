import 'package:flutter/material.dart';

/// Order detail screen with vendor progress updates at regular intervals
class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildStatusCard()),
            SliverToBoxAdapter(child: _buildOrderInfo()),
            SliverToBoxAdapter(child: _buildVendorCard(context)),
            SliverToBoxAdapter(child: _buildProgressUpdates()),
            SliverToBoxAdapter(child: _buildActions(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
          Text('#$orderId', style: const TextStyle(color: Color(0xFF00C853), fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: const Text('In Production', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.15), Colors.purple.withOpacity(0.08)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Progress', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('65%', style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(value: 0.65, backgroundColor: Color(0xFF1E2D33), valueColor: AlwaysStoppedAnimation(Colors.blue), minHeight: 8),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStage('Design', true, true),
              _buildStageLine(true),
              _buildStage('Fabric', true, true),
              _buildStageLine(true),
              _buildStage('Production', true, false),
              _buildStageLine(false),
              _buildStage('QC', false, false),
              _buildStageLine(false),
              _buildStage('Delivery', false, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStage(String label, bool active, bool completed) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF00C853) : active ? Colors.blue : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(completed ? Icons.check : active ? Icons.circle : Icons.circle_outlined,
              color: completed || active ? Colors.white : Colors.white38, size: 14),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildStageLine(bool active) {
    return Expanded(
      child: Container(
        height: 2, margin: const EdgeInsets.only(bottom: 18),
        color: active ? const Color(0xFF00C853) : Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A2A30), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _infoRow('Product', 'Silk Curtains (Custom)'),
          _infoRow('Fabric Type', 'Mulberry Silk'),
          _infoRow('Quantity', '200 meters'),
          _infoRow('Budget', '₹85,000'),
          _infoRow('Deadline', '28 Feb 2026'),
          _infoRow('Created', '05 Feb 2026'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A30), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF12AEE2).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: const Color(0xFF12AEE2).withOpacity(0.2),
              child: const Text('L', style: TextStyle(color: Color(0xFF12AEE2), fontWeight: FontWeight.bold, fontSize: 18))),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Lakshmi Textiles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Icon(Icons.verified, color: Color(0xFF12AEE2), size: 16),
                ]),
                Text('Textile Manufacturer • Coimbatore', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/chat', arguments: {'orderId': 'FB-9045', 'recipientName': 'Lakshmi Textiles'}),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chat_bubble, color: Color(0xFF00C853), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressUpdates() {
    final updates = [
      _Update('Production Started', 'Weaving of silk fabric has begun', '10 Feb, 3:45 PM', Icons.factory, Colors.blue, image: 'https://picsum.photos/seed/prod1/200/150'),
      _Update('Fabric Dyeing Complete', 'Maroon and gold dyeing finished', '08 Feb, 11:20 AM', Icons.color_lens, Colors.purple, image: 'https://picsum.photos/seed/dye1/200/150'),
      _Update('Raw Material Sourced', 'Mulberry silk cocoons procured', '06 Feb, 9:00 AM', Icons.inventory, Colors.orange),
      _Update('Design Approved', 'Your design has been approved by vendor', '05 Feb, 5:30 PM', Icons.check_circle, const Color(0xFF00C853)),
      _Update('Order Accepted', 'Lakshmi Textiles accepted your order', '05 Feb, 2:15 PM', Icons.handshake, const Color(0xFF12AEE2)),
    ];
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.update, color: Color(0xFF12AEE2), size: 20),
              SizedBox(width: 8),
              Text('Vendor Updates', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...updates.asMap().entries.map((e) => _buildUpdateTile(e.value, e.key == updates.length - 1)),
        ],
      ),
    );
  }

  Widget _buildUpdateTile(_Update update, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: update.color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(update.icon, color: update.color, size: 18),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.white.withOpacity(0.08))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF1A2A30), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(update.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(update.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(update.time, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                  if (update.image != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(update.image!, height: 100, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 100, color: Colors.white.withOpacity(0.05),
                          child: const Center(child: Icon(Icons.image, color: Colors.white24)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.flag, color: Colors.red, size: 18),
              label: const Text('Report', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/order-tracking'),
              icon: const Icon(Icons.location_on, size: 18),
              label: const Text('Track'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }
}

class _Update {
  final String title, description, time;
  final IconData icon;
  final Color color;
  final String? image;
  _Update(this.title, this.description, this.time, this.icon, this.color, {this.image});
}
