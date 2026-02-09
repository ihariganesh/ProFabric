import 'package:flutter/material.dart';

class AIDesignScreen extends StatefulWidget {
  const AIDesignScreen({super.key});

  @override
  State<AIDesignScreen> createState() => _AIDesignScreenState();
}

class _AIDesignScreenState extends State<AIDesignScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '50');
  final TextEditingController _colorController =
      TextEditingController(text: '#12AEE2');
  String _selectedThread = 'Pure Silk';
  bool _hasGenerated = false;

  @override
  void dispose() {
    _promptController.dispose();
    _quantityController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _generateDesign() {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your dream fabric'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _hasGenerated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating your design...'),
        backgroundColor: Color(0xFF12AEE2),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF101D22).withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Design Studio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // AI Fabric Prompt Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DESCRIBE YOUR DREAM FABRIC',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: TextField(
                            controller: _promptController,
                            maxLines: 5,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'e.g., Iridescent silk with floating gold geometric patterns and a soft velvet finish',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // AI Generate Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _generateDesign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF12AEE2),
                        foregroundColor: const Color(0xFF101D22),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Color(0xFF12AEE2).withOpacity(0.2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 12),
                          Text(
                            'AI Generate Design',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_hasGenerated) ...[
                    // Design Preview Header
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        'Design Preview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // 3D Render Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCBnbF0z-rgjN4_sdc-uGQZ8OgTVSSIhSBk9O23XZwnVJV0xLLSKqiK0Ndxo7fgB-xVv0AdxQs9jjNR0ik9cXsX54jrSyjGjq7sBYcuR30_4sMtJds7oUncMwmnTpeCpRGpxSoQ2KQZOvAWCuS6KKwGDrLc3J1wO-lUvT8Kfl96TfZdL8_SQrXR3N91bIAYmk1-xNz3p_JHjSZYtWVsn4A05yG2phmNmWPT5dWsaum6BW6qZWjdWFWGnMciftH5YetotykkBP3Rb3lM',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.threed_rotation,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '3D High-Fidelity Render',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Interactive visualization engine',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.verified,
                                    color: Color(0xFF12AEE2),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Technical Specifications
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Technical Specifications',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity (Yards)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _quantityController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.all(12),
                                          suffixText: 'YD',
                                          suffixStyle: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Color Hex/Pick',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF12AEE2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                              ),
                                            ),
                                            child: TextField(
                                              controller: _colorController,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'monospace',
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.all(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Thread Type',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildThreadOption('Pure Silk'),
                                const SizedBox(width: 8),
                                _buildThreadOption('Pima Cotton'),
                                const SizedBox(width: 8),
                                _buildThreadOption('Synthetic Blend'),
                                const SizedBox(width: 8),
                                _buildThreadOption('Linen'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 120), // Space for FAB
                ],
              ),
            ),

            // Floating Action Button
            if (_hasGenerated)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF101D22).withOpacity(0),
                        const Color(0xFF101D22),
                        const Color(0xFF101D22),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/vendor-selection',
                            arguments: {'designId': 'AI-GEN-123'},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF101D22),
                          minimumSize: const Size(double.infinity, 64),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 16,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.factory),
                            SizedBox(width: 12),
                            Text(
                              'Find Best Vendors',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 128,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadOption(String label) {
    final isSelected = _selectedThread == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedThread = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF12AEE2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF101D22) : Colors.white,
          ),
        ),
      ),
    );
  }
}
