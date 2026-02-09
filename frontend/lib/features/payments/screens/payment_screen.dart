import 'package:flutter/material.dart';

/// Payment details and escrow management screen
/// Shows milestone-based payments and allows payment actions
class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.orderId,
    this.totalAmount = 125000.0,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  // Mock milestone data
  final List<_PaymentMilestone> _milestones = [
    _PaymentMilestone(
      id: 1,
      name: 'Advance Payment',
      percentage: 30,
      status: MilestoneStatus.released,
      releasedAt: DateTime(2026, 1, 5),
    ),
    _PaymentMilestone(
      id: 2,
      name: 'Sample Approval',
      percentage: 20,
      status: MilestoneStatus.escrowed,
      releasedAt: null,
    ),
    _PaymentMilestone(
      id: 3,
      name: 'Production Complete',
      percentage: 25,
      status: MilestoneStatus.pending,
      releasedAt: null,
    ),
    _PaymentMilestone(
      id: 4,
      name: 'Quality Check',
      percentage: 15,
      status: MilestoneStatus.pending,
      releasedAt: null,
    ),
    _PaymentMilestone(
      id: 5,
      name: 'Delivery Confirmed',
      percentage: 10,
      status: MilestoneStatus.pending,
      releasedAt: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final released = _milestones
        .where((m) => m.status == MilestoneStatus.released)
        .fold<double>(0, (sum, m) => sum + (widget.totalAmount * m.percentage / 100));
    final escrowed = _milestones
        .where((m) => m.status == MilestoneStatus.escrowed)
        .fold<double>(0, (sum, m) => sum + (widget.totalAmount * m.percentage / 100));
    final pending = _milestones
        .where((m) => m.status == MilestoneStatus.pending)
        .fold<double>(0, (sum, m) => sum + (widget.totalAmount * m.percentage / 100));

    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentSummaryCard(released, escrowed, pending),
                    const SizedBox(height: 24),
                    _buildMilestoneTimeline(),
                    const SizedBox(height: 24),
                    _buildPaymentHistory(),
                  ],
                ),
              ),
            ),
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
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Payment & Escrow',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white54),
            onPressed: _showEscrowInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(double released, double escrowed, double pending) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00C853).withOpacity(0.2),
            Color(0xFF00C853).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF00C853).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF00C853).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Color(0xFF00C853)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Order Value',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    '₹${widget.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryItem(
                label: 'Released',
                amount: released,
                color: const Color(0xFF00C853),
                icon: Icons.check_circle,
              ),
              _buildSummaryItem(
                label: 'In Escrow',
                amount: escrowed,
                color: Colors.orange,
                icon: Icons.lock,
              ),
              _buildSummaryItem(
                label: 'Pending',
                amount: pending,
                color: Colors.grey,
                icon: Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.timeline, color: Color(0xFF00C853)),
            SizedBox(width: 8),
            Text(
              'Payment Milestones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._milestones.asMap().entries.map((entry) {
          final index = entry.key;
          final milestone = entry.value;
          final isLast = index == _milestones.length - 1;
          
          return _buildMilestoneItem(milestone, isLast);
        }),
      ],
    );
  }

  Widget _buildMilestoneItem(_PaymentMilestone milestone, bool isLast) {
    final amount = widget.totalAmount * milestone.percentage / 100;
    final statusColor = switch (milestone.status) {
      MilestoneStatus.released => const Color(0xFF00C853),
      MilestoneStatus.escrowed => Colors.orange,
      MilestoneStatus.pending => Colors.grey,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.2),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Icon(
                  milestone.status == MilestoneStatus.released
                      ? Icons.check
                      : milestone.status == MilestoneStatus.escrowed
                          ? Icons.lock
                          : Icons.circle,
                  color: statusColor,
                  size: 12,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: milestone.status == MilestoneStatus.released
                        ? statusColor
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: milestone.status == MilestoneStatus.escrowed
                      ? statusColor.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          milestone.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          milestone.status.name.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${milestone.percentage}%',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (milestone.releasedAt != null)
                        Text(
                          'Released: ${_formatDate(milestone.releasedAt!)}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                    ],
                  ),
                  if (milestone.status == MilestoneStatus.escrowed) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showDisputeDialog(milestone),
                            icon: const Icon(Icons.warning_amber, size: 16),
                            label: const Text('Dispute'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : () => _releaseMilestone(milestone),
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.check, size: 16),
                            label: const Text('Release'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history, color: Color(0xFF00C853)),
            SizedBox(width: 8),
            Text(
              'Transaction History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionItem(
          transactionId: 'TXN-ADV-A1B2C3',
          type: 'Advance Payment',
          amount: widget.totalAmount * 0.30,
          status: 'Released',
          date: DateTime(2026, 1, 5),
        ),
        _buildTransactionItem(
          transactionId: 'TXN-SAM-D4E5F6',
          type: 'Sample Approval',
          amount: widget.totalAmount * 0.20,
          status: 'In Escrow',
          date: DateTime(2026, 1, 10),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String transactionId,
    required String type,
    required double amount,
    required String status,
    required DateTime date,
  }) {
    final isReleased = status == 'Released';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isReleased ? const Color(0xFF00C853) : Colors.orange).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isReleased ? Icons.check_circle : Icons.lock,
              color: isReleased ? const Color(0xFF00C853) : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  transactionId,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isReleased ? const Color(0xFF00C853) : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(date),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEscrowInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2A30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: Color(0xFF00C853)),
                SizedBox(width: 8),
                Text(
                  'How Escrow Works',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoItem(
              icon: Icons.lock,
              title: 'Secure Funds',
              description: 'Your payment is held securely in escrow until milestones are completed.',
            ),
            _buildInfoItem(
              icon: Icons.verified,
              title: 'Milestone Release',
              description: 'Funds are released only when you approve each production milestone.',
            ),
            _buildInfoItem(
              icon: Icons.support_agent,
              title: 'Dispute Protection',
              description: 'If issues arise, our team helps resolve disputes fairly.',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF00C853).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00C853), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _releaseMilestone(_PaymentMilestone milestone) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Release', style: TextStyle(color: Colors.white)),
        content: Text(
          'Release ₹${(widget.totalAmount * milestone.percentage / 100).toStringAsFixed(0)} for "${milestone.name}"?\n\nThis action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
            child: const Text('Release'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isProcessing = false;
        final index = _milestones.indexWhere((m) => m.id == milestone.id);
        if (index != -1) {
          _milestones[index] = _PaymentMilestone(
            id: milestone.id,
            name: milestone.name,
            percentage: milestone.percentage,
            status: MilestoneStatus.released,
            releasedAt: DateTime.now(),
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment released successfully!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
      }
    }
  }

  void _showDisputeDialog(_PaymentMilestone milestone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            SizedBox(width: 8),
            Text('Raise Dispute', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our team will review the dispute and contact both parties within 24-48 hours.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dispute submitted. Our team will contact you soon.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Submit Dispute'),
          ),
        ],
      ),
    );
  }
}

enum MilestoneStatus { pending, escrowed, released }

class _PaymentMilestone {
  final int id;
  final String name;
  final int percentage;
  final MilestoneStatus status;
  final DateTime? releasedAt;

  _PaymentMilestone({
    required this.id,
    required this.name,
    required this.percentage,
    required this.status,
    this.releasedAt,
  });
}
