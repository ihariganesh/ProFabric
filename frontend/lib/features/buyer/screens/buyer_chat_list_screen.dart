import 'package:flutter/material.dart';
import '../../../core/services/firestore_chat_service.dart';

/// Buyer chat list — shows all real Firestore conversations.
class BuyerChatListScreen extends StatefulWidget {
  const BuyerChatListScreen({super.key});

  @override
  State<BuyerChatListScreen> createState() => _BuyerChatListScreenState();
}

class _BuyerChatListScreenState extends State<BuyerChatListScreen> {
  final _search = TextEditingController();
  String _query = '';

  static const _palette = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _searchBar(),
            const Divider(color: Color(0x0DFFFFFF), height: 1),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text('Messages',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          GestureDetector(
            onTap: () => setState(() {}),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12)),
              child:
                  const Icon(Icons.search, color: Colors.white54, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search conversations…',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
            prefixIcon:
                Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _list() {
    return StreamBuilder<List<ChatConversation>>(
      stream: FirestoreChatService().myConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C853)));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)));
        }
        var items = snapshot.data ?? [];
        if (_query.isNotEmpty) {
          final q = _query.toLowerCase();
          items = items
              .where((c) => c.otherName.toLowerCase().contains(q))
              .toList();
        }
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.white.withOpacity(0.1), size: 56),
                const SizedBox(height: 14),
                const Text('No conversations yet',
                    style: TextStyle(color: Colors.white38, fontSize: 16)),
                const SizedBox(height: 6),
                const Text(
                  'Chat with a textile vendor from the Marketplace',
                  style: TextStyle(color: Colors.white24, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, i) => _buildChatTile(ctx, items[i]),
        );
      },
    );
  }

  Widget _buildChatTile(BuildContext context, ChatConversation chat) {
    final color =
        _palette[chat.otherName.hashCode.abs() % _palette.length];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/chat', arguments: {
          'orderId': '',
          'recipientName': chat.otherName,
          'recipientRole': 'Textile',
          'recipientId': chat.otherUid,
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.15),
                child: Text(
                  chat.otherName.isNotEmpty
                      ? chat.otherName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(chat.otherName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: chat.unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.w500)),
                        ),
                        Text(chat.timeLabel,
                            style: TextStyle(
                                color: chat.unreadCount > 0
                                    ? const Color(0xFF00C853)
                                    : Colors.white38,
                                fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: chat.unreadCount > 0
                                      ? Colors.white70
                                      : Colors.white38,
                                  fontSize: 13)),
                        ),
                        if (chat.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFF00C853),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('${chat.unreadCount}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
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

