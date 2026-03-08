import 'package:flutter/material.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/services/auth_service.dart';

/// Generic Vendor Dashboard - redesigned with clean dark palette.
class VendorDashboardScreen extends StatefulWidget {
  final UserRole userRole;
  final String userName;
  final String userEmail;

  const VendorDashboardScreen({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _navIndex = 0;

  static const _kBg = Color(0xFF0A0F1A);
  static const _kSurf = Color(0xFF111827);
  static const _kCard = Color(0xFF1C2333);
  static const _kBorder = Color(0xFF1E2D3D);
  static const _kGreen = Color(0xFF10B981);
  static const _kAmber = Color(0xFFF59E0B);
  static const _kRed = Color(0xFFEF4444);

  Color get _accent => widget.userRole.themeColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _statsRow(),
            _tabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _activeJobsTab(),
                  _pendingBidsTab(),
                  _completedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
      floatingActionButton: _fab(),
    );
  }

  Widget _header() {
    final user = AuthService().currentUser;
    final rawName = user?.displayName;
    final name =
        (rawName != null && rawName.isNotEmpty) ? rawName : widget.userName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'V';
    final accent = _accent;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        color: _kSurf,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showProfileSheet,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: user?.photoURL == null
                    ? LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                image: user?.photoURL != null
                    ? DecorationImage(
                        image: NetworkImage(user!.photoURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user?.photoURL == null
                  ? Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                _pill(widget.userRole.displayName, accent),
              ],
            ),
          ),
          _iconBtn(Icons.notifications_outlined, () {
            Navigator.pushNamed(context, '/notifications');
          }, badge: true),
          const SizedBox(width: 4),
          _iconBtn(Icons.chat_bubble_outline_rounded, () {
            Navigator.pushNamed(context, '/chat-list',
                arguments: {'role': 'vendor'});
          }),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: Colors.white54, size: 20)),
            if (badge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _kSurf, width: 1.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statsRow() {
    return Container(
      color: _kSurf,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _statCard('Active Jobs', '6', Icons.work_outline_rounded, _accent),
          const SizedBox(width: 10),
          _statCard('Pending Bids', '4', Icons.gavel_rounded, _kAmber),
          const SizedBox(width: 10),
          _statCard(
              'Completed', '38', Icons.check_circle_outline_rounded, _kGreen),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      color: _kSurf,
      child: TabBar(
        controller: _tabController,
        indicatorColor: _accent,
        indicatorWeight: 2,
        labelColor: _accent,
        unselectedLabelColor: const Color(0xFF4B5563),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: _kBorder,
        tabs: const [
          Tab(text: 'Active Jobs'),
          Tab(text: 'Pending Bids'),
          Tab(text: 'Completed')
        ],
      ),
    );
  }

  Widget _activeJobsTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 4,
      itemBuilder: (_, i) => _activeJobCard(i),
    );
  }

  Widget _activeJobCard(int i) {
    const progresses = [0.6, 0.35, 0.8, 0.15];
    final progress = progresses[i % progresses.length];
    final orderId = 'ORD-${3001 + i}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(widget.userRole.icon, color: _accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orderId,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const Text('From Textile Orchestrator',
                              style: TextStyle(
                                  color: Color(0xFF4B5563), fontSize: 11)),
                        ],
                      ),
                    ),
                    _statusPill('In Progress', _accent),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation(_accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(progress * 100).toInt()}%',
                        style: TextStyle(
                            color: _accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _infoChip(Icons.inventory_2_outlined, '${200 + i * 50}m'),
                    const SizedBox(width: 12),
                    _infoChip(Icons.schedule_rounded, '${5 + i} days left'),
                    const Spacer(),
                    _outlineBtn('Update', () {}),
                    const SizedBox(width: 8),
                    _solidBtn(
                        'Mark Done', _kGreen, () => _confirmDone(orderId)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pendingBidsTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 3,
      itemBuilder: (_, i) => _pendingBidCard(i),
    );
  }

  Widget _pendingBidCard(int i) {
    final orderId = 'ORD-${4001 + i}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(orderId,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                _statusPill('New Request', _kAmber),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity',
                            style: TextStyle(
                                color: Color(0xFF4B5563), fontSize: 11)),
                        Text('${300 + i * 100}m',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: _kBorder),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deadline',
                            style: TextStyle(
                                color: Color(0xFF4B5563), fontSize: 11)),
                        Text('${10 + i} days',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: _kBorder),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Budget',
                            style: TextStyle(
                                color: Color(0xFF4B5563), fontSize: 11)),
                        Text('₹${i + 2}L',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _outlineBtnFull('Decline', () {})),
                const SizedBox(width: 10),
                Expanded(
                    child: _solidBtnFull(
                        'Accept Bid', _accent, () => _acceptBid(orderId))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _completedTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 5,
      itemBuilder: (_, i) => _completedCard(i),
    );
  }

  Widget _completedCard(int i) {
    final orderId = 'ORD-${5001 + i}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_rounded, color: _kGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orderId,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text('Delivered ${i + 2} days ago',
                    style: const TextStyle(
                        color: Color(0xFF4B5563), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${(i + 1) * 45}K',
                  style: const TextStyle(
                      color: _kGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const Text('Earned',
                  style: TextStyle(color: Color(0xFF4B5563), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF374151), size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      ],
    );
  }

  Widget _outlineBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _solidBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _outlineBtnFull(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _solidBtnFull(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _bottomNav() {
    const items = [
      ('Dashboard', Icons.grid_view_rounded),
      ('Jobs', Icons.work_outline_rounded),
      ('Chat', Icons.chat_bubble_outline_rounded),
      ('Earnings', Icons.account_balance_wallet_outlined),
      ('Profile', Icons.person_outline_rounded),
    ];
    final accent = _accent;
    return Container(
      decoration: const BoxDecoration(
        color: _kSurf,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final sel = _navIndex == i;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (i == 2) {
                Navigator.pushNamed(context, '/chat-list',
                    arguments: {'role': 'vendor'});
                return;
              }
              setState(() => _navIndex = i);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sel
                          ? accent.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(items[i].$2,
                        color: sel ? accent : const Color(0xFF374151),
                        size: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(items[i].$1,
                      style: TextStyle(
                          color: sel ? accent : const Color(0xFF374151),
                          fontSize: 10,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _fab() {
    final accent = _accent;
    return FloatingActionButton(
      backgroundColor: accent,
      elevation: 0,
      onPressed: _showQuickActions,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheet([
        _sheetTile(Icons.person_outline_rounded, 'Profile Settings',
            () => Navigator.pop(context)),
        _sheetTile(Icons.settings_outlined, 'App Settings', () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/settings');
        }),
        _sheetTile(Icons.bar_chart_rounded, 'Earnings Report',
            () => Navigator.pop(context)),
        const Divider(color: _kBorder),
        _sheetTile(Icons.logout_rounded, 'Sign Out', () async {
          Navigator.pop(context);
          await AuthService().signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        }, color: _kRed),
      ]),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _sheet([
        const Text('Quick Actions',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _sheetTile(Icons.update_rounded, 'Update Job Status',
            () => Navigator.pop(context)),
        _sheetTile(Icons.upload_outlined, 'Upload Proof of Work',
            () => Navigator.pop(context)),
        _sheetTile(Icons.chat_outlined, 'Contact Orchestrator',
            () => Navigator.pop(context)),
      ]),
    );
  }

  Widget _sheet(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: _kBorder),
          left: BorderSide(color: _kBorder),
          right: BorderSide(color: _kBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: _kBorder, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          ...children,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    final accent = _accent;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (color ?? accent).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? const Color(0xFF6B7280), size: 18),
      ),
      title: Text(label,
          style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.white.withValues(alpha: 0.15), size: 18),
      onTap: onTap,
    );
  }

  void _confirmDone(String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _kBorder),
        ),
        title: const Text('Mark as Completed',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Mark $orderId as completed and notify the orchestrator?',
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF4B5563))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$orderId marked as completed'),
                backgroundColor: _kGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            },
            child: const Text('Confirm',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _acceptBid(String orderId) {
    final accent = _accent;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _kBorder),
        ),
        title: const Text('Accept Bid',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Accept the job request for $orderId?',
            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Decline',
                style: TextStyle(color: Color(0xFF4B5563))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$orderId accepted'),
                backgroundColor: accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            },
            child: const Text('Accept',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
