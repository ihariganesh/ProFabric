import 'package:flutter/material.dart';

/// Common marketplace where any user can post products for sale and buy
class EnhancedMarketplaceScreen extends StatefulWidget {
  const EnhancedMarketplaceScreen({super.key});

  @override
  State<EnhancedMarketplaceScreen> createState() => _EnhancedMarketplaceScreenState();
}

class _EnhancedMarketplaceScreenState extends State<EnhancedMarketplaceScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'Fabrics', 'Curtains', 'Aprons', 'Table Linen', 'Bags', 'Custom'];

  final _products = [
    _Product(title: 'Premium Silk Saree Fabric', price: 1200, unit: '/meter', seller: 'Royal Silks', rating: 4.8, reviews: 124,
        category: 'Fabrics', image: 'https://picsum.photos/seed/silk1/300/300', isFeatured: true),
    _Product(title: 'Cotton Curtain Set (2 Panels)', price: 2500, unit: '/set', seller: 'HomeDecor Plus', rating: 4.5, reviews: 89,
        category: 'Curtains', image: 'https://picsum.photos/seed/curtain1/300/300'),
    _Product(title: 'Chef Apron - Denim Blue', price: 450, unit: '/piece', seller: 'UniformCraft', rating: 4.7, reviews: 256,
        category: 'Aprons', image: 'https://picsum.photos/seed/apron1/300/300'),
    _Product(title: 'Jute Tote Bags (Pack of 10)', price: 1800, unit: '/pack', seller: 'EcoWeave Co', rating: 4.6, reviews: 67,
        category: 'Bags', image: 'https://picsum.photos/seed/jute1/300/300', isFeatured: true),
    _Product(title: 'Linen Table Runner - Handwoven', price: 980, unit: '/piece', seller: 'Lakshmi Handlooms', rating: 4.9, reviews: 45,
        category: 'Table Linen', image: 'https://picsum.photos/seed/linen1/300/300'),
    _Product(title: 'Organic Cotton Fabric Roll', price: 350, unit: '/meter', seller: 'GreenThread Mills', rating: 4.4, reviews: 198,
        category: 'Fabrics', image: 'https://picsum.photos/seed/cotton1/300/300'),
    _Product(title: 'Embroidered Cushion Covers (Set of 4)', price: 1600, unit: '/set', seller: 'ArtisanHome', rating: 4.3, reviews: 72,
        category: 'Custom', image: 'https://picsum.photos/seed/cushion1/300/300'),
    _Product(title: 'Polyester Printed Curtain', price: 1100, unit: '/piece', seller: 'Modern Prints', rating: 4.2, reviews: 31,
        category: 'Curtains', image: 'https://picsum.photos/seed/poly1/300/300'),
  ];

  List<_Product> get _filtered => _selectedCategory == 'All' ? _products : _products.where((p) => p.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildFeaturedBanner()),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildProductCard(_filtered[i]),
                  childCount: _filtered.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostProductSheet(),
        backgroundColor: const Color(0xFF12AEE2),
        icon: const Icon(Icons.sell_rounded, size: 20),
        label: const Text('Sell', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Marketplace', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Buy & sell textile products', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.filter_list, color: Colors.white54, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF1A2A30), borderRadius: BorderRadius.circular(14)),
      child: const TextField(
        style: TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.white38, size: 20),
          hintText: 'Search fabrics, curtains, aprons...',
          hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final selected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat, style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
              selected: selected,
              selectedColor: const Color(0xFF12AEE2),
              backgroundColor: const Color(0xFF1A2A30),
              onSelected: (_) => setState(() => _selectedCategory = cat),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: selected ? const Color(0xFF12AEE2) : Colors.white12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF12AEE2).withOpacity(0.2), const Color(0xFF00C853).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF12AEE2).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔥 Trending Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Premium organic fabrics at 20% off', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF12AEE2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Shop Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF12AEE2).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_offer, color: Color(0xFF12AEE2), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(_Product product) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A2A30), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(image: NetworkImage(product.image), fit: BoxFit.cover),
                  ),
                ),
                if (product.isFeatured)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6)),
                      child: const Text('Featured', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.favorite_border, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(product.seller, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  const Spacer(),
                  Row(
                    children: [
                      Text('₹${product.price.toInt()}', style: const TextStyle(color: Color(0xFF00C853), fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(product.unit, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 13),
                      const SizedBox(width: 2),
                      Text('${product.rating}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostProductSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: Color(0xFF1A2A30), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Post a Product', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 120, width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12, style: BorderStyle.solid)),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, color: Colors.white38, size: 36),
                  SizedBox(height: 8),
                  Text('Add Product Photos', style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildFormField('Product Title'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildFormField('Price (₹)')),
              const SizedBox(width: 10),
              Expanded(child: _buildFormField('Unit (e.g. /meter)')),
            ]),
            const SizedBox(height: 10),
            _buildFormField('Description'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product posted!'), backgroundColor: Color(0xFF00C853))); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12AEE2), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Post Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true, fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _Product {
  final String title, seller, category, image, unit;
  final double price, rating;
  final int reviews;
  final bool isFeatured;
  _Product({required this.title, required this.price, required this.unit, required this.seller, required this.rating, required this.reviews, required this.category, required this.image, this.isFeatured = false});
}
