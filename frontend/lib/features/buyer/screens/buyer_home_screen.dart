import 'package:flutter/material.dart';
import 'buyer_dashboard_screen.dart';
import 'buyer_orders_screen.dart';
import 'buyer_marketplace_screen.dart';
import '../../chat/screens/buyer_chat_hub_screen.dart';

/// Completely reworked buyer home — bottom navigation shell
/// Tabs: Home · Orders · (+) New Request · Textiles · Messages
class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BuyerDashboardScreen(),
    BuyerOrdersScreen(),
    SizedBox(), // placeholder – FAB opens bottom sheet
    BuyerMarketplaceScreen(),
    BuyerChatHubScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      _showCreateOrderSheet();
      return;
    }
    setState(() => _currentIndex = index);
  }

  // ─── Create‑Order Bottom Sheet ──────────────────────────────────────
  void _showCreateOrderSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _CreateOrderSheet(),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111D22),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.space_dashboard_rounded, 'Home'),
              _navItem(1, Icons.receipt_long_rounded, 'Orders'),
              _centerFab(),
              _navItem(3, Icons.factory_rounded, 'Textiles'),
              _navItem(4, Icons.forum_rounded, 'Messages'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final sel = _currentIndex == i;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(i),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF6C63FF).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: sel ? const Color(0xFF6C63FF) : Colors.white24,
                    size: 22),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: sel ? const Color(0xFF6C63FF) : Colors.white24,
                  fontSize: 10,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerFab() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3F8CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

// ─── Create Order Bottom Sheet ────────────────────────────────────────────
class _CreateOrderSheet extends StatelessWidget {
  const _CreateOrderSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111D23),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('New Fabric Request',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('How would you like to describe your fabric need?',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45), fontSize: 14)),
          const SizedBox(height: 28),

          // 1 — AI Design Studio
          _SheetOption(
            icon: Icons.palette_rounded,
            colors: const [Color(0xFF6C63FF), Color(0xFF9B6CFF)],
            title: 'AI Design Studio',
            sub: 'Create a new fabric design from scratch with AI tools',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ai-design');
            },
          ),
          const SizedBox(height: 14),

          // 2 — Upload Sample Image
          _SheetOption(
            icon: Icons.cloud_upload_rounded,
            colors: const [Color(0xFF3F8CFF), Color(0xFF00C8FF)],
            title: 'Upload Sample Image',
            sub: 'Import a fabric sample photo with color, type, thread & budget details',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/fabric-request');
            },
          ),
          const SizedBox(height: 14),

          // 3 — Manual Entry
          _SheetOption(
            icon: Icons.edit_note_rounded,
            colors: const [Color(0xFF00C896), Color(0xFF00E5A0)],
            title: 'Manual Description',
            sub: 'Describe your fabric requirements in detail manually',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/create-order');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final String title, sub;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.colors,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors[0].withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(sub,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: colors[0].withValues(alpha: 0.5), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
