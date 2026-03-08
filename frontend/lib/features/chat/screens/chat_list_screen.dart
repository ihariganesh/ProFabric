import 'package:flutter/material.dart';
import '../../../core/services/firestore_chat_service.dart';

/// Universal chat list screen – used by all roles.
/// Backed by Firestore real-time conversations stream.
class ChatListScreen extends StatefulWidget {
  final String userRole;

  const ChatListScreen({super.key, this.userRole = 'buyer'});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1015),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _searchBar(),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Messages',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search conversations…',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withOpacity(0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
              child: CircularProgressIndicator(color: Color(0xFF00B0FF)));
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
          return const Center(
              child: Text('No conversations yet',
                  style: TextStyle(color: Colors.white24)));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => _tile(items[i]),
        );
      },
    );
  }

  static const _palette = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
  ];

  Widget _tile(ChatConversation c) {
    final color = _palette[c.otherName.hashCode.abs() % _palette.length];
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/chat', arguments: {
        'orderId': '',
        'recipientName': c.otherName,
        'recipientRole': 'User',
        'recipientId': c.otherUid,
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Text(
                c.otherName.isNotEmpty ? c.otherName[0].toUpperCase() : '?',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(c.otherName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: c.unreadCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.w500)),
                      const Spacer(),
                      Text(c.timeLabel,
                          style: TextStyle(
                              color: c.unreadCount > 0
                                  ? const Color(0xFF00E676)
                                  : Colors.white.withOpacity(0.2),
                              fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: c.unreadCount > 0
                                    ? Colors.white60
                                    : Colors.white24,
                                fontSize: 13)),
                      ),
                      if (c.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${c.unreadCount}',
                              style: const TextStyle(
                                  color: Color(0xFF0A1015),
                                  fontSize: 10,
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
    );
  }
}
