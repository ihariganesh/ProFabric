import 'package:flutter/material.dart';
import 'dart:math';

/// Fabric Request Screen – Buyer uploads a sample image and fills in
/// fabric details (color, type, thread, quantity, timeline, budget).
/// System then finds the best matching textiles.
class FabricRequestScreen extends StatefulWidget {
  const FabricRequestScreen({super.key});

  @override
  State<FabricRequestScreen> createState() => _FabricRequestScreenState();
}

class _FabricRequestScreenState extends State<FabricRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _imageUploaded = false;
  bool _isSubmitting = false;

  // Form fields
  String _selectedColor = '';
  String _selectedFabricType = 'Cotton';
  String _selectedThreadType = 'Single Ply';
  final _quantityCtrl = TextEditingController();
  String _selectedTimeline = '2-3 Weeks';
  final _budgetCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  final _fabricTypes = [
    'Cotton',
    'Silk',
    'Linen',
    'Polyester',
    'Wool',
    'Denim',
    'Velvet',
    'Jute',
    'Satin',
    'Chiffon',
    'Organza',
    'Rayon',
  ];

  final _threadTypes = [
    'Single Ply',
    'Double Ply',
    'Multi Ply',
    'Twisted',
    'Core Spun',
    'Textured',
    'Mercerized',
  ];

  final _timelines = [
    '1 Week',
    '2-3 Weeks',
    '1 Month',
    '2 Months',
    '3+ Months',
  ];

  final _colorOptions = [
    {'name': 'Red', 'color': const Color(0xFFE53935)},
    {'name': 'Blue', 'color': const Color(0xFF1E88E5)},
    {'name': 'Green', 'color': const Color(0xFF43A047)},
    {'name': 'Yellow', 'color': const Color(0xFFFDD835)},
    {'name': 'Purple', 'color': const Color(0xFF8E24AA)},
    {'name': 'Orange', 'color': const Color(0xFFFF8F00)},
    {'name': 'Pink', 'color': const Color(0xFFEC407A)},
    {'name': 'Teal', 'color': const Color(0xFF00897B)},
    {'name': 'Brown', 'color': const Color(0xFF6D4C41)},
    {'name': 'Black', 'color': const Color(0xFF212121)},
    {'name': 'White', 'color': const Color(0xFFF5F5F5)},
    {'name': 'Grey', 'color': const Color(0xFF757575)},
    {'name': 'Beige', 'color': const Color(0xFFD7CCC8)},
    {'name': 'Navy', 'color': const Color(0xFF1A237E)},
    {'name': 'Maroon', 'color': const Color(0xFF880E4F)},
    {'name': 'Custom', 'color': const Color(0xFF424242)},
  ];

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _budgetCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _simulateImageUpload() {
    setState(() => _imageUploaded = true);
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessSheet();
      }
    });
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Color(0xFF131E22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF00C896).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF00C896), size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Request Submitted!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'We\'re finding the best textile match for your requirements. You\'ll be notified when we find suitable options.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/ai-vendor-match');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('View Textile Matches',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back to Home',
                  style: TextStyle(color: Color(0xFF3F8CFF))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1215),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Fabric Request',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Upload Section ─────────────────────────
              _sectionTitle('Upload Sample Image', 'Optional but recommended'),
              const SizedBox(height: 12),
              _uploadArea(),
              const SizedBox(height: 28),

              // ─── Description ────────────────────────────
              _sectionTitle('Description', 'Describe the fabric you need'),
              const SizedBox(height: 12),
              _textArea(
                controller: _descriptionCtrl,
                hint:
                    'e.g., Looking for a soft cotton fabric with floral pattern for summer collection…',
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              // ─── Color Selection ────────────────────────
              _sectionTitle('Preferred Color', 'Select your desired color'),
              const SizedBox(height: 12),
              _colorGrid(),
              const SizedBox(height: 28),

              // ─── Fabric Type ────────────────────────────
              _sectionTitle('Fabric Type', 'Choose material type'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _fabricTypes,
                selected: _selectedFabricType,
                onSelected: (v) => setState(() => _selectedFabricType = v),
              ),
              const SizedBox(height: 28),

              // ─── Thread Type ────────────────────────────
              _sectionTitle('Thread Type', 'Select thread specification'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _threadTypes,
                selected: _selectedThreadType,
                onSelected: (v) => setState(() => _selectedThreadType = v),
              ),
              const SizedBox(height: 28),

              // ─── Quantity ───────────────────────────────
              _sectionTitle('Quantity', 'In meters or pieces'),
              const SizedBox(height: 12),
              _inputField(
                controller: _quantityCtrl,
                hint: 'e.g., 500 meters',
                icon: Icons.straighten_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Quantity is required' : null,
              ),
              const SizedBox(height: 28),

              // ─── Timeline ───────────────────────────────
              _sectionTitle('Delivery Timeline', 'Expected delivery period'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _timelines,
                selected: _selectedTimeline,
                onSelected: (v) => setState(() => _selectedTimeline = v),
              ),
              const SizedBox(height: 28),

              // ─── Budget ─────────────────────────────────
              _sectionTitle('Budget', 'Optional – helps in matching'),
              const SizedBox(height: 12),
              _inputField(
                controller: _budgetCtrl,
                hint: 'e.g., ₹50,000',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 36),

              // ─── Submit Button ──────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    disabledBackgroundColor:
                        const Color(0xFF6C63FF).withOpacity(0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text('Find Best Textile Match',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section Title ──────────────────────────────────────────────────
  Widget _sectionTitle(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(sub,
            style:
                TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12)),
      ],
    );
  }

  // ─── Upload Area ────────────────────────────────────────────────────
  Widget _uploadArea() {
    return GestureDetector(
      onTap: _simulateImageUpload,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: _imageUploaded ? 200 : 160,
        decoration: BoxDecoration(
          color: _imageUploaded
              ? const Color(0xFF6C63FF).withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _imageUploaded
                ? const Color(0xFF6C63FF).withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
            width: _imageUploaded ? 2 : 1,
          ),
        ),
        child: _imageUploaded
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(0.2),
                            const Color(0xFF3F8CFF).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.image_rounded,
                          color: Color(0xFF6C63FF), size: 60),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C896).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Color(0xFF00C896), size: 14),
                          SizedBox(width: 4),
                          Text('Uploaded',
                              style: TextStyle(
                                  color: Color(0xFF00C896), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _imageUploaded = false),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red, size: 18),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F8CFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_rounded,
                        color: Color(0xFF3F8CFF), size: 32),
                  ),
                  const SizedBox(height: 14),
                  const Text('Tap to upload sample image',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('JPG, PNG up to 10MB',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 12)),
                ],
              ),
      ),
    );
  }

  // ─── Color Grid ─────────────────────────────────────────────────────
  Widget _colorGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _colorOptions.map((c) {
        final name = c['name'] as String;
        final color = c['color'] as Color;
        final isSelected = _selectedColor == name;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withOpacity(0.08),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(Icons.check_rounded,
                    color:
                        name == 'White' || name == 'Beige' || name == 'Yellow'
                            ? Colors.black87
                            : Colors.white,
                    size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ─── Chip Selector ──────────────────────────────────────────────────
  Widget _chipSelector({
    required List<String> items,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onSelected(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6C63FF).withOpacity(0.15)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6C63FF).withOpacity(0.5)
                    : Colors.white.withOpacity(0.06),
              ),
            ),
            child: Text(item,
                style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF6C63FF) : Colors.white54,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  // ─── Input Field ────────────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.25), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // ─── Text Area ──────────────────────────────────────────────────────
  Widget _textArea({
    required TextEditingController controller,
    required String hint,
    int maxLines = 3,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
