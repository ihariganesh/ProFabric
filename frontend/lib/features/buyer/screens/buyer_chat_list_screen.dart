import 'package:flutter/material.dart';

/// Chat list showing all vendor conversations
class BuyerChatListScreen extends StatelessWidget {
  const BuyerChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      _ChatItem(name: 'Lakshmi Textiles', orderId: 'FB-9045', lastMsg: 'Sample fabric is ready for review', time: '2m ago', unread: 3, isOnline: true, avatar: 'L'),
      _ChatItem(name: 'Sai Fabrics', orderId: 'FB-9038', lastMsg: 'We will start production tomorrow', time: '1h ago', unread: 0, isOnline: true, avatar: 'S'),
      _ChatItem(name: 'Arvind Mills', orderId: 'FB-9021', lastMsg: 'Design has been approved ✓', time: '3h ago', unread: 1, isOnline: false, avatar: 'A'),
      _ChatItem(name: 'Modern Prints', orderId: 'FB-9010', lastMsg: 'Quality check in progress', time: 'Yesterday', unread: 0, isOnline: false, avatar: 'M'),
      _ChatItem(name: 'EcoWeave Co', orderId: 'FB-8990', lastMsg: 'Thank you for your order!', time: '2 days ago', unread: 0, isOnline: false, avatar: 'E'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Messages', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.search, color: Colors.white54, size: 22),
                  ),
                ],
              ),
            ),
            // Online vendors strip
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: chats.where((c) => c.isOnline).length,
                itemBuilder: (ctx, i) {
                  final online = chats.where((c) => c.isOnline).toList()[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF00C853).withOpacity(0.2),
                              child: Text(online.avatar, style: const TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Positioned(
                              right: 0, bottom: 0,
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF101D22), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(online.name.split(' ').first, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.05), height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (ctx, i) => _buildChatTile(context, chats[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, _ChatItem chat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/chat', arguments: {
          'orderId': chat.orderId,
          'recipientName': chat.name,
          'recipientRole': 'Textile Manufacturer',
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF1E2D33),
                    child: Text(chat.avatar, style: const TextStyle(color: Color(0xFF12AEE2), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  if (chat.isOnline)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: const Color(0xFF00C853), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF101D22), width: 2)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(chat.name, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: chat.unread > 0 ? FontWeight.bold : FontWeight.w500)),
                        ),
                        Text(chat.time, style: TextStyle(color: chat.unread > 0 ? const Color(0xFF00C853) : Colors.white38, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(chat.lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: chat.unread > 0 ? Colors.white70 : Colors.white38, fontSize: 13)),
                        ),
                        if (chat.unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(10)),
                            child: Text('${chat.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    Text('#${chat.orderId}', style: const TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatItem {
  final String name, orderId, lastMsg, time, avatar;
  final int unread;
  final bool isOnline;
  _ChatItem({required this.name, required this.orderId, required this.lastMsg, required this.time, required this.unread, required this.isOnline, required this.avatar});
}
