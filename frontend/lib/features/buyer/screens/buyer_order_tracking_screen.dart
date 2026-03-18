import 'package:flutter/material.dart';

/// Order Tracking Screen – Shows live tracking for a specific order
/// with timeline, vendor info, media updates, and communication.
class BuyerOrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const BuyerOrderTrackingScreen({super.key, required this.orderId});

  @override
  State<BuyerOrderTrackingScreen> createState() =>
      _BuyerOrderTrackingScreenState();
}

class _BuyerOrderTrackingScreenState extends State<BuyerOrderTrackingScreen> {
  final _stages = [
    _TrackStage(
      title: 'Request Submitted',
      sub: 'Your fabric request was received',
      date: '25 Feb 2026',
      icon: Icons.description_rounded,
      status: _StageStatus.completed,
    ),
    _TrackStage(
      title: 'Textile Matched',
      sub: 'A textile partner was matched for your request',
      date: '26 Feb 2026',
      icon: Icons.handshake_rounded,
      status: _StageStatus.completed,
    ),
    _TrackStage(
      title: 'Order Confirmed',
      sub: 'You confirmed the order with textile',
      date: '27 Feb 2026',
      icon: Icons.check_circle_rounded,
      status: _StageStatus.completed,
    ),
    _TrackStage(
      title: 'In Production',
      sub: 'Fabric is being manufactured',
      date: '28 Feb 2026',
      icon: Icons.precision_manufacturing_rounded,
      status: _StageStatus.active,
    ),
    _TrackStage(
      title: 'Quality Check',
      sub: 'Pending quality verification',
      date: 'Expected 8 Mar',
      icon: Icons.verified_rounded,
      status: _StageStatus.upcoming,
    ),
    _TrackStage(
      title: 'Dispatched',
      sub: 'Ready for shipping',
      date: 'Expected 10 Mar',
      icon: Icons.local_shipping_rounded,
      status: _StageStatus.upcoming,
    ),
    _TrackStage(
      title: 'Delivered',
      sub: 'Delivery to your location',
      date: 'Expected 15 Mar',
      icon: Icons.inventory_rounded,
      status: _StageStatus.upcoming,
    ),
  ];

  final _updates = [
    _ProcessUpdate(
      message: 'Loom setup complete. Starting weaving process.',
      time: '2 hours ago',
      hasImage: true,
    ),
    _ProcessUpdate(
      message: 'Thread dyeing completed. Color matched to sample.',
      time: '1 day ago',
      hasImage: true,
    ),
    _ProcessUpdate(
      message: 'Raw material procurement done. Quality verified.',
      time: '2 days ago',
      hasImage: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _progressOverview()),
            SliverToBoxAdapter(child: _vendorCard()),
            SliverToBoxAdapter(child: _trackingTimeline()),
            SliverToBoxAdapter(child: _processUpdates()),
            SliverToBoxAdapter(child: _actionButtons()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${widget.orderId}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              Text('Fabric Order',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 13)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3F8CFF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Color(0xFF3F8CFF), size: 8),
                SizedBox(width: 6),
                Text('In Production',
                    style: TextStyle(
                        color: Color(0xFF3F8CFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressOverview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF6C63FF).withOpacity(0.12),
          const Color(0xFF3F8CFF).withOpacity(0.06),
        ]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.15)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text('Overall Progress',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              Spacer(),
              Text('57%',
                  style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.57,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoChip(Icons.calendar_today_rounded, 'ETA: 15 Mar'),
              _infoChip(Icons.straighten_rounded, '500 meters'),
              _infoChip(Icons.currency_rupee_rounded, '₹85,000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white30, size: 14),
        const SizedBox(width: 4),
        Text(text,
            style:
                TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
      ],
    );
  }

  Widget _vendorCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('T',
                  style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Textile Partner',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 6),
                    Icon(Icons.verified_rounded,
                        color: Color(0xFF6C63FF), size: 16),
                  ],
                ),
                const SizedBox(height: 3),
                Text('Assigned to your order',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/chat', arguments: {
              'orderId': widget.orderId,
              'recipientName': 'Textile Partner',
              'recipientRole': 'Textile',
            }),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3F8CFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF3F8CFF), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingTimeline() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking Timeline',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ..._stages.asMap().entries.map((entry) {
            final i = entry.key;
            final stage = entry.value;
            final isLast = i == _stages.length - 1;
            return _timelineItem(stage, isLast);
          }),
        ],
      ),
    );
  }

  Widget _timelineItem(_TrackStage stage, bool isLast) {
    final isCompleted = stage.status == _StageStatus.completed;
    final isActive = stage.status == _StageStatus.active;
    final color = isCompleted
        ? const Color(0xFF00C896)
        : isActive
            ? const Color(0xFF6C63FF)
            : Colors.white.withOpacity(0.15);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(isActive ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                    border:
                        isActive ? Border.all(color: color, width: 2) : null,
                  ),
                  child: Icon(
                    stage.icon,
                    color: color,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? const Color(0xFF00C896).withOpacity(0.3)
                          : Colors.white.withOpacity(0.06),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stage.title,
                      style: TextStyle(
                          color: isActive || isCompleted
                              ? Colors.white
                              : Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(stage.sub,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35), fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(stage.date,
                      style: TextStyle(
                          color: isActive
                              ? const Color(0xFF6C63FF)
                              : Colors.white.withOpacity(0.25),
                          fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _processUpdates() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Process Updates',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('From Textile',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          ..._updates.map((u) => _updateCard(u)),
        ],
      ),
    );
  }

  Widget _updateCard(_ProcessUpdate u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(u.message,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  color: Colors.white.withOpacity(0.25), size: 14),
              const SizedBox(width: 4),
              Text(u.time,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 11)),
              const Spacer(),
              if (u.hasImage)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F8CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_rounded,
                          color: Color(0xFF3F8CFF), size: 14),
                      SizedBox(width: 4),
                      Text('Photo',
                          style: TextStyle(
                              color: Color(0xFF3F8CFF), fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/chat', arguments: {
                'orderId': widget.orderId,
                'recipientName': 'Lakshmi Textiles',
                'recipientRole': 'Textile',
              }),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3F8CFF),
                side:
                    BorderSide(color: const Color(0xFF3F8CFF).withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.support_agent_rounded,
                  size: 18, color: Colors.white),
              label:
                  const Text('Support', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StageStatus { completed, active, upcoming }

class _TrackStage {
  final String title, sub, date;
  final IconData icon;
  final _StageStatus status;
  _TrackStage({
    required this.title,
    required this.sub,
    required this.date,
    required this.icon,
    required this.status,
  });
}

class _ProcessUpdate {
  final String message, time;
  final bool hasImage;
  _ProcessUpdate({
    required this.message,
    required this.time,
    this.hasImage = false,
  });
}
