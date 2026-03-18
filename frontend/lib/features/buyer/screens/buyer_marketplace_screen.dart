import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/services/user_service.dart';

/// Buyer Marketplace – Browse available textiles and their specializations.
/// Shows featured textiles, browse by fabric type, and recent textile listings.
class BuyerMarketplaceScreen extends StatefulWidget {
  const BuyerMarketplaceScreen({super.key});

  @override
  State<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  String _category = 'All';
  final _searchCtrl = TextEditingController();
  String _query = '';

  final _cats = [
    'All',
    'Cotton',
    'Silk',
    'Linen',
    'Polyester',
    'Denim',
    'Wool',
    'Jute',
  ];

  final List<_Textile> _textiles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTextiles();
  }

  Future<void> _loadTextiles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final users = await UserService().getUsersByRole('textile');
      if (!mounted) return;
      const palette = [
        Color(0xFF3B82F6),
        Color(0xFF8B5CF6),
        Color(0xFF10B981),
        Color(0xFFEC4899),
        Color(0xFFF59E0B),
      ];
      setState(() {
        _textiles.clear();
        for (var i = 0; i < users.length; i++) {
          final u = users[i];
          final rawName = u['displayName'] as String?;
          final name = (rawName != null && rawName.isNotEmpty)
              ? rawName
              : (u['email'] as String? ?? '').split('@').first;
          _textiles.add(_Textile(
            uid: u['uid'] as String? ?? '',
            name: name.isEmpty ? 'Textile Co.' : name,
            location: (u['location'] as String?) ?? 'India',
            rating: ((u['rating'] ?? 4.5) as num).toDouble(),
            orders: (u['orders'] ?? 0) as int,
            specialization:
                (u['specialization'] as String?) ?? 'Fabric Manufacturer',
            minOrder: (u['minOrder'] as String?) ?? '50 m',
            priceRange:
                (u['priceRange'] as String?) ?? '\u20b980\u2013\u20b9200/m',
            category: (u['category'] as String?) ?? '',
            tags:
                List<String>.from(u['tags'] as List? ?? ['Fabric', 'Textile']),
            color: palette[i % palette.length],
            verified: (u['verified'] as bool?) ?? false,
          ));
        }
      });
    } catch (e) {
      if (kDebugMode) print('Marketplace load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_Textile> get _filtered {
    var list = _category == 'All'
        ? _textiles
        : _textiles
            .where((t) => t.category == _category || t.category.isEmpty)
            .toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.specialization.toLowerCase().contains(q) ||
              t.location.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _searchBar()),
            SliverToBoxAdapter(child: _categories()),
            SliverToBoxAdapter(child: _featuredBanner()),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(child: _emptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _textileCard(_filtered[i]),
                    childCount: _filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/fabric-request'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('New Request',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover Textiles',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Find the perfect textile for your fabric needs',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.tune_rounded, color: Colors.white54, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search textiles, fabrics, locations…',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _categories() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        itemCount: _cats.length,
        itemBuilder: (_, i) {
          final c = _cats[i];
          final sel = _category == c;
          return GestureDetector(
            onTap: () => setState(() => _category = c),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: sel
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Center(
                child: Text(c,
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.white38,
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _featuredBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF6C63FF).withValues(alpha: 0.15),
          const Color(0xFF0B1215),
        ]),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF6C63FF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Smart Matching ✨',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Upload your sample and let AI find the best textile',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Color(0xFF6C63FF), size: 16),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        children: [
          Icon(Icons.store_outlined,
              color: Colors.white.withValues(alpha: 0.1), size: 56),
          const SizedBox(height: 14),
          Text(
            'No textiles listed yet',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Textile vendors will appear here once they join the platform',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/fabric-request'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
              ),
              child: const Text('Post a Fabric Request',
                  style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textileCard(_Textile t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111D22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.color.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to textile detail or start chat
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: avatar, name, rating
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: t.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(t.name[0],
                            style: TextStyle(
                                color: t.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(t.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              if (t.verified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded,
                                    color: Color(0xFF6C63FF), size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  size: 13),
                              const SizedBox(width: 3),
                              Text(t.location,
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text('${t.rating}',
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Specialization
                Text(t.specialization,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13)),
                const SizedBox(height: 12),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: t.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: t.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: t.color.withValues(alpha: 0.12)),
                            ),
                            child: Text(tag,
                                style: TextStyle(
                                    color: t.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                // Bottom row: price, min order, orders
                Row(
                  children: [
                    _infoChip(Icons.currency_rupee_rounded, t.priceRange),
                    const Spacer(),
                    _infoChip(Icons.inventory_2_rounded, '${t.orders} orders'),
                  ],
                ),
                const SizedBox(height: 14),
                // CTA
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/chat', arguments: {
                          'recipientId': t.uid,
                          'recipientName': t.name,
                          'recipientRole': 'Textile',
                        }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.color,
                          side:
                              BorderSide(color: t.color.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Chat',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/fabric-request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.color,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Send Request',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white24, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}

class _Textile {
  final String uid;
  final String name, location, specialization, minOrder, priceRange, category;
  final double rating;
  final int orders;
  final List<String> tags;
  final Color color;
  final bool verified;

  _Textile({
    required this.uid,
    required this.name,
    required this.location,
    required this.rating,
    required this.orders,
    required this.specialization,
    required this.minOrder,
    required this.priceRange,
    required this.category,
    required this.tags,
    required this.color,
    this.verified = false,
  });
}
