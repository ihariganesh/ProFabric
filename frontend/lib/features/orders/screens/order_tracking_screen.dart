import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    this.orderId = 'FB-8921',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101D22).withOpacity(0.8),
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
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Order #$orderId',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map Section
                    SizedBox(
                      height: 380,
                      child: Stack(
                        children: [
                          // Map Background
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF0D1619),
                                  Color(0xFF101D22),
                                ],
                              ),
                            ),
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: MapRoutePainter(),
                            ),
                          ),

                          // Gradient Fade
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 100,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF101D22),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Status Card
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'IN PRODUCTION',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF12AEE2),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      Text(
                                        'Est. Arrival: Oct 28',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: 0.45,
                                      minHeight: 6,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.1),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF12AEE2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Shipment Journey Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Shipment Journey',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Timeline
                          _buildTimelineStep(
                            icon: Icons.add_circle_outline,
                            iconColor: const Color(0xFF12AEE2),
                            title: 'Order Created',
                            subtitle: 'Your design specification submitted',
                            time: 'Oct 15, 2023',
                            buttonText: 'Details',
                            isCompleted: true,
                            isLast: false,
                          ),

                          _buildTimelineStep(
                            icon: Icons.science_outlined,
                            iconColor: const Color(0xFF12AEE2),
                            title: 'Sample Produced',
                            subtitle: 'Pre-production sample is ready',
                            time: 'Oct 18, 2023',
                            buttonText: 'Approve',
                            isCompleted: true,
                            isLast: false,
                          ),

                          _buildTimelineStep(
                            icon: Icons.shopping_basket_outlined,
                            iconColor: const Color(0xFF12AEE2),
                            title: 'Fabric Sourced',
                            subtitle: 'Egyptian Cotton sourced from Weaver',
                            time: 'Oct 20, 2023',
                            buttonText: 'Sellers',
                            isCompleted: true,
                            isLast: false,
                          ),

                          _buildTimelineStep(
                            icon: Icons.print_outlined,
                            iconColor: const Color(0xFF12AEE2),
                            title: 'Printing In Progress',
                            subtitle: 'Digital printing on 500m fabric',
                            time: 'In Progress • 65%',
                            buttonText: 'Printer',
                            isCompleted: false,
                            isActive: true,
                            isLast: false,
                            hasSubCard: true,
                          ),

                          _buildTimelineStep(
                            icon: Icons.content_cut,
                            iconColor: Colors.white.withOpacity(0.3),
                            title: 'Stitching & Assembly',
                            subtitle: 'Cutting and sewing into garments',
                            time: 'Scheduled: Oct 25',
                            buttonText: 'Stitcher',
                            isCompleted: false,
                            isLast: false,
                            opacity: 0.6,
                          ),

                          _buildTimelineStep(
                            icon: Icons.inventory_2_outlined,
                            iconColor: Colors.white.withOpacity(0.3),
                            title: 'Packaging',
                            subtitle: 'Final inspection and labeling',
                            time: 'Scheduled: Oct 27',
                            buttonText: 'Unit',
                            isCompleted: false,
                            isLast: false,
                            opacity: 0.4,
                          ),

                          _buildTimelineStep(
                            icon: Icons.local_shipping_outlined,
                            iconColor: Colors.white.withOpacity(0.3),
                            title: 'Ready for Shipment',
                            subtitle: 'Logistics provider assigned',
                            time: 'Est: Oct 28',
                            buttonText: 'Courier',
                            isCompleted: false,
                            isLast: true,
                            opacity: 0.2,
                          ),
                        ],
                      ),
                    ),

                    // Contact Support Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2D33),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.support_agent),
                            SizedBox(width: 12),
                            Text(
                              'Contact Logistics Manager',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101D22).withOpacity(0.8),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.grid_view, 'Dashboard', false),
                _buildNavItem(Icons.location_on, 'Tracking', true),
                _buildNavItem(Icons.inventory_2, 'Inventory', false),
                _buildNavItem(Icons.person, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive
              ? const Color(0xFF12AEE2)
              : Colors.white.withOpacity(0.5),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive
                ? const Color(0xFF12AEE2)
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required String buttonText,
    required bool isCompleted,
    required bool isLast,
    bool isActive = false,
    bool hasSubCard = false,
    double opacity = 1.0,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Icon
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF12AEE2)
                    : iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF12AEE2).withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : iconColor,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: isCompleted
                    ? const Color(0xFF12AEE2)
                    : Colors.white.withOpacity(0.1),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.w600,
                              color: isActive
                                  ? const Color(0xFF12AEE2)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isActive
                                  ? const Color(0xFF12AEE2)
                                  : Colors.white.withOpacity(0.4),
                              letterSpacing: isActive ? 1 : 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'orderId': 'FB-8921',
                            'recipientName': buttonText,
                            'recipientRole': _getRoleForButton(buttonText),
                          },
                        );
                      },
                      icon: const Icon(Icons.chat, size: 14),
                      label: Text(buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? const Color(0xFF12AEE2)
                            : const Color(0xFF1E2D33),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasSubCard)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Live production feed available',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.3),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                if (!isLast) const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getRoleForButton(String text) {
    switch (text) {
      case 'Details':
        return 'Buyer Support';
      case 'Approve':
        return 'Design Studio';
      case 'Sellers':
        return 'Fabric Market';
      case 'Printer':
        return 'Printing Unit';
      case 'Stitcher':
        return 'Stitching Unit';
      case 'Unit':
        return 'Packaging Hub';
      case 'Courier':
        return 'Logistics Provider';
      default:
        return 'Vendor';
    }
  }
}

class MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF12AEE2).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw curved route
    path.moveTo(size.width * 0.2, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.2,
    );

    // Dashed line
    const dashWidth = 6;
    const dashSpace = 4;
    double distance = 0;

    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final start = pathMetric.getTangentForOffset(distance)!.position;
        distance += dashWidth;
        final end = pathMetric.getTangentForOffset(distance)!.position;
        canvas.drawLine(start, end, paint);
        distance += dashSpace;
      }
    }

    // Draw nodes
    final nodePaint = Paint()
      ..color = const Color(0xFF12AEE2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      6,
      nodePaint,
    );

    // Active node with pulse
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      8,
      nodePaint..color = const Color(0xFF12AEE2),
    );

    // Destination node
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      6,
      nodePaint..color = const Color(0xFF325A67),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
