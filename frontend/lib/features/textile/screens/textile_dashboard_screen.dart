import 'package:flutter/material.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/collab_request_service.dart';
import 'textile_profile_setup_screen.dart';

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
  bool _isLoading = true;
  bool _isProfileComplete = true;

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
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    final user = AuthService().currentUser;
    if (user != null) {
      final data = await UserService().getUserData(user.uid);
      if (data != null && data['isProfileComplete'] == true) {
        setState(() {
          _isProfileComplete = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isProfileComplete = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _useEcoFlow = false;
  final List<Map<String, dynamic>> _riskAlerts = [
    {
      'title': 'Port Strike Alert',
      'region': 'Kolkata Port',
      'impact': 'High',
      'icon': Icons.warning_amber_rounded
    },
    {
      'title': 'Weather Warning',
      'region': 'Coastal Region',
      'impact': 'Medium',
      'icon': Icons.cloudy_snowing
    }
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kBlue)),
      );
    }

    if (!_isProfileComplete) {
      return TextileProfileSetupScreen(
        onComplete: () {
          setState(() {
            _isProfileComplete = true;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _statsRow(),
            _riskRadarWidget(),
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

  Widget _riskRadarWidget() {
    if (_riskAlerts.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _riskAlerts.length,
        itemBuilder: (context, i) {
          final alert = _riskAlerts[i];
          final color = alert['impact'] == 'High' ? _kRed : _kAmber;
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(alert['icon'] as IconData, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(alert['title'] as String, 
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(alert['region'] as String, 
                        style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _ecoFlowToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _useEcoFlow ? _kGreen.withValues(alpha: 0.5) : _kBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_rounded, color: _kGreen),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EcoFlow Sustainability Optimizer', 
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Prioritize carbon-neutral supply chains', 
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: _useEcoFlow,
            activeColor: _kGreen,
            onChanged: (v) => setState(() => _useEcoFlow = v),
          ),
        ],
      ),
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
    return StreamBuilder<List<CollabRequest>>(
      stream: CollabRequestService.instance.requestStream,
      initialData: CollabRequestService.instance.requests,
      builder: (context, snapshot) {
        final reqs = snapshot.data ?? [];
        final pending = reqs.where((r) => r.status == CollabRequestStatus.pending).length;
        final inProduction = reqs.where((r) => r.status == CollabRequestStatus.inProduction).length;
        final ready = reqs.where((r) => r.status == CollabRequestStatus.readyToShip).length;

        return Container(
          color: _kSurf,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              _statCard('Pending', pending.toString(), Icons.hourglass_top_rounded, _kAmber),
              const SizedBox(width: 10),
              _statCard('In Production', inProduction.toString(), Icons.precision_manufacturing_rounded, _kBlue),
              const SizedBox(width: 10),
              _statCard('Ready to Ship', ready.toString(), Icons.local_shipping_rounded, _kGreen),
            ],
          ),
        );
      },
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
    return StreamBuilder<List<CollabRequest>>(
      stream: CollabRequestService.instance.requestStream,
      initialData: CollabRequestService.instance.requests,
      builder: (context, snapshot) {
        final reqs = snapshot.data ?? [];
        final pendingReqs =
            reqs.where((r) => r.status == CollabRequestStatus.pending).toList();

        if (pendingReqs.isEmpty) {
          return const Center(
            child: Text('No pending orders yet',
                style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: pendingReqs.length,
          itemBuilder: (context, i) {
            final req = pendingReqs[i];
            return _orderCard(
              orderId: req.id,
              buyer: req.buyerName,
              fabric: req.fabricType,
              quantity: req.quantityMeters,
              deadline: req.deadline,
            );
          },
        );
      },
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
                    const Spacer(),
                    _outlineBtn('Decline', () {
                      CollabRequestService.instance.rejectRequest(orderId);
                    }),
                    const SizedBox(width: 8),
                    _outlineBtn('Simulate', () => _showFabricSim(orderId)),
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

  void _showFabricSim(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCard,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.precision_manufacturing_outlined, color: _kBlue),
            SizedBox(width: 10),
            Text('FabricSim Digital Twin', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Simulating production run for this supply chain...', 
              style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            _simResultRow('Bottlenecks', 'Dyeing (High Risk)', _kRed),
            _simResultRow('Energy Est.', '1,240 kWh', _kBlue),
            _simResultRow('Delay Prob.', '15%', _kAmber),
            _simResultRow('Confidence', '92%', _kGreen),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
          _solidBtn('Optimize Path', _kBlue, () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _simResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEdgeGuardQC(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kCard,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.videocam_rounded, color: _kRed),
            SizedBox(width: 10),
            Text('EdgeGuard Live QC', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.texture_rounded, color: Colors.white10, size: 100)),
                  // Simulated Defect Map
                  Positioned(
                    left: 50, top: 40,
                    child: _defectMarker('Hole'),
                  ),
                  Positioned(
                    right: 80, bottom: 60,
                    child: _defectMarker('Stain'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Defect Map Generated', style: TextStyle(color: _kRed, fontSize: 14, fontWeight: FontWeight.bold)),
            const Text('2 defects detected in current batch', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
          _solidBtn('Flag Batch', _kRed, () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _defectMarker(String label) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: _kRed, width: 2),
      ),
      child: Center(
        child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: _kRed, shape: BoxShape.circle)),
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
    return StreamBuilder<List<CollabRequest>>(
      stream: CollabRequestService.instance.requestStream,
      initialData: CollabRequestService.instance.requests,
      builder: (context, snapshot) {
        final reqs = snapshot.data ?? [];
        final prodReqs = reqs.where((r) => r.status == CollabRequestStatus.inProduction).toList();

        if (prodReqs.isEmpty) {
          return const Center(
            child: Text('No orders in production', style: TextStyle(color: Colors.white54)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: prodReqs.length,
          itemBuilder: (context, i) => _productionCard(prodReqs[i]),
        );
      },
    );
  }

  Widget _productionCard(CollabRequest req) {
    // Basic mapping of progress to stages
    // Let's divide 1.0 into 4 stages: 0.25, 0.50, 0.75, 1.00
    final stages = [
      ('Fabric Sourcing', _kGreen, req.productionProgress >= 0.25),
      ('Printing', _kBlue, req.productionProgress >= 0.50),
      ('Stitching', _kAmber, req.productionProgress >= 0.75),
      ('Quality Check', const Color(0xFF374151), req.productionProgress >= 1.00),
    ];

    void _advanceProgress() {
      double newProg = req.productionProgress + 0.25;
      if (newProg > 1.0) newProg = 1.0;
      
      String stage = 'In Production';
      if (newProg >= 0.25) stage = 'Fabric Sourcing';
      if (newProg >= 0.50) stage = 'Printing';
      if (newProg >= 0.75) stage = 'Stitching';
      if (newProg >= 1.00) stage = 'Quality Check Pass';

      if (newProg >= 1.00) {
        CollabRequestService.instance.markReadyToShip(req.id);
      } else {
        CollabRequestService.instance.updateProgress(req.id, newProg, stage);
      }
    }

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
              Text(req.id,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              _outlineBtn('EdgeGuard QC', () => _showEdgeGuardQC(req.id)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${(req.productionProgress * 100).toInt()}% Complete',
                  style: const TextStyle(
                      color: _kBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Deadline: ${req.deadline}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: req.productionProgress,
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
                          color: s.$3 ? s.$2.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(11)),
                      child: Center(
                        child: Icon(
                            s.$3
                                ? Icons.check_rounded
                                : Icons.hourglass_empty_rounded,
                            color: s.$3 ? s.$2 : Colors.white38,
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
          const SizedBox(height: 12),
          Center(
            child: _solidBtn('Advance Stage', _kBlue, _advanceProgress),
          ),
        ],
      ),
    );
  }

  Widget _vendorNetworkTab() {
    final vendors = [
      (UserRole.fabricSeller, 12, 4),
      (UserRole.printingUnit, 8, 2),
      (UserRole.stitchingUnit, 15, 5),
      (UserRole.logistics, 6, 3),
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
      itemCount: vendors.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _ecoFlowToggle();
        final (role, total, active) = vendors[i - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _vendorNetworkCard(role, total, active),
        );
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
            child: Text(
                '${total == 0 ? 0 : (active / total * 100).toInt()}% Active',
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
                    Text('₹0',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    Text('No data yet',
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
              _metricCard('Completed', '0', '0%', true,
                  Icons.check_circle_outline_rounded),
              const SizedBox(width: 12),
              _metricCard('Avg. Delivery', '0 days', '0%', true,
                  Icons.schedule_rounded),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricCard('Customer Rating', 'N/A ★', '0', true,
                  Icons.star_outline_rounded),
              const SizedBox(width: 12),
              _metricCard(
                  'On-Time Rate', '0%', '0%', true, Icons.verified_outlined),
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
              CollabRequestService.instance.acceptRequest(
                orderId,
                price: int.tryParse(costCtrl.text),
                timeline: daysCtrl.text.isNotEmpty ? daysCtrl.text : null,
              );
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
