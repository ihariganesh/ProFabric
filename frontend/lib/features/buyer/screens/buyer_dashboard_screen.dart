import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

/// Buyer Dashboard – the landing tab.
/// Shows greeting, quick-action cards (Design Studio / Upload Sample),
/// active order summary, and recent textile matches.
class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _greeting()),
            SliverToBoxAdapter(child: _quickStats()),
            SliverToBoxAdapter(child: _createOrderSection()),
            SliverToBoxAdapter(child: _recentMatches()),
            SliverToBoxAdapter(child: _activeOrders()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ─── Greeting ───────────────────────────────────────────────────────
  Widget _greeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showProfileSheet(),
            child: Builder(builder: (_) {
              final user = AuthService().currentUser;
              final name = (user?.displayName?.isNotEmpty == true)
                  ? user!.displayName!
                  : (user?.email?.split('@').first ?? 'User');
              final initials = name.isNotEmpty ? name[0].toUpperCase() : 'B';
              final photoURL = user?.photoURL;
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: photoURL == null
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF3F8CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  image: photoURL != null
                      ? DecorationImage(
                          image: NetworkImage(photoURL),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoURL == null
                    ? Center(
                        child: Text(initials,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      )
                    : null,
              );
            }),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good Morning 👋',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13)),
                const SizedBox(height: 3),
                const Text('Find Your Perfect Fabric',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3)),
              ],
            ),
          ),
          _iconBtn(Icons.notifications_none_rounded, badge: true, onTap: () {
            Navigator.pushNamed(context, '/notifications');
          }),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon,
      {bool badge = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Stack(
          children: [
            Icon(icon, color: Colors.white60, size: 22),
            if (badge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFF6C63FF), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Profile / Settings Bottom Sheet ─────────────────────────────────
  void _showProfileSheet() {
    final authService = AuthService();
    final user = authService.currentUser;
    final displayName = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'Buyer');
    final email = user?.email ?? '';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111D23),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Profile header
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F8CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 14),
            Text(displayName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(email,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Buyer',
                  style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 24),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 8),

            // Menu items
            _profileMenuItem(
              icon: Icons.person_outline_rounded,
              title: 'Profile Settings',
              subtitle: 'Edit name, photo & preferences',
              color: const Color(0xFF6C63FF),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile-settings');
              },
            ),
            _profileMenuItem(
              icon: Icons.settings_rounded,
              title: 'App Settings',
              subtitle: 'Theme, language & notifications',
              color: const Color(0xFF3F8CFF),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/app-settings');
              },
            ),
            _profileMenuItem(
              icon: Icons.receipt_long_rounded,
              title: 'My Orders',
              subtitle: 'View all orders & history',
              color: const Color(0xFF00C896),
              onTap: () {
                Navigator.pop(context);
                // Switch to Orders tab - find parent BuyerHomeScreen
              },
            ),
            _profileMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'FAQs, contact us',
              color: const Color(0xFFFFB74D),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help-support');
              },
            ),
            _profileMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About FabricFlow',
              subtitle: 'Version 1.0.0',
              color: Colors.white38,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),

            const SizedBox(height: 8),
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(height: 8),

            // Logout
            _profileMenuItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              color: const Color(0xFFEF5350),
              onTap: () => _confirmLogout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: color == const Color(0xFFEF5350)
                                ? color
                                : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.15), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    Navigator.pop(context); // close profile sheet
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2930),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              final authService = AuthService();
              await authService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text('Logout',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─── Quick Stats Row ────────────────────────────────────────────────
  Widget _quickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Row(
        children: [
          _statCard('Pending\nRequests', '0', Icons.hourglass_top_rounded,
              const Color(0xFF6C63FF)),
          const SizedBox(width: 10),
          _statCard('Matched\nTextiles', '0', Icons.handshake_rounded,
              const Color(0xFF3F8CFF)),
          const SizedBox(width: 10),
          _statCard('Active\nOrders', '0', Icons.local_shipping_rounded,
              const Color(0xFF00C896)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }

  // ─── Create Order Section ───────────────────────────────────────────
  Widget _createOrderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Place a Fabric Request',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Choose how you want to describe your fabric need',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  title: 'Design Studio',
                  sub: 'Create with AI tools',
                  icon: Icons.palette_rounded,
                  gradient: const [Color(0xFF6C63FF), Color(0xFF9B6CFF)],
                  onTap: () => Navigator.pushNamed(context, '/ai-design'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  title: 'Upload Sample',
                  sub: 'Import image & details',
                  icon: Icons.cloud_upload_rounded,
                  gradient: const [Color(0xFF3F8CFF), Color(0xFF00C8FF)],
                  onTap: () => Navigator.pushNamed(context, '/fabric-request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required String title,
    required String sub,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradient[0].withValues(alpha: 0.15),
              gradient[1].withValues(alpha: 0.04)
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gradient[0].withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(sub,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ─── Recent Textile Matches ─────────────────────────────────────────
  Widget _recentMatches() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Recent Textile Matches',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/ai-vendor-match'),
                child: const Text('See All',
                    style: TextStyle(color: Color(0xFF3F8CFF), fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF111D22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Column(
              children: [
                Icon(Icons.handshake_outlined,
                    color: Colors.white.withValues(alpha: 0.12), size: 40),
                const SizedBox(height: 10),
                Text('No matches yet',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Create a fabric request to find matched textiles',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Active Orders ──────────────────────────────────────────────────
  Widget _activeOrders() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Active Orders',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              const Text('View All',
                  style: TextStyle(color: Color(0xFF3F8CFF), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF111D22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    color: Colors.white.withValues(alpha: 0.12), size: 40),
                const SizedBox(height: 10),
                Text('No active orders',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Your placed orders will appear here',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
