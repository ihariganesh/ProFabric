import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Multi-step order creation screen for buyers
/// Follows the textile workflow: Design → Specifications → Quantity → Review
class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _designPromptController = TextEditingController();
  final _quantityController = TextEditingController(text: '100');
  final _threadCountController = TextEditingController(text: '200');
  final _gsmController = TextEditingController(text: '180');
  final _notesController = TextEditingController();

  // Selected values
  String _selectedFabricType = 'Cotton';
  String _selectedWeavePattern = 'Plain';
  String _selectedPrintType = 'Digital Print';
  String _selectedFinish = 'Soft Finish';
  String _selectedDeliverySpeed = 'Standard (15-20 days)';
  String? _generatedDesignUrl;
  bool _isGeneratingDesign = false;
  bool _isSubmitting = false;

  final List<String> _fabricTypes = [
    'Cotton',
    'Silk',
    'Polyester',
    'Linen',
    'Wool',
    'Rayon',
    'Denim',
    'Velvet',
    'Satin',
    'Chiffon',
  ];

  final List<String> _weavePatterns = [
    'Plain',
    'Twill',
    'Satin',
    'Jacquard',
    'Dobby',
    'Oxford',
    'Herringbone',
    'Basket',
  ];

  final List<String> _printTypes = [
    'Digital Print',
    'Screen Print',
    'Block Print',
    'Rotary Print',
    'Sublimation',
    'Solid Color',
    'No Print',
  ];

  final List<String> _finishes = [
    'Soft Finish',
    'Crisp Finish',
    'Mercerized',
    'Pre-shrunk',
    'Wrinkle-free',
    'Water-repellent',
  ];

  final List<String> _deliverySpeeds = [
    'Express (7-10 days)',
    'Standard (15-20 days)',
    'Economy (25-30 days)',
  ];

  @override
  void dispose() {
    _designPromptController.dispose();
    _quantityController.dispose();
    _threadCountController.dispose();
    _gsmController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildProgressIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: _buildStepContent(),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101D22),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Place your textile order',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${_currentStep + 1}/4',
              style: const TextStyle(
                color: Color(0xFF00C853),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isComplete = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF00C853)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        key: ValueKey(_currentStep),
        padding: const EdgeInsets.all(16),
        child: switch (_currentStep) {
          0 => _buildDesignStep(),
          1 => _buildSpecificationsStep(),
          2 => _buildQuantityStep(),
          3 => _buildReviewStep(),
          _ => const SizedBox(),
        },
      ),
    );
  }

  // Step 1: Design
  Widget _buildDesignStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.brush,
          title: 'Design Your Fabric',
          subtitle: 'Describe your design or upload a reference',
        ),
        const SizedBox(height: 24),

        // AI Design Prompt
        _buildSectionTitle('AI Design Generation'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _designPromptController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'Describe your fabric design...\ne.g., "Floral pattern with soft pastel colors, suitable for summer dresses"',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Upload Reference'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _isGeneratingDesign ? null : _generateDesign,
                      icon: _isGeneratingDesign
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(_isGeneratingDesign
                          ? 'Generating...'
                          : 'Generate Design'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Generated Design Preview
        if (_generatedDesignUrl != null) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Generated Design'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFF00C853).withOpacity(0.5)),
              image: const DecorationImage(
                image:
                    NetworkImage('https://picsum.photos/seed/fabric/400/200'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'AI Generated',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Design Templates
        const SizedBox(height: 24),
        _buildSectionTitle('Or Choose a Template'),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              final templates = [
                'Floral',
                'Geometric',
                'Abstract',
                'Traditional',
                'Minimal'
              ];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://picsum.photos/seed/template$index/100/100'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    templates[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Step 2: Specifications
  Widget _buildSpecificationsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.settings,
          title: 'Fabric Specifications',
          subtitle: 'Define material and technical requirements',
        ),
        const SizedBox(height: 24),

        // Fabric Type
        _buildDropdownField(
          label: 'Fabric Type',
          value: _selectedFabricType,
          items: _fabricTypes,
          onChanged: (value) => setState(() => _selectedFabricType = value!),
        ),
        const SizedBox(height: 16),

        // Weave Pattern
        _buildDropdownField(
          label: 'Weave Pattern',
          value: _selectedWeavePattern,
          items: _weavePatterns,
          onChanged: (value) => setState(() => _selectedWeavePattern = value!),
        ),
        const SizedBox(height: 16),

        // Thread Count & GSM Row
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                label: 'Thread Count',
                controller: _threadCountController,
                suffix: 'TPI',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                label: 'GSM (Weight)',
                controller: _gsmController,
                suffix: 'g/m²',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Print Type
        _buildDropdownField(
          label: 'Print Type',
          value: _selectedPrintType,
          items: _printTypes,
          onChanged: (value) => setState(() => _selectedPrintType = value!),
        ),
        const SizedBox(height: 16),

        // Finish
        _buildDropdownField(
          label: 'Finish',
          value: _selectedFinish,
          items: _finishes,
          onChanged: (value) => setState(() => _selectedFinish = value!),
        ),
        const SizedBox(height: 24),

        // Color Palette Selection
        _buildSectionTitle('Color Palette'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildColorChip(Colors.red),
            _buildColorChip(Colors.blue),
            _buildColorChip(Colors.green),
            _buildColorChip(Colors.orange),
            _buildColorChip(Colors.purple),
            _buildColorChip(Colors.teal),
            _buildColorChip(Colors.pink),
            _buildColorChip(Colors.indigo),
            _buildAddColorChip(),
          ],
        ),
      ],
    );
  }

  // Step 3: Quantity
  Widget _buildQuantityStep() {
    final quantity = int.tryParse(_quantityController.text) ?? 100;
    final estimatedCost = _calculateEstimatedCost(quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.inventory,
          title: 'Order Quantity',
          subtitle: 'Set quantity and delivery preferences',
        ),
        const SizedBox(height: 24),

        // Quantity Input
        _buildNumberField(
          label: 'Quantity (Meters)',
          controller: _quantityController,
          suffix: 'meters',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        // Quick quantity buttons
        Wrap(
          spacing: 8,
          children: [50, 100, 250, 500, 1000].map((qty) {
            final isSelected = quantity == qty;
            return ActionChip(
              label: Text('$qty m'),
              backgroundColor: isSelected
                  ? const Color(0xFF00C853)
                  : Colors.white.withOpacity(0.05),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
              ),
              onPressed: () {
                _quantityController.text = qty.toString();
                setState(() {});
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Delivery Speed
        _buildDropdownField(
          label: 'Delivery Speed',
          value: _selectedDeliverySpeed,
          items: _deliverySpeeds,
          onChanged: (value) => setState(() => _selectedDeliverySpeed = value!),
        ),
        const SizedBox(height: 24),

        // Cost Estimation Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00C853).withOpacity(0.2),
                const Color(0xFF00C853).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calculate, color: Color(0xFF00C853)),
                  SizedBox(width: 8),
                  Text(
                    'Cost Estimation',
                    style: TextStyle(
                      color: Color(0xFF00C853),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCostRow(
                  'Base Price', '₹${(estimatedCost * 0.6).toStringAsFixed(0)}'),
              _buildCostRow('Printing Cost',
                  '₹${(estimatedCost * 0.2).toStringAsFixed(0)}'),
              _buildCostRow('Finishing Cost',
                  '₹${(estimatedCost * 0.1).toStringAsFixed(0)}'),
              _buildCostRow(
                  'Delivery', '₹${(estimatedCost * 0.1).toStringAsFixed(0)}'),
              const Divider(color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '₹${estimatedCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '* Final price will be confirmed after vendor bidding',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Additional Notes
        _buildSectionTitle('Additional Notes (Optional)'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Any special requirements or instructions...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Review
  Widget _buildReviewStep() {
    final quantity = int.tryParse(_quantityController.text) ?? 100;
    final estimatedCost = _calculateEstimatedCost(quantity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          icon: Icons.rate_review,
          title: 'Review Order',
          subtitle: 'Confirm your order details',
        ),
        const SizedBox(height: 24),

        // Design Preview
        if (_generatedDesignUrl != null ||
            _designPromptController.text.isNotEmpty)
          _buildReviewCard(
            icon: Icons.brush,
            title: 'Design',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_generatedDesignUrl != null)
                  Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://picsum.photos/seed/fabric/400/200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  _designPromptController.text.isNotEmpty
                      ? _designPromptController.text
                      : 'No design specified',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Specifications
        _buildReviewCard(
          icon: Icons.settings,
          title: 'Specifications',
          child: Column(
            children: [
              _buildReviewRow('Fabric Type', _selectedFabricType),
              _buildReviewRow('Weave Pattern', _selectedWeavePattern),
              _buildReviewRow(
                  'Thread Count', '${_threadCountController.text} TPI'),
              _buildReviewRow('GSM', '${_gsmController.text} g/m²'),
              _buildReviewRow('Print Type', _selectedPrintType),
              _buildReviewRow('Finish', _selectedFinish),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quantity & Delivery
        _buildReviewCard(
          icon: Icons.inventory,
          title: 'Quantity & Delivery',
          child: Column(
            children: [
              _buildReviewRow('Quantity', '$quantity meters'),
              _buildReviewRow('Delivery', _selectedDeliverySpeed),
              _buildReviewRow(
                  'Estimated Cost', '₹${estimatedCost.toStringAsFixed(0)}'),
            ],
          ),
        ),

        if (_notesController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildReviewCard(
            icon: Icons.notes,
            title: 'Additional Notes',
            child: Text(
              _notesController.text,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Agreement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.5)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'By placing this order, you agree to our Terms of Service and allow vendors to submit bids for your order.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00C853).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00C853), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A2A30),
              style: const TextStyle(color: Colors.white),
              icon:
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    String? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixText: suffix,
              suffixStyle: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip(Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
      ),
    );
  }

  Widget _buildAddColorChip() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      child: const Icon(Icons.add, color: Colors.white54, size: 20),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00C853), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Go back to edit
                  if (title == 'Design') {
                    setState(() => _currentStep = 0);
                  } else if (title == 'Specifications') {
                    setState(() => _currentStep = 1);
                  } else if (title == 'Quantity & Delivery') {
                    setState(() => _currentStep = 2);
                  }
                },
                child: const Text('Edit',
                    style: TextStyle(color: Color(0xFF00C853))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101D22),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentStep < 3 ? 'Continue' : 'Place Order',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Actions
  void _generateDesign() async {
    if (_designPromptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a design description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isGeneratingDesign = true);

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGeneratingDesign = false;
      _generatedDesignUrl = 'https://picsum.photos/seed/fabric/400/200';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Design generated successfully!'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitOrder();
    }
  }

  void _submitOrder() async {
    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    // Show success dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A2A30),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00C853),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order #FB-${DateTime.now().millisecondsSinceEpoch % 10000} has been submitted. Vendors will start bidding soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Orders'),
              ),
            ],
          ),
        ),
      );
    }
  }

  double _calculateEstimatedCost(int quantity) {
    double baseRate = switch (_selectedFabricType) {
      'Silk' => 450.0,
      'Cotton' => 250.0,
      'Linen' => 350.0,
      'Wool' => 400.0,
      'Denim' => 280.0,
      'Velvet' => 380.0,
      _ => 200.0,
    };

    // Add print cost
    if (_selectedPrintType != 'Solid Color' &&
        _selectedPrintType != 'No Print') {
      baseRate += 50;
    }

    // Add finish cost
    if (_selectedFinish != 'Soft Finish') {
      baseRate += 30;
    }

    // Express delivery premium
    if (_selectedDeliverySpeed.contains('Express')) {
      return quantity * baseRate * 1.2;
    }

    return quantity * baseRate;
  }
}
