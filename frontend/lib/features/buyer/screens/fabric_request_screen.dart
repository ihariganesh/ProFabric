import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

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
  File? _selectedImage;
  bool _isSubmitting = false;
  Color? _extractedColor;

  // Form fields
  String _selectedColor = '';
  String _selectedFabricType = 'Cotton';
  String _selectedThreadType = 'Single Ply';
  final _quantityCtrl = TextEditingController();
  String _selectedTimeline = '2-3 Weeks';
  final _budgetCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  // New text controllers
  final _fabricGsmCtrl = TextEditingController();
  final _numberColorsCtrl = TextEditingController();
  final _customInstructionsCtrl = TextEditingController();

  // New selection states
  String _selectedProductType = 'Saree';
  String _productCategoryMode = 'Fabric Only';
  String _selectedFabricFinish = 'Soft';
  String _isRfdAcceptable = 'No';
  String _selectedPrintingMethod = 'Digital printing';
  String _selectedPatternType = 'Repeating pattern';
  String _selectedQualityPriority = 'Balanced';

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

  final _productTypes = [
    'Saree',
    'Kurti',
    'Shirt',
    'Dress',
    'Upholstery fabric',
    'Bedsheet',
    'Custom textile',
  ];

  final _productCategoryModes = [
    'Fabric Only',
    'Fabric + Stitching',
  ];

  final _fabricFinishes = [
    'Soft',
    'Stretchable',
    'Durable',
  ];

  final _yesNoOptions = [
    'Yes',
    'No',
  ];

  final _printingMethods = [
    'Digital printing',
    'Screen printing',
    'Block printing',
    'Reactive printing',
    'Pigment printing',
  ];

  final _patternTypes = [
    'Repeating pattern',
    'Large motif',
    'Full fabric print',
  ];

  final _qualityPriorities = [
    'Lowest cost',
    'Best quality',
    'Fastest delivery',
    'Balanced',
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
    _fabricGsmCtrl.dispose();
    _numberColorsCtrl.dispose();
    _customInstructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedImage = file;
        _imageUploaded = true;
      });
      _extractColor(file);
    }
  }

  Future<void> _extractColor(File imageFile) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        FileImage(imageFile),
      );
      if (paletteGenerator.dominantColor != null) {
        setState(() {
          _extractedColor = paletteGenerator.dominantColor!.color;
          _selectedColor = 'Extracted';
        });
      }
    } catch (e) {
      debugPrint('Error extracting color: $e');
    }
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
                  Navigator.pushReplacementNamed(context, '/vendor-selection');
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
              if (_extractedColor == null) ...[
                _sectionTitle('Preferred Color', 'Select your desired color'),
                const SizedBox(height: 12),
                _colorGrid(),
                const SizedBox(height: 28),
              ] else ...[
                _sectionTitle(
                    'Extracted Color', 'Detected from your sample image'),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _extractedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Automatically selected based on image',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

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

              // ─── Product Type ───────────────────────────
              _sectionTitle('Product Type',
                  'What is being made? (Determines fabric choice, stitching complexity, and printing method)'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _productTypes,
                selected: _selectedProductType,
                onSelected: (v) => setState(() => _selectedProductType = v),
              ),
              const SizedBox(height: 28),

              // ─── Manufacturing Mode ─────────────────────
              _sectionTitle('Manufacturing Mode',
                  'Is it fabric-only or fabric + stitching?'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _productCategoryModes,
                selected: _productCategoryMode,
                onSelected: (v) => setState(() => _productCategoryMode = v),
              ),
              const SizedBox(height: 28),

              // ─── Fabric GSM / Thickness ─────────────────
              _sectionTitle(
                  'Fabric GSM / Thickness', 'Preference for thickness'),
              const SizedBox(height: 12),
              _inputField(
                controller: _fabricGsmCtrl,
                hint: 'e.g., 150 GSM',
                icon: Icons.layers_rounded,
              ),
              const SizedBox(height: 28),

              // ─── Fabric Finish ──────────────────────────
              _sectionTitle(
                  'Required Fabric Finish', 'Select the finish properties'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _fabricFinishes,
                selected: _selectedFabricFinish,
                onSelected: (v) => setState(() => _selectedFabricFinish = v),
              ),
              const SizedBox(height: 28),

              // ─── RFD Acceptable ─────────────────────────
              _sectionTitle('RFD Fabric Acceptable?',
                  'Is Ready for Dyeing fabric acceptable?'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _yesNoOptions,
                selected: _isRfdAcceptable,
                onSelected: (v) => setState(() => _isRfdAcceptable = v),
              ),
              const SizedBox(height: 28),

              // ─── Printing Requirements ──────────────────
              _sectionTitle('Printing Method Preference',
                  'Your design image determines printing complexity'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _printingMethods,
                selected: _selectedPrintingMethod,
                onSelected: (v) => setState(() => _selectedPrintingMethod = v),
              ),
              const SizedBox(height: 28),

              _sectionTitle('Number of Colors', 'Expected number of colors'),
              const SizedBox(height: 12),
              _inputField(
                controller: _numberColorsCtrl,
                hint: 'e.g., 4',
                icon: Icons.palette_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 28),

              _sectionTitle('Pattern Type', 'What kind of pattern?'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _patternTypes,
                selected: _selectedPatternType,
                onSelected: (v) => setState(() => _selectedPatternType = v),
              ),
              const SizedBox(height: 28),

              // ─── Quality Priority ───────────────────────
              _sectionTitle(
                  'Quality Priority', 'What is most important to you?'),
              const SizedBox(height: 12),
              _chipSelector(
                items: _qualityPriorities,
                selected: _selectedQualityPriority,
                onSelected: (v) => setState(() => _selectedQualityPriority = v),
              ),
              const SizedBox(height: 28),

              // ─── Custom Instructions ────────────────────
              _sectionTitle('Custom Instructions',
                  'Special embroidery, Packaging requirements, Fabric treatment, etc.'),
              const SizedBox(height: 12),
              _textArea(
                controller: _customInstructionsCtrl,
                hint: 'Enter any special requirements here...',
                maxLines: 3,
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
      onTap: _pickImage,
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
        child: _imageUploaded && _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C896).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Uploaded',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _imageUploaded = false;
                          _selectedImage = null;
                          _extractedColor = null;
                          _selectedColor = '';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.white, size: 18),
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
