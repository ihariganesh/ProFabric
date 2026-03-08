import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/collab_request_service.dart';

/// Notifications screen — shows live notifications from CollabRequestService
/// plus seeded sample ones. Updates in real-time via stream.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = CollabRequestService.instance;
  late StreamSubscription _sub;
  String _activeFilter = 'All';

  final _filterOptions = ['All', 'Requests', 'Orders', 'Production', 'Payments'];

  @override
  void initState() {
    super.initState();
    _service.seedSampleNotifications();
    _sub = _service.notificationStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  List<AppNotification> get _filtered {
    final all = _service.notifications;
    if (_activeFilter == 'All') return all;
    final cat = _activeFilter.toLowerCase();
    return all.where((n) => n.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _filterChips(),
            Expanded(
              child: items.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _notifCard(items[i]),
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
            child: Text('Notifications',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            onTap: () {
              _service.markAllRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All marked as read'),
                  backgroundColor: Color(0xFF6C63FF),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text('Mark all read',
                style: TextStyle(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─── Filter Chips ───────────────────────────────────────────────────
  Widget _filterChips() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _filterOptions.length,
        itemBuilder: (_, i) {
          final f = _filterOptions[i];
          final sel = _activeFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: sel ? null : Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(f,
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ),
          );
        },
      ),
    );
  }

  // ─── Notification Card ──────────────────────────────────────────────
  Widget _notifCard(AppNotification n) {
    final iconData = _iconFor(n.icon);
    final iconColor = _colorFor(n.icon);
    final timeAgo = _timeAgo(n.createdAt);

    return GestureDetector(
      onTap: () {
        _service.markRead(n.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead
              ? Colors.white.withValues(alpha: 0.02)
              : const Color(0xFF6C63FF).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.isRead
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFF6C63FF).withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700)),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6C63FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5), fontSize: 13, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(timeAgo,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_rounded,
              color: Colors.white.withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 12),
          Text('No notifications yet',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 15)),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────
  IconData _iconFor(String key) {
    switch (key) {
      case 'send': return Icons.send_rounded;
      case 'accepted': return Icons.check_circle_rounded;
      case 'declined': return Icons.cancel_rounded;
      case 'shipping': return Icons.local_shipping_rounded;
      case 'quality': return Icons.verified_rounded;
      case 'chat': return Icons.chat_bubble_rounded;
      case 'payment': return Icons.payment_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String key) {
    switch (key) {
      case 'send': return const Color(0xFF6C63FF);
      case 'accepted': return const Color(0xFF00C896);
      case 'declined': return const Color(0xFFEF5350);
      case 'shipping': return const Color(0xFF3F8CFF);
      case 'quality': return const Color(0xFF00C896);
      case 'chat': return const Color(0xFF6C63FF);
      case 'payment': return const Color(0xFF00C896);
      default: return const Color(0xFF3F8CFF);
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
