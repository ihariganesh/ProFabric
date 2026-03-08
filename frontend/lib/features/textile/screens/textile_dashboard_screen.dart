import 'package:flutter/material.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/services/auth_service.dart';

/// Textile Orchestrator Dashboard – clean redesign.
class TextileDashboardScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const TextileDashboardScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<TextileDashboardScreen> createState() => _TextileDashboardScreenState();
}

class _TextileDashboardScreenState extends State<TextileDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _navIndex = 0;

  static const _kBlue = Color(0xFF3B82F6);
  static const _kGreen = Color(0xFF10B981);
  static const _kAmber = Color(0xFFF59E0B);
  static const _kRed = Color(0xFFEF4444);
  static const _kBg = Color(0xFF0A0F1A);
  static const _kSurf = Color(0xFF111827);
  static const _kCard = Color(0xFF1C2333);
  static const _kBorder = Color(0xFF1E2D3D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                  _pendingOrdersTab(),
                  _productionTab(),
                  _vendorNetworkTab(),
                  _analyticsTab(),
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
    final name = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : widget.userName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'T';

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
                    ? const LinearGradient(
                        colors: [_kBlue, Color(0xFF60A5FA)],
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
                Row(
                  children: [
                    _pill('Textile Orchestrator', _kBlue),
                    const SizedBox(width: 8),
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: _kGreen,
                            borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 4),
                    const Text('Active',
                        style:
                            TextStyle(color: Color(0xFF4B5563), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          _iconBtn(Icons.notifications_outlined, () {
            Navigator.pushNamed(context, '/notifications');
          }, badge: true),
          const SizedBox(width: 4),
          _iconBtn(Icons.chat_bubble_outline_rounded, () {
            Navigator.pushNamed(context, '/chat-list',
                arguments: {'role': 'textile'});
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
          _statCard('Pending', '12', Icons.hourglass_top_rounded, _kAmber),
          const SizedBox(width: 10),
          _statCard('In Production', '8', Icons.precision_manufacturing_rounded,
              _kBlue),
          const SizedBox(width: 10),
          _statCard(
              'Ready to Ship', '5', Icons.local_shipping_rounded, _kGreen),
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
            Icon(icon, color: color, size: 22),
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
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: _kBlue,
        indicatorWeight: 2,
        labelColor: _kBlue,
        unselectedLabelColor: const Color(0xFF4B5563),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: _kBorder,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: const [
          Tab(text: 'Pending Orders'),
          Tab(text: 'Production'),
          Tab(text: 'Vendor Network'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _pendingOrdersTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 5,
      itemBuilder: (_, i) => _orderCard(
        orderId: 'ORD-${1001 + i}',
        buyer: 'Buyer ${i + 1}',
        fabric: ['Cotton', 'Silk', 'Polyester', 'Wool', 'Linen'][i],
        quantity: (100 + i * 50),
        deadline: '${15 + i} days',
      ),
    );
  }

  Widget _orderCard({
    required String orderId,
    required String buyer,
    required String fabric,
    required int quantity,
    required String deadline,
  }) {
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
          onTap: () => _showOrderDetails(orderId),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    _statusPill('Awaiting Acceptance', _kAmber),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoChip(Icons.person_outline_rounded, buyer),
                    const SizedBox(width: 10),
                    _infoChip(Icons.texture_rounded, fabric),
                    const SizedBox(width: 10),
                    _infoChip(Icons.square_foot_rounded, '${quantity}m'),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: _kBorder, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: Color(0xFF374151), size: 14),
                    const SizedBox(width: 4),
                    Text('Deadline: $deadline',
                        style: const TextStyle(
                            color: Color(0xFF4B5563), fontSize: 12)),
                    const Spacer(),
                    _outlineBtn('Details', () => _showOrderDetails(orderId)),
                    const SizedBox(width: 8),
                    _solidBtn(
                        'Accept', _kBlue, () => _showAcceptDialog(orderId)),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _productionTab() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 3,
      itemBuilder: (_, i) => _productionCard(i),
    );
  }

  Widget _productionCard(int i) {
    final stages = [
      ('Fabric Sourcing', _kGreen, true),
      ('Printing', _kBlue, i > 0),
      ('Stitching', _kAmber, false),
      ('Quality Check', const Color(0xFF374151), false),
    ];
    final progress = 0.25 + i * 0.2;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ORD-${2001 + i}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${(progress * 100).toInt()}% Complete',
                  style: const TextStyle(
                      color: _kBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: const AlwaysStoppedAnimation(_kBlue),
            ),
          ),
          const SizedBox(height: 16),
          ...stages.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                          color: s.$2.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(11)),
                      child: Center(
                        child: Icon(
                            s.$3
                                ? Icons.check_rounded
                                : Icons.hourglass_empty_rounded,
                            color: s.$2,
                            size: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(s.$1,
                            style: TextStyle(
                                color: s.$3
                                    ? Colors.white
                                    : const Color(0xFF4B5563),
                                fontSize: 13))),
                    if (s.$3) _statusPill('Done', s.$2),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _vendorNetworkTab() {
    final vendors = [
      (UserRole.fabricSeller, 12, 8),
      (UserRole.printingUnit, 6, 4),
      (UserRole.stitchingUnit, 8, 5),
      (UserRole.logistics, 4, 3),
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: vendors.length,
      itemBuilder: (_, i) {
        final (role, total, active) = vendors[i];
        return _vendorNetworkCard(role, total, active);
      },
    );
  }

  Widget _vendorNetworkCard(UserRole role, int total, int active) {
    final color = role.themeColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Icon(role.icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('$active active · $total total',
                    style: const TextStyle(
                        color: Color(0xFF4B5563), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreen.withValues(alpha: 0.2)),
            ),
            child: Text('${(active / total * 100).toInt()}% Active',
                style: const TextStyle(
                    color: _kGreen, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _analyticsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kBlue.withValues(alpha: 0.12),
                  _kBg,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.insights_rounded,
                      color: _kBlue, size: 28),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Revenue',
                        style:
                            TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
                    SizedBox(height: 2),
                    Text('₹12.4 Lakhs',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    Text('+24% from last month',
                        style: TextStyle(color: _kGreen, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Key Metrics',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricCard('Completed', '156', '+12%', true,
                  Icons.check_circle_outline_rounded),
              const SizedBox(width: 12),
              _metricCard('Avg. Delivery', '18 days', '-8%', true,
                  Icons.schedule_rounded),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricCard('Customer Rating', '4.8 ★', '+0.2', true,
                  Icons.star_outline_rounded),
              const SizedBox(width: 12),
              _metricCard(
                  'On-Time Rate', '94%', '+3%', true, Icons.verified_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
      String label, String value, String change, bool up, IconData icon) {
    final color = up ? _kGreen : _kRed;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF374151), size: 18),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 11)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                    up
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 12),
                Text(change,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    const items = [
      ('Dashboard', Icons.grid_view_rounded),
      ('Orders', Icons.receipt_long_rounded),
      ('Chat', Icons.chat_bubble_outline_rounded),
      ('Vendors', Icons.people_outline_rounded),
      ('Profile', Icons.person_outline_rounded),
    ];

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
                    arguments: {'role': 'textile'});
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
                          ? _kBlue.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(items[i].$2,
                            color: sel ? _kBlue : const Color(0xFF374151),
                            size: 22),
                        if (i == 2)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _kGreen,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: _kSurf, width: 1.5),
                              ),
                              child: const Center(
                                child: Text('5',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(items[i].$1,
                      style: TextStyle(
                          color: sel ? _kBlue : const Color(0xFF374151),
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
    return FloatingActionButton(
      backgroundColor: _kBlue,
      elevation: 0,
      onPressed: _showQuickActions,
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _kBorder, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            _sheetTile(Icons.person_outline_rounded, 'Profile Settings',
                () => Navigator.pop(context)),
            _sheetTile(Icons.settings_outlined, 'App Settings', () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            }),
            _sheetTile(Icons.help_outline_rounded, 'Help & Support',
                () => Navigator.pop(context)),
            const Divider(color: _kBorder),
            _sheetTile(Icons.logout_rounded, 'Sign Out', () async {
              Navigator.pop(context);
              await AuthService().signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            }, color: const Color(0xFFEF4444)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (color ?? _kBlue).withValues(alpha: 0.1),
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

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
            const Text('Quick Actions',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _sheetTile(Icons.add_shopping_cart_rounded, 'Create Order',
                () => Navigator.pop(context)),
            _sheetTile(Icons.person_add_outlined, 'Add Vendor',
                () => Navigator.pop(context)),
            _sheetTile(Icons.assignment_outlined, 'Assign Sub-Order',
                () => Navigator.pop(context)),
            _sheetTile(Icons.chat_outlined, 'Message Buyer',
                () => Navigator.pop(context)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Opening $orderId'),
      backgroundColor: _kBlue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showAcceptDialog(String orderId) {
    final costCtrl = TextEditingController();
    final daysCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _kBorder),
        ),
        title: const Text('Accept Order',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Accept $orderId and start orchestrating production?',
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
            const SizedBox(height: 16),
            _dialogField('Proposed Cost (₹)', costCtrl, TextInputType.number),
            const SizedBox(height: 12),
            _dialogField('Estimated Days', daysCtrl, TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF4B5563))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$orderId accepted!'),
                backgroundColor: _kGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
            },
            child: const Text('Accept Order',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
      String label, TextEditingController ctrl, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
        filled: true,
        fillColor: _kBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBlue, width: 1.5),
        ),
      ),
    );
  }
}
