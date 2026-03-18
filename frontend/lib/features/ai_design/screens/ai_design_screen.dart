import 'dart:math';
import 'package:flutter/material.dart';

/// AI Design Studio — describe your fabric, generate a preview, find vendors.
/// Fully self-contained with simulated AI generation (no backend needed).
class AIDesignScreen extends StatefulWidget {
  const AIDesignScreen({super.key});

  @override
  State<AIDesignScreen> createState() => _AIDesignScreenState();
}

class _AIDesignScreenState extends State<AIDesignScreen>
    with TickerProviderStateMixin {
  final _promptController = TextEditingController();
  final _quantityController = TextEditingController(text: '50');
  String _selectedThread = 'Pure Silk';

  bool _isGenerating = false;
  bool _hasGenerated = false;
  double _genProgress = 0;

  AnimationController? _pulseCtrl;
  Animation<double>? _pulseAnim;

  // Generated "design" palette – randomised on each generation
  List<Color> _palette = [];
  String _designId = '';
  int _prodDays = 0;
  double _costPerMeter = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    _promptController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // ─── Generation Simulation ──────────────────────────────────────────
  Future<void> _generateDesign() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please describe your dream fabric first'),
        backgroundColor: Color(0xFFEF5350),
      ));
      return;
    }

    setState(() {
      _isGenerating = true;
      _hasGenerated = false;
      _genProgress = 0;
    });

    // Simulate AI steps
    final steps = [
      'Analyzing prompt…',
      'Generating color palette…',
      'Rendering fabric texture…',
      'Applying thread patterns…',
      'Computing specifications…',
    ];

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(Duration(milliseconds: 400 + Random().nextInt(400)));
      if (!mounted) return;
      setState(() => _genProgress = (i + 1) / steps.length);
    }

    // Build random but deterministic-ish palette from prompt hash
    final hash = prompt.hashCode;
    final rng = Random(hash);
    _palette = List.generate(
      5,
      (_) => Color.fromARGB(
        255,
        60 + rng.nextInt(196),
        60 + rng.nextInt(196),
        60 + rng.nextInt(196),
      ),
    );
    _designId = 'AI-${(hash.abs() % 90000 + 10000)}';
    _prodDays = 7 + rng.nextInt(21);
    _costPerMeter = 120 + rng.nextDouble() * 380;

    setState(() {
      _isGenerating = false;
      _hasGenerated = true;
    });
  }

  // ─── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _promptSection()),
                SliverToBoxAdapter(child: _generateButton()),
                if (_isGenerating) SliverToBoxAdapter(child: _loadingSection()),
                if (_hasGenerated) ...[
                  SliverToBoxAdapter(child: _designPreview()),
                  SliverToBoxAdapter(child: _paletteRow()),
                  SliverToBoxAdapter(child: _techSpecs()),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            if (_hasGenerated) _fab(),
          ],
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1215),
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 18),
            ),
          ),
          const Expanded(
            child: Text('Design Studio',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Prompt Input ───────────────────────────────────────────────────
  Widget _promptSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DESCRIBE YOUR DREAM FABRIC',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: TextField(
              controller: _promptController,
              maxLines: 4,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, height: 1.5),
              decoration: InputDecoration(
                hintText:
                    'e.g., White woolen fabric with gold round patterns and a soft matte finish',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Quick suggestion chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _suggestionChip('Silk with gold motifs'),
                _suggestionChip('Floral cotton print'),
                _suggestionChip('Geometric linen weave'),
                _suggestionChip('Velvet paisley pattern'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _promptController.text = text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15)),
          ),
          child: Text(text,
              style: TextStyle(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.8),
                  fontSize: 12)),
        ),
      ),
    );
  }

  // ─── Generate Button ────────────────────────────────────────────────
  Widget _generateButton() {
    final anim = _pulseAnim;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: _isGenerating ? null : _generateDesign,
        child: anim != null
            ? AnimatedBuilder(
                animation: anim,
                builder: (_, child) {
                  final scale = _isGenerating ? anim.value : 1.0;
                  return Transform.scale(scale: scale, child: child);
                },
                child: _generateButtonContent(),
              )
            : _generateButtonContent(),
      ),
    );
  }

  Widget _generateButtonContent() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isGenerating
              ? [const Color(0xFF3F8CFF), const Color(0xFF6C63FF)]
              : [const Color(0xFF6C63FF), const Color(0xFF3F8CFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isGenerating)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          else
            const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Text(
            _isGenerating ? 'Generating…' : 'AI Generate Design',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ─── Loading Progress ───────────────────────────────────────────────
  Widget _loadingSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _genProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _genProgress < 0.2
                ? 'Analyzing your description…'
                : _genProgress < 0.4
                    ? 'Generating color palette…'
                    : _genProgress < 0.6
                        ? 'Rendering fabric texture…'
                        : _genProgress < 0.8
                            ? 'Applying thread patterns…'
                            : 'Finalizing design…',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Design Preview (locally rendered) ──────────────────────────────
  Widget _designPreview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Design Preview',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                // The "generated" fabric render — a gradient mesh
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: _FabricPatternPainter(
                        colors: _palette,
                        prompt: _promptController.text,
                      ),
                    ),
                  ),
                ),
                // 3D render label
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF111D22),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI-Generated Fabric Render',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text('Design ID: $_designId',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF00C896).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                color: Color(0xFF00C896), size: 14),
                            SizedBox(width: 4),
                            Text('HD Render',
                                style: TextStyle(
                                    color: Color(0xFF00C896),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Palette Row ────────────────────────────────────────────────────
  Widget _paletteRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Extracted Color Palette',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: _palette.map((c) {
              final hex =
                  '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(hex,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 9,
                              fontFamily: 'monospace')),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Technical Specs ────────────────────────────────────────────────
  Widget _techSpecs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Technical Specifications',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _specField(
                      'Quantity (Yards)', _quantityController, 'YD')),
              const SizedBox(width: 14),
              Expanded(
                  child: _specReadonly(
                      'Est. Cost/m', '₹${_costPerMeter.toStringAsFixed(0)}')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _specReadonly('Production', '$_prodDays days')),
              const SizedBox(width: 14),
              Expanded(child: _specReadonly('Design ID', _designId)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Thread Type',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _threadChip('Pure Silk'),
                _threadChip('Pima Cotton'),
                _threadChip('Synthetic Blend'),
                _threadChip('Linen'),
                _threadChip('Wool'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specField(String label, TextEditingController ctrl, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              suffixText: suffix,
              suffixStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _specReadonly(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _threadChip(String label) {
    final sel = _selectedThread == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedThread = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: sel
                ? const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3F8CFF)])
                : null,
            color: sel ? null : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: sel
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? Colors.white : Colors.white54)),
        ),
      ),
    );
  }

  // ─── Bottom FAB ─────────────────────────────────────────────────────
  Widget _fab() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0B1215).withValues(alpha: 0),
              const Color(0xFF0B1215),
              const Color(0xFF0B1215),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/ai-vendor-match', arguments: {
              'designId': _designId,
              'prompt': _promptController.text,
            });
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.factory_rounded, color: Color(0xFF0B1215), size: 22),
                SizedBox(width: 10),
                Text('Find Best Textiles',
                    style: TextStyle(
                        color: Color(0xFF0B1215),
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Painter for "AI Generated" Fabric Pattern ─────────────────
class _FabricPatternPainter extends CustomPainter {
  final List<Color> colors;
  final String prompt;

  _FabricPatternPainter({required this.colors, required this.prompt});

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final rng = Random(prompt.hashCode);

    // Background gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors[0], colors[colors.length > 1 ? 1 : 0]],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Layered circles / ovals to simulate fabric texture
    for (int i = 0; i < 30; i++) {
      final c = colors[rng.nextInt(colors.length)];
      final paint = Paint()
        ..color = c.withValues(alpha: 0.15 + rng.nextDouble() * 0.25)
        ..style = PaintingStyle.fill;
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final rx = 20 + rng.nextDouble() * size.width * 0.3;
      final ry = 20 + rng.nextDouble() * size.height * 0.3;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: rx, height: ry),
          paint);
    }

    // Wavy lines to simulate threads
    for (int j = 0; j < 12; j++) {
      final paint = Paint()
        ..color = colors[rng.nextInt(colors.length)].withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + rng.nextDouble() * 3;
      final path = Path();
      final startY = rng.nextDouble() * size.height;
      path.moveTo(0, startY);
      for (double x = 0; x < size.width; x += 20) {
        final y = startY + sin(x * 0.02 + j) * (20 + rng.nextDouble() * 40);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    // Subtle grid overlay
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FabricPatternPainter old) =>
      old.prompt != prompt;
}
