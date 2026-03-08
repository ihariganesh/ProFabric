import 'package:flutter/material.dart';

/// AI Vendor Match screen – buyer uploads their existing design,
/// AI analyses it and recommends the best textile manufacturers.
class AIVendorMatchScreen extends StatefulWidget {
  const AIVendorMatchScreen({super.key});

  @override
  State<AIVendorMatchScreen> createState() => _AIVendorMatchScreenState();
}

class _AIVendorMatchScreenState extends State<AIVendorMatchScreen> {
  bool _uploaded = false;
  bool _analyzing = false;
  bool _showResults = false;
  RangeValues _budget = const RangeValues(20000, 100000);
  String _timeline = '2-3 weeks';
  String _fabric = 'Auto-detect';

  final _fabrics = [
    'Auto-detect',
    'Silk',
    'Cotton',
    'Linen',
    'Polyester',
    'Jute',
    'Velvet',
    'Denim',
    'Wool'
  ];
  final _timelines = [
    '1 week',
    '2-3 weeks',
    '1 month',
    '2 months',
    '3+ months'
  ];

  // Vendors are populated from the real AI matching backend.
  final List<_Vendor> _vendors = [];

  void _simulateUpload() {
    setState(() => _uploaded = true);
  }

  void _runAnalysis() {
    setState(() => _analyzing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _analyzing = false;
          _showResults = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1015),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF00B0FF), size: 20),
            SizedBox(width: 8),
            Text('Upload & AI Match',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showResults) ...[
              _uploadSection(),
              if (_uploaded) ...[
                const SizedBox(height: 28),
                _configSection(),
                const SizedBox(height: 28),
                _analyseButton(),
              ],
            ],
            if (_showResults) ...[
              _resultsHeader(),
              const SizedBox(height: 16),
              if (_vendors.isEmpty)
                _noResultsState()
              else
                ..._vendors.map((v) => _vendorCard(v)),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Upload Section ─────────────────────────────────────────────────
  Widget _uploadSection() {
    return GestureDetector(
      onTap: _uploaded ? null : _simulateUpload,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _uploaded
              ? const Color(0xFF00E676).withOpacity(0.06)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _uploaded
                ? const Color(0xFF00E676).withOpacity(0.25)
                : Colors.white.withOpacity(0.08),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _uploaded
                  ? Icons.check_circle_rounded
                  : Icons.cloud_upload_rounded,
              size: 52,
              color: _uploaded
                  ? const Color(0xFF00E676)
                  : Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _uploaded ? 'Design uploaded!' : 'Upload Your Design',
              style: TextStyle(
                color: _uploaded ? const Color(0xFF00E676) : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _uploaded
                  ? 'floral-pattern-v3.png  •  2.4 MB'
                  : 'Tap to upload an image, PDF or sketch of your existing design',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),
            if (!_uploaded) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _uploadChip(Icons.image_rounded, 'Gallery'),
                  const SizedBox(width: 12),
                  _uploadChip(Icons.camera_alt_rounded, 'Camera'),
                  const SizedBox(width: 12),
                  _uploadChip(Icons.insert_drive_file_rounded, 'File'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _uploadChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00B0FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00B0FF).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00B0FF), size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF00B0FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─── Configuration Section ──────────────────────────────────────────
  Widget _configSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF00B0FF).withOpacity(0.12),
              const Color(0xFF7C4DFF).withOpacity(0.05),
            ]),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: const Color(0xFF00B0FF).withOpacity(0.15)),
          ),
          child: const Row(
            children: [
              Icon(Icons.psychology_rounded,
                  color: Color(0xFF00B0FF), size: 32),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI will analyse your design',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                        'Fabric type, colour palette, weave pattern and complexity are auto-detected.',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Fabric override
        const Text('Fabric Type Override',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _fabrics
              .map((f) => ChoiceChip(
                    label: Text(f,
                        style: TextStyle(
                            color: _fabric == f ? Colors.white : Colors.white38,
                            fontSize: 12)),
                    selected: _fabric == f,
                    selectedColor: const Color(0xFF00B0FF),
                    backgroundColor: const Color(0xFF111D23),
                    onSelected: (_) => setState(() => _fabric = f),
                    side: BorderSide(
                        color: _fabric == f
                            ? const Color(0xFF00B0FF)
                            : Colors.white10),
                  ))
              .toList(),
        ),
        const SizedBox(height: 22),

        // Budget
        const Text('Budget Range',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₹${_budget.start.toInt()}',
                style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            Text('₹${_budget.end.toInt()}',
                style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF00E676),
            inactiveTrackColor: Colors.white.withOpacity(0.06),
            thumbColor: const Color(0xFF00E676),
            overlayColor: const Color(0xFF00E676).withOpacity(0.15),
          ),
          child: RangeSlider(
            values: _budget,
            min: 5000,
            max: 500000,
            divisions: 99,
            onChanged: (v) => setState(() => _budget = v),
          ),
        ),
        const SizedBox(height: 18),

        // Timeline
        const Text('Timeline',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timelines
              .map((t) => ChoiceChip(
                    label: Text(t,
                        style: TextStyle(
                            color:
                                _timeline == t ? Colors.white : Colors.white38,
                            fontSize: 12)),
                    selected: _timeline == t,
                    selectedColor: const Color(0xFF00E676),
                    backgroundColor: const Color(0xFF111D23),
                    onSelected: (_) => setState(() => _timeline = t),
                    side: BorderSide(
                        color: _timeline == t
                            ? const Color(0xFF00E676)
                            : Colors.white10),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _analyseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _analyzing ? null : _runAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B0FF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _analyzing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('AI is analysing your design…',
                      style: TextStyle(color: Colors.white)),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Find Best Vendors',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
      ),
    );
  }

  // ─── Results ────────────────────────────────────────────────────────
  Widget _resultsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E676).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF00E676), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Analysis Complete',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Found ${_vendors.length} vendors matching your design',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showResults = false),
            child: const Text('Modify',
                style: TextStyle(color: Color(0xFF00B0FF))),
          ),
        ],
      ),
    );
  }

  Widget _noResultsState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              color: Colors.white.withOpacity(0.1), size: 52),
          const SizedBox(height: 14),
          Text(
            'No matches found yet',
            style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'AI vendor matching will be available once the backend is connected',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _vendorCard(_Vendor v) {
    final isTop = v.match >= 90;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111D23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isTop
                ? const Color(0xFF00E676).withOpacity(0.25)
                : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          const Color(0xFF00B0FF).withOpacity(0.15),
                      child: Text(v.name[0],
                          style: const TextStyle(
                              color: Color(0xFF00B0FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          Text(v.location,
                              style: const TextStyle(
                                  color: Colors.white30, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isTop
                                ? const Color(0xFF00E676)
                                : const Color(0xFF00B0FF))
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${v.match}% match',
                          style: TextStyle(
                              color: isTop
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFF00B0FF),
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // AI reason
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.amber.withOpacity(0.6), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(v.reason,
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('Quality', v.quality, const Color(0xFF00E676)),
                    _stat('Speed', v.speed, const Color(0xFF00B0FF)),
                    _stat('Trust', v.trust, const Color(0xFFFF9100)),
                  ],
                ),
                const SizedBox(height: 14),

                // Bottom meta
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('${v.rating}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(width: 14),
                    Icon(Icons.inventory_2_rounded,
                        color: Colors.white.withOpacity(0.2), size: 14),
                    const SizedBox(width: 4),
                    Text('${v.orders} orders',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                    const Spacer(),
                    Text('₹${v.price}/m',
                        style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('~${v.delivery}',
                        style: const TextStyle(
                            color: Colors.white30, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: v.tags
                      .map((t) => Chip(
                            label: Text(t,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 10)),
                            backgroundColor: Colors.white.withOpacity(0.04),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          // Action row
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/chat',
                        arguments: {'recipientName': v.name}),
                    icon:
                        const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Chat'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00B0FF)),
                  ),
                ),
                Container(
                    width: 1,
                    height: 24,
                    color: Colors.white.withOpacity(0.04)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context, v.name);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${v.name} selected!'),
                        backgroundColor: const Color(0xFF00E676),
                      ));
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 16),
                    label: const Text('Select'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00E676)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 3,
              ),
              Text('$value',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white30, fontSize: 10)),
      ],
    );
  }
}

class _Vendor {
  final String name, location, delivery, reason;
  final int match, orders, quality, speed, trust;
  final double rating, price;
  final List<String> tags;

  _Vendor({
    required this.name,
    required this.location,
    required this.match,
    required this.rating,
    required this.price,
    required this.orders,
    required this.delivery,
    required this.quality,
    required this.speed,
    required this.trust,
    required this.tags,
    required this.reason,
  });
}
