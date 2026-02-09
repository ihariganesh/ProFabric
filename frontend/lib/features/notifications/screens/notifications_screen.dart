import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(
                        color: Color(0xFF12AEE2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Orders', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Production', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Logistics', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Payments', false),
                  ],
                ),
              ),
            ),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNotificationItem(
                    icon: Icons.local_shipping,
                    iconColor: const Color(0xFF12AEE2),
                    title: 'Order #FB-8921 En Route',
                    subtitle:
                        'Your fabric shipment is 45% through production at Mill X',
                    time: '5 minutes ago',
                    isUnread: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.inventory_2,
                    iconColor: Colors.orange,
                    title: 'Low Stock Alert',
                    subtitle:
                        'Egyptian Cotton - Giza 45 inventory below threshold',
                    time: '1 hour ago',
                    isUnread: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.payment,
                    iconColor: Colors.green,
                    title: 'Payment Received',
                    subtitle: 'INR 2,45,000 received for Order #FB-8850',
                    time: '3 hours ago',
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.verified,
                    iconColor: Colors.green,
                    title: 'Quality Check Passed',
                    subtitle: 'Order #FB-8902 passed all quality inspections',
                    time: '5 hours ago',
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.chat_bubble,
                    iconColor: const Color(0xFF12AEE2),
                    title: 'New Message from Global Stitch',
                    subtitle:
                        'Production timeline has been updated for your review',
                    time: '8 hours ago',
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.local_offer,
                    iconColor: Colors.purple,
                    title: 'New Vendor Bid Received',
                    subtitle:
                        '3 vendors submitted bids for your fabric request',
                    time: '1 day ago',
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.warning,
                    iconColor: Colors.red,
                    title: 'Delay Notification',
                    subtitle: 'Order #FB-8745 delayed by 2 days due to weather',
                    time: '2 days ago',
                    isUnread: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF12AEE2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? const Color(0xFF101D22) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? Color(0xFF12AEE2).withOpacity(0.05)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? Color(0xFF12AEE2).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF12AEE2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
