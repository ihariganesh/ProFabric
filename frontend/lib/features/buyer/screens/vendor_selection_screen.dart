import 'package:flutter/material.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/constants/user_roles.dart';

class VendorSelectionScreen extends StatefulWidget {
  final String? designId;
  const VendorSelectionScreen({super.key, this.designId});

  @override
  State<VendorSelectionScreen> createState() => _VendorSelectionScreenState();
}

class _VendorSelectionScreenState extends State<VendorSelectionScreen> {
  String _selectedFilter = 'AI Recommended';
  final List<String> _filters = ['AI Recommended', 'Lowest Price', 'Highest Rating', 'Fastest Delivery'];

  final List<Map<String, dynamic>> _vendors = [
    {
      'name': 'GreenThread Hub',
      'location': 'Tirupur, India',
      'rating': 4.9,
      'price_score': 85,
      'quality_score': 98,
      'efficiency_score': 92,
      'base_quote': 125000,
      'capabilities': ['Digital Printing', 'Organic Cotton', 'Export Quality'],
      'ai_tag': 'Best Quality',
      'image': 'https://picsum.photos/seed/vendor1/200/200',
    },
    {
      'name': 'TexOrch Solutions',
      'location': 'Surat, India',
      'rating': 4.7,
      'price_score': 95,
      'quality_score': 88,
      'efficiency_score': 96,
      'base_quote': 110000,
      'capabilities': ['Bulk Sourcing', 'Fast Turnaround', 'Synthetic Specialized'],
      'ai_tag': 'Most Efficient',
      'image': 'https://picsum.photos/seed/vendor2/200/200',
    },
    {
      'name': 'Heritage Weaves',
      'location': 'Jaipur, India',
      'rating': 4.8,
      'price_score': 75,
      'quality_score': 99,
      'efficiency_score': 82,
      'base_quote': 145000,
      'capabilities': ['Handloom', 'Block Printing', 'Artisan Network'],
      'ai_tag': 'Premium Choice',
      'image': 'https://picsum.photos/seed/vendor3/200/200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2D33),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Vendor Matching', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Optimizing for Price & Quality', style: TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildAIAnalysisBanner(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return _buildVendorCard(vendor);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildAIAnalysisBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF12AEE2).withOpacity(0.2),
            Color(0xFF9C27B0).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF12AEE2).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Color(0xFF12AEE2)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Analysis Complete',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Matching your silk floral design with top orchestrators in India.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = filter),
              backgroundColor: const Color(0xFF1E2D33),
              selectedColor: const Color(0xFF12AEE2),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 12,
              ),
              checkmarkColor: Colors.black,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(vendor['image'], width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vendor['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF12AEE2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vendor['ai_tag'],
                              style: const TextStyle(color: Color(0xFF12AEE2), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(vendor['location'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(vendor['rating'].toString(), style: const TextStyle(color: Colors.white)),
                          const Spacer(),
                          Text(
                            '₹${(vendor['base_quote'] / 1000).toStringAsFixed(0)}K',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('Price', vendor['price_score'], Colors.green),
                _buildMetric('Quality', vendor['quality_score'], Colors.blue),
                _buildMetric('Speed', vendor['efficiency_score'], Colors.orange),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Wrap(
              spacing: 8,
              children: (vendor['capabilities'] as List<String>).map((c) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(c, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                )
              ).toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showCollaborationModal(vendor);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12AEE2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
              ),
              child: const Text('Connect & Request Sample', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 3,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text('$score', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D33),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
              child: const Text('Back to Studio', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '34 total matches found',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCollaborationModal(Map<String, dynamic> vendor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2D33),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.handshake, color: Color(0xFF12AEE2), size: 32),
                const SizedBox(width: 16),
                Text('Collab with ${vendor['name']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'A request will be sent to the hub orchestrator. They will review your AI design and provide a detailed production timeline.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/order-tracking');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12AEE2)),
                    child: const Text('Confirm Request', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
