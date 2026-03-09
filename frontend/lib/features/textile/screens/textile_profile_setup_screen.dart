import 'package:flutter/material.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/auth_service.dart';

class TextileProfileSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TextileProfileSetupScreen({super.key, required this.onComplete});

  @override
  State<TextileProfileSetupScreen> createState() =>
      _TextileProfileSetupScreenState();
}

class _TextileProfileSetupScreenState extends State<TextileProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isSubmitting = false;

  final List<String> _availableProducts = [
    'Sarees',
    'Kurtis',
    'Shirts',
    'Dresses',
    'Upholstery',
    'Bedsheets'
  ];
  final List<String> _selectedProducts = [];

  String _majorProduct = 'Sarees';
  String _quality = 'Premium';

  final _qualities = ['Premium', 'High', 'Standard', 'Economy'];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one product you produce.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        await UserService().updateUserProfile(
          userId: user.uid,
          additionalData: {
            'isProfileComplete': true,
            'companyPhone': _phoneCtrl.text.trim(),
            'companyAddress': _addressCtrl.text.trim(),
            'producedProducts': _selectedProducts,
            'majorProduct': _majorProduct,
            'productQuality': _quality,
          },
        );
      }
      widget.onComplete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1215),
        elevation: 0,
        title: const Text('Complete Your Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Force them to complete this
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please set up your company details to start receiving orders.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 28),

              // ─── Phone Number ─────────────────────────
              _sectionTitle('Phone Number', 'For official communications'),
              const SizedBox(height: 12),
              _inputField(
                controller: _phoneCtrl,
                hint: 'e.g., +91 98765 43210',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              // ─── Company Address ─────────────────────
              _sectionTitle('Company Address', 'Where is your unit located?'),
              const SizedBox(height: 12),
              _inputField(
                controller: _addressCtrl,
                hint: 'Complete address...',
                icon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              // ─── Products Produced ───────────────────
              _sectionTitle('Products Produced', 'Select all that apply'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableProducts.map((prod) {
                  final isSelected = _selectedProducts.contains(prod);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedProducts.remove(prod);
                        } else {
                          _selectedProducts.add(prod);
                        }
                        if (!_selectedProducts.contains(_majorProduct) &&
                            _selectedProducts.isNotEmpty) {
                          _majorProduct = _selectedProducts.first;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
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
                      child: Text(prod,
                          style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.white54,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ─── Major Product ───────────────────────
              _sectionTitle('Major Product', 'Your primary production focus'),
              const SizedBox(height: 12),
              if (_selectedProducts.isEmpty)
                const Text('Select products above first.',
                    style: TextStyle(color: Colors.white54, fontSize: 13))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedProducts.map((prod) {
                    final isSelected = _majorProduct == prod;
                    return GestureDetector(
                      onTap: () => setState(() => _majorProduct = prod),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00C896).withOpacity(0.15)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00C896).withOpacity(0.5)
                                : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Text(prod,
                            style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF00C896)
                                    : Colors.white54,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 28),

              // ─── Product Quality ────────────────────
              _sectionTitle('Product Quality', 'Your typical quality grade'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _qualities.map((q) {
                  final isSelected = _quality == q;
                  return GestureDetector(
                    onTap: () => setState(() => _quality = q),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF8F00).withOpacity(0.15)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF8F00).withOpacity(0.5)
                              : Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Text(q,
                          style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFFF8F00)
                                  : Colors.white54,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // ─── Submit Button ──────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    disabledBackgroundColor:
                        const Color(0xFF6C63FF).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Complete Profile',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Icon(icon, color: Colors.white.withOpacity(0.25), size: 20),
        ),
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
}
