import 'package:flutter/material.dart';
import '../../../core/services/collab_request_service.dart';

/// AI Vendor Matching — buyer sees matched vendors and sends collab requests.
class VendorSelectionScreen extends StatefulWidget {
  final String? designId;
  const VendorSelectionScreen({super.key, this.designId});

  @override
  State<VendorSelectionScreen> createState() => _VendorSelectionScreenState();
}

class _VendorSelectionScreenState extends State<VendorSelectionScreen> {
  String _selectedFilter = 'AI Recommended';
  final _filters = ['AI Recommended', 'Lowest Price', 'Highest Rating', 'Fastest Delivery'];

  final _vendors = <Map<String, dynamic>>[
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
    },
  ];

  // Track which vendors already have a pending request
  final Set<String> _sentRequests = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _aiBanner(),
            _filterChips(),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                itemCount: _vendors.length,
                itemBuilder: (_, i) => _vendorCard(_vendors[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1215),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Vendor Matching',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Optimizing for Price & Quality',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI Analysis Banner ─────────────────────────────────────────────
  Widget _aiBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF6C63FF).withValues(alpha: 0.15),
          const Color(0xFF3F8CFF).withValues(alpha: 0.08),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Color(0xFF6C63FF), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Analysis Complete',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 2),
                Text('Matching your silk floral design with top orchestrators in India.',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Chips ───────────────────────────────────────────────────
  Widget _filterChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final f = _filters[i];
          final sel = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: sel ? null : Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sel) ...[
                    const Icon(Icons.check, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                  ],
                  Text(f,
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.white54,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Vendor Card ────────────────────────────────────────────────────
  Widget _vendorCard(Map<String, dynamic> v) {
    final name = v['name'] as String;
    final location = v['location'] as String;
    final rating = v['rating'] as double;
    final pScore = v['price_score'] as int;
    final qScore = v['quality_score'] as int;
    final eScore = v['efficiency_score'] as int;
    final quote = v['base_quote'] as int;
    final caps = v['capabilities'] as List<String>;
    final tag = v['ai_tag'] as String;
    final alreadySent = _sentRequests.contains(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111D22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(name[0],
                            style: const TextStyle(
                                color: Color(0xFF6C63FF), fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3F8CFF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(tag,
                                    style: const TextStyle(
                                        color: Color(0xFF3F8CFF), fontSize: 10, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(location,
                              style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 3),
                              Text('$rating',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Text('₹${(quote / 1000).toStringAsFixed(0)}K',
                                  style: const TextStyle(
                                      color: Color(0xFF00C896), fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Circular score metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metric('Price', pScore, const Color(0xFF00C896)),
                    _metric('Quality', qScore, const Color(0xFF3F8CFF)),
                    _metric('Speed', eScore, const Color(0xFFFF9100)),
                  ],
                ),
                const SizedBox(height: 14),

                // Capability tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: caps
                      .map((c) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(c,
                                style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // Action button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: alreadySent
                  ? const Color(0xFF00C896).withValues(alpha: 0.15)
                  : const Color(0xFF6C63FF),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              child: InkWell(
                onTap: alreadySent ? null : () => _showCollaborationSheet(v),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        alreadySent ? Icons.check_circle_rounded : Icons.handshake_rounded,
                        color: alreadySent ? const Color(0xFF00C896) : Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        alreadySent ? 'Request Sent ✓' : 'Connect & Request Sample',
                        style: TextStyle(
                          color: alreadySent ? const Color(0xFF00C896) : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, int score, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
        const SizedBox(height: 6),
        SizedBox(
          width: 44, height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 3,
              ),
              Text('$score',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Collaboration Bottom Sheet ─────────────────────────────────────
  void _showCollaborationSheet(Map<String, dynamic> vendor) {
    final name = vendor['name'] as String;
    final location = vendor['location'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CollabSheet(
        vendorName: name,
        vendorLocation: location,
        designId: widget.designId ?? '',
        onConfirmed: () {
          setState(() => _sentRequests.add(name));
        },
      ),
    );
  }
}

// ─── Confirm Sheet (stateful for animation) ───────────────────────────
class _CollabSheet extends StatefulWidget {
  final String vendorName;
  final String vendorLocation;
  final String designId;
  final VoidCallback onConfirmed;

  const _CollabSheet({
    required this.vendorName,
    required this.vendorLocation,
    required this.designId,
    required this.onConfirmed,
  });

  @override
  State<_CollabSheet> createState() => _CollabSheetState();
}

class _CollabSheetState extends State<_CollabSheet>
    with SingleTickerProviderStateMixin {
  bool _sending = false;
  bool _sent = false;

  Future<void> _confirmRequest() async {
    setState(() => _sending = true);

    // Actually send via the service
    CollabRequestService.instance.sendRequest(
      vendorName: widget.vendorName,
      vendorLocation: widget.vendorLocation,
      designId: widget.designId,
    );

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() {
      _sending = false;
      _sent = true;
    });

    widget.onConfirmed();

    // Auto-dismiss after showing success
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF111D22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_sent) ...[
            _successView(),
          ] else ...[
            _requestView(),
          ],
        ],
      ),
    );
  }

  Widget _requestView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.handshake_rounded, color: Color(0xFF6C63FF), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text('Collab with ${widget.vendorName}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'A request will be sent to the hub orchestrator. They will review your AI design and provide a detailed production timeline.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 12),

        // What happens next
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _stepRow(Icons.send_rounded, 'Request sent to ${widget.vendorName}', const Color(0xFF6C63FF)),
              const SizedBox(height: 10),
              _stepRow(Icons.visibility_rounded, 'They review your design & specs', const Color(0xFF3F8CFF)),
              const SizedBox(height: 10),
              _stepRow(Icons.notifications_active_rounded, 'You get notified when they respond', const Color(0xFF00C896)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Confirm button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _sending ? null : _confirmRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              disabledBackgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _sending
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Sending Request…',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  )
                : const Text('Confirm Request',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _stepRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        ),
      ],
    );
  }

  Widget _successView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF00C896), size: 48),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Request Sent!',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Your collaboration request has been sent to ${widget.vendorName}. '
          'You\'ll receive a notification when they respond.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active_rounded, color: Color(0xFF6C63FF), size: 16),
              const SizedBox(width: 8),
              Text('Check Notifications for updates',
                  style: TextStyle(color: const Color(0xFF6C63FF).withValues(alpha: 0.9), fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
