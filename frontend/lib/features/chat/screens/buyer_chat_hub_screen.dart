import 'package:flutter/material.dart';

/// Buyer Chat Hub – conversations with textiles, grouped by order.
/// Reworked with purple/blue palette and media sharing indicators.
class BuyerChatHubScreen extends StatefulWidget {
  const BuyerChatHubScreen({super.key});

  @override
  State<BuyerChatHubScreen> createState() => _BuyerChatHubScreenState();
}

class _BuyerChatHubScreenState extends State<BuyerChatHubScreen> {
  final _search = TextEditingController();
  String _query = '';

  final List<_Chat> _chats = [];

  List<_Chat> get _filtered {
    if (_query.isEmpty) return _chats;
    final q = _query.toLowerCase();
    return _chats
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.orderId.toLowerCase().contains(q) ||
            c.fabricName.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _searchBar(),
            Expanded(child: _chatList()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final unreadTotal = _chats.fold<int>(0, (s, c) => s + c.unread);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Messages',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Chat with your textiles & partners',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 13)),
                    if (unreadTotal > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$unreadTotal new',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.edit_rounded, color: Colors.white54, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by textile, order ID, fabric…',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.3)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _chatList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined,
                color: Colors.white.withValues(alpha: 0.1), size: 56),
            const SizedBox(height: 12),
            Text('No conversations yet',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: list.length,
      itemBuilder: (_, i) => _chatTile(list[i]),
    );
  }

  Widget _chatTile(_Chat c) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/chat', arguments: {
        'orderId': c.orderId,
        'recipientName': c.name,
        'recipientRole': c.role,
        'recipientId': c.id,
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
          ),
        ),
        child: Row(
          children: [
            // Avatar with online dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: c.accent.withValues(alpha: 0.12),
                  child: Text(c.name[0],
                      style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),
                if (c.online)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C896),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0B1215), width: 2),
                      ),
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
                        child: Text(c.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: c.unread > 0
                                    ? FontWeight.bold
                                    : FontWeight.w500)),
                      ),
                      if (c.hasMedia)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(Icons.perm_media_rounded,
                              color: c.accent.withValues(alpha: 0.5), size: 14),
                        ),
                      Text(c.time,
                          style: TextStyle(
                              color: c.unread > 0
                                  ? const Color(0xFF6C63FF)
                                  : Colors.white24,
                              fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Fabric + Order tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: c.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(c.fabricName,
                            style: TextStyle(color: c.accent, fontSize: 10)),
                      ),
                      const SizedBox(width: 6),
                      Text('#${c.orderId}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                              fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: c.unread > 0
                                    ? Colors.white70
                                    : Colors.white30,
                                fontSize: 13)),
                      ),
                      if (c.unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${c.unread}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
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

class _Chat {
  final String id, name, role, orderId, fabricName, lastMsg, time;
  final int unread;
  final bool online, hasMedia;
  final Color accent;

  _Chat({
    required this.id,
    required this.name,
    required this.role,
    required this.orderId,
    required this.fabricName,
    required this.lastMsg,
    required this.time,
    required this.unread,
    required this.online,
    required this.accent,
    required this.hasMedia,
  });
}
