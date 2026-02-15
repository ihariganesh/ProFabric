import 'package:flutter/material.dart';

/// AI-powered vendor suggestion screen based on order requirements
/// Shows budget, timeline, fabric type and recommends best matching manufacturers
class AIVendorMatchScreen extends StatefulWidget {
  const AIVendorMatchScreen({super.key});

  @override
  State<AIVendorMatchScreen> createState() => _AIVendorMatchScreenState();
}

class _AIVendorMatchScreenState extends State<AIVendorMatchScreen> {
  bool _isAnalyzing = false;
  bool _showResults = false;
  RangeValues _budgetRange = const RangeValues(20000, 100000);
  String _selectedTimeline = '2-3 weeks';
  String _selectedFabric = 'Silk';

  final _fabrics = ['Silk', 'Cotton', 'Linen', 'Polyester', 'Jute', 'Velvet', 'Denim', 'Wool'];
  final _timelines = ['1 week', '2-3 weeks', '1 month', '2 months', '3+ months'];

  final _vendors = [
    _AIVendor(name: 'Lakshmi Textiles', location: 'Coimbatore, TN', matchScore: 96, rating: 4.9, price: 420,
        completedOrders: 1240, delivery: '18 days', quality: 98, speed: 92, trust: 95, tags: ['Premium Silk', 'Certified', 'Bulk Ready'],
        reason: 'Best match for silk fabric within your budget. Known for premium quality and timely delivery.'),
    _AIVendor(name: 'Sai Fabrics', location: 'Erode, TN', matchScore: 88, rating: 4.7, price: 380,
        completedOrders: 890, delivery: '20 days', quality: 90, speed: 88, trust: 92, tags: ['Cost Effective', 'Quick Turnaround'],
        reason: 'Great value option. Slightly lower price point with good quality standards.'),
    _AIVendor(name: 'Arvind Mills', location: 'Ahmedabad, GJ', matchScore: 82, rating: 4.8, price: 460,
        completedOrders: 3200, delivery: '25 days', quality: 95, speed: 80, trust: 97, tags: ['Large Scale', 'ISO Certified', 'Premium'],
        reason: 'Industrial-scale production. Higher price but exceptional quality assurance and reliability.'),
    _AIVendor(name: 'Royal Silks', location: 'Kanchipuram, TN', matchScore: 78, rating: 4.6, price: 550,
        completedOrders: 560, delivery: '22 days', quality: 97, speed: 85, trust: 90, tags: ['Artisan', 'Handloom', 'Traditional'],
        reason: 'Specializes in traditional handloom silk. Premium quality for heritage designs.'),
  ];

  void _runAIAnalysis() {
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _isAnalyzing = false; _showResults = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF12AEE2), size: 20),
            SizedBox(width: 8),
            Text('AI Vendor Match', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showResults) ...[
              _buildConfigSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _runAIAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12AEE2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isAnalyzing
                      ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 12),
                          Text('AI is analyzing...', style: TextStyle(color: Colors.white)),
                        ])
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 8),
                          Text('Find Best Vendors', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ]),
                ),
              ),
            ],
            if (_showResults) ...[
              _buildResultsHeader(),
              const SizedBox(height: 16),
              ..._vendors.map((v) => _buildVendorCard(v)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI branding card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF12AEE2).withOpacity(0.15),
              Colors.purple.withOpacity(0.05),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF12AEE2).withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.psychology, color: Color(0xFF12AEE2), size: 36),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Smart Vendor Matching', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Set your requirements and our AI will find the best textile manufacturers for your order.',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Fabric type
        const Text('Fabric Type', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _fabrics.map((f) => ChoiceChip(
            label: Text(f, style: TextStyle(color: _selectedFabric == f ? Colors.white : Colors.white54, fontSize: 12)),
            selected: _selectedFabric == f,
            selectedColor: const Color(0xFF12AEE2),
            backgroundColor: const Color(0xFF1A2A30),
            onSelected: (_) => setState(() => _selectedFabric = f),
            side: BorderSide(color: _selectedFabric == f ? const Color(0xFF12AEE2) : Colors.white12),
          )).toList(),
        ),
        const SizedBox(height: 20),

        // Budget range
        const Text('Budget Range', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₹${_budgetRange.start.toInt()}', style: const TextStyle(color: Color(0xFF00C853), fontSize: 14, fontWeight: FontWeight.w600)),
            Text('₹${_budgetRange.end.toInt()}', style: const TextStyle(color: Color(0xFF00C853), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF00C853),
            inactiveTrackColor: Colors.white.withOpacity(0.08),
            thumbColor: const Color(0xFF00C853),
            overlayColor: const Color(0xFF00C853).withOpacity(0.2),
          ),
          child: RangeSlider(
            values: _budgetRange, min: 5000, max: 500000, divisions: 99,
            onChanged: (v) => setState(() => _budgetRange = v),
          ),
        ),
        const SizedBox(height: 16),

        // Timeline
        const Text('Timeline', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _timelines.map((t) => ChoiceChip(
            label: Text(t, style: TextStyle(color: _selectedTimeline == t ? Colors.white : Colors.white54, fontSize: 12)),
            selected: _selectedTimeline == t,
            selectedColor: const Color(0xFF00C853),
            backgroundColor: const Color(0xFF1A2A30),
            onSelected: (_) => setState(() => _selectedTimeline = t),
            side: BorderSide(color: _selectedTimeline == t ? const Color(0xFF00C853) : Colors.white12),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00C853).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Analysis Complete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Found ${_vendors.length} vendors matching your requirements', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showResults = false),
            child: const Text('Modify', style: TextStyle(color: Color(0xFF12AEE2))),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(_AIVendor vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vendor.matchScore >= 90 ? const Color(0xFF00C853).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF12AEE2).withOpacity(0.2),
                      child: Text(vendor.name[0], style: const TextStyle(color: Color(0xFF12AEE2), fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendor.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                          Text(vendor.location, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (vendor.matchScore >= 90 ? const Color(0xFF00C853) : const Color(0xFF12AEE2)).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${vendor.matchScore}% match', style: TextStyle(
                        color: vendor.matchScore >= 90 ? const Color(0xFF00C853) : const Color(0xFF12AEE2),
                        fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // AI reason
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amber.withOpacity(0.7), size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(vendor.reason, style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Quality', vendor.quality, Colors.green),
                    _buildStat('Speed', vendor.speed, Colors.blue),
                    _buildStat('Trust', vendor.trust, Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('${vendor.rating}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(width: 12),
                    Icon(Icons.inventory_2, color: Colors.white.withOpacity(0.3), size: 14),
                    const SizedBox(width: 4),
                    Text('${vendor.completedOrders} orders', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const Spacer(),
                    Text('₹${vendor.price}/m', style: const TextStyle(color: Color(0xFF00C853), fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('~${vendor.delivery}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: vendor.tags.map((t) => Chip(
                    label: Text(t, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/chat', arguments: {'recipientName': vendor.name}),
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Contact'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF12AEE2)),
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.white.withOpacity(0.05)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context, vendor.name);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${vendor.name} selected!'), backgroundColor: const Color(0xFF00C853)),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Select'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF00C853)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 44, height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: value / 100, backgroundColor: Colors.white.withOpacity(0.05), valueColor: AlwaysStoppedAnimation(color), strokeWidth: 3),
              Text('$value', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}

class _AIVendor {
  final String name, location, delivery, reason;
  final int matchScore, completedOrders, quality, speed, trust;
  final double rating, price;
  final List<String> tags;
  _AIVendor({required this.name, required this.location, required this.matchScore, required this.rating,
    required this.price, required this.completedOrders, required this.delivery, required this.quality,
    required this.speed, required this.trust, required this.tags, required this.reason});
}
